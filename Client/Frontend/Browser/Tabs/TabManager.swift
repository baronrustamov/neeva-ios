/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Foundation
import Shared
import Storage
import WebKit
import XCGLogger

private let log = Logger.browser

enum PreferredSelectTabTarget {
    case parent
    case mostRecent
    case noPreference
    case doNotSelect

    var shouldSelect: Bool {
        if case .doNotSelect = self {
            return false
        }
        return true
    }
}

// TabManager must extend NSObjectProtocol in order to implement WKNavigationDelegate
class TabManager: NSObject, TabEventHandler, WKNavigationDelegate {
    private let tabEventHandlers: [TabEventHandler]
    private let store: TabManagerStore
    var scene: UIScene
    let profile: Profile
    let incognitoModel: IncognitoModel

    var isIncognito: Bool {
        incognitoModel.isIncognito
    }

    private let delaySelectingNewPopupTab: TimeInterval = 0.1

    static var all = WeakList<TabManager>()

    // External classes should only be able to access this through `activeTabs` and `archivedTabs`.
    private var tabs = [Tab]()
    var tabsUpdatedPublisher = PassthroughSubject<Void, Never>()

    // Tab Group related variables
    @Default(.archivedTabsDuration) private var archivedTabsDuration

    // TODO: consolidate accessors, don't need both `tabs` and `activeTabs`
    var activeTabs: [Tab] { tabs }
    var archivedTabs: [ArchivedTab] = []
    var activeTabGroups: [String: TabGroup] = [:]
    var archivedTabGroups: [String: ArchivedTabGroup] = [:]

    // Use `selectedTabPublisher` to observe changes to `selectedTab`.
    private(set) var selectedTab: Tab?
    private(set) var selectedTabPublisher = CurrentValueSubject<Tab?, Never>(nil)
    /// A publisher that forwards the url from the current selectedTab
    private(set) var selectedTabURLPublisher = CurrentValueSubject<URL?, Never>(nil)
    /// Publisher used to observe changes to the `selectedTab.webView`.
    /// Will also update if the `WebView` is set to nil.
    private(set) var selectedTabWebViewPublisher = CurrentValueSubject<WKWebView?, Never>(nil)
    /// A publisher that refreshes data in ArchivedTabsPanelModel, which should happen after
    ///  updateAllTabDataAndSendNotifications runs.
    private(set) var updateArchivedTabsPublisher = PassthroughSubject<Void, Never>()
    private var selectedTabSubscription: AnyCancellable?
    private var selectedTabURLSubscription: AnyCancellable?
    private var archivedTabsDurationSubscription: AnyCancellable?
    private var spaceFromTabGroupSubscription: AnyCancellable?

    private var needsHeavyUpdatesPostAnimation = false

    private let navDelegate: TabManagerNavDelegate

    // A WKWebViewConfiguration used for normal tabs
    lazy var configuration: WKWebViewConfiguration = {
        return TabManager.makeWebViewConfig(isIncognito: false)
    }()

    // A WKWebViewConfiguration used for private mode tabs
    private lazy var incognitoConfiguration: WKWebViewConfiguration = {
        return TabManager.makeWebViewConfig(isIncognito: true)
    }()

    // Enables undo of recently closed tabs
    /// Supports closing/restoring a group of tabs or a single tab (alone in an array)
    var recentlyClosedTabs = [[SavedTab]]() {
        didSet {
            recentlyClosedTabsFlattened = recentlyClosedTabs.flatMap { $0 }
        }
    }
    var recentlyClosedTabsFlattened: [SavedTab] = []
    // Groups tabs closed at the same time so they can be restored together.
    private let recentlyClosedTabGroupTimerDuration: TimeInterval = 1.5
    private var recentlyClosedTabGroupTimer: Timer?
    private var closedTabsToShowToastFor = [SavedTab]()

    private var normalTabs: [Tab] {
        assert(Thread.isMainThread)
        return tabs.filter { !$0.isIncognito }
    }

    var incognitoTabs: [Tab] {
        assert(Thread.isMainThread)
        return tabs.filter { $0.isIncognito }
    }

    var activeNormalTabs: [Tab] {
        return activeTabs.filter { !$0.isIncognito }
    }

    var todaysTabs: [Tab] {
        return activeNormalTabs.filter { $0.isIncluded(in: .today) }
    }

    var count: Int {
        assert(Thread.isMainThread)

        return tabs.count
    }

    var cookieCutterModel: CookieCutterModel?

    // MARK: - Init
    init(profile: Profile, scene: UIScene, incognitoModel: IncognitoModel) {
        assert(Thread.isMainThread)
        self.profile = profile
        self.navDelegate = TabManagerNavDelegate()
        self.tabEventHandlers = TabEventHandlers.create()
        self.store = TabManagerStore.shared
        self.scene = scene
        self.incognitoModel = incognitoModel
        super.init()

        Self.all.insert(self)

        register(self, forTabEvents: .didLoadFavicon, .didChangeContentBlocking)

        addNavigationDelegate(self)

        NotificationCenter.default.addObserver(
            self, selector: #selector(prefsDidChange), name: UserDefaults.didChangeNotification,
            object: nil)

        selectedTabSubscription =
            selectedTabPublisher
            .sink { [weak self] tab in
                self?.selectedTabURLSubscription?.cancel()
                if tab == nil {
                    self?.selectedTabURLPublisher.send(nil)
                }
                self?.selectedTabURLSubscription = tab?.$url
                    .sink {
                        self?.selectedTabURLPublisher.send($0)
                    }
            }

        archivedTabsDurationSubscription =
            _archivedTabsDuration.publisher.dropFirst().sink {
                [weak self] _ in
                self?.updateAllTabDataAndSendNotifications(notify: false)
                // update CardGrid and ArchivedTabsPanelView with the latest data
                self?.updateArchivedTabsPublisher.send()
            }
    }

    func addNavigationDelegate(_ delegate: WKNavigationDelegate) {
        assert(Thread.isMainThread)

        self.navDelegate.insert(delegate)
    }

    subscript(index: Int) -> Tab? {
        assert(Thread.isMainThread)

        if index >= tabs.count {
            return nil
        }
        return tabs[index]
    }

    subscript(webView: WKWebView) -> Tab? {
        assert(Thread.isMainThread)

        for tab in tabs where tab.webView === webView {
            return tab
        }

        return nil
    }

    // MARK: - Get Tab
    func getTabFor(_ url: URL, with parent: Tab? = nil) -> Tab? {
        assert(Thread.isMainThread)

        let options: [URL.EqualsOption] = [
            .normalizeHost, .ignoreFragment, .ignoreLastSlash, .ignoreScheme,
        ]

        log.info(
            "Looking for matching tab, url: \(url) under parent tab: \(String(describing: parent))"
        )

        let incognito = self.isIncognito
        return tabs.first { tab in
            guard tab.isIncognito == incognito else {
                return false
            }

            // Tab.url will be nil if the Tab is yet to be restored.
            if let tabURL = tab.url {
                log.info("Checking tabURL: \(tabURL)")
                if url.equals(tabURL, with: options) {
                    if let parent = parent {
                        return tab.parent == parent
                    } else {
                        return true
                    }
                }
            } else if let sessionUrl = tab.sessionData?.currentUrl {  // Match zombie tabs
                log.info("Checking sessionUrl: \(sessionUrl)")

                if url.equals(sessionUrl, with: options) {
                    if let parent = parent {
                        return tab.parent == parent || tab.parentUUID == parent.tabUUID
                    } else {
                        return true
                    }
                }
            }

            return false
        }
    }

    func getTabCountForCurrentType(limitToToday: Bool = false) -> Int {
        getTabsForCurrentType(limitToToday: limitToToday).count
    }

    func getTabsForCurrentType(limitToToday: Bool = false) -> [Tab] {
        let isIncognito = isIncognito

        if isIncognito {
            return incognitoTabs
        } else {
            return limitToToday ? todaysTabs : activeNormalTabs
        }
    }

    func getTabForUUID(uuid: String) -> Tab? {
        assert(Thread.isMainThread)
        let filteredTabs = tabs.filter { tab -> Bool in
            tab.tabUUID == uuid
        }
        return filteredTabs.first
    }

    // MARK: - Select Tab
    // This function updates the _selectedIndex.
    // Note: it is safe to call this with `tab` and `previous` as the same tab, for use in the case where the index of the tab has changed (such as after deletion).
    func selectTab(_ tab: Tab?, previous: Tab? = nil, notify: Bool) {
        assert(Thread.isMainThread)
        let previous = previous ?? selectedTab
        previous?.isSelected = false
        tab?.isSelected = true
        selectedTab = tab

        // TODO(darin): This writes to a published variable generating a notification.
        // Are we okay with that happening here?
        incognitoModel.update(isIncognito: tab?.isIncognito ?? isIncognito)
        removeAllIncognitoTabsForLeavingIncognitoMode(
            previousWasIncognito: previous?.isIncognito ?? false)

        store.preserveTabs(
            tabs, archivedTabs: archivedTabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)

        assert(tab === selectedTab, "Expected tab is selected")

        if let selectedTab = selectedTab {
            selectedTab.lastExecutedTime = Date.nowMilliseconds()
            selectedTab.applyTheme()

            if selectedTab.shouldPerformHeavyUpdatesUponSelect {
                // Don't need to send WebView notifications if they will be sent below.
                updateWebViewForSelectedTab(notify: !notify)

                // Tab data needs to be updated after the lastExecutedTime is modified.
                updateAllTabDataAndSendNotifications(notify: notify)
            } else {
                needsHeavyUpdatesPostAnimation = true
            }
        }

        if notify {
            sendSelectTabNotifications(previous: previous)
            selectedTabWebViewPublisher.send(selectedTab?.webView)
        }

        updateWindowTitle()

        if let tab = tab, tab.isIncognito, let url = tab.url, NeevaConstants.isAppHost(url.host),
            !url.path.starts(with: "/incognito")
        {
            tab.webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                if cookies.first(where: {
                    NeevaConstants.isAppHost($0.domain) && $0.name == "httpd~incognito"
                        && $0.isSecure
                }) != nil {
                    return
                }

                GraphQLAPI.shared.perform(
                    mutation: StartIncognitoMutation(url: url)
                ) { result in
                    guard
                        case .success(let data) = result,
                        let url = URL(string: data.startIncognito)
                    else { return }
                    let configuration = URLSessionConfiguration.ephemeral
                    makeURLSession(userAgent: UserAgent.getUserAgent(), configuration: .ephemeral)
                        .dataTask(with: url) { (_, _, _) in
                            print(configuration.httpCookieStorage?.cookies ?? [])
                        }
                }
            }
        }
    }

    private func updateWebViewForSelectedTab(notify: Bool) {
        selectedTab?.createWebViewOrReloadIfNeeded()

        if notify {
            selectedTabWebViewPublisher.send(selectedTab?.webView)
        }
    }

    func updateSelectedTabDataPostAnimation() {
        selectedTab?.shouldPerformHeavyUpdatesUponSelect = true

        if needsHeavyUpdatesPostAnimation {
            needsHeavyUpdatesPostAnimation = false

            // Tab data needs to be updated after the lastExecutedTime is modified.
            updateAllTabDataAndSendNotifications(notify: true)
            updateWebViewForSelectedTab(notify: true)
        }
    }

    /// Updates the name of the window when using iPad multitasking.
    func updateWindowTitle() {
        if let selectedTab = selectedTab, !selectedTab.isIncognito {
            scene.title = selectedTab.displayTitle
        } else {
            scene.title = ""
        }
    }

    func flagAllTabsToReload() {
        for tab in tabs {
            if tab == selectedTab {
                tab.reload()
            } else if tab.webView != nil {
                tab.needsReloadUponSelect = true
            }
        }
    }

    // MARK: - Incognito
    // TODO(darin): Refactor these methods to set incognito mode. These should probably
    // move to `BrowserModel` and `TabManager` should just observe `IncognitoModel`.
    func setIncognitoMode(to isIncognito: Bool) {
        self.incognitoModel.update(isIncognito: isIncognito)
    }

    func toggleIncognitoMode(
        fromTabTray: Bool = true,
        clearSelectedTab: Bool = true,
        openLazyTab: Bool = true,
        selectNewTab: Bool = false
    ) {
        let bvc = SceneDelegate.getBVC(with: scene)

        // set to nil while inconito changes
        if clearSelectedTab {
            selectedTab = nil
        }

        incognitoModel.toggle()
        removeAllIncognitoTabsForLeavingIncognitoMode(previousWasIncognito: !isIncognito)

        if selectNewTab {
            if let mostRecentTab = mostRecentTab(inTabs: isIncognito ? incognitoTabs : normalTabs) {
                selectTab(mostRecentTab, notify: true)
            } else if isIncognito && openLazyTab {  // no empty tab tray in incognito
                bvc.openLazyTab(openedFrom: fromTabTray ? .tabTray : .openTab(selectedTab))
            } else {
                let placeholderTab = Tab(
                    bvc: bvc, configuration: configuration, isIncognito: isIncognito)

                // Creates a placeholder Tab to make sure incognito is switched in the Top Bar
                select(placeholderTab)
            }
        }
    }

    func switchIncognitoMode(
        incognito: Bool, fromTabTray: Bool = true, clearSelectedTab: Bool = false,
        openLazyTab: Bool = true
    ) {
        if isIncognito != incognito {
            toggleIncognitoMode(
                fromTabTray: fromTabTray,
                clearSelectedTab: clearSelectedTab,
                openLazyTab: openLazyTab)
        }
    }

    @objc private func prefsDidChange() {
        DispatchQueue.main.async {
            let allowPopups = !Defaults[.blockPopups]
            // Each tab may have its own configuration, so we should tell each of them in turn.
            for tab in self.tabs {
                tab.webView?.configuration.preferences.javaScriptCanOpenWindowsAutomatically =
                    allowPopups
            }
            // The default tab configurations also need to change.
            self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = allowPopups
            self.incognitoConfiguration.preferences.javaScriptCanOpenWindowsAutomatically =
                allowPopups
        }
    }

    func addPopupForParentTab(
        bvc: BrowserViewController, parentTab: Tab, configuration: WKWebViewConfiguration
    ) -> Tab {
        let popup = Tab(bvc: bvc, configuration: configuration, isIncognito: parentTab.isIncognito)
        let config = TabConfig(
            insertLocation: InsertTabLocation(parent: parentTab),
            flushToDisk: true,
            zombie: false,
            isPopup: true
        )
        configureTab(popup, tabConfig: config, notify: true)

        // Wait momentarily before selecting the new tab, otherwise the parent tab
        // may be unable to set `window.location` on the popup immediately after
        // calling `window.open("")`.
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySelectingNewPopupTab) {
            self.selectTab(popup, notify: true)
        }

        // if we open from SRP, carry over the query
        if let parentURL = parentTab.url,
            NeevaConstants.isNeevaSearchResultPage(parentURL),
            let parentQuery = parentTab.queryForNavigation.findQueryForNavigation(with: parentURL)
        {
            var copiedQuery = parentQuery
            copiedQuery.location = .SRP
            popup.queryForNavigation.currentQuery = copiedQuery
        }

        return popup
    }

    private func sendSelectTabNotifications(previous: Tab? = nil) {
        selectedTabPublisher.send(selectedTab)

        if selectedTab?.shouldPerformHeavyUpdatesUponSelect ?? true {
            updateWebViewForSelectedTab(notify: true)
        }

        if let tab = previous {
            TabEvent.post(.didLoseFocus, for: tab)
        }

        if let tab = selectedTab {
            TabEvent.post(.didGainFocus, for: tab)
        }
    }

    func rearrangeTabs(fromIndex: Int, toIndex: Int, notify: Bool) {
        let toRootUUID = tabs[toIndex].rootUUID
        if getTabGroup(for: toRootUUID) != nil {
            // If the Tab is being dropped in a TabGroup, change it's,
            // rootUUID so it joins the TabGroup.
            tabs[fromIndex].rootUUID = toRootUUID
        } else {
            // Tab was dragged out of a TabGroup, reset it's rootUUID.
            tabs[fromIndex].rootUUID = UUID().uuidString
        }

        tabs.rearrange(from: fromIndex, to: toIndex)

        if notify {
            updateAllTabDataAndSendNotifications(notify: true)
        }

        preserveTabs()
    }

    // TODO: make this function private
    internal func updateAllTabDataAndSendNotifications(notify: Bool) {
        // Handle the case of the selected tab needing to be archived. This can happen
        // if the app has been in the background for a while. In this case, we'll just
        // regard the tab as still being active to avoid the selected tab disappearing.
        if let selectedTab = selectedTab, selectedTab.shouldBeArchived {
            selectedTab.lastExecutedTime = Date.nowMilliseconds()
        }

        // Determine if any of the active tabs should be converted to archived tabs.
        // Incognito tabs are never archived.
        let shouldBeArchivedCondition: (Tab) -> Bool = {
            !$0.isIncognito && $0.shouldBeArchived
        }
        let tabsToArchive = tabs.filter(shouldBeArchivedCondition)
        for tab in tabsToArchive {
            tab.closeWebView()
            // Discard tabIndex at this point. When restored, we'll simply append to activeTabs.
            archivedTabs.append(
                ArchivedTab(
                    savedTab: tab.saveSessionDataAndCreateSavedTab(isSelected: false, tabIndex: nil)
                ))
        }
        if !tabsToArchive.isEmpty {
            tabs.removeAll(where: shouldBeArchivedCondition)
        }

        // Re-build any tab groups.
        func generateTabGroups<TabType: GenericTab>(
            for tabs: [TabType], predicate: ([TabType]) -> Bool
        ) -> [String: GenericTabGroup<TabType>] {
            return tabs.reduce(into: [String: [TabType]]()) { dict, tab in
                dict[tab.rootUUID, default: []].append(tab)
            }
            .filter({ predicate($0.value) })
            .reduce(into: [String: GenericTabGroup<TabType>]()) { dict, element in
                dict[element.key] = .init(children: element.value, id: element.key)
            }
        }
        activeTabGroups = generateTabGroups(for: tabs) { tabs in
            tabs.count > 1
        }
        archivedTabGroups = generateTabGroups(for: archivedTabs) { tabs in
            // Allow groups of one in the archived set.
            tabs.count > 1 || Defaults[.tabGroupNames][tabs[0].rootUUID] != nil
        }
        updateTabGroupNames()

        if notify {
            tabsUpdatedPublisher.send()
        }

        storeChanges()
    }

    // Tab Group related functions
    func removeTabFromTabGroup(_ tab: Tab) {
        tab.rootUUID = UUID().uuidString
        updateAllTabDataAndSendNotifications(notify: true)
    }

    func getTabGroup(for rootUUID: String) -> TabGroup? {
        return activeTabGroups[rootUUID]
    }

    func getTabGroup(for tab: Tab) -> TabGroup? {
        return activeTabGroups[tab.rootUUID]
    }

    func closeTabGroup(_ item: TabGroup, showToast: Bool) {
        removeTabs(item.children, showToast: showToast)
    }

    private func updateTabGroupNames() {
        var temp = [String: String]()
        activeTabGroups.forEach { group in
            temp[group.key] = group.value.displayTitle
        }
        archivedTabGroups.forEach { group in
            temp[group.key] = group.value.displayTitle
        }
        Defaults[.tabGroupNames] = temp
    }

    static func makeWebViewConfig(isIncognito: Bool) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.phoneNumber]
        configuration.processPool = WKProcessPool()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = !Defaults[.blockPopups]
        // We do this to go against the configuration of the <meta name="viewport">
        // tag to behave the same way as Safari :-(
        configuration.ignoresViewportScaleLimits = true
        if isIncognito {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        configuration.setURLSchemeHandler(InternalSchemeHandler(), forURLScheme: InternalURL.scheme)

        return configuration
    }

    // MARK: - AddTab
    @discardableResult func addTabsForURLs(
        _ urls: [URL],
        zombie: Bool = true, shouldSelectTab: Bool = true, incognito: Bool = false,
        rootUUID: String? = nil
    ) -> [Tab] {
        assert(Thread.isMainThread)

        if urls.isEmpty {
            return []
        }

        var newTabs: [Tab] = []
        var config = TabConfig(flushToDisk: false, zombie: zombie)
        for url in urls {
            config.request = URLRequest(url: url)
            let createdTab = self.addTab(
                tabConfig: config,
                isIncognito: incognito,
                notify: false
            )
            newTabs.append(createdTab)
        }

        if let rootUUID = rootUUID {
            for tab in newTabs {
                tab.rootUUID = rootUUID
            }
        }

        self.updateAllTabDataAndSendNotifications(notify: false)

        // Select the most recent.
        if shouldSelectTab {
            selectTab(newTabs.last, notify: true)
        }

        // Okay now notify that we bulk-loaded so we can adjust counts and animate changes.
        tabsUpdatedPublisher.send()

        // Flush.
        storeChanges()

        return newTabs
    }

    @discardableResult
    func addTab(
        webViewConfig: WKWebViewConfiguration? = nil,
        tabConfig: TabConfig = .default,
        isIncognito: Bool = false,
        notify: Bool = true
    ) -> Tab {
        assert(Thread.isMainThread)

        // Take the given configuration. Or if it was nil, take our default configuration for the current browsing mode.
        let configuration: WKWebViewConfiguration =
            webViewConfig ?? (isIncognito ? incognitoConfiguration : self.configuration)

        let bvc = SceneDelegate.getBVC(with: scene)
        let tab = Tab(bvc: bvc, configuration: configuration, isIncognito: isIncognito)
        configureTab(
            tab,
            tabConfig: tabConfig,
            notify: notify
        )

        return tab
    }

    private func configureTab(
        _ tab: Tab,
        tabConfig: TabConfig = .default,
        notify: Bool
    ) {
        assert(Thread.isMainThread)

        // If network is not available webView(_:didCommit:) is not going to be called
        // We should set request url in order to show url in url bar even no network
        tab.setURL(tabConfig.request?.url)

        insertTab(
            tab,
            at: tabConfig.insertLocation,
            notify: notify
        )

        if let webView = tabConfig.webView {
            tab.restore(webView)
        } else if !tabConfig.zombie {
            tab.createWebview()
        }

        tab.navigationDelegate = self.navDelegate

        if let query = tabConfig.query {
            tab.queryForNavigation.currentQuery = .init(
                typed: query,
                suggested: tabConfig.suggestedQuery,
                location: tabConfig.queryLocation
            )
        }

        if let request = tabConfig.request {
            if let nav = tab.loadRequest(request),
                let visitType = tabConfig.visitType
            {
                tab.browserViewController?.recordNavigationInTab(
                    navigation: nav, visitType: visitType
                )
            }
        } else if !tabConfig.isPopup {
            let url = InternalURL.baseUrl / "about" / "home"
            tab.loadRequest(PrivilegedRequest(url: url) as URLRequest)
            tab.setURL(url)
        }

        if tabConfig.flushToDisk {
            storeChanges()
        }
    }

    private func insertTab(
        _ tab: Tab,
        at location: InsertTabLocation = .default,
        notify: Bool
    ) {
        if let index = location.index, index <= tabs.count {
            tabs.insert(tab, at: index)
        } else {
            var insertIndex: Int?

            // Add tab to be root of a tab group if it follows the rule for the nytimes case.
            // See TabGroupTests.swift for example.
            for possibleChildTab in tab.isIncognito ? incognitoTabs : normalTabs {
                if addTabToTabGroupIfNeeded(newTab: tab, possibleChildTab: possibleChildTab) {
                    guard let childTabIndex = tabs.firstIndex(of: possibleChildTab) else {
                        continue
                    }

                    // Insert the tab where the child tab is so it appears
                    // before it in the Tab Group.
                    insertIndex = childTabIndex
                    break
                }
            }

            if let insertIndex = insertIndex {
                tabs.insert(tab, at: insertIndex)
            } else {
                // If the tab wasn't made a parent of a tab group, move
                // it next to its parent if it has one.
                if let parent = location.parent,
                    var insertIndex = tabs.firstIndex(of: parent)
                {
                    insertIndex += 1
                    while insertIndex < tabs.count && tabs[insertIndex].isDescendentOf(parent) {
                        insertIndex += 1
                    }

                    if location.keepInParentTabGroup {
                        tab.rootUUID = parent.rootUUID
                    }

                    tabs.insert(tab, at: insertIndex)
                } else {
                    // Else just add it to the end of the tabs.
                    tabs.append(tab)
                }
            }

            if let parent = location.parent {
                tab.parent = parent
                tab.parentUUID = parent.tabUUID
            }
        }

        if notify {
            updateAllTabDataAndSendNotifications(notify: notify)
        }
    }

    func duplicateTab(_ tab: Tab, incognito: Bool) {
        guard let url = tab.url else { return }
        let newTab = addTab(
            tabConfig: .init(
                request: URLRequest(url: url),
                insertLocation: InsertTabLocation(parent: incognito ? nil : tab)
            ),
            isIncognito: incognito
        )
        selectTab(newTab, notify: true)
    }

    // MARK: Tab Groups
    /// Checks if the new tab URL matches the origin URL for the tab and if so,
    /// then the two tabs should be in a Tab Group together.
    @discardableResult func addTabToTabGroupIfNeeded(
        newTab: Tab, possibleChildTab: Tab
    ) -> Bool {
        guard
            let childTabInitialURL = possibleChildTab.initialURL,
            let newTabURL = newTab.url
        else {
            return false
        }

        let options: [URL.EqualsOption] = [
            .normalizeHost, .ignoreFragment, .ignoreLastSlash, .ignoreScheme,
        ]
        let shouldCreateTabGroup = childTabInitialURL.equals(newTabURL, with: options)

        /// TODO: To make this more effecient, we should refactor `TabGroupManager`
        /// to be apart of `TabManager`. That we can quickly check if the ChildTab is in a Tab Group.
        /// See #3088 + #3098 for more info.
        let childTabIsInTabGroup: Bool = {
            let tabs = tabs.filter { $0 != possibleChildTab }
            for tab in tabs where tab.rootUUID == possibleChildTab.rootUUID {
                return true
            }

            return false
        }()

        if shouldCreateTabGroup {
            if !childTabIsInTabGroup {
                // Create a Tab Group by setting the child tab's rootID.
                possibleChildTab.rootUUID = newTab.rootUUID
            } else {
                // Set the new tab's root ID the same as the current tab,
                // since they should both be in the same Tab Group.
                newTab.rootUUID = possibleChildTab.rootUUID
            }
        }

        return shouldCreateTabGroup
    }

    // MARK: Restore Tabs
    @discardableResult func restoreSavedTabs(
        _ savedTabs: [SavedTab], isIncognito: Bool = false, shouldSelectTab: Bool = true,
        overrideSelectedTab: Bool = false
    ) -> Tab? {
        // makes sure at least one tab is selected
        // if no tab selected, select the last one (most recently closed)
        var restoredTabs = [Tab]()
        restoredTabs.reserveCapacity(savedTabs.count)

        for index in savedTabs.indices {
            let savedTab = savedTabs[index]
            let urlRequest: URLRequest? = savedTab.url != nil ? URLRequest(url: savedTab.url!) : nil

            var tab: Tab
            var config = TabConfig(request: urlRequest, flushToDisk: false, zombie: true)
            if let tabIndex = savedTab.tabIndex {
                config.insertLocation.index = tabIndex
            } else {
                config.insertLocation.parent = getTabForUUID(uuid: savedTab.parentUUID ?? "")
            }
            tab = addTab(
                tabConfig: config,
                isIncognito: isIncognito,
                notify: false
            )

            savedTab.configureTab(tab, imageStore: store.imageStore)

            restoredTabs.append(tab)
        }

        // Select the last restored tab that was selected,
        // if none of the restored tabs was selected, select the last restored tab
        var selectedSavedTab: Tab?
        if let restoredSelectedTabIndex = savedTabs.lastIndex(where: { $0.isSelected }) {
            selectedSavedTab = restoredTabs[restoredSelectedTabIndex]
        } else if let lastTab = restoredTabs.last {
            selectedSavedTab = lastTab
        }

        resolveParentRef(for: restoredTabs, restrictToActiveTabs: true)

        // Prevents a sticky tab tray
        SceneDelegate.getBVC(with: scene).browserModel.cardTransitionModel.update(to: .hidden)

        if let selectedSavedTab = selectedSavedTab, shouldSelectTab,
            selectedTab == nil || overrideSelectedTab
        {
            self.selectTab(selectedSavedTab, notify: true)
        }

        // remove all tabs in `savedTabs` from `recentlyClosedTabs` and clean up any empty collections
        let tabsToFilter = Set(savedTabs)
        recentlyClosedTabs = recentlyClosedTabs.compactMap { group -> [SavedTab]? in
            let filteredGroup = group.filter { tab in
                // this test compares by `Hashable` protocol
                !tabsToFilter.contains(tab)
            }
            guard !filteredGroup.isEmpty else {
                return nil
            }
            return filteredGroup
        }

        closedTabsToShowToastFor.removeAll { tabsToFilter.contains($0) }
        updateAllTabDataAndSendNotifications(notify: true)

        return selectedSavedTab
    }

    func restoreAllClosedTabs() {
        restoreSavedTabs(recentlyClosedTabsFlattened)
    }

    @discardableResult
    func restore(savedTab: SavedTab, resolveParentRef: Bool = true) -> Tab {
        // Provide an empty request to prevent a new tab from loading the home screen.
        // NOTE: tabIndex is ignored here as tabs are assumed to be saved in the order
        // they should be re-inserted.
        let tab = addTab(
            tabConfig: .init(flushToDisk: false, zombie: true),
            isIncognito: savedTab.isIncognito,
            notify: false)
        savedTab.configureTab(tab, imageStore: store.imageStore)
        if resolveParentRef {
            self.resolveParentRef(for: [tab])
        }
        // Do not attempt to open Universal Links until the user has done a manual navigation.
        tab.shouldOpenUniversalLinks = false
        return tab
    }

    func resolveParentRef(for restoredTabs: [Tab], restrictToActiveTabs: Bool = false) {
        let tabs = restrictToActiveTabs ? self.activeTabs : self.tabs
        let uuidMapping = [String: Tab](
            uniqueKeysWithValues: zip(tabs.map { $0.tabUUID }, tabs)
        )

        restoredTabs.forEach { tab in
            guard let parentUUID = tab.parentUUID,
                UUID(uuidString: parentUUID) != nil
            else {
                return
            }
            tab.parent = uuidMapping[parentUUID]
        }
    }

    // MARK: - CloseTabs
    /// - Parameters:
    ///     - selectTabPreferring preference: Preference for how the new tab should be picked. pass `nil` to not select a new tab
    func removeTab(
        _ tab: Tab?,
        showToast: Bool = false,
        selectTabPreferring preference: PreferredSelectTabTarget = .noPreference
    ) {
        guard let tab = tab else {
            return
        }

        // The index of the removed tab w.r.s to the normalTabs/incognitoTabs is
        // calculated in advance, and later used for finding rightOrLeftTab. In time-based
        // switcher, the normalTabs get filtered to make sure we only select tab in
        // today section.
        let normalTabsToday = normalTabs.filter {
            $0.isIncluded(in: .today)
        }

        let index =
            tab.isIncognito
            ? incognitoTabs.firstIndex(where: { $0 == tab })
            : normalTabsToday.firstIndex(where: { $0 == tab })

        addTabsToRecentlyClosed([tab], showToast: showToast)
        removeTab(tab, flushToDisk: true, notify: true)

        if (selectedTab?.isIncognito ?? false) == tab.isIncognito,
            preference.shouldSelect
        {
            updateSelectedTabAfterRemovalOf(
                tab,
                deletedIndex: index,
                with: preference,
                notify: true
            )
        }
    }

    func removeTabs(
        _ tabsToBeRemoved: [Tab],
        showToast: Bool = true,
        updateSelectedTab: Bool = true,
        dontAddToRecentlyClosed: Bool = false,
        notify: Bool = true
    ) {
        guard tabsToBeRemoved.count > 0 else {
            return
        }

        if !dontAddToRecentlyClosed {
            addTabsToRecentlyClosed(tabsToBeRemoved, showToast: showToast)
        }

        let lastTab = tabsToBeRemoved[tabsToBeRemoved.count - 1]
        let lastTabIndex = tabs.firstIndex(of: lastTab)
        let tabsToKeep = self.tabs.filter { !tabsToBeRemoved.contains($0) }
        self.tabs = tabsToKeep

        tabsToBeRemoved.forEach { tab in
            removeTab(tab, flushToDisk: false, notify: false)
        }

        if let lastTabIndex = lastTabIndex, updateSelectedTab {
            updateSelectedTabAfterRemovalOf(lastTab, deletedIndex: lastTabIndex, notify: true)
        }

        updateAllTabDataAndSendNotifications(notify: notify)
        storeChanges()
    }

    /// Removes the tab from TabManager, alerts delegates, and stores data.
    /// - Parameter notify: if set to true, will call the delegate after the tab
    ///   is removed.
    private func removeTab(_ tab: Tab, flushToDisk: Bool, notify: Bool) {
        guard let removalIndex = tabs.firstIndex(where: { $0 === tab }) else {
            log.error("Could not find index of tab to remove, tab count: \(count)")
            return
        }

        tabs.remove(at: removalIndex)
        tab.closeWebView()

        tabs.forEach {
            if $0.parent == tab {
                $0.parent = nil
            }
        }

        if tab.isIncognito && incognitoTabs.count < 1 {
            incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
        }

        if notify {
            TabEvent.post(.didClose, for: tab)
            updateAllTabDataAndSendNotifications(notify: notify)
        }

        if flushToDisk {
            storeChanges()
        }
    }

    private func updateSelectedTabAfterRemovalOf(
        _ tab: Tab,
        deletedIndex: Int?,
        with targetPreference: PreferredSelectTabTarget = .noPreference,
        notify: Bool
    ) {
        guard targetPreference.shouldSelect else {
            return
        }
        // Check that there are viable tab targets

        // Based on if the closed tab is incognito, create an ordered set of viable tabs
        // In time-based switcher, the we only selected tabs in the `Today` section
        let viableTabs: [Tab] =
            tab.isIncognito
            ? incognitoTabs
            : normalTabs.filter {
                $0.isIncluded(in: [.pinned, .today])
            }

        // If the currently selected tab is still a viable selection target, no work needs to be done
        if let selectedTab = selectedTab,
            viableTabs.contains(selectedTab)
        {
            return
        }

        let bvc = SceneDelegate.getBVC(with: scene)
        // If no viable tabs are left, show tab grid
        guard !viableTabs.isEmpty else {
            DispatchQueue.main.async {
                self.selectTab(nil, notify: notify)
                bvc.browserModel.showGridWithNoAnimation()
            }
            return
        }

        // Perform selection by prioritizing preference
        var tabToSelect: Tab?

        switch targetPreference {
        case .parent:
            // Select parent without recency or pinned checks
            // allow selecting parent tabs from not `Today` section
            let availableTabs = tab.isIncognito ? incognitoTabs : normalTabs
            if let parentTab = tab.parent,
                parentTab != tab,
                availableTabs.contains(parentTab)
            {
                tabToSelect = parentTab
            }
        case .mostRecent:
            // Select most recent tab without checking parent
            tabToSelect = mostRecentTab(inTabs: viableTabs) ?? viableTabs.last
        case .noPreference:
            // Default flow
            // Select parent tab if it is most recent or pinned
            // else select adjacent tab (prefer higher index) in viable tabs
            // else select most recent or last viable tab
            if let parentTab = tab.parent,
                parentTab != tab,
                mostRecentTab(inTabs: viableTabs) == parentTab || parentTab.isPinned
            {
                tabToSelect = parentTab
            } else if let deletedIndex = deletedIndex,
                let adjacentTab = viableTabs[safe: deletedIndex]
                    ?? viableTabs[safe: deletedIndex - 1]
            {
                tabToSelect = adjacentTab
            } else {
                tabToSelect = mostRecentTab(inTabs: viableTabs) ?? viableTabs.last
            }
        default:
            break
        }

        // Perform selection
        if let tabToSelect = tabToSelect {
            selectTab(tabToSelect, previous: selectedTab, notify: notify)
        } else {
            selectTab(nil, notify: notify)
            bvc.browserModel.showGridWithNoAnimation()
        }
    }

    // MARK: Remove All Tabs
    func removeAllTabs() {
        removeTabs(tabs, showToast: false)
    }

    // This function is strictly used for clearing all Incognito
    // tabs after the user exits Incognito Mode (if this behavior
    // is set in Preferences).
    func removeAllIncognitoTabs() {
        // Clear the list of Desktop Mode sites that is saved in memory.
        Tab.ChangeUserAgent.incognitoModeHostList.removeAll()

        removeTabs(incognitoTabs)
        incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
    }

    /// If the user has the `closeIncognitoTabs` enabled, delete all incognito tabs.
    /// Used when toggling out of incognito mode, or selecting a normal tab.
    func removeAllIncognitoTabsForLeavingIncognitoMode(previousWasIncognito: Bool) {
        if Defaults[.closeIncognitoTabs], !isIncognito, previousWasIncognito {
            removeAllIncognitoTabs()
        }
    }

    // MARK: Recently Closed Tabs
    func getRecentlyClosedTabForURL(_ url: URL) -> SavedTab? {
        assert(Thread.isMainThread)
        return recentlyClosedTabsFlattened.filter({ $0.url == url }).first
    }

    func addTabsToRecentlyClosed(_ tabs: [Tab], showToast: Bool) {
        // Avoid remembering incognito tabs.
        let tabs = tabs.filter { !$0.isIncognito }
        if tabs.isEmpty {
            return
        }

        let savedTabs = tabs.map {
            $0.saveSessionDataAndCreateSavedTab(
                isSelected: selectedTab === $0, tabIndex: self.tabs.firstIndex(of: $0))
        }

        if recentlyClosedTabGroupTimer?.isValid ?? false, recentlyClosedTabs.count > 0 {
            recentlyClosedTabs[0].append(contentsOf: savedTabs)
        } else {
            recentlyClosedTabs.insert(savedTabs, at: 0)
        }

        if showToast {
            closedTabsToShowToastFor.append(contentsOf: savedTabs)
        }

        recentlyClosedTabGroupTimer?.invalidate()
        recentlyClosedTabGroupTimer = Timer.scheduledTimer(
            withTimeInterval: recentlyClosedTabGroupTimerDuration, repeats: false,
            block: { _ in
                if self.closedTabsToShowToastFor.count > 0 {
                    ToastDefaults().showToastForClosedTabs(
                        self.closedTabsToShowToastFor, tabManager: self)
                    self.closedTabsToShowToastFor.removeAll()
                }
            }
        )
    }

    // MARK: Zombie Tabs
    /// Turns all but the newest x Tabs into Zombie Tabs.
    func makeTabsIntoZombies(tabsToKeepAlive: Int = 10) {
        // Filter tabs for each Scene
        let tabs = tabs.sorted {
            $0.lastExecutedTime > $1.lastExecutedTime
        }

        tabs.enumerated().forEach { index, tab in
            if tab != selectedTab, index >= tabsToKeepAlive {
                tab.closeWebView()
            }
        }
    }

    /// Used when the user logs out. Clears any Neeva tabs so they are logged out there too.
    func clearNeevaTabs() {
        let neevaTabs = tabs.filter { $0.url?.isNeevaURL() ?? false }
        neevaTabs.forEach { tab in
            if tab == selectedTab {
                tab.reload()
            } else {
                tab.closeWebView()
            }

            // Clear the tab's screenshot by setting it to nil.
            // Will be erased from memory when `storeChanges` is called.
            tab.setScreenshot(nil)
        }
    }

    // MARK: Blank Tabs
    /// Removes any tabs with the location `about:blank`. Seen when clicking web links that open native apps.
    func removeBlankTabs() {
        removeTabs(tabs.filter { $0.url == URL.aboutBlank }, showToast: false)
    }

    // MARK: - CreateOrSwitchToTab
    enum CreateOrSwitchToTabResult {
        case createdNewTab
        case switchedToExistingTab
    }

    @discardableResult func createOrSwitchToTab(
        for url: URL,
        query: String? = nil, suggestedQuery: String? = nil,
        visitType: VisitType? = nil,
        from parentTab: Tab? = nil,
        keepInParentTabGroup: Bool = true
    )
        -> CreateOrSwitchToTabResult
    {
        if let tab = selectedTab {
            ScreenshotHelper(controller: SceneDelegate.getBVC(with: scene)).takeScreenshot(tab)
        }

        if let existingTab = getTabFor(url, with: keepInParentTabGroup ? parentTab : nil) {
            selectTab(existingTab, notify: true)
            existingTab.browserViewController?
                .postLocationChangeNotificationForTab(existingTab, visitType: visitType)

            return .switchedToExistingTab
        } else {
            let config = TabConfig(
                request: URLRequest(url: url),
                insertLocation: InsertTabLocation(
                    parent: parentTab,
                    keepInParentTabGroup: keepInParentTabGroup
                ),
                flushToDisk: true,
                zombie: false,
                query: query,
                suggestedQuery: suggestedQuery,
                visitType: visitType
            )
            let newTab = addTab(
                tabConfig: config,
                isIncognito: isIncognito
            )
            selectTab(newTab, notify: true)

            return .createdNewTab
        }
    }

    @discardableResult func createOrSwitchToTabForSpace(for url: URL, spaceID: String)
        -> CreateOrSwitchToTabResult
    {
        if let tab = selectedTab {
            ScreenshotHelper(controller: SceneDelegate.getBVC(with: scene)).takeScreenshot(tab)
        }

        if let existingTab = getTabFor(url) {
            existingTab.parentSpaceID = spaceID
            existingTab.rootUUID = spaceID
            selectTab(existingTab, notify: true)
            return .switchedToExistingTab
        } else {
            let newTab = addTab(
                tabConfig: .init(
                    request: URLRequest(url: url), flushToDisk: true, zombie: false
                ),
                isIncognito: isIncognito
            )
            newTab.parentSpaceID = spaceID
            newTab.rootUUID = spaceID
            selectTab(newTab, notify: true)
            updateAllTabDataAndSendNotifications(notify: true)
            return .createdNewTab
        }
    }

    // MARK: - TabEventHandler
    func tab(_ tab: Tab, didLoadFavicon favicon: Favicon?, with: Data?) {
        // Write the tabs out again to make sure we preserve the favicon update.
        store.preserveTabs(
            tabs, archivedTabs: archivedTabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)
    }

    func tabDidChangeContentBlocking(_ tab: Tab) {
        tab.reload()
    }

    // MARK: - TabStorage
    func preserveTabs() {
        store.preserveTabs(
            tabs, archivedTabs: archivedTabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)
    }

    func storeChanges() {
        saveTabs(toProfile: profile, normalTabs)
        store.preserveTabs(
            tabs, archivedTabs: archivedTabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)
    }

    private func hasTabsToRestoreAtStartup() -> Bool {
        return store.getStartupTabs(for: scene).count > 0
    }

    private func saveTabs(toProfile profile: Profile, _ tabs: [Tab]) {
        // It is possible that not all tabs have loaded yet, so we filter out tabs with a nil URL.
        let storedTabs: [RemoteTab] = tabs.compactMap(Tab.toRemoteTab)

        // Don't insert into the DB immediately. We tend to contend with more important
        // work like querying for top sites.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            profile.storeTabs(storedTabs)
        }
    }

    /// - Returns: Returns a bool of whether a tab was selected.
    func restoreTabs(_ forced: Bool = false) -> Bool {
        log.info("Restoring tabs")

        guard forced || count == 0, !AppConstants.IsRunningTest, hasTabsToRestoreAtStartup()
        else {
            log.info("Skipping tab restore")
            tabsUpdatedPublisher.send()
            return false
        }

        let tabToSelect = store.restoreStartupTabs(
            for: scene, clearIncognitoTabs: Defaults[.closeIncognitoTabs], tabManager: self)

        if var tabToSelect = tabToSelect {
            selectTab(tabToSelect, notify: true)
        }

        updateAllTabDataAndSendNotifications(notify: true)

        return tabToSelect != nil
    }

    // MARK: - Pinned Tabs
    func toggleTabPinnedState(_ tab: Tab) {
        tab.pinnedTime =
            (tab.isPinned ? nil : Date().timeIntervalSinceReferenceDate)
        tab.isPinned.toggle()

        tabsUpdatedPublisher.send()
        storeChanges()
    }

    func handleAsNavigationFromPinnedTabIfNeeded(tab: Tab, url: URL) {
        let options: [URL.EqualsOption] = [
            .normalizeHost, .ignoreFragment, .ignoreLastSlash, .ignoreScheme,
        ]

        if tab.isPinned,
            !(tab.backList?.first?.url.equals(url, with: options) ?? false),
            !(tab.url?.equals(url, with: options) ?? false),
            !(InternalURL(tab.url)?.isSessionRestore ?? false),
            !(InternalURL(url)?.isSessionRestore ?? false)
        {
            handleNavigationFromPinnedTab(tab)
        }
    }

    private func handleNavigationFromPinnedTab(_ tab: Tab) {
        guard FeatureFlag[.pinnedTabImprovments] else {
            return
        }

        let tabIndex = tabs.firstIndex(of: tab)

        // Create a new placeholder tab to represent the pinned tab.
        // Should be a zombie with the same session data as
        // the original pinned tab before it navigated.
        let newPinnedTab = addTab(
            tabConfig: .init(
                insertLocation: InsertTabLocation(index: tabIndex),
                flushToDisk: true,
                zombie: true
            )
        )
        let savedTab = tab.saveSessionDataAndCreateSavedTab(
            isSelected: false, tabIndex: tabIndex, isForPinnedTabPlaceholder: true)
        savedTab.configureTab(newPinnedTab, imageStore: store.imageStore)
        newPinnedTab.updateCanGoBackForward()

        // Reset the navigated tab (the original pinned tabs) data.
        tab.tabUUID = UUID().uuidString
        tab.parent = newPinnedTab
        tab.parentUUID = newPinnedTab.tabUUID
        tab.parentSpaceID = ""
        tab.pinnedTime = nil
        tab.isPinned = false
        tab.updateCanGoBackForward()

        // Update the other children with the new parent.
        tabs.forEach {
            if $0.parentUUID ?? "" == newPinnedTab.tabUUID {
                $0.parent = newPinnedTab
            }
        }

        updateAllTabDataAndSendNotifications(notify: true)
    }

    // MARK: - TabStats
    struct TabStats {
        let numberOfActiveNonZombieTabs: Int
        let numberOfActiveZombieTabs: Int
        let numberOfArchivedTabs: Int

        fileprivate init(
            numberOfActiveNonZombieTabs: Int, numberOfActiveZombieTabs: Int,
            numberOfArchivedTabs: Int
        ) {
            self.numberOfActiveNonZombieTabs = numberOfActiveNonZombieTabs
            self.numberOfActiveZombieTabs = numberOfActiveZombieTabs
            self.numberOfArchivedTabs = numberOfArchivedTabs
        }
    }

    func getTabStats() -> TabStats {
        let numberOfZombieTabs = activeTabs.filter({ $0.webView == nil }).count

        return TabStats(
            numberOfActiveNonZombieTabs: activeTabs.count - numberOfZombieTabs,
            numberOfActiveZombieTabs: numberOfZombieTabs,
            numberOfArchivedTabs: archivedTabs.count
        )
    }

    // MARK: - WKNavigationDelegate
    // Note the main frame JSContext (i.e. document, window) is not available yet.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Save stats for the page we are leaving.
        if let tab = self[webView], let blocker = tab.contentBlocker, let url = tab.url {
            blocker.pageStatsCache[url] = blocker.stats
        }
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        // Clear stats for the page we are newly generating.
        if navigationResponse.isForMainFrame, let tab = self[webView],
            let blocker = tab.contentBlocker, let url = navigationResponse.response.url
        {
            blocker.pageStatsCache[url] = nil
        }
        decisionHandler(.allow)
    }

    // The main frame JSContext is available, and DOM parsing has begun.
    // Do not excute JS at this point that requires running prior to DOM parsing.
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let tab = self[webView] else { return }

        tab.hasContentProcess = true

        if let url = webView.url, let blocker = tab.contentBlocker {
            // Initialize to the cached stats for this page. If the page is being fetched
            // from WebKit's page cache, then this will pick up stats from when that page
            // was previously loaded. If not, then the cached value will be empty.
            blocker.stats = blocker.pageStatsCache[url] ?? TPPageStats()
            if !blocker.isEnabled {
                webView.evaluateJavascriptInDefaultContentWorld(
                    "window.__firefox__.TrackingProtectionStats.setEnabled(false, \(UserScriptManager.appIdToken))"
                )
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let pageZoom = selectedTab?.pageZoom,
            webView.value(forKey: "viewScale") as? CGFloat != pageZoom
        {
            // Trigger the didSet hook
            selectedTab?.pageZoom = pageZoom
        }

        // tab restore uses internal pages, so don't call storeChanges unnecessarily on startup
        if let url = webView.url {
            if let internalUrl = InternalURL(url), internalUrl.isSessionRestore {
                return
            }

            // When the Tab has done its first non-internal navigation, it's OK to open Universal Links.
            selectedTab?.shouldOpenUniversalLinks = true
            storeChanges()
        }
    }

    /// Called when the WKWebView's content process has gone away. If this happens for the currently selected tab
    /// then we immediately reload it.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard let tab = self[webView] else { return }

        tab.hasContentProcess = false

        if tab == selectedTab {
            tab.consecutiveCrashes += 1

            // Only automatically attempt to reload the crashed
            // tab three times before giving up.
            if tab.consecutiveCrashes < 3 {
                webView.reload()
            } else {
                tab.consecutiveCrashes = 0
            }
        }
    }
}

// WKNavigationDelegates must implement NSObjectProtocol
class TabManagerNavDelegate: NSObject, WKNavigationDelegate {
    fileprivate var delegates = WeakList<WKNavigationDelegate>()

    func insert(_ delegate: WKNavigationDelegate) {
        delegates.insert(delegate)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didCommit: navigation)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)"), error: \(error)")

        for delegate in delegates {
            delegate.webView?(webView, didFail: navigation, withError: error)
        }
    }

    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)"), error: \(error)")

        for delegate in delegates {
            delegate.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didFinish: navigation)
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webViewWebContentProcessDidTerminate?(webView)
        }
    }

    func webView(
        _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        let authenticatingDelegates = delegates.filter { wv in
            return wv.responds(to: #selector(webView(_:didReceive:completionHandler:)))
        }

        guard let firstAuthenticatingDelegate = authenticatingDelegates.first else {
            return completionHandler(.performDefaultHandling, nil)
        }

        firstAuthenticatingDelegate.webView?(webView, didReceive: challenge) {
            (disposition, credential) in
            completionHandler(disposition, credential)
        }
    }

    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didStartProvisionalNavigation: navigation)
        }
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        Logger.network.info(
            "webView.url: \(webView.url?.absoluteString ?? "(nil)"), request.url: \(navigationAction.request.url?.absoluteString ?? "(nil)"), isMainFrame: \(navigationAction.targetFrame?.isMainFrame.description ?? "(nil)")"
        )

        var res = WKNavigationActionPolicy.allow
        for delegate in delegates {
            delegate.webView?(
                webView, decidePolicyFor: navigationAction,
                decisionHandler: { policy in
                    if policy == .cancel {
                        res = policy
                    }
                })
        }
        decisionHandler(res)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        Logger.network.info(
            "webView.url: \(webView.url ?? "(nil)"), response.url: \(navigationResponse.response.url ?? "(nil)"), isMainFrame: \(navigationResponse.isForMainFrame)"
        )

        var res = WKNavigationResponsePolicy.allow
        for delegate in delegates {
            delegate.webView?(
                webView, decidePolicyFor: navigationResponse,
                decisionHandler: { policy in
                    if policy == .cancel {
                        res = policy
                    }
                })
        }

        decisionHandler(res)
    }
}

// MARK: Archived Tabs
extension TabManager {
    func select(archivedTab: ArchivedTab) {
        if let index = archivedTabs.firstIndex(where: { $0 === archivedTab }) {
            archivedTabs.remove(at: index)
        }
        selectTab(restore(savedTab: archivedTab.savedTab), notify: true)
    }

    func restore(archivedTabGroup: ArchivedTabGroup) {
        var restoredTabs: [Tab] = []

        for tab in archivedTabGroup.children {
            // Individually restore each tab so we can update the lastExecutedTime.
            let restoredTab = restore(savedTab: tab.savedTab)
            restoredTab.lastExecutedTime = Date.nowMilliseconds()
            restoredTabs.append(restoredTab)
        }

        if let tabToSelect = restoredTabs.first {
            selectTab(tabToSelect, notify: true)
        }

        remove(archivedTabGroup: archivedTabGroup)
    }

    func remove(archivedTabs toBeRemoved: [ArchivedTab]) {
        archivedTabs = archivedTabs.filter { !toBeRemoved.contains($0) }
        updateAllTabDataAndSendNotifications(notify: true)
    }

    func remove(archivedTabGroup: ArchivedTabGroup) {
        remove(archivedTabs: archivedTabGroup.children)
    }

    func add(archivedTab: ArchivedTab) {
        archivedTabs.append(archivedTab)
    }

    func debugArchiveAllTabs() {
        // Very intentionally just change the lastExecutedTime here to simulate enough
        // time passing to cause all tabs to appear as though they should be archived.
        // Don't update anything else so we can use this as a way to test out how the
        // code handles this scenario.
        tabs.forEach { $0.lastExecutedTime = 0 }
        updateAllTabDataAndSendNotifications(notify: true)
    }
}

// MARK: Testing support
extension TabManager {
    convenience init(
        profile: Profile, imageStore: DiskImageStore?
    ) {
        assert(AppConstants.IsRunningTest)
        assert(Thread.isMainThread)

        let scene = SceneDelegate.getCurrentScene(for: nil)
        let incognitoModel = IncognitoModel(isIncognito: false)
        self.init(profile: profile, scene: scene, incognitoModel: incognitoModel)
    }

    func countTabsOnDiskForTesting() -> Int {
        assert(AppConstants.IsRunningTest)
        return store.countTabsOnDiskForTesting(sceneId: SceneDelegate.getCurrentSceneId(for: nil))
    }

    func countRestoredTabsForTesting() -> Int {
        assert(AppConstants.IsRunningTest)
        return store.getStartupTabs(for: SceneDelegate.getCurrentScene(for: nil)).count
    }

    // TODO(jon): Find a way to test the prod version of this function
    // (`restoreTabs(_:) instead.
    func restoreTabsForTesting() {
        assert(AppConstants.IsRunningTest)
        _ = store.restoreStartupTabs(
            for: SceneDelegate.getCurrentScene(for: nil),
            clearIncognitoTabs: false,
            tabManager: self
        )
        updateAllTabDataAndSendNotifications(notify: true)
    }

    func clearArchiveForTesting() {
        assert(AppConstants.IsRunningTest)
        store.clearArchive(for: SceneDelegate.getCurrentScene(for: nil))
    }

    func configureTabForTesting(_ tab: Tab, afterTab parent: Tab? = nil) {
        assert(AppConstants.IsRunningTest)

        var config: TabConfig = .default
        config.request = URLRequest(url: tab.url!)
        config.insertLocation.parent = parent
        config.flushToDisk = false
        config.zombie = false

        configureTab(
            tab,
            tabConfig: config,
            notify: true
        )
    }
}
