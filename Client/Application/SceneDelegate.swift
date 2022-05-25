// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import CoreSpotlight
import Defaults
import SDWebImage
import Shared
import Storage
import StoreKit

private let log = Logger.browser

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var scene: UIScene?

    var bvc: BrowserViewController!
    private var geigerCounter: KMCGeigerCounter?

    private static var activeSceneCount: Int = 0

    // MARK: - Scene state
    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        self.scene = scene
        guard let scene = (scene as? UIWindowScene) else { return }

        window = .init(windowScene: scene)
        window!.makeKeyAndVisible()

        Self.handleThemePreference(for: Defaults[.customizeTheme] ?? .system)

        setupRootViewController(scene)

        if Defaults[.enableGeigerCounter] {
            startGeigerCounter()
        }

        log.info("URL contexts from willConnectTo: \(connectionOptions.urlContexts)")
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)

        log.info("Checking for user activites: \(connectionOptions.userActivities)")
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcut(shortcutItem: shortcutItem)
        }

        updateCurrentVersion()
    }

    private func setupRootViewController(_ scene: UIScene) {
        let profile = getAppDelegate().profile

        self.bvc = BrowserViewController(profile: profile, window: window!, scene: scene)

        bvc.edgesForExtendedLayout = []
        bvc.restorationIdentifier = NSStringFromClass(BrowserViewController.self)
        bvc.restorationClass = AppDelegate.self

        window!.rootViewController = bvc
        bvc.tabManager.selectedTab?.reload()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        self.scene = scene

        Self.activeSceneCount += 1
        if Self.activeSceneCount == 1 {
            // We are back in the foreground, so set applicationCleanlyBackgrounded to false so that we can detect that
            // the application was cleanly backgrounded later.
            Defaults[.applicationCleanlyBackgrounded] = false

            getAppDelegate().profile._reopen()
        }

        checkForSignInTokenOnDevice()

        // This loads tabs queued up using the ShareTo "Load in Background" functionality.
        // We execute a trivial deferred to put this on the background queue.
        succeed().upon { _ in
            self.bvc.loadQueuedTabs()
        }

        getAppDelegate().updateTopSitesWidget()

        // If server is already running this won't do anything.
        // This will restart the server if it was stopped in `sceneDidEnterBackground`.
        getAppDelegate().setUpWebServer(getAppDelegate().profile)

        NotificationPermissionHelper.shared.updatePermissionState()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        checkUserActivenessLastWeek()
        checkUserForegroundActivity()

        LocalNotifications.scheduleNeevaPromoCallbackIfAuthorized(
            callSite: LocalNotifications.ScheduleCallSite.enterForeground
        )

        bvc.downloadQueue.resumeAll()

        ClientLogger.shared.logCounter(
            .AppEnterForeground,
            attributes: EnvironmentHelper.shared.getAttributes()
        )

        // send number of spotlight index events from the last session
        sendAggregatedSpotlightLogs()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        bvc.tabManager.preserveTabs()

        Self.activeSceneCount -= 1
        if Self.activeSceneCount == 0 {
            // At this point we are happy to mark the app as applicationCleanlyBackgrounded. If a crash happens in background
            // sync then that crash will still be reported. But we won't bother the user with the Restore Tabs
            // dialog. We don't have to because at this point we already saved the tab state properly.
            Defaults[.applicationCleanlyBackgrounded] = true

            WebServer.sharedInstance.server.stop()
            getAppDelegate().shutdownProfile()
        }

        getAppDelegate().updateTopSitesWidget()
        bvc.downloadQueue.pauseAll()
    }

    static func handleThemePreference(for option: AppearanceThemeOption) {
        getAllSceneDelegates().forEach { scene in
            switch option {
            case .system:
                scene.window?.overrideUserInterfaceStyle = .unspecified
            case .dark:
                scene.window?.overrideUserInterfaceStyle = .dark
            case .light:
                scene.window?.overrideUserInterfaceStyle = .light
            }
        }
    }

    // MARK: - URL managment
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // almost always one URL
        guard let url = URLContexts.first?.url,
            let routerpath = NavigationPath(bvc: bvc, url: url)
        else {
            log.info(
                "Failed to unwrap url for context: \(URLContexts.first?.url.absoluteString ?? "")")
            return
        }

        log.info("URL passed: \(url)")

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == "http" || components.scheme == "https"
        {
            var attributes = [ClientLogCounterAttribute]()
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let _ = NavigationPath.maybeRewriteURL(url, components)
            {
                attributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.DeeplinkAttribute.searchRedirect,
                        value: "1"
                    )
                )
            }
            ClientLogger.shared.logCounter(.OpenDefaultBrowserURL, attributes: attributes)
            ConversionLogger.log(event: .handledNavigationAsDefaultBrowser)

            Defaults[.didSetDefaultBrowser] = true
        }

        DispatchQueue.main.async {
            if !self.checkForSignInToken(in: url) {
                log.info("Passing URL to router path: \(routerpath)")
                NavigationPath.handle(nav: routerpath, with: self.bvc)
            }
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == UserActivityHandler.browsingActivityType {
            ClientLogger.shared.logCounter(
                .openURLFromUserActivity,
                attributes:
                    EnvironmentHelper.shared.getAttributes()
                    + [
                        ClientLogCounterAttribute(
                            key: LogConfig.SpotlightAttribute.urlPayload,
                            value: (userActivity.userInfo?["url"] as? String) ?? ""
                        )
                    ]
            )
            if let urlString = userActivity.userInfo?["url"] as? String,
                let url = URL(string: urlString)
            {
                self.bvc.switchToTabForURLOrOpen(url)
            }
        } else if userActivity.activityType == CSSearchableItemActionType,
            let itemIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier]
                as? String
        {
            if let url = URL(string: itemIdentifier),
                url.isWebPage()
            {
                // the identifier is a url link from a page in a space
                // this itemIdentifier is the spaces id
                ClientLogger.shared.logCounter(
                    .openCSSearchableItem,
                    attributes:
                        EnvironmentHelper.shared.getAttributes()
                        + [
                            ClientLogCounterAttribute(
                                key: LogConfig.SpotlightAttribute.urlPayload,
                                value: itemIdentifier
                            )
                        ]
                )

                self.bvc.switchToTabForURLOrOpen(url)
            } else {
                // this itemIdentifier is the spaces id
                ClientLogger.shared.logCounter(
                    .openCSSearchableItem,
                    attributes:
                        EnvironmentHelper.shared.getAttributes()
                        + [
                            ClientLogCounterAttribute(
                                key: LogConfig.SpotlightAttribute.spaceIdPayload,
                                value: itemIdentifier
                            )
                        ]
                )

                self.bvc.browserModel.openSpace(
                    spaceId: itemIdentifier, bvc: self.bvc, completion: {})
            }
        } else if !continueSiriIntent(continue: userActivity) {
            _ = checkForUniversalURL(continue: userActivity)
        }
    }

    func continueSiriIntent(continue userActivity: NSUserActivity) -> Bool {
        var attributes = [
            EnvironmentHelper.shared.getSessionUUID()
        ]
        if let intent = userActivity.interaction?.intent as? OpenURLIntent {
            self.bvc.openURLInNewTab(intent.url)
            ClientLogger.shared.logCounter(.openURLShortcut, attributes: attributes)
            return true
        }

        if let intent = userActivity.interaction?.intent as? SearchNeevaIntent {
            // shortcut has query input, start search for query
            if let query = intent.text,
                !query.isEmpty,
                let url = SearchEngine.current.searchURLForQuery(query)
            {
                attributes.append(ClientLogCounterAttribute(key: "hasQuery", value: String(true)))
                self.bvc.openURLInNewTab(url)
            } else {
                // open a new search
                DispatchQueue.main.async { [self] in
                    let isEmpty = self.bvc.tabManager.normalTabs.count == 0
                    self.bvc.searchQueryModel.value = ""
                    self.bvc.openLazyTab(
                        openedFrom: isEmpty ? .tabTray : .openTab(nil),
                        switchToIncognitoMode: false
                    )
                }
            }
            ClientLogger.shared.logCounter(.searchShortcut, attributes: attributes)
            return true
        }

        return false
    }

    func checkForUniversalURL(continue userActivity: NSUserActivity) -> Bool {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        else {
            return false
        }

        log.info("Universal URL passed: \(incomingURL)")

        if !self.checkForSignInToken(in: incomingURL) {
            self.bvc.openURLInNewTab(incomingURL)
        }

        return true
    }

    // MARK: - Shortcut
    func windowScene(
        _ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        handleShortcut(shortcutItem: shortcutItem, completionHandler: completionHandler)
    }

    func handleShortcut(
        shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void = { _ in }
    ) {
        let handledShortCutItem = QuickActions.sharedInstance.handleShortCutItem(
            shortcutItem, withBrowserViewController: bvc)
        completionHandler(handledShortCutItem)
    }

    // MARK: - Get data for current scene
    static func getCurrentSceneDelegate(with scene: UIScene) -> SceneDelegate? {
        let sceneDelegate = scene.delegate as? SceneDelegate
        return sceneDelegate
    }

    /// Gets the  Scene Delegate for a view.
    /// - Warning: If view is nil, the function will fallback to a different method, but it is **preffered** if a view **is passed**.
    static func getCurrentSceneDelegate(for view: UIView?) -> SceneDelegate {
        if let view = view, let sceneDelegate = getSceneDelegate(for: view) {  // preffered method
            return sceneDelegate
        } else if let sceneDelegate = getActiveSceneDelegate() {
            return sceneDelegate
        }

        fatalError("Scene Delegate doesn't exist for view or is nil")
    }

    @available(
        *, deprecated, message: "should use getCurrentSceneDelegate with non-nil view or scene"
    )
    static func getCurrentSceneDelegateOrNil() -> SceneDelegate? {
        if let sceneDelegate = getActiveSceneDelegate() {
            return sceneDelegate
        }

        return nil
    }

    static private func getSceneDelegate(for view: UIView) -> SceneDelegate? {
        let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate
        return sceneDelegate
    }

    /// - Warning: Should be avoided as multiple scenes could be active.
    static private func getActiveSceneDelegate() -> SceneDelegate? {
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive
                || UIApplication.shared.connectedScenes.count == 1,
                let sceneDelegate = ((scene as? UIWindowScene)?.delegate as? SceneDelegate)
            {
                return sceneDelegate
            }
        }

        return nil
    }

    static func getAllSceneDelegates() -> [SceneDelegate] {
        return UIApplication.shared.connectedScenes.compactMap {
            (($0 as? UIWindowScene)?.delegate as? SceneDelegate)
        }
    }

    static func getCurrentScene(for view: UIView?) -> UIScene {
        if let scene = getCurrentSceneDelegate(for: view).scene {
            return scene
        }

        fatalError("Scene doesn't exist or is nil")
    }

    static func getCurrentSceneId(for view: UIView?) -> String {
        return getCurrentScene(for: view).session.persistentIdentifier
    }

    static func getKeyWindow(for view: UIView?) -> UIWindow {
        if let window = getCurrentSceneDelegate(for: view).window {
            return window
        }

        fatalError("Window for current scene is nil")
    }

    // MARK: - BVC
    static func getBVC(for view: UIView?) -> BrowserViewController {
        return getCurrentSceneDelegate(for: view).bvc
    }

    static func getBVC(with scene: UIScene?) -> BrowserViewController {
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            return sceneDelegate.bvc
        }

        fatalError("Scene Delegate doesn't exist for scene or is nil")
    }

    static func getAllBVCs() -> [BrowserViewController] {
        return getAllSceneDelegates().map { $0.bvc }
    }

    @available(*, deprecated, message: "should use getBVC with a non-nil view or scene")
    static func getBVCOrNil() -> BrowserViewController? {
        return getCurrentSceneDelegateOrNil()?.bvc
    }

    // MARK: - Tab Manager
    static func getTabManager(for view: UIView) -> TabManager {
        return getCurrentSceneDelegate(for: view).bvc.tabManager
    }

    static func getAllTabManagers() -> [TabManager] {
        return getAllSceneDelegates().map { $0.bvc.tabManager }
    }

    @available(*, deprecated, message: "should use getTabManager with a non-nil view")
    static func getTabManagerOrNil() -> TabManager? {
        return getCurrentSceneDelegateOrNil()?.bvc.tabManager
    }

    // MARK: - Geiger
    public func startGeigerCounter() {
        if let scene = self.scene as? UIWindowScene {
            geigerCounter = KMCGeigerCounter(windowScene: scene)
        }
    }

    public func stopGeigerCounter() {
        geigerCounter?.disable()
        geigerCounter = nil
    }

    // MARK: - Sign In
    func checkForSignInTokenOnDevice() {
        log.info("Checking for sign in token from App Clip on device")

        if let signInToken = AppClipHelper.retreiveAppClipData() {
            self.handleSignInToken(signInToken)
        } else {
            log.info("Unable to retrieve sign in token from App Clip on device")
        }
    }

    /// Checks for a sign in token in the URL and also handles the URL if true.
    func checkForSignInToken(in url: URL) -> Bool {
        log.info("Checking for sign in token from URL: \(url)")

        // This is in case the App Clip sign in URL ends up opening the app
        // Will occur if the app is already installed
        if url.scheme == "https", NeevaConstants.isAppHost(url.host, allowM1: true),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.path == "/appclip/login",
            let queryItems = components.queryItems,
            let signInToken = queryItems.first(where: { $0.name == "token" })?.value
        {
            log.info("Passing sign in token from URL: \(signInToken)")
            self.handleSignInToken(signInToken)

            return true
        }

        return false
    }

    func handleSignInToken(_ signInToken: String) {
        log.info("Using sign in token \(signInToken) from App Clip")

        Defaults[.introSeen] = true
        AppClipHelper.saveTokenToDevice(nil)

        DispatchQueue.main.async { [self] in
            let signInURL = URL(
                string: "https://\(NeevaConstants.appHost)/login/qr/finish?q=\(signInToken)")!

            log.info("Navigating to sign in URL: \(signInURL)")
            bvc.switchToTabForURLOrOpen(signInURL)
        }
    }

    func checkUserForegroundActivity() {
        #if !DEBUG
            if let scene = (scene as? UIWindowScene),
                Defaults[.numberOfAppForeground] >= AppRatingSystemDialogRule.numOfAppForeground
                    && !Defaults[.didTriggerSystemReviewDialog]
            {
                // Note that Apple has full control over when to show the actual review dialog
                // see here for more information:
                // https://developer.apple.com/documentation/storekit/requesting_app_store_reviews
                SKStoreReviewController.requestReview(in: scene)
                Defaults[.didTriggerSystemReviewDialog] = true
            }
        #endif

        Defaults[.numberOfAppForeground] += 1
    }

    func checkUserActivenessLastWeek() {
        let minusOneWeekToCurrentDate = Calendar.current.date(
            byAdding: .weekOfYear, value: -1, to: Date())

        guard let startOfLastWeek = minusOneWeekToCurrentDate else {
            return
        }

        Defaults[.loginLastWeekTimeStamp] = Defaults[.loginLastWeekTimeStamp].suffix(2).filter {
            $0 > startOfLastWeek
        }
        Defaults[.loginLastWeekTimeStamp].append(Date())
    }

    // MARK: - App Version
    private func updateCurrentVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let lastVersionActiveOn = Defaults[.lastVersionActiveOn],
                lastVersionActiveOn != version
            {
                onAppUpdate(previousVersion: lastVersionActiveOn, currentVersion: version)
            }

            Defaults[.lastVersionActiveOn] = version
        }
    }

    /// Called when the user updates the app, and then opens it.
    /// Useful for updating flags, migrating data, etc.
    @discardableResult func onAppUpdate(previousVersion: String, currentVersion: String) -> Bool {
        if currentVersion.compare(previousVersion, options: .numeric) == .orderedDescending {
            // currentVersion is newer than the previousVersion

            // clear deprecated `Default` values
            Defaults.reset(.appExtensionTelemetryOpenUrl)  // deprecated 2022-05-18

            // migrate the content blocking enabled flag for users upgrading prior to 1.42.0 which is our cookie cutter release
            // TODO: remove this after a couple releases as most of our users should be upgraded
            if previousVersion.compare("1.42.0", options: .numeric) == .orderedAscending {
                Defaults[.cookieCutterEnabled] = Defaults[.contentBlockingEnabled]
            }

            return true
        }

        return false
    }

    func sendAggregatedSpotlightLogs() {
        ClientLogger.shared.logCounter(
            .spotlightEventsForSession,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.CountForEvent.createUserActivity.rawValue,
                    value: String(Defaults[.numOfIndexedUserActivities])
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.CountForEvent.addThumbnailToUserActivity
                        .rawValue,
                    value: String(Defaults[.numOfThumbnailsForUserActivity])
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.CountForEvent.willIndex.rawValue,
                    value: String(Defaults[.numOfWillIndexEvents])
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.CountForEvent.didIndex.rawValue,
                    value: String(Defaults[.numOfDidIndexEvents])
                ),
            ]
        )
        Defaults[.numOfIndexedUserActivities] = 0
        Defaults[.numOfThumbnailsForUserActivity] = 0
        Defaults[.numOfWillIndexEvents] = 0
        Defaults[.numOfDidIndexEvents] = 0
    }
}
