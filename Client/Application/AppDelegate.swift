/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import CrashReporter
import Defaults
import SDWebImage
import Shared
import XCGLogger

private let log = Logger.browser

class AppDelegate: UIResponder, UIApplicationDelegate, UIViewControllerRestoration {
    static var orientationLock = UIInterfaceOrientationMask.all

    public static func viewController(
        withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder
    ) -> UIViewController? {
        return nil
    }

    weak var application: UIApplication?

    // The profile is initialized during startup below and then remains valid for the
    // lifetime of the app. Expose a non-optional Profile accessor for convenience.
    private var lateInitializedProfile: Profile?
    var profile: Profile {
        lateInitializedProfile!
    }

    // MARK: - Lifecycle
    /*
     * "Return false if the app should not perform the application(_:performActionFor:completionHandler:)
     * method because you’re handling the invocation of a Home screen quick action"
     * https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623032-application
     */
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // If feedback did not finish sending before app closed, record that here
        if !Defaults[.feedbackBeingSent] {
            ClientLogger.shared.logCounterBypassIncognito(.FeedbackFailedToSend)
        }
        Defaults[.feedbackBeingSent] = false

        lateInitializedProfile = createProfile()

        // Set up a web server that serves us static content. Do this early so that it is ready when the UI is presented.
        setUpWebServer(profile)

        // Hold references to willFinishLaunching parameters for delayed app launch
        self.application = application

        // Cleanup can be a heavy operation, take it out of the startup path. Instead check after a few seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.profile.cleanupHistoryIfNeeded()
        }

        // This code path is for users who have authorized notification prompt but
        // haven't registered the token with the server.
        // TODO: we should remove this code path in a few releases when most users registered the token
        if let notificationToken = Defaults[.notificationToken],
            !Defaults[.didRegisterNotificationTokenOnServer]
        {
            NotificationPermissionHelper.shared.registerDeviceTokenWithServer(
                deviceToken: notificationToken)
            Defaults[.didRegisterNotificationTokenOnServer] = true
        }

        UNUserNotificationCenter.current().delegate = self

        startApplication()

        return true
    }

    func startApplication() {
        log.info("startApplication begin")

        // set session UUID v2 before any logging event
        if Defaults[.sessionUUIDv2].isEmpty {
            Defaults[.sessionUUIDv2] = UUID().uuidString
        }

        #if !DEBUG
            if !startCrashReporter() {
                log.info("Failed to start crash reporter")
            }
        #endif

        // set session UUID and timestamp if not set
        if Defaults[.sessionUUID].isEmpty {
            Defaults[.sessionUUID] = UUID().uuidString
            Defaults[.sessionUUIDExpirationTime] = Date()

            if Defaults[.firstSessionUUID].isEmpty {
                Defaults[.firstSessionUUID] = Defaults[.sessionUUID]
            }
        }

        // Set the Neeva UA for browsing.
        setUserAgent()

        // Start the keyboard helper to monitor and cache keyboard state.
        KeyboardHelper.defaultHelper.startObserving()

        DynamicFontHelper.defaultHelper.startObserving()

        MenuHelper.defaultHelper.setItems()

        SystemUtils.onFirstRun()

        sendAggregatedLogsFromLastLaunch()

        log.info("startApplication end")

        if FeatureFlag[.interactiveScrollView] {
            UIScrollView.appearance().keyboardDismissMode = .interactive
        }
    }

    // periphery:ignore
    func startCrashReporter() -> Bool {
        let config = PLCrashReporterConfig(signalHandlerType: .mach, symbolicationStrategy: [])
        guard let crashReporter = PLCrashReporter(configuration: config) else {
            print("Could not create an instance of PLCrashReporter")
            return false
        }

        do {
            try crashReporter.enableAndReturnError()
        } catch let error {
            print("Warning: Could not enable crash reporter: \(error)")
            return false
        }

        PerformanceLogger.shared.logPageLoadWithCrashedStatus(
            crashed: crashReporter.hasPendingCrashReport()
        )

        crashReporter.purgePendingCrashReport()
        return true
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return
            !(launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem]
            is UIApplicationShortcutItem)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // We have only five seconds here, so let's hope this doesn't take too long?.

        // Make sure tabs state has been saved.
        for tabManager in TabManager.all.makeIterator() {
            tabManager.preserveTabs()
        }

        shutdownProfile()
    }

    // MARK: - Rotation
    func application(
        _ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    static func setRotationLock(to: UIInterfaceOrientationMask) {
        DispatchQueue.main.async {
            orientationLock = to
            UIDevice.current.setValue(
                UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }

    // MARK: - Scene
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func createProfile() -> Profile {
        return BrowserProfile(localName: Defaults[.profileLocalName])
    }

    fileprivate func setUserAgent() {
        let neevaUA = UserAgent.getUserAgent()

        // Set the UA for WKWebView (via defaults), the favicon fetcher, and the image loader.
        // This only needs to be done once per runtime. Note that we use defaults here that are
        // readable from extensions, so they can just use the cached identifier.
        SDWebImageDownloader.shared.setValue(neevaUA, forHTTPHeaderField: "User-Agent")

        // SDWebImage is setting accept headers that report we support webp. We don't
        SDWebImageDownloader.shared.setValue("image/*;q=0.8", forHTTPHeaderField: "Accept")
    }

    func setUpWebServer(_ profile: Profile) {
        let server = WebServer.sharedInstance
        guard !server.isRunning else { return }

        ReaderModeHandlers.register(server, profile: profile)

        let responders: [(String, InternalSchemeResponse)] =
            [
                (AboutHomeHandler.path, AboutHomeHandler()),
                (AboutLicenseHandler.path, AboutLicenseHandler()),
                (SessionRestoreHandler.path, SessionRestoreHandler()),
                (ErrorPageHandler.path, ErrorPageHandler()),
            ]
        responders.forEach { (path, responder) in
            InternalSchemeHandler.responders[path] = responder
        }

        if AppConstants.IsRunningTest || AppConstants.IsRunningPerfTest {
            server.registerHandlersForTestMethods()
        }

        // Bug 1223009 was an issue whereby CGDWebserver crashed when moving to a background task
        // catching and handling the error seemed to fix things, but we're not sure why.
        // Either way, not implicitly unwrapping a try is not a great way of doing things
        // so this is better anyway.
        do {
            try server.start()
            log.error("WebServer started")
        } catch let err as NSError {
            log.error("Failed to start WebServer: \(err)")
            print("Error: Unable to start WebServer \(err)")
        }
    }

    func updateTopSitesWidget() {
        TopSitesHandler.writeWidgetKitTopSites(profile: profile)
    }

    func shutdownProfile() {
        // Use optional here so that the underlying struct value type is passed by reference.
        var taskId: UIBackgroundTaskIdentifier?

        // According to https://developer.apple.com/documentation/uikit/uiapplication/1623031-beginbackgroundtask,
        // the `expirationHandler` may be called if we are already close to running out of time. In that case,
        // we want to take care to still shutdown the profile. It is safe to call `_shutdown` more than once.

        let shutdownHandler = {
            self.profile._shutdown()
            if let unwrappedTaskId = taskId {
                UIApplication.shared.endBackgroundTask(unwrappedTaskId)
                taskId = nil
            }
        }

        taskId = UIApplication.shared.beginBackgroundTask(expirationHandler: shutdownHandler)
        shutdownHandler()
    }
}

extension AppDelegate {
    // https://gist.github.com/uc-compass-bot/21a50972615f49fd581d928317e4e1a9#file-lowmemorywarningtracking-swift
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        var attributes = [
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.DeviceName,
                value: NeevaConstants.deviceNameValue
            )
        ]

        if let footprint = memoryFootprint {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.PerformanceAttribute.memoryUsage,
                    value: "\(footprint / 1024 / 1024) MB"
                )
            )
        }

        let tabManager = SceneDelegate.getTabManagerOrNil()
        let activeTabs = tabManager?.activeTabs ?? []
        let archivedTabs = tabManager?.archivedTabs ?? []

        let numberOfZombieTabs: Int = {
            activeTabs.filter { $0.webView == nil }.count
        }()

        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.AllTabsOpened,
                value: "\(activeTabs.count + archivedTabs.count)"
            )
        )

        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.NumberOfZombieTabs,
                value: "\(numberOfZombieTabs)"
            )
        )

        ClientLogger.shared.logCounter(.LowMemoryWarning, attributes: attributes)

        for sceneDelegate in SceneDelegate.getAllSceneDelegates() {
            sceneDelegate.bvc.tabManager.makeTabsIntoZombies()
        }
    }

    private var memoryFootprint: mach_vm_size_t? {
        guard let memory_offset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else {
            return nil
        }
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(
            MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size
        )
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(
            memory_offset / MemoryLayout<integer_t>.size
        )
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard kr == KERN_SUCCESS, count >= TASK_VM_INFO_REV1_COUNT else {
            return nil
        }
        return info.phys_footprint
    }
}

extension AppDelegate {
    func sendAggregatedLogsFromLastLaunch() {
        // send number of spotlight index events from the last session
        sendAggregatedSpotlightLogs()
        // send number of cheatsheet stats from the last session
        sendAggregatedCheatsheetLogs()
    }

    func sendAggregatedSpotlightLogs() {
        ClientLogger.shared.logCounterBypassIncognito(
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

    func sendAggregatedCheatsheetLogs() {
        CheatsheetSessionUsageLogger.shared.sendLogsOnAppStarted()
    }
}

func getAppDelegate() -> AppDelegate {
    return (UIApplication.shared.delegate as? AppDelegate)!
}
