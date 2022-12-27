/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Foundation
import SafariServices
import Shared
import Storage
import SwiftUI
import UIKit
import WebKit

class BrowserViewController: UIViewController {
    private(set) var searchQueryModel = SearchQueryModel()
    private(set) var locationModel = LocationViewModel()

    lazy var readerModeModel: ReaderModeModel = {
        let model = ReaderModeModel(
            setReadingMode: { [self] enabled in
                DispatchQueue.main.async {
                    if enabled {
                        self.enableReaderMode()
                    } else {
                        self.disableReaderMode()
                    }
                }
            }, tabManager: tabManager)
        model.delegate = self
        return model
    }()

    private(set) lazy var suggestionModel: SuggestionModel = {
        return SuggestionModel(bvc: self, profile: self.profile, queryModel: self.searchQueryModel)
    }()

    private(set) lazy var zeroQueryModel: ZeroQueryModel = {
        let model = ZeroQueryModel(
            bvc: self,
            profile: profile,
            shareURLHandler: { url, view in
                let helper = ShareExtensionHelper(url: url, tab: nil)
                let controller = helper.createActivityViewController({ (_, _) in })
                if UIDevice.current.userInterfaceIdiom != .pad {
                    controller.modalPresentationStyle = .formSheet
                } else {
                    controller.popoverPresentationController?.sourceView = view
                    controller.popoverPresentationController?.permittedArrowDirections = .up
                }

                self.present(controller, animated: true, completion: nil)
            })
        model.delegate = self
        return model
    }()

    let chromeModel = TabChromeModel()
    let cheatsheetPromoModel = CheatsheetPromoModel()
    let incognitoModel = IncognitoModel(isIncognito: false)

    lazy var tabCardModel: TabCardModel = {
        TabCardModel(manager: tabManager)
    }()

    lazy var gridModel: GridModel = {
        GridModel(tabManager: tabManager, tabCardModel: tabCardModel)
    }()

    lazy var browserModel: BrowserModel = {
        BrowserModel(
            gridModel: gridModel, tabManager: tabManager, chromeModel: chromeModel,
            incognitoModel: incognitoModel, switcherToolbarModel: switcherToolbarModel,
            toastViewManager: toastViewManager, overlayManager: overlayManager)
    }()

    private lazy var switcherToolbarModel: SwitcherToolbarModel = {
        SwitcherToolbarModel(
            tabManager: tabManager,
            openLazyTab: { self.openLazyTab(openedFrom: .tabTray) },
            createNewSpace: {
                self.overlayManager.showModal(style: .withTitle) {
                    CreateSpaceOverlayContent()
                        .environmentObject(self.gridModel.spaceCardModel)
                }
            }
        )
    }()

    lazy var browserHost: BrowserHost = {
        BrowserHost(bvc: self)
    }()

    lazy var overlayManager: OverlayManager = {
        OverlayManager(
            chromeModel: chromeModel,
            openURLInNewTabPreservingIncognitoState: openURLInNewTabPreservingIncognitoState)
    }()
    var restoreTabToastHasKeyCommandPriority = false

    private(set) lazy var simulateForwardModel: SimulatedSwipeModel = {
        SimulatedSwipeModel(
            tabManager: tabManager, swipeDirection: .forward
        )
    }()

    private(set) lazy var simulatedSwipeModel: SimulatedSwipeModel = {
        SimulatedSwipeModel(
            tabManager: tabManager, swipeDirection: .back
        )
    }()

    private(set) lazy var tabContainerModel: TabContainerModel = {
        return TabContainerModel(bvc: self)
    }()

    private(set) lazy var trackingStatsViewModel: TrackingStatsViewModel = {
        return TrackingStatsViewModel(tabManager: tabManager)
    }()

    private(set) lazy var toastViewManager: ToastViewManager = {
        ToastViewManager(overlayManager: overlayManager)
    }()

    private(set) lazy var notificationViewManager: NotificationViewManager = {
        NotificationViewManager(overlayManager: overlayManager)
    }()

    var findInPageModel: FindInPageModel?

    private(set) var readerModeCache: ReaderModeCache
    private(set) var screenshotHelper: ScreenshotHelper!

    var interstitialViewModel: InterstitialViewModel?

    // popover rotation handling
    var displayedPopoverController: UIViewController?
    var updateDisplayedPopoverProperties: (() -> Void)?

    let profile: Profile
    let tabManager: TabManager

    // Backdrop used for displaying greyed background for private tabs
    private(set) var webViewContainerBackdrop: UIView!

    // Tracking navigation items to record history types.
    // TODO: weak references?
    private var ignoredNavigation = Set<WKNavigation>()
    private var typedNavigation = [WKNavigation: VisitType]()

    // Keep track of allowed `URLRequest`s from `webView(_:decidePolicyFor:decisionHandler:)` so
    // that we can obtain the originating `URLRequest` when a `URLResponse` is received. This will
    // allow us to re-trigger the `URLRequest` if the user requests a file to be downloaded.
    var pendingRequests = [String: URLRequest]()

    // This is set when the user taps "Download Link" from the context menu. We then force a
    // download of the next request through the `WKNavigationDelegate` that matches this web view.
    weak var pendingDownloadWebView: WKWebView?

    let downloadQueue = DownloadQueue()

    private(set) var feedbackImage: UIImage?

    static var createNewTabOnStartForTesting: Bool = false
    static var createArchivedTabOnStartForTesting: Bool = false

    /// Update the screenshot sent along with feedback. Called before opening overflow menu
    func updateFeedbackImage() {
        UIGraphicsBeginImageContextWithOptions(view.window!.bounds.size, true, 0)
        defer { UIGraphicsEndImageContext() }

        if !view.window!.drawHierarchy(in: view.window!.bounds, afterScreenUpdates: false) {
            // ???
            print("failed to draw hierarchy")
        }
        feedbackImage = UIGraphicsGetImageFromCurrentImageContext()
    }

    private var subscriptions: Set<AnyCancellable> = []

    init(profile: Profile, scene: UIScene) {
        self.profile = profile
        self.tabManager = TabManager(profile: profile, scene: scene, incognitoModel: incognitoModel)
        self.readerModeCache = DiskReaderModeCache.sharedInstance

        super.init(nibName: nil, bundle: nil)

        self.tabManager.cookieCutterModel = browserModel.cookieCutterModel
        self.tabManager.selectedTabPublisher.dropFirst().sink { [weak self] tab in
            if tab == nil {
                self?.showTabTray()
            }
        }.store(in: &subscriptions)

        chromeModel.topBarDelegate = self
        chromeModel.toolbarDelegate = self

        cheatsheetPromoModel.subscribe(to: self.tabManager)
        cheatsheetPromoModel.subscribe(
            to: self.browserModel.contentVisibilityModel,
            overlayManager: self.overlayManager,
            trackingModel: self.trackingStatsViewModel
        )

        didInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        dismissVisibleMenus()

        // The popover view controller is presented with `present`
        // this hide method calls `dismiss`. When it is called inside
        // cooridnator.animate, it breaks the UI after rotation.
        if !chromeModel.inlineToolbar {
            overlayManager.hideCurrentOverlay(ofPriority: .sheet)
        }

        coordinator.animate { [self] _ in
            browserModel.scrollingControlModel.updateMinimumZoom()

            if let popover = displayedPopoverController {
                updateDisplayedPopoverProperties?()
                present(popover, animated: true, completion: nil)
            }

            if chromeModel.inlineToolbar {
                overlayManager.hideCurrentOverlay(ofPriority: .sheet)
            }
        } completion: { [self] _ in
            browserModel.scrollingControlModel.setMinimumZoom()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate func didInit() {
        screenshotHelper = ScreenshotHelper(controller: self)

        tabManager.selectedTabPublisher.prepend(nil).withPrevious().sink { [weak self] in
            self?.selectedTabChanged(selected: $0.1, previous: $0.0)
        }.store(in: &subscriptions)

        tabManager.selectedTabWebViewPublisher.sink { [weak self] webView in
            if let webView = webView {
                self?.locationModel.updateSecureListener(with: webView)
            }
        }.store(in: &subscriptions)

        tabManager.addNavigationDelegate(self)
        downloadQueue.delegate = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateViewConstraints()
    }

    func shouldShowFooterForTraitCollection(_ previousTraitCollection: UITraitCollection) -> Bool {
        return previousTraitCollection.verticalSizeClass != .compact
            && previousTraitCollection.horizontalSizeClass != .regular
    }

    func updateToolbarStateForTraitCollection(_ newCollection: UITraitCollection) {
        let showToolbar = shouldShowFooterForTraitCollection(newCollection)
        chromeModel.inlineToolbar = !showToolbar

        if let tab = tabManager.selectedTab {
            updateURLBarDisplayURL(tab)
        }
    }

    override func willTransition(
        to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)

        // During split screen launching on iPad, this callback gets fired before viewDidLoad gets a chance to
        // set things up. Make sure to only update the toolbar state if the view is ready for it.
        if isViewLoaded {
            updateToolbarStateForTraitCollection(newCollection)
        }

        displayedPopoverController?.dismiss(animated: true, completion: nil)

        coordinator.animate { [self] _ in
            browserModel.scrollingControlModel.showToolbars(animated: false)
        }
    }

    func dismissVisibleMenus() {
        displayedPopoverController?.dismiss(animated: true)
    }

    @objc func appDidEnterBackgroundNotification() {
        displayedPopoverController?.dismiss(animated: false) {
            self.updateDisplayedPopoverProperties = nil
            self.displayedPopoverController = nil
        }

        gridModel.resizeModel.canResizeGrid = false
    }

    @objc func tappedTopArea() {
        browserModel.scrollingControlModel.showToolbars(animated: true)
    }

    @objc func appWillResignActiveNotification() {
        // Dismiss any popovers that might be visible
        displayedPopoverController?.dismiss(animated: false) {
            self.updateDisplayedPopoverProperties = nil
            self.displayedPopoverController = nil
        }

        // If we are displying a private tab, hide any elements in the tab that we wouldn't want shown
        // when the app is in the app switcher
        guard incognitoModel.isIncognito else {
            return
        }

        view.bringSubviewToFront(webViewContainerBackdrop)
        webViewContainerBackdrop.alpha = 1
        presentedViewController?.popoverPresentationController?.containerView?.alpha = 0
        presentedViewController?.view.alpha = 0

        gridModel.resizeModel.canResizeGrid = false
    }

    @objc func appDidBecomeActiveNotification() {
        // Re-show any components that might have been hidden because they were being displayed
        // as part of a private mode tab
        UIView.animate(
            withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(),
            animations: {
                self.presentedViewController?.popoverPresentationController?.containerView?.alpha =
                    1
                self.presentedViewController?.view.alpha = 1
                self.view.backgroundColor = UIColor.clear
            },
            completion: { _ in
                self.webViewContainerBackdrop.alpha = 0
                self.view.sendSubviewToBack(self.webViewContainerBackdrop)
            })

        // Re-show toolbar which might have been hidden during scrolling (prior to app moving into the background)
        browserModel.scrollingControlModel.showToolbars(animated: false)

        if NeevaUserInfo.shared.isUserLoggedIn {
            DispatchQueue.main.async {
                SpaceStore.shared.refresh()
            }
        }

        DispatchQueue.main.async {
            SpaceStore.suggested.refresh()
        }

        gridModel.resizeModel.canResizeGrid = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self, selector: #selector(appWillResignActiveNotification),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidEnterBackgroundNotification),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        KeyboardHelper.defaultHelper.addDelegate(self)

        // In case if the background is accidentally shown
        view.backgroundColor = .DefaultBackground

        webViewContainerBackdrop = UIView()
        webViewContainerBackdrop.backgroundColor = .brand.charcoal
        webViewContainerBackdrop.alpha = 0
        view.addSubview(webViewContainerBackdrop)

        browserHost.willMove(toParent: self)
        view.addSubview(browserHost.view)
        addChild(browserHost)

        self.updateToolbarStateForTraitCollection(self.traitCollection)

        setupConstraints()

        // Setup UIDropInteraction to handle dragging and dropping
        // links into the view from other apps.
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)

        setNeedsStatusBarAppearanceUpdate()

        for tab in tabManager.activeTabs {
            // Update the `background-color` of any blank webviews.
            (tab.webView as? TabWebView)?.applyTheme()
        }
        tabManager.selectedTab?.applyTheme()

        guard
            let contentScript = self.tabManager.selectedTab?.getContentScript(
                name: ReaderMode.name())
        else { return }
        appyThemeForPreferences(contentScript: contentScript)
    }

    fileprivate func setupConstraints() {
        DispatchQueue.main.async {
            self.browserHost.view.makeAllEdges(equalTo: self.view)
            self.webViewContainerBackdrop.makeAllEdges(equalTo: self.view)
        }
    }

    func loadQueuedTabs() {
        assert(!Thread.current.isMainThread, "This must be called in the background.")
        self.profile.queue.getQueuedTabs() >>== { cursor in

            // This assumes that the DB returns rows in some kind of sane order.
            // It does in practice, so WFM.
            if cursor.count > 0 {

                let urls = cursor.compactMap { $0?.url.asURL }
                if !urls.isEmpty {
                    DispatchQueue.main.async {
                        self.tabManager.addTabsForURLs(urls, zombie: false)
                    }
                }

                // Clear *after* making an attempt to open. We're making a bet that
                // it's better to run the risk of perhaps opening twice on a crash,
                // rather than losing data.
                self.profile.queue.clearQueuedTabs()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // config log environment variable
        ClientLogger.shared.env = EnvironmentHelper.shared.env

        let didSelectTabOnStartup = tabManager.restoreTabs()

        DispatchQueue.main.async {
            if Self.createArchivedTabOnStartForTesting {
                self.tabManager.add(
                    archivedTab: ArchivedTab(
                        savedTab: self.tabManager.addTab(
                            tabConfig: .init(
                                request: URLRequest(url: "www.example.com"), zombie: true),
                            isIncognito: false
                        ).saveSessionDataAndCreateSavedTab(isSelected: false, tabIndex: nil)
                    )
                )
                self.tabManager.updateAllTabDataAndSendNotifications(notify: true)
            }

            if Self.createNewTabOnStartForTesting {
                self.tabManager.select(self.tabManager.addTab())
            } else if !didSelectTabOnStartup {
                if !Defaults[.didFirstNavigation] {
                    self.showZeroQuery()
                } else {
                    self.gridModel.switcherAnimationModel.update(switchWithAnimation: false)
                    self.showTabTray()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.gridModel.switcherAnimationModel.update(switchWithAnimation: true)
                    }
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if !Defaults[.introSeen] {
            var startScreen: WelcomeFlowScreen?

            if Defaults[.welcomeFlowRestoreToDefaultBrowser] {
                Defaults[.welcomeFlowRestoreToDefaultBrowser] = false
                startScreen = .defaultBrowser
            }

            presentWelcomeFlow(startScreen: startScreen)
        }

        tabManager.selectedTab?.lastExecutedTime = Date.nowMilliseconds()

        super.viewDidAppear(animated)

        showQueuedAlertIfAvailable()
    }

    fileprivate func showQueuedAlertIfAvailable() {
        if let queuedAlertInfo = tabManager.selectedTab?.dequeueJavascriptAlertPrompt() {
            let alertController = queuedAlertInfo.alertController()
            alertController.delegate = self
            present(alertController, animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func showZeroQuery(
        openedFrom: ZeroQueryOpenedLocation? = nil,
        isLazyTab: Bool = false
    ) {
        // makes sure zeroQuery isn't already open
        guard zeroQueryModel.openedFrom == nil else { return }

        if browserModel.gridModel.visibilityModel.showGrid {
            hideCardGrid(withAnimation: false)
        }

        if isLazyTab {
            chromeModel.triggerOverlay()
        }

        searchQueryModel.value = ""

        self.tabContainerModel.updateContent(
            .showZeroQuery(
                isIncognito: incognitoModel.isIncognito,
                isLazyTab: isLazyTab,
                openedFrom))
    }

    func closeLazyTab() {
        // Have to be a lazy tab to close a lazy tab
        guard self.zeroQueryModel.isLazyTab else {
            print("Tried to close lazy tab that wasn't a lazy tab")
            dismissEditingAndHideZeroQuery()
            return
        }

        DispatchQueue.main.async {
            switch self.zeroQueryModel.openedFrom {
            case .createdTab:
                self.tabManager.close(self.tabManager.selectedTab!)
            case .newTabButton:
                if self.tabManager.selectedTab == nil {
                    self.showTabTray()
                }
            case .openTab(let openedTab):
                if openedTab == nil && self.tabManager.selectedTab == nil {
                    self.showTabTray()
                }
            case .tabTray:
                if Defaults[.didFirstNavigation] {
                    self.showTabTray()
                }
            default:
                break
            }

            self.dismissEditingAndHideZeroQuery()
        }
    }

    func dismissEditingAndHideZeroQuery(
        wasCancelled: Bool = false,
        completionHandler: (() -> Void)? = nil
    ) {
        chromeModel.setEditingLocation(to: false)

        DispatchQueue.main.async { [weak self] in
            self?.hideZeroQuery(wasCancelled: wasCancelled)
            completionHandler?()
        }
    }

    func dismissEditingAndHideZeroQuerySync(wasCancelled: Bool = false) {
        chromeModel.setEditingLocation(to: false)
        hideZeroQuery(wasCancelled: wasCancelled)
    }

    private func hideZeroQuery(wasCancelled: Bool = false) {
        tabContainerModel.updateContent(.hideZeroQuery)
        zeroQueryModel.reset(bvc: self, wasCancelled: wasCancelled)
    }

    fileprivate func updateInZeroQuery(_ url: URL?) {
        if !chromeModel.isEditingLocation {
            guard let url = url else {
                dismissEditingAndHideZeroQuery()
                return
            }

            if !url.absoluteString.hasPrefix(
                "\(InternalURL.baseUrl)/\(SessionRestoreHandler.path)")
            {
                dismissEditingAndHideZeroQuery()
            }
        }
    }

    func finishEditingAndSubmit(
        _ url: URL,
        visitType: VisitType,
        forTab tab: Tab?,
        with suggestedQuery: String? = nil
    ) {
        if BrowserViewController.isCommandKeyPressed && tabManager.getTabCountForCurrentType() > 0 {
            openURLInBackground(url)
            return
        }

        if zeroQueryModel.targetTab == .existingOrNewTab {
            dismissEditingAndHideZeroQuery()
            tabManager.createOrSwitchToTab(
                for: url,
                query: searchQueryModel.value,
                suggestedQuery: suggestedQuery,
                visitType: visitType,
                from: zeroQueryModel.openedFrom?.openedTab,
                keepInParentTabGroup: false
            )
        } else if zeroQueryModel.isLazyTab || zeroQueryModel.targetTab == .newTab {
            dismissEditingAndHideZeroQuery()
            openURLInNewTab(
                url,
                isIncognito: zeroQueryModel.isIncognito,
                query: searchQueryModel.value,
                visitType: visitType
            )
        } else if let tab = tab {
            tab.queryForNavigation.currentQuery = .init(
                typed: searchQueryModel.value,
                suggested: suggestedQuery,
                location: .suggestion
            )

            if zeroQueryModel.openedFrom == .backButton {
                // Once user changes current URL from the back button, the forward history list needs
                // to be overriden. Going back, and THEN loading the request accomplishes that.

                DispatchQueue.main.async {
                    tab.webView?.goBack()

                    guard let nav = tab.loadRequest(URLRequest(url: url)) else {
                        return
                    }

                    self.recordNavigationInTab(navigation: nav, visitType: visitType)
                }
            } else if let nav = tab.loadRequest(URLRequest(url: url)) {
                recordNavigationInTab(navigation: nav, visitType: visitType)
            }
        }

        locationModel.url = url
        chromeModel.setEditingLocation(to: false)
    }

    override func accessibilityPerformEscape() -> Bool {
        if chromeModel.isEditingLocation {
            closeLazyTab()
            return true
        } else if let selectedTab = tabManager.selectedTab, selectedTab.canGoBack {
            selectedTab.goBack()
            return true
        }

        return false
    }

    func updateUIForReaderHomeStateForTab(_ tab: Tab) {
        updateURLBarDisplayURL(tab)

        browserModel.scrollingControlModel.showToolbars(animated: false)

        if let url = tab.url {
            updateInZeroQuery(url as URL)
        }
    }

    /// Updates the URL bar text and button states.
    /// Call this whenever the page URL changes.
    fileprivate func updateURLBarDisplayURL(_ tab: Tab) {
        locationModel.url = tab.url?.displayURL
    }

    // MARK: Opening New Tabs
    func switchToTabForURLOrOpen(_ url: URL, isIncognito: Bool = false) {
        popToBVC()

        if let tab = tabManager.getTabFor(url) {
            tabManager.selectTab(tab, notify: true)
        } else {
            openURLInNewTab(url, isIncognito: isIncognito)
        }
    }

    func switchToTabForWidgetURLOrOpen(_ url: URL, uuid: String, isIncognito: Bool = false) {
        popToBVC()
        if let tab = tabManager.getTabForUUID(uuid: uuid) {
            tabManager.selectTab(tab, notify: true)
        } else {
            openURLInNewTab(url, isIncognito: isIncognito)
        }
    }

    func openURLInNewTab(
        _ url: URL?, isIncognito: Bool = false, query: String? = nil, visitType: VisitType? = nil
    ) {
        if let selectedTab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(selectedTab)
        }

        let request: URLRequest?
        if let url = url {
            request = URLRequest(url: url)
        } else {
            request = nil
        }

        DispatchQueue.main.async { [self] in
            let tab = tabManager.addTab(
                tabConfig: .init(
                    request: request,
                    query: query,
                    visitType: visitType
                ),
                isIncognito: isIncognito
            )
            // Do not launch Universal Links in another app if the user
            // did a manual navigation.
            tab.shouldOpenUniversalLinks = query == nil

            tabManager.selectTab(tab, notify: true)
            hideCardGrid(withAnimation: false)
        }
    }

    func openURLInNewTabPreservingIncognitoState(_ url: URL) {
        self.openURLInNewTab(url, isIncognito: incognitoModel.isIncognito)
    }

    func openURLInBackground(_ url: URL, isIncognito: Bool? = nil) {
        let isIncognito = isIncognito == nil ? incognitoModel.isIncognito : isIncognito!

        let tab = self.tabManager.addTab(
            tabConfig: .init(
                request: URLRequest(url: url),
                insertLocation: InsertTabLocation(parent: tabManager.selectedTab)
            ),
            isIncognito: isIncognito
        )

        var toastLabelText: LocalizedStringKey

        if isIncognito {
            toastLabelText = "New Incognito Tab opened"
        } else {
            toastLabelText = "New Tab opened"
        }

        toastViewManager.makeToast(
            text: toastLabelText,
            buttonText: "Switch",
            buttonAction: {
                self.tabManager.selectTab(tab, notify: true)
            }
        )
    }

    func openLazyTab(
        openedFrom: ZeroQueryOpenedLocation = .openTab(nil), switchToIncognitoMode: Bool? = nil
    ) {
        popToBVC()

        if let switchToIncognitoMode = switchToIncognitoMode {
            tabManager.setIncognitoMode(to: switchToIncognitoMode)
        }

        browserModel.scrollingControlModel.showToolbars(animated: true)
        showZeroQuery(openedFrom: openedFrom, isLazyTab: true)
    }

    func openSearchNewTab(isIncognito: Bool = false, _ text: String) {
        popToBVC()
        if let searchURL = SearchEngine.current.searchURLForQuery(text) {
            openURLInNewTab(searchURL, isIncognito: isIncognito)
        } else {
            // We still don't have a valid URL, so something is broken. Give up.
            print("Error handling URL entry: \"\(text)\".")
            assertionFailure("Couldn't generate search URL: \(text)")
        }
    }

    /// Closes or hides any overlayed views and returns to the selected tab
    func popToBVC() {
        if browserModel.gridModel.visibilityModel.showGrid {
            // Hides CardGrid
            browserModel.hideGridWithNoAnimation()

            // Closes any Space that may be open
            gridModel.spaceCardModel.detailedSpace = nil

            // Resets the CardGrid to be showing tabs for when user reopens the CardGrid
            gridModel.switchToTabs(incognito: incognitoModel.isIncognito)
        }

        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        } else if chromeModel.isEditingLocation {
            // Closes the Suggest UI
            dismissEditingAndHideZeroQuerySync(wasCancelled: false)
        }

        overlayManager.hideCurrentOverlay()

        DispatchQueue.main.async {
            // View alpha is set to 0 in `viewWillAppear` creating a blank screen.
            self.view.alpha = 1
        }
    }

    func presentActivityViewController(
        _ url: URL, tab: Tab? = nil, sourceView: UIView?, sourceRect: CGRect,
        arrowDirection: UIPopoverArrowDirection
    ) {
        let helper = ShareExtensionHelper(url: url, tab: tab)

        var appActivities = [UIActivity]()

        let deferredSites = self.profile.history.isPinnedTopSite(tab?.url?.absoluteString ?? "")

        let isPinned = deferredSites.value.successValue ?? false

        if FeatureFlag[.pinToTopSites] {
            var topSitesActivity: PinToTopSitesActivity
            if isPinned == false {
                topSitesActivity = PinToTopSitesActivity(isPinned: isPinned) { [weak tab] in
                    guard let url = tab?.url?.displayURL,
                        let sql = self.profile.history as? SQLiteHistory
                    else { return }

                    sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                        guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                            return succeed()
                        }
                        return self.profile.history.addPinnedTopSite(site)
                    }.uponQueue(.main) { [self] result in
                        if result.isSuccess {
                            toastViewManager.makeToast(text: "Pinned To Top Sites").enqueue(
                                manager: toastViewManager)
                        }
                    }
                }
            } else {
                topSitesActivity = PinToTopSitesActivity(isPinned: isPinned) { [weak tab] in
                    guard let url = tab?.url?.displayURL,
                        let sql = self.profile.history as? SQLiteHistory
                    else { return }

                    sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                        guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                            return succeed()
                        }

                        return self.profile.history.removeFromPinnedTopSites(site)
                    }.uponQueue(.main) { [self] result in
                        if result.isSuccess {
                            toastViewManager.makeToast(text: "Removed From Top Sites").enqueue(
                                manager: toastViewManager)
                        }
                    }
                }
            }
            appActivities.append(topSitesActivity)
        }

        let controller = helper.createActivityViewController(appActivities: appActivities) {
            [weak self] _, _ in
            guard let self = self else { return }

            // After dismissing, check to see if there were any prompts we queued up
            self.showQueuedAlertIfAvailable()

            // Usually the popover delegate would handle nil'ing out the references we have to it
            // on the BVC when displaying as a popover but the delegate method doesn't seem to be
            // invoked on iOS 10. See Bug 1297768 for additional details.
            self.displayedPopoverController = nil
            self.updateDisplayedPopoverProperties = nil
        }

        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
            popoverPresentationController.permittedArrowDirections = arrowDirection
            popoverPresentationController.delegate = self
        }

        present(controller, animated: true, completion: nil)
    }

    func postLocationChangeNotificationForTab(
        _ tab: Tab, navigation: WKNavigation? = nil, visitType: VisitType? = nil
    ) {
        let notificationCenter = NotificationCenter.default
        var info = [AnyHashable: Any]()
        info["url"] = tab.url?.displayURL
        info["title"] = tab.title ?? ""
        if let visitType = visitType?.rawValue
            ?? self.getVisitTypeForTab(navigation: navigation)?.rawValue
        {
            info["visitType"] = visitType
        }
        info["isPrivate"] = incognitoModel.isIncognito
        notificationCenter.post(name: .OnLocationChange, object: self, userInfo: info)
    }

    /// Enum to represent the WebView observation or delegate that triggered calling `navigateInTab`
    enum WebViewUpdateStatus {
        case title
        case url
        case finishedNavigation
    }

    func navigateInTab(
        tab: Tab, to navigation: WKNavigation? = nil, webViewStatus: WebViewUpdateStatus
    ) {
        guard let webView = tab.webView else {
            print("Cannot navigate in tab without a webView")
            return
        }

        if !Defaults[.didFirstNavigation] {
            ClientLogger.shared.logCounter(.FirstNavigation)
        }
        Defaults[.didFirstNavigation] = true

        if let url = webView.url {
            if !InternalURL.isValid(url: url) || url.isReaderModeURL, !url.isFileURL {
                postLocationChangeNotificationForTab(tab, navigation: navigation)

                webView.evaluateJavascriptInDefaultContentWorld(
                    "\(ReaderModeNamespace).checkReadability()")
            }

            TabEvent.post(.didChangeURL(url), for: tab)
        }

        // Represents WebView observation or delegate update that called this function
        switch webViewStatus {
        case .title, .url, .finishedNavigation:
            // Workaround for issue #1562. It's not safe to insert a WebView into a View hierarchy
            // directly from a property change event. There could be a lot of WebKit code on the
            // stack at this point.
            DispatchQueue.main.async {
                if tab !== self.tabManager.selectedTab, let webView = tab.webView {
                    // To Screenshot a tab that is hidden we must add the webView,
                    // then wait enough time for the webview to render.
                    self.view.insertSubview(webView, at: 0)

                    // This is kind of a hacky fix for Bug 1476637 to prevent webpages from focusing
                    // the touch-screen keyboard from the background even though they shouldn't be
                    // able to.
                    webView.resignFirstResponder()

                    // We need a better way of identifying when webviews are finished rendering
                    // There are cases in which the page will still show a loading animation or
                    // nothing when the screenshot is being taken, depending on internet connection
                    // Issue created: https://github.com/mozilla-mobile/firefox-ios/issues/7003
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.screenshotHelper.takeScreenshot(tab)
                        if webView.superview == self.view {
                            webView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }

    func showTabTray() {
        guard !browserModel.gridModel.visibilityModel.showGrid else { return }

        // log show tap tray
        ClientLogger.shared.logCounter(
            .ShowTabTray, attributes: EnvironmentHelper.shared.getAttributes())

        updateFindInPageVisibility(visible: false)

        if zeroQueryModel.isLazyTab {
            browserModel.showGridWithNoAnimation()
        } else {
            browserModel.showGridWithAnimation()
        }

        if let tab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(tab)
        }
    }

    func hideCardGrid(withAnimation: Bool) {
        if withAnimation {
            browserModel.hideGridWithAnimation()
        } else {
            browserModel.hideGridWithNoAnimation()
        }
    }

    func shareURL(url: URL, view: UIView) {
        let helper = ShareExtensionHelper(url: url, tab: nil)
        let controller = helper.createActivityViewController({ (_, _) in })
        if UIDevice.current.userInterfaceIdiom != .pad {
            controller.modalPresentationStyle = .formSheet
        } else {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.permittedArrowDirections = .up
        }

        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: URL Bar Delegate support code
extension BrowserViewController {
    func urlBarDidEnterOverlayMode() {
        if browserModel.gridModel.visibilityModel.showGrid || tabManager.selectedTab == nil {
            openLazyTab(openedFrom: .tabTray)
        } else {
            showZeroQuery(openedFrom: .openTab(tabManager.selectedTab))
        }
    }

    func urlBarDidLeaveOverlayMode() {
        updateInZeroQuery(tabManager.selectedTab?.url as URL?)
        // this prevents showing a blank screen when exit from
        // the keyboard when there is no active tab for first time user
        if !Defaults[.didFirstNavigation] {
            tabContainerModel.updateContent(.hideSuggestions)
            zeroQueryModel.reset(bvc: self, wasCancelled: false)
        }
    }
}

/// History visit management.
/// TODO: this should be expanded to track various visit types; see Bug 1166084.
extension BrowserViewController {
    func ignoreNavigationInTab(navigation: WKNavigation) {
        self.ignoredNavigation.insert(navigation)
    }

    func recordNavigationInTab(navigation: WKNavigation, visitType: VisitType) {
        self.typedNavigation[navigation] = visitType
    }

    /// Untrack and do the right thing.
    func getVisitTypeForTab(navigation: WKNavigation?) -> VisitType? {
        guard let navigation = navigation else {
            // See https://github.com/WebKit/webkit/blob/master/Source/WebKit2/UIProcess/Cocoa/NavigationState.mm#L390
            return VisitType.link
        }

        if let _ = self.ignoredNavigation.remove(navigation) {
            return nil
        }

        return self.typedNavigation.removeValue(forKey: navigation) ?? VisitType.link
    }
}

extension BrowserViewController: TabDelegate {
    private func subscribe(to webView: WKWebView, for tab: Tab) {
        let updateGestureHandler = {
            if let helper = tab.getContentScript(name: ContextMenuHelper.name())
                as? ContextMenuHelper
            {
                // This is zero-cost if already installed. It needs to be checked frequently (hence every event here triggers this function), as when a new tab is created it requires multiple attempts to setup the handler correctly.
                helper.replaceGestureHandlerIfNeeded()
            }
        }

        let tabManager = self.tabManager

        // Observers that live as long as the tab. They are all cancelled in Tab/close(),
        // so it is safe to use a strong reference to self.
        let estimatedProgressPub = webView.publisher(for: \.estimatedProgress, options: .new)
        let isLoadingPub = webView.publisher(for: \.isLoading, options: .new)
        estimatedProgressPub.combineLatest(isLoadingPub)
            .forEach(updateGestureHandler)
            .filter { _ in tab === tabManager.selectedTab }
            .sink { [self] (estimatedProgress, isLoading) in
                // When done loading, we want to set progress to 1 so that we allow the progress
                // complete animation to happen. But we want to avoid showing incomplete progress
                // when no longer loading (as may happen when a page load is interrupted).
                if let url = webView.url, !InternalURL.isValid(url: url) {
                    if isLoading {
                        chromeModel.estimatedProgress = estimatedProgress
                    } else if estimatedProgress == 1 && chromeModel.estimatedProgress != 1 {
                        chromeModel.estimatedProgress = 1

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
                            if chromeModel.estimatedProgress == 1 {
                                chromeModel.estimatedProgress = nil
                            }
                        }
                    } else {
                        chromeModel.estimatedProgress = nil
                    }
                } else {
                    chromeModel.estimatedProgress = nil
                }
            }
            .store(in: &tab.webViewSubscriptions)

        webView.publisher(for: \.url, options: .new)
            .forEach(updateGestureHandler)
            // Special case for "about:blank" popups, if the webView.url is nil, keep the tab url as "about:blank"
            .filter { tab.url != .aboutBlank || $0 != nil }
            .sink { [self] url in
                if let url = url {
                    tabManager.handleAsNavigationFromPinnedTabIfNeeded(tab: tab, url: url)
                }

                // To prevent spoofing, only change the URL immediately if the new URL is on
                // the same origin as the current URL. Otherwise, do nothing and wait for
                // didCommitNavigation to confirm the page load.
                if tab.url?.origin == url?.origin {
                    tab.setURL(url)

                    if tab === tabManager.selectedTab && !tab.restoring {
                        updateUIForReaderHomeStateForTab(tab)
                    }

                    // Catch history pushState navigation, but ONLY for same origin navigation,
                    // for reasons above about URL spoofing risk.
                    navigateInTab(tab: tab, webViewStatus: .url)
                }
            }
            .store(in: &tab.webViewSubscriptions)

        webView.publisher(for: \.title, options: .new)
            .forEach(updateGestureHandler)
            .compactMap { $0 }
            // Ensure that the tab title *actually* changed to prevent repeated calls
            // to navigateInTab(tab:).
            .filter { !$0.isEmpty && $0 != tab.lastTitle }
            .sink { [self] title in
                tab.lastTitle = title
                navigateInTab(tab: tab, webViewStatus: .title)

                tabManager.updateWindowTitle()
            }
            .store(in: &tab.webViewSubscriptions)

        webView.scrollView
            .publisher(for: \.contentSize, options: .new)
            .sink { [self] _ in
                browserModel.scrollingControlModel.contentSizeDidChange()
            }
            .store(in: &tab.webViewSubscriptions)
    }

    func tab(_ tab: Tab, didCreateWebView webView: WKWebView) {
        webView.uiDelegate = self

        let formPostHelper = FormPostHelper(tab: tab)
        tab.addContentScript(formPostHelper, name: FormPostHelper.name())

        let readerMode = ReaderMode(tab: tab)
        readerMode.delegate = self
        tab.addContentScript(readerMode, name: ReaderMode.name())

        let contextMenuHelper = ContextMenuHelper(tab: tab)
        contextMenuHelper.delegate = self
        tab.addContentScript(contextMenuHelper, name: ContextMenuHelper.name())

        let errorHelper = ErrorPageHelper(certStore: profile.certStore)
        tab.addContentScript(errorHelper, name: ErrorPageHelper.name())

        let sessionRestoreHelper = SessionRestoreHelper(tab: tab)
        sessionRestoreHelper.delegate = self
        tab.addContentScript(sessionRestoreHelper, name: SessionRestoreHelper.name())

        let findInPageHelper = FindInPageHelper(tab: tab)
        findInPageHelper.delegate = self
        tab.addContentScript(findInPageHelper, name: FindInPageHelper.name())

        let downloadContentScript = DownloadContentScript(tab: tab)
        tab.addContentScript(downloadContentScript, name: DownloadContentScript.name())

        let printHelper = PrintHelper(tab: tab)
        tab.addContentScript(printHelper, name: PrintHelper.name())

        tab.addContentScript(LocalRequestHelper(), name: LocalRequestHelper.name())

        let blocker = NeevaTabContentBlocker(tab: tab)
        tab.contentBlocker = blocker
        tab.addContentScript(blocker, name: NeevaTabContentBlocker.name())

        tab.addContentScript(FocusHelper(tab: tab), name: FocusHelper.name())
        tab.injectCookieCutterScript(cookieCutterModel: browserModel.cookieCutterModel)

        let webuiMessageHelper = WebUIMessageHelper(
            tab: tab,
            webView: webView,
            tabManager: tabManager)
        tab.addContentScript(webuiMessageHelper, name: WebUIMessageHelper.name())
    }

    func tab(_ tab: Tab, didUpdateWebView webView: WKWebView) {
        self.subscribe(to: webView, for: tab)
    }

    // Cleans up a tab when it is to be removed.
    func tab(_ tab: Tab, willDeleteWebView webView: WKWebView) {
        tab.cancelQueuedAlerts()
        webView.uiDelegate = nil
        webView.scrollView.delegate = nil
    }

    func tab(_ tab: Tab, didSelectAddToSpaceForSelection selection: String) {
        showAddToSpacesSheet(
            url: tab.url!,
            title: tab.displayTitle, description: selection, webView: tab.webView!, tab: tab)
    }

    func tab(_ tab: Tab, didSelectFindInPageForSelection selection: String) {
        updateFindInPageVisibility(visible: true, query: selection)
    }

    func tab(_ tab: Tab, didSelectSearchWithNeevaForSelection selection: String) {
        openSearchNewTab(isIncognito: incognitoModel.isIncognito, selection)
    }
}

extension BrowserViewController: ZeroQueryPanelDelegate {
    func zeroQueryPanelDidRequestToSaveToSpace(_ url: URL, title: String?, description: String?) {
        chromeModel.setEditingLocation(to: false)
        // Pass a nil WKWebView to disambiguate the function call.
        showAddToSpacesSheet(url: url, title: title, description: description, webView: nil)
    }

    func zeroQueryPanel(didSelectURL url: URL, visitType: VisitType) {
        if NeevaUserInfo.shared.isUserLoggedIn
            && url.absoluteString.starts(with: NeevaConstants.appSpacesURL.absoluteString)
        {
            dismissEditingAndHideZeroQuery()
            browserModel.openSpace(spaceID: url.lastPathComponent)
            return
        }
        finishEditingAndSubmit(url, visitType: visitType, forTab: tabManager.selectedTab)
    }

    func zeroQueryPanelDidRequestToOpenInNewTab(_ url: URL, isIncognito: Bool) {
        dismissEditingAndHideZeroQuery()
        openURLInBackground(url, isIncognito: isIncognito)
    }

    func zeroQueryPanel(didEnterQuery query: String) {
        searchQueryModel.value = query
        chromeModel.setEditingLocation(to: true)
    }
}

extension BrowserViewController {
    func selectedTabChanged(selected: Tab?, previous: Tab?) {
        /*
         * Sometimes we load a SFSafariViewController and immediately close the tab behind it
         * (e.g., with Google Device Policy profile downloads). We need to make an exception
         * for this case, otherwise the SFSafariViewController will close too quickly for the
         * user to interact with it.
         */
        if !(presentedViewController is SFSafariViewController?) {
            presentedViewController?.dismiss(animated: false, completion: nil)
        }

        // Remove the old accessibilityLabel. Since this webview shouldn't be visible, it doesn't need it
        // and having multiple views with the same label confuses tests.
        if let wv = previous?.webView {
            wv.endEditing(true)
            wv.accessibilityLabel = nil
            wv.accessibilityElementsHidden = true
            wv.accessibilityIdentifier = nil
        }

        if let tab = selected, let webView = tab.webView {
            updateURLBarDisplayURL(tab)

            readerModeCache =
                tab.isIncognito
                ? MemoryReaderModeCache.sharedInstance : DiskReaderModeCache.sharedInstance
            ReaderModeHandlers.readerModeCache = readerModeCache

            // This is a terrible workaround for a bad iOS 12 bug where PDF
            // content disappears any time the view controller changes (i.e.
            // the user taps on the tabs tray). It seems the only way to get
            // the PDF to redraw is to either reload it or revisit it from
            // back/forward list. To try and avoid hitting the network again
            // for the same PDF, we revisit the current back/forward item and
            // restore the previous scrollview zoom scale and content offset
            // after a short 100ms delay. *facepalm*
            //
            // https://bugzilla.mozilla.org/show_bug.cgi?id=1516524
            if tab.temporaryDocument?.mimeType == MIMEType.PDF {
                let previousZoomScale = webView.scrollView.zoomScale
                let previousContentOffset = webView.scrollView.contentOffset

                if let currentItem = webView.backForwardList.currentItem {
                    webView.go(to: currentItem)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    webView.scrollView.setZoomScale(previousZoomScale, animated: false)
                    webView.scrollView.setContentOffset(previousContentOffset, animated: false)
                }
            }

            webView.accessibilityLabel = .WebViewAccessibilityLabel
            webView.accessibilityIdentifier = "contentView"
            webView.accessibilityElementsHidden = false

            if webView.url == nil {
                // The web view can go gray if it was zombified due to memory pressure.
                // When this happens, the URL is nil, so try restoring the page upon selection.
                tab.reload()
            }
        }

        updateFindInPageVisibility(visible: false, tab: previous)

        if let url = selected?.webView?.url, !InternalURL.isValid(url: url) {
            if selected?.isLoading ?? false {
                chromeModel.estimatedProgress = selected?.estimatedProgress
            } else {
                chromeModel.estimatedProgress = nil
            }
        }

        if let readerMode = selected?.getContentScript(name: ReaderMode.name()) as? ReaderMode {
            readerModeModel.setReadingModeState(state: readerMode.state)
        } else {
            readerModeModel.setReadingModeState(state: .unavailable)
        }

        updateInZeroQuery(selected?.url as URL?)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension BrowserViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController
    ) {
        displayedPopoverController = nil
        updateDisplayedPopoverProperties = nil
    }

    override func present(
        _ viewControllerToPresent: UIViewController, animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        if let imagePicker = viewControllerToPresent as? UIImagePickerController {
            // Force the image picker to use a PageSheet, prevents a bug where
            // the BrowserView content would be shrunk until the app reloads.
            imagePicker.modalPresentationStyle = .pageSheet
        }

        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension BrowserViewController: UIAdaptivePresentationControllerDelegate {
    // Returning None here makes sure that the Popover is actually presented as a Popover and
    // not as a full-screen modal, which is the default on compact device classes.
    func adaptivePresentationStyle(
        for controller: UIPresentationController, traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

extension BrowserViewController: ContextMenuHelperDelegate {
    fileprivate static var contextMenuElements: ContextMenuHelper.Elements?

    func contextMenuHelper(didLongPressImage elements: ContextMenuHelper.Elements) {
        BrowserViewController.contextMenuElements = elements
        let imageContextMenu = ImageContextMenu(elements: elements) { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .saveImage: self.saveImage()
            case .copyImage: self.copyImage()
            case .copyImageLink: self.copyImageLink()
            case .addToSpace: self.addImageToSpace()
            case .addToSpaceWithImage: self.addToSpaceWithImage()
            }
        }
        present(imageContextMenu, animated: true)
        tabManager.selectedTab?.webView?.stopLoading()
    }

    @objc func saveImage() {
        guard let url = BrowserViewController.contextMenuElements?.image else { return }
        BrowserViewController.contextMenuElements = nil

        self.getImageData(url) { data in
            guard let image = UIImage(data: data) else { return }
            self.writeToPhotoAlbum(image: image)
        }
    }

    @objc func copyImage() {
        guard let url = BrowserViewController.contextMenuElements?.image else { return }
        BrowserViewController.contextMenuElements = nil

        // put the actual image on the clipboard
        // do this asynchronously just in case we're in a low bandwidth situation
        let pasteboard = UIPasteboard.general
        pasteboard.url = url as URL
        let changeCount = pasteboard.changeCount
        let application = UIApplication.shared
        var taskId = UIBackgroundTaskIdentifier(rawValue: 0)
        taskId = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(taskId)
        })

        makeURLSession(
            userAgent: UserAgent.getUserAgent(),
            configuration: URLSessionConfiguration.default
        ).dataTask(with: url) { (data, response, error) in
            guard let _ = validatedHTTPResponse(response, statusCode: 200..<300) else {
                application.endBackgroundTask(taskId)
                return
            }

            // Only set the image onto the pasteboard if the pasteboard hasn't changed since
            // fetching the image; otherwise, in low-bandwidth situations,
            // we might be overwriting something that the user has subsequently added.
            if changeCount == pasteboard.changeCount, let imageData = data, error == nil {
                pasteboard.addImageWithData(imageData, forURL: url)
            }

            application.endBackgroundTask(taskId)
        }.resume()
    }

    @objc func copyImageLink() {
        guard let url = BrowserViewController.contextMenuElements?.image else { return }
        BrowserViewController.contextMenuElements = nil

        UIPasteboard.general.url = url as URL
    }

    @objc func addImageToSpace() {
        guard let url = BrowserViewController.contextMenuElements?.image,
            let webView = tabManager.selectedTab?.webView
        else {
            return
        }

        showAddToSpacesSheet(
            url: url,
            title: BrowserViewController.contextMenuElements?.title, webView: webView,
            tab: tabManager.selectedTab)

        BrowserViewController.contextMenuElements = nil
    }

    @objc func addToSpaceWithImage() {
        if let pageURL = tabManager.selectedTab?.url, let webView = tabManager.selectedTab?.webView
        {
            showAddToSpacesSheet(
                url: pageURL,
                title: self.tabManager.selectedTab?.title,
                webView: webView, tab: tabManager.selectedTab)
        }
    }

    fileprivate func getImageData(_ url: URL, success: @escaping (Data) -> Void) {
        makeURLSession(
            userAgent: UserAgent.getUserAgent(), configuration: URLSessionConfiguration.default
        ).dataTask(with: url) { (data, response, _) in
            if let _ = validatedHTTPResponse(response, statusCode: 200..<300), let data = data {
                success(data)
            }
        }.resume()
    }
}

extension BrowserViewController {
    @objc func image(
        _ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer
    ) {
    }
}

extension BrowserViewController: KeyboardHelperDelegate {
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState
    ) {
        updateViewConstraints()
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState
    ) {}

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState
    ) {
        updateViewConstraints()
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidHideWithState state: KeyboardState
    ) {}
}

extension BrowserViewController: SessionRestoreHelperDelegate {
    func sessionRestoreHelper(didRestoreSessionForTab tab: Tab) {
        tab.restoring = false

        if let tab = tabManager.selectedTab, tab.webView === tab.webView {
            updateUIForReaderHomeStateForTab(tab)
        }
    }
}

extension BrowserViewController: JSPromptAlertControllerDelegate {
    func promptAlertControllerDidDismiss(_ alertController: JSPromptAlertController) {
        showQueuedAlertIfAvailable()
    }
}

extension BrowserViewController {
    func showAddToSpacesSheet(
        url: URL, title: String?, description: String? = nil,
        webView: WKWebView?, importData: SpaceImportHandler? = nil, tab: Tab? = nil
    ) {
        weak var model = self.gridModel.spaceCardModel

        // Look at mediaURL from page metadata and large images within the page and dedupe
        // across URLs
        var set = Set<String>()
        var thumbnailUrls = [URL]()
        if let mediaURL =
            URL(string: tab?.pageMetadata?.mediaURL ?? "")
        {
            thumbnailUrls.append(mediaURL)
            set.insert(mediaURL.absoluteString)
        }

        if let webView = webView {
            // TODO: Inject this as a ContentScript to avoid the delay here.
            webView.evaluateJavaScript(SpaceImportHandler.descriptionImageScript) {
                [weak self]
                (result, _) in

                guard let self = self else { return }
                let output = result as? [[String]]

                if let imageUrls = output?[1]
                    .filter({ set.update(with: $0) == nil })
                    .compactMap({ $0.asURL })
                {
                    thumbnailUrls.append(contentsOf: imageUrls)
                }

                let updater = SocialInfoUpdater.from(
                    url: url, ogInfo: output?.last, title: title ?? ""
                ) {
                    range, data, id in
                    if let details = model?.detailedSpace {
                        details.allDetails.replaceSubrange(
                            range, with: [SpaceEntityThumbnail(data: data, spaceID: id.id)])
                    }
                }

                model?.thumbnailURLCandidates[url] = thumbnailUrls

                let thumbnailUrl = thumbnailUrls.first(where: {
                    $0.isImage
                })?.absoluteString

                self.showAddToSpacesSheet(
                    url: url,
                    title: updater?.title ?? title,
                    description: description ?? updater?.description ?? output?.first?.first,
                    thumbnail: thumbnailUrl,
                    importData: importData,
                    updater: updater)
            }
        } else {
            let updater = SocialInfoUpdater.from(url: url, ogInfo: nil, title: title ?? "") {
                range, data, id in
                if let details = model?.detailedSpace {
                    details.allDetails.replaceSubrange(
                        range, with: [SpaceEntityThumbnail(data: data, spaceID: id.id)])
                }
            }

            model?.thumbnailURLCandidates[url] = thumbnailUrls

            let thumbnailUrl = thumbnailUrls.first(where: {
                $0.isImage
            })?.absoluteString

            self.showAddToSpacesSheet(
                url: url,
                title: title,
                description: description,
                thumbnail: thumbnailUrl,
                importData: importData,
                updater: updater)
        }
    }

    /// Convenience method to reduce code duplication.
    private func showAddToSpacesModal(
        request: AddToSpaceRequest, importData: SpaceImportHandler? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        overlayManager.showModal(
            style: .spaces,
            headerButton: OverlayHeaderButton(
                text: "View Spaces",
                icon: .bookmarkOnBookmark,
                action: {
                    self.browserModel.showSpaces()
                    ClientLogger.shared.logCounter(
                        .ViewSpacesFromSheet,
                        attributes: EnvironmentHelper.shared.getAttributes())
                }),
            content: {
                AddToSpaceOverlayContent(
                    request: request,
                    bvc: self, importData: importData
                )
                .environmentObject(self.chromeModel)
                .environmentObject(self.browserModel)
                .environmentObject(self.overlayManager)
            }, onDismiss: onDismiss)
    }

    func showAddToSpacesSheet(
        url: URL,
        title: String?,
        description: String?,
        thumbnail: String? = nil,
        importData: SpaceImportHandler? = nil,
        updater: SocialInfoUpdater? = nil
    ) {
        let title = (title ?? "").isEmpty ? url.absoluteString : title!

        // This should never fail. The initializer only fails when
        // the input is empty.
        guard
            let request = AddToSpaceRequest(
                input: [
                    AddToSpaceInput(
                        url: url, title: title, thumbnail: thumbnail, description: description)
                ], updater: updater
            )
        else { return }

        showAddToSpacesModal(request: request, importData: importData) {
            if request.state != .initial
                && request.state != .savingToSpace
                && request.state != .savedToSpace
            {
                ToastDefaults().showToastForAddToSpaceUI(bvc: self, request: request)
            }
        }
    }

    func showAddToSpacesSheetForGroup(tabGroup: TabGroup) {
        guard
            let request = AddToSpaceRequest(
                input: tabGroup.children.compactMap {
                    guard let url = $0.url else { return nil }
                    return AddToSpaceInput(url: url, title: $0.displayTitle)
                })
        else { return }

        showAddToSpacesModal(request: request)
    }

    func showSpacesLoginRequiredSheet() {
        overlayManager.showModal(style: .withTitle) {
            SpacesLoginRequiredView()
                .environment(\.onSigninOrJoinNeeva) {
                    ClientLogger.shared.logCounter(.SpacesLoginRequired)

                    self.overlayManager.hideCurrentOverlay()

                    self.presentSignInOrUpFlow()
                }
        }
    }
}

// MARK: - Cheatsheet Sheet/Popover
extension BrowserViewController {
    /// Fetch chearsheet info and present cheatsheet
    ///
    /// Cheatsheat is presented as sheet on iPhone in portrait; otherwise, it is presented as popover
    /// This is consistent with the behaviour of [showModal](x-source-tag://showModal)
    func showCheatSheetOverlay() {
        // if on iphone and portrait, present as sheet
        // otherwise, present as popover
        overlayManager.showModal(style: .cheatsheet) {
            CheatsheetOverlayContent(
                menuAction: { self.perform(overflowMenuAction: $0, targetButtonView: nil) },
                tabManager: self.tabManager
            )
            .environment(\.onSigninOrJoinNeeva) {
                ClientLogger.shared.logCounter(
                    .CheatsheetErrorSigninOrJoinNeeva,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes()
                )

                self.overlayManager.hideCurrentOverlay()
                self.presentSignInOrUpFlow(onCompleteHideCardGrid: true)
            }
        }

        self.dismissVC()
    }
}

extension UIViewController {
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension BrowserViewController {
    func showShareSheet(buttonView: UIView) {
        guard
            let tab = tabManager.selectedTab,
            let url = tab.url
        else { return }

        if url.isFileURL {
            share(fileURL: url, buttonView: buttonView, presentableVC: self)
        } else {
            share(tab: tab, from: buttonView, presentableVC: self)
        }
    }

    func showBackForwardList() {
        guard let backForwardList = tabManager.selectedTab?.webView?.backForwardList,
            backForwardList.all.count > 1
        else {
            return
        }

        overlayManager.show(
            overlay: .backForwardList(
                BackForwardListView(
                    model: BackForwardListModel(
                        backForwardList: backForwardList
                    ),
                    overlayManager: overlayManager,
                    navigationClicked: { navigationListItem in
                        self.tabManager.selectedTab?.goToBackForwardListItem(navigationListItem)
                    }
                )
            )
        )
    }
}

extension BrowserViewController {
    func openSettings(openPage: SettingsPage? = nil) {
        let action = {
            let controller = SettingsViewController(bvc: self, openPage: openPage) {
                self.overlayManager.isPresentedViewControllerVisible = false
            }

            self.present(controller, animated: true)
        }

        TourManager.shared.userReachedStep(tapTarget: .settingMenu)

        // For the connected apps tour prompt
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true, completion: action)
        } else {
            action()
        }

        overlayManager.isPresentedViewControllerVisible = true
    }
}

extension BrowserViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    )
        -> UIContextMenuConfiguration?
    {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                let children: [UIMenuElement] = []
                return UIMenu(title: "", children: children)
            })
    }

}
