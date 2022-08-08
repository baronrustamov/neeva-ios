/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Foundation
import Shared
import Storage
import SwiftyJSON
import WebKit

private let log = Logger.browser

func mostRecentTab(inTabs tabs: [Tab]) -> Tab? {
    var recent = tabs.first
    tabs.forEach { tab in
        if let time = tab.lastExecutedTime, time > (recent?.lastExecutedTime ?? 0) {
            recent = tab
        }
    }
    return recent
}

protocol TabContentScript {
    static func name() -> String
    func scriptMessageHandlerName() -> String?
    func userContentController(didReceiveScriptMessage message: WKScriptMessage)
}

@objc
protocol TabDelegate {
    func tab(_ tab: Tab, didSelectFindInPageForSelection selection: String)
    func tab(_ tab: Tab, didSelectAddToSpaceForSelection selection: String)
    func tab(_ tab: Tab, didSelectSearchWithNeevaForSelection selection: String)
    @objc optional func tab(_ tab: Tab, didCreateWebView webView: WKWebView)
    @objc optional func tab(_ tab: Tab, willDeleteWebView webView: WKWebView)
}

public enum TabSection: String, CaseIterable {
    case all = "All"
    case pinned = "Pinned"
    case today = "Today"
    case yesterday = "Yesterday"
    case lastWeek = "Past 7 Days"
    case lastMonth = "Past 30 Days"
    case overAMonth = "Older"
}

class Tab: NSObject, ObservableObject {
    let isIncognito: Bool
    @Published var isPinned: Bool = false
    var pinnedTime: TimeInterval?

    // PageMetadata is derived from the page content itself, and as such lags behind the
    // rest of the tab.
    var pageMetadata: PageMetadata?

    var hasContentProcess: Bool = false
    var consecutiveCrashes: UInt = 0

    var tabUUID: String = UUID().uuidString

    var canonicalURL: URL? {
        if let siteURL = pageMetadata?.siteURL {
            // If the canonical URL from the page metadata doesn't contain the
            // "#" fragment, check if the tab's URL has a fragment and if so,
            // append it to the canonical URL.
            if siteURL.fragment == nil,
                let fragment = self.url?.fragment,
                let siteURLWithFragment = URL(string: "\(siteURL.absoluteString)#\(fragment)")
            {
                return siteURLWithFragment
            }

            return siteURL
        }
        return self.url
    }

    var userActivity: NSUserActivity?

    private(set) var webView: WKWebView?

    var tabDelegate: TabDelegate?
    /// This set is cleared out when the tab is closed, ensuring that any subscriptions are invalidated.
    var webViewSubscriptions: Set<AnyCancellable> = []
    private var subscriptions: Set<AnyCancellable> = []

    @Published var favicon: Favicon?

    var lastExecutedTime: Timestamp?
    var sessionData: SessionData?
    fileprivate var lastRequest: URLRequest?
    var restoring: Bool = false
    var needsReloadUponSelect = false
    var shouldPerformHeavyUpdatesUponSelect = true

    @Published private(set) var canGoBack = false
    @Published private(set) var canGoForward = false

    // MARK: Properties mirrored from webView
    @Published private(set) var isLoading = false
    @Published private(set) var estimatedProgress: Double = 0
    @Published var title: String?
    /// For security reasons, the URL may differ from the web view’s URL.
    @Published var url: URL?
    @Default(.archivedTabsDuration) var archivedTabsDuration
    private var webViewCanGoBack = false {
        didSet {
            updateCanGoBack()
        }
    }
    private var webViewCanGoForward = false {
        didSet {
            updateCanGoForward()
        }
    }

    private var observer: AnyCancellable?
    var pageZoom: CGFloat = 1.0 {
        didSet {
            webView?.setValue(pageZoom, forKey: "viewScale")
        }
    }

    // MARK: - Cheatsheet Properties
    /// Cheatsheet info for current url
    lazy private(set) var cheatsheetModel: CheatsheetMenuViewModel = {
        CheatsheetMenuViewModel(tab: self, service: CheatsheetServiceProvider.shared)
    }()

    /// Called by BVC TabDelegate, updates the URL whenever it changes in the `WebView`.
    func setURL(_ newValue: URL?) {
        if let internalUrl = InternalURL(newValue), internalUrl.isAuthorized {
            url = internalUrl.stripAuthorization
        } else {
            url = newValue
        }

        updateCanGoBackForward()
    }

    // MARK: - Navigation Properties
    /// URL of the initial page opened in this Tab
    var initialURL: URL? {
        // Using `.url` here rather than `.initialURL` since the latter can be an
        // "internal://local/sessionrestore?history=..." URL. For newly created
        // tabs, checking `.initialURL` might still be interesting to better handle
        // redirect scenarios, but this approach will be more consistent across
        // restarts of the app.
        if let initialURL = backList?.first?.url {
            // Check if this is a session restore URL and if so, then extract the real
            // URL from the parameter.
            if let nestedURL = InternalURL.unwrapSessionRestore(url: initialURL) {
                return nestedURL
            }
            return initialURL
        }
        // Fallback to reading from `sessionData` when `webView` is not loaded yet.
        return sessionData?.initialUrl
    }
    var queryForNavigation: QueryForNavigation = QueryForNavigation()
    var backList: [WKBackForwardListItem]? { webView?.backForwardList.backList }
    var forwardList: [WKBackForwardListItem]? { webView?.backForwardList.forwardList }

    var isEditing: Bool = false

    // When viewing a non-HTML content type in the webview (like a PDF document), this var will
    // be non-nil and hold a reference to a tempfile containing the downloaded content so it can
    // be shared to external applications.
    var temporaryDocument: TemporaryDocument?
    // During navigation, the instance is held in a provisional state here, and only promoted to
    // the above var when navigation commits.
    var provisionalTemporaryDocument: TemporaryDocument?

    var contentBlocker: NeevaTabContentBlocker?

    /// The last title shown by this tab. Used by the tab tray to show titles for zombie tabs.
    var lastTitle: String?

    var changedUserAgentHasChanged = false

    /// Whether or not the desktop site was requested with the last request, reload or navigation.
    var changedUserAgent: Bool = false {
        didSet {
            if changedUserAgent != oldValue {
                changedUserAgentHasChanged = true
                TabEvent.post(.didToggleDesktopMode, for: self)
            }
        }
    }

    var showRequestDesktop: Bool {
        changedUserAgentHasChanged
            ? changedUserAgent
            : UIDevice.current.useTabletInterface
    }

    var readerModeAvailableOrActive: Bool {
        if let readerMode = self.getContentScript(name: "ReaderMode") as? ReaderMode {
            return readerMode.state != .unavailable
        }
        return false
    }

    var isArchived: Bool {
        if isPinned {
            return false
        }

        switch archivedTabsDuration {
        case .week:
            return
                !(isIncluded(in: .today)
                || isIncluded(in: .yesterday)
                || isIncluded(in: .lastWeek))
        case .month:
            return
                !(isIncluded(in: .today)
                || isIncluded(in: .yesterday)
                || isIncluded(in: .lastWeek)
                || isIncluded(in: .lastMonth))
        case .forever:
            return false
        }
    }

    fileprivate(set) var screenshot: UIImage?
    @Published var screenshotUUID: UUID?

    // If this tab has been opened from another, its parent will point to the tab from which it was opened
    weak var parent: Tab? {
        didSet {
            updateCanGoBack()
        }
    }
    var parentUUID: String? = nil
    var parentSpaceID: String? = nil

    // All tabs with the same `rootUUID` are considered part of the same group.
    var rootUUID: String = UUID().uuidString

    fileprivate var contentScriptManager = TabContentScriptManager()

    fileprivate let configuration: WKWebViewConfiguration

    /// Any time a tab tries to make requests to display a Javascript Alert and we are not the active
    /// tab instance, queue it for later until we become foregrounded.
    fileprivate var alertQueue = [JSAlertInfo]()

    weak var browserViewController: BrowserViewController?

    init(
        bvc: BrowserViewController, configuration: WKWebViewConfiguration, isIncognito: Bool = false
    ) {
        self.configuration = configuration
        // TODO(darin): Need to untangle this dependency on BVC!
        self.browserViewController = bvc
        self.tabDelegate = bvc
        self.isIncognito = isIncognito
        super.init()
    }

    class func toRemoteTab(_ tab: Tab) -> RemoteTab? {
        if tab.isIncognito {
            return nil
        }

        if let displayURL = tab.url?.displayURL, RemoteTab.shouldIncludeURL(displayURL) {
            let history = Array(tab.historyList.filter(RemoteTab.shouldIncludeURL).reversed())
            return RemoteTab(
                clientGUID: nil,
                URL: displayURL,
                title: tab.displayTitle,
                history: history,
                lastUsed: Date.nowMilliseconds(),
                icon: nil)
        } else if let sessionData = tab.sessionData, !sessionData.urls.isEmpty {
            let history = Array(sessionData.urls.filter(RemoteTab.shouldIncludeURL).reversed())
            if let displayURL = history.first {
                return RemoteTab(
                    clientGUID: nil,
                    URL: displayURL,
                    title: tab.displayTitle,
                    history: history,
                    lastUsed: sessionData.lastUsedTime,
                    icon: nil)
            }
        }

        return nil
    }

    weak var navigationDelegate: WKNavigationDelegate? {
        didSet {
            if let webView = webView {
                webView.navigationDelegate = navigationDelegate
            }
        }
    }

    /// Creates a `WebView` or checks if the `Tab` should be reloaded.
    func createWebViewOrReloadIfNeeded() {
        if !createWebview() && needsReloadUponSelect {
            reload()
        }
    }

    @discardableResult func createWebview() -> Bool {
        if webView == nil {
            configuration.userContentController = WKUserContentController()
            configuration.allowsInlineMediaPlayback = true
            let webView = TabWebView(frame: .zero, configuration: configuration)
            webView.delegate = self

            webView.accessibilityLabel = .WebViewAccessibilityLabel
            webView.allowsBackForwardNavigationGestures = true
            webView.allowsLinkPreview = true

            // Turning off masking allows the web content to flow outside of the scrollView's frame
            // which allows the content appear beneath the toolbars in the BrowserViewController
            webView.scrollView.layer.masksToBounds = false
            webView.navigationDelegate = navigationDelegate

            restore(webView)

            self.webView = webView
            addRefreshControl()

            send(
                webView: \.title, to: \.title,
                provided: { [weak self] in self?.hasContentProcess ?? false })
            send(webView: \.isLoading, to: \.isLoading)
            send(webView: \.canGoBack, to: \.webViewCanGoBack)
            send(webView: \.canGoForward, to: \.webViewCanGoForward)

            $isLoading
                .combineLatest(webView.publisher(for: \.estimatedProgress, options: .new))
                .sink { isLoading, progress in
                    // Unfortunately WebKit can report partial progress when isLoading is false! That can
                    // happen when a load is cancelled. Avoid reporting partial progress here, but take
                    // care to let the case of progress complete (value of 1) through.
                    self.estimatedProgress = (isLoading || progress == 1) ? progress : 0
                }
                .store(in: &webViewSubscriptions)

            UserScriptManager.shared.injectUserScriptsIntoTab(self)
            tabDelegate?.tab?(self, didCreateWebView: webView)

            return true
        }

        return false
    }

    func addRefreshControl() {
        guard let webView = webView else { return }

        let rc = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in
                self?.reload()
                // Dismiss refresh control now as the regular progress bar will soon appear.
                self?.webView?.scrollView.refreshControl?.endRefreshing()
            })
        webView.scrollView.refreshControl = rc
        webView.scrollView.bringSubviewToFront(rc)
    }

    /// Helper function to observe changes to a given key path on the web view and assign
    /// them to a property on `self`. Stores the subscription in `webViewSubscriptions`
    /// for future disposal in `close()`
    private func send<T>(
        webView keyPath: KeyPath<WKWebView, T>,
        to localKeyPath: ReferenceWritableKeyPath<Tab, T>,
        provided filter: @escaping () -> Bool = { true }
    ) {
        webView?.publisher(for: keyPath, options: [.initial, .new])
            .filter { _ in filter() }
            .assign(to: localKeyPath, on: self)
            .store(in: &webViewSubscriptions)
    }

    func restore(_ webView: WKWebView) {
        // Pulls restored session data from a previous SavedTab to load into the Tab. If it's nil, a session restore
        // has already been triggered via custom URL, so we use the last request to trigger it again; otherwise,
        // we extract the information needed to restore the tabs and create a NSURLRequest with the custom session restore URL
        // to trigger the session restore via custom handlers
        if let sessionData = self.sessionData {
            restoring = true

            var urls = [String]()
            for url in sessionData.urls {
                urls.append(url.absoluteString)
            }

            let currentPage = sessionData.currentPage
            var jsonDict = [String: AnyObject]()
            jsonDict["history"] = urls as AnyObject?
            jsonDict["currentPage"] = currentPage as AnyObject?
            guard
                let json = JSON(jsonDict).stringify()?.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed)
            else {
                return
            }

            if let restoreURL = URL(
                string: "\(InternalURL.baseUrl)/\(SessionRestoreHandler.path)?history=\(json)")
            {
                let request = PrivilegedRequest(url: restoreURL) as URLRequest
                webView.load(request)
                lastRequest = request
            }
        } else if let request = lastRequest {
            webView.load(request)
        } else if let url = url {
            webView.load(URLRequest(url: url))

            print(
                "creating webview with no lastRequest and no session data: \(self.url?.description ?? "nil")"
            )
        }
    }

    func closeWebView() {
        // TODO: - deinit cheatsheet models
        contentScriptManager.uninstall(tab: self)
        webViewSubscriptions = []

        if let webView = webView {
            tabDelegate?.tab?(self, willDeleteWebView: webView)
        }

        saveSessionData()
        webView?.navigationDelegate = nil
        webView?.removeFromSuperview()
        webView = nil
    }

    var historyList: [URL] {
        func listToUrl(_ item: WKBackForwardListItem) -> URL { return item.url }
        var tabs = self.backList?.map(listToUrl) ?? [URL]()
        if let url = url {
            tabs.append(url)
        }
        return tabs
    }

    var displayTitle: String {
        let result: String
        if let title = title, !title.isEmpty {
            result = title
        } else if let url = self.url, !InternalURL.isValid(url: url),
            let shownUrl = url.displayURL?.absoluteString
        {
            result = shownUrl
        } else if let lastTitle = lastTitle, !lastTitle.isEmpty {
            result = lastTitle
        } else {
            result = self.url?.displayURL?.absoluteString ?? ""
        }
        return result.truncateTo(length: 100)
    }

    func attachCurrentSearchQueryToCurrentNavigation() {
        guard let webView = webView else {
            return
        }

        queryForNavigation.attachCurrentSearchQueryToCurrentNavigation(webView: webView)
        updateCanGoBackForward()
    }

    func backNavigationSuggestionQuery() -> String? {
        guard let navigation = webView?.backForwardList.currentItem,
            let query = queryForNavigation.findQueryFor(navigation: navigation),
            query.location == .suggestion
        else {
            return nil
        }

        return query.typed
    }

    func updateCanGoBackForward() {
        updateCanGoBack()
        updateCanGoForward()
    }

    func updateCanGoBack() {
        canGoBack =
            backNavigationSuggestionQuery() != nil || parent != nil
            || !(parentSpaceID ?? "").isEmpty || webViewCanGoBack
    }

    func updateCanGoForward() {
        if let bvc = browserViewController, bvc.tabManager.selectedTab == self {
            canGoForward =
                webViewCanGoForward || bvc.simulatedSwipeModel.canGoForward()
        } else {
            canGoForward = webViewCanGoForward
        }
    }

    func goBack(checkBackNavigationSuggestionQuery: Bool = true) {
        // If the user opened this tab from FastTap, return to FastTap.
        // Else if the user opened this tab from another one, close this one to return to the parent.
        // Else if the user opened this tab from a space, return to the SpaceDetailView.
        // Else just perform a regular back navigation.
        if checkBackNavigationSuggestionQuery,
            let searchQuery = backNavigationSuggestionQuery(),
            let bvc = browserViewController
        {
            DispatchQueue.main.async {
                bvc.chromeModel.setEditingLocation(to: true)

                // Small delayed needed to prevent animation intefernce
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    bvc.searchQueryModel.value = searchQuery
                    bvc.tabContainerModel.updateContent(
                        .showZeroQuery(
                            isIncognito: bvc.browserModel.incognitoModel.isIncognito,
                            isLazyTab: false,
                            .backButton))
                    bvc.tabContainerModel.updateContent(.showSuggestions)
                    bvc.zeroQueryModel.targetTab = .currentTab
                }
            }
        } else if let _ = parent, !webViewCanGoBack {
            browserViewController?.tabManager.removeTab(self, showToast: false)
        } else if let id = parentSpaceID, !id.isEmpty, !webViewCanGoBack {
            browserViewController?.browserModel.openSpace(spaceID: id)
        } else {
            webView?.goBack()
        }
    }

    func goForward() {
        webView?.goForward()
    }

    func goToBackForwardListItem(_ item: WKBackForwardListItem) {
        webView?.go(to: item)
    }

    @discardableResult func loadRequest(_ request: URLRequest) -> WKNavigation? {
        if let webView = webView {
            // Convert about:reader?url=http://example.com URLs to local ReaderMode URLs
            if let url = request.url, let syncedReaderModeURL = url.decodeReaderModeURL,
                let localReaderModeURL = syncedReaderModeURL.encodeReaderModeURL(
                    WebServer.sharedInstance.baseReaderModeURL())
            {
                let readerModeRequest = PrivilegedRequest(url: localReaderModeURL) as URLRequest
                lastRequest = readerModeRequest
                return webView.load(readerModeRequest)
            }
            lastRequest = request
            if let url = request.url, url.isFileURL, request.isPrivileged {
                return webView.loadFileURL(url, allowingReadAccessTo: url)
            }

            return webView.load(request)
        }
        return nil
    }

    func stop() {
        webView?.stopLoading()
    }

    func reload() {
        // If the current page is an error page, and the reload button is tapped, load the original URL
        if let url = webView?.url, let internalUrl = InternalURL(url),
            let page = internalUrl.originalURLFromErrorPage
        {
            webView?.replaceLocation(with: page)
            return
        }

        if let _ = webView?.reloadFromOrigin() {
            return
        }

        if let webView = self.webView {
            restore(webView)
        }

        needsReloadUponSelect = false
    }

    func getMostRecentQuery(restrictToCurrentNavigation: Bool = false) -> QueryForNavigation.Query?
    {
        guard Thread.isMainThread else {
            return DispatchQueue.main.sync {
                getMostRecentQuery(restrictToCurrentNavigation: restrictToCurrentNavigation)
            }
        }

        guard let webView = webView else {
            return nil
        }

        if restrictToCurrentNavigation {
            guard let navigation = webView.backForwardList.currentItem else {
                return nil
            }

            return queryForNavigation.findQueryFor(navigation: navigation)
        } else {
            for navigation
                in ([webView.backForwardList.currentItem]
                + webView.backForwardList.backList.reversed()).compactMap({ $0 })
            {
                return queryForNavigation.findQueryFor(navigation: navigation)
            }
        }

        return nil
    }

    func addContentScript(_ helper: TabContentScript, name: String) {
        contentScriptManager.addContentScript(helper, name: name, forTab: self)
    }

    func getContentScript(name: String) -> TabContentScript? {
        return contentScriptManager.getContentScript(name)
    }

    func removeContentScript(name: String) {
        contentScriptManager.removeContentScript(name, forTab: self)
    }

    func hideContent(_ animated: Bool = false) {
        webView?.isUserInteractionEnabled = false
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: { () -> Void in
                    self.webView?.alpha = 0.0
                })
        } else {
            webView?.alpha = 0.0
        }
    }

    func showContent(_ animated: Bool = false) {
        webView?.isUserInteractionEnabled = true
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: { () -> Void in
                    self.webView?.alpha = 1.0
                })
        } else {
            webView?.alpha = 1.0
        }
    }

    func setScreenshot(_ screenshot: UIImage?, revUUID: Bool = true) {
        self.screenshot = screenshot
        if revUUID {
            self.screenshotUUID = UUID()
        }

        guard let screenshotUUID = screenshotUUID, let screenshot = screenshot else {
            return
        }

        TabManagerStore.shared.imageStore?.updateOne(
            key: screenshotUUID.uuidString, image: screenshot)
    }

    func toggleChangeUserAgent() {
        changedUserAgent = !changedUserAgent
        reload()
    }

    func queueJavascriptAlertPrompt(_ alert: JSAlertInfo) {
        alertQueue.append(alert)
    }

    func dequeueJavascriptAlertPrompt() -> JSAlertInfo? {
        guard !alertQueue.isEmpty else {
            return nil
        }
        return alertQueue.removeFirst()
    }

    func cancelQueuedAlerts() {
        while alertQueue.first != nil {
            alertQueue.removeFirst().cancel()
        }
    }

    func isDescendentOf(_ ancestor: Tab) -> Bool {
        return sequence(first: parent) { $0?.parent }.contains { $0 == ancestor }
    }

    func applyTheme() {
        UITextField.appearance().keyboardAppearance = isIncognito ? .dark : .default
    }

    func showAddToSpacesSheet() {
        guard let url = canonicalURL?.displayURL else { return }

        if FeatureFlag[.spacify],
            let domain = SpaceImportDomain(rawValue: self.url?.baseDomain ?? ""),
            let webView = webView
        {
            webView.evaluateJavaScript(domain.script) {
                [weak browserViewController, weak self] (result, error) in
                guard let bvc = browserViewController, let self = self else { return }
                guard let linkData = result as? [[String]] else {
                    bvc.showAddToSpacesSheet(
                        url: url, title: self.title, webView: webView)
                    return
                }

                let importData = SpaceImportHandler(
                    title: self.url!.path.remove("/").capitalized, data: linkData)
                bvc.showAddToSpacesSheet(
                    url: url, title: self.title,
                    webView: webView,
                    importData: importData
                )
            }
        } else {
            browserViewController?.showAddToSpacesSheet(url: url, title: title, webView: webView)
        }
    }

    func isIncluded(in tabSections: [TabSection]) -> Bool {
        return tabSections.map({ isIncluded(in: $0) }).contains(true)
    }

    /// Returns a bool on if the tab was last used in the passed `TabSection`.
    /// Tab will also return `true` for `today` if it is pinned and `pinnnedTabSection` isn't enabled.
    func isIncluded(in tabSection: TabSection) -> Bool {
        // The fallback value won't be used. tab.lastExecutedTime is
        // guaranteed to be non-nil in configureTab()
        let lastExecutedTime = lastExecutedTime ?? Date.nowMilliseconds()
        return wasLastExecuted(
            in: tabSection, isPinned: isPinned, lastExecutedTime: lastExecutedTime)
    }

    private func saveSessionData() {
        let currentItem: WKBackForwardListItem! = webView?.backForwardList.currentItem

        // Freshly created WebViews won't have any history entries at all.
        // If we have no history, no need to create the SessionData.
        if currentItem != nil {
            // Here we create the SessionData for the tab and pass that to the SavedTab.
            let navigationList = webView?.backForwardList.all ?? []
            let urls = navigationList.compactMap { $0.url }
            let currentPage = -(webView?.backForwardList.forwardList ?? []).count
            let queries = navigationList.map {
                queryForNavigation.findQueryFor(navigation: $0)
            }

            sessionData = SessionData(
                currentPage: currentPage, urls: urls,
                queries: queries.map { $0?.typed },
                suggestedQueries: queries.map { $0?.suggested },
                queryLocations: queries.map { $0?.location },
                lastUsedTime: lastExecutedTime ?? Date.nowMilliseconds()
            )
        }
    }

    func saveSessionDataAndCreateSavedTab(isSelected: Bool, tabIndex: Int?) -> SavedTab {
        saveSessionData()

        return SavedTab(
            screenshotUUID: screenshotUUID, isSelected: isSelected,
            title: title ?? lastTitle, isIncognito: isIncognito, isPinned: isPinned,
            pinnedTime: pinnedTime, lastExecutedTIme: lastExecutedTime,
            faviconURL: displayFavicon?.url, url: url, sessionData: sessionData,
            uuid: tabUUID, rootUUID: rootUUID, parentUUID: parentUUID ?? "",
            tabIndex: tabIndex, parentSpaceID: parentSpaceID ?? "",
            pageZoom: pageZoom)
    }
}

extension Tab: TabWebViewDelegate {
    fileprivate func tabWebView(
        _ tabWebView: TabWebView, didSelectFindInPageForSelection selection: String
    ) {
        tabDelegate?.tab(self, didSelectFindInPageForSelection: selection)
    }
    fileprivate func tabWebView(
        _ tabWebView: TabWebView, didSelectAddToSpaceForSelection selection: String
    ) {
        tabDelegate?.tab(self, didSelectAddToSpaceForSelection: selection)
    }
    fileprivate func tabWebViewSearchWithNeeva(
        _ tabWebViewSearchWithNeeva: TabWebView,
        didSelectSearchWithNeevaForSelection selection: String
    ) {
        tabDelegate?.tab(self, didSelectSearchWithNeevaForSelection: selection)
    }
}

extension Tab: ContentBlockerTab {
    func currentURL() -> URL? {
        return url
    }

    func currentWebView() -> WKWebView? {
        return webView
    }

    func injectCookieCutterScript(cookieCutterModel: CookieCutterModel) {
        let cookieCutterHelper = CookieCutterHelper(cookieCutterModel: cookieCutterModel)
        addContentScript(cookieCutterHelper, name: CookieCutterHelper.name())
    }
}

private class TabContentScriptManager: NSObject, WKScriptMessageHandler {
    private var helpers = [String: TabContentScript]()

    // Without calling this, the TabContentScriptManager will leak.
    func uninstall(tab: Tab) {
        helpers.forEach { helper in
            if let name = helper.value.scriptMessageHandlerName() {
                tab.webView?.configuration.userContentController.removeScriptMessageHandler(
                    forName: name)
            }
        }
    }

    @objc func userContentController(
        _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
        for helper in helpers.values {
            if let scriptMessageHandlerName = helper.scriptMessageHandlerName(),
                scriptMessageHandlerName == message.name
            {
                helper.userContentController(didReceiveScriptMessage: message)
                return
            }
        }
    }

    func addContentScript(_ helper: TabContentScript, name: String, forTab tab: Tab) {
        guard helpers[name] == nil else {
            log.info("Duplicate helper script added: \(name)")
            return
        }

        helpers[name] = helper

        // If this helper handles script messages, then get the handler name and register it. The Browser
        // receives all messages and then dispatches them to the right TabHelper.
        if let scriptMessageHandlerName = helper.scriptMessageHandlerName() {
            tab.webView?.configuration.userContentController.addInDefaultContentWorld(
                scriptMessageHandler: self, name: scriptMessageHandlerName)
        }
    }

    func getContentScript(_ name: String) -> TabContentScript? {
        return helpers[name]
    }

    func removeContentScript(_ name: String, forTab tab: Tab) {
        tab.webView?.configuration.userContentController.removeScriptMessageHandler(
            forName: name)
    }
}

private protocol TabWebViewDelegate: AnyObject {
    func tabWebView(_ tabWebView: TabWebView, didSelectFindInPageForSelection selection: String)
    func tabWebView(_ tabWebView: TabWebView, didSelectAddToSpaceForSelection selection: String)
    func tabWebViewSearchWithNeeva(
        _ tabWebViewSearchWithNeeva: TabWebView,
        didSelectSearchWithNeevaForSelection selection: String)
}

class TabWebView: WKWebView, MenuHelperInterface {
    fileprivate weak var delegate: TabWebViewDelegate?

    // Updates the `background-color` of the webview to match
    // the theme if the webview is showing "about:blank" (nil).
    func applyTheme() {
        if url == nil {
            let backgroundColor = UIColor.DefaultBackground.hexString
            evaluateJavascriptInDefaultContentWorld(
                "document.documentElement.style.backgroundColor = '\(backgroundColor)';")
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return super.canPerformAction(action, withSender: sender)
            || action == MenuHelper.SelectorFindInPage || action == MenuHelper.SelectorAddToSpace
    }

    @objc func menuHelperAddToSpace() {
        evaluateJavascriptInDefaultContentWorld("getSelection().toString()") { result, _ in
            let selection = result as? String ?? ""
            self.delegate?.tabWebView(self, didSelectAddToSpaceForSelection: selection)
        }
    }

    @objc func menuHelperFindInPage() {
        evaluateJavascriptInDefaultContentWorld("getSelection().toString()") { result, _ in
            let selection = result as? String ?? ""
            self.delegate?.tabWebView(self, didSelectFindInPageForSelection: selection)
        }
    }

    @objc func menuHelperSearchWithNeeva() {
        evaluateJavascriptInDefaultContentWorld("getSelection().toString()") { result, _ in
            let selection = result as? String ?? ""
            self.delegate?.tabWebViewSearchWithNeeva(
                self, didSelectSearchWithNeevaForSelection: selection)
        }
    }

    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // The find-in-page selection menu only appears if the webview is the first responder.
        becomeFirstResponder()

        return super.hitTest(point, with: event)
    }

    /// Override evaluateJavascript - should not be called directly on TabWebViews any longer
    // We should only be calling evaluateJavascriptInDefaultContentWorld in the future
    @available(
        *, unavailable,
        message:
            "Do not call evaluateJavaScript directly on TabWebViews, should only be called on super class"
    )
    override func evaluateJavaScript(
        _ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil
    ) {
        super.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
}

public func wasLastExecuted(in tabSection: TabSection, isPinned: Bool, lastExecutedTime: Timestamp)
    -> Bool
{
    // lastExecutedTime is passed in milliseconds, needs to be converted to seconds.
    let lastExecutedTimeSeconds = lastExecutedTime / 1000
    let dateLastExecutedTime = Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds))

    if isPinned {
        switch tabSection {
        case .all:
            return true
        case .pinned:
            return FeatureFlag[.pinnnedTabSection]
        case .today:
            // If the tab is pinned, and pinnnedTabSection isn't enabled, keep it in the today section.
            return FeatureFlag[.pinnnedTabSection] ? false : dateLastExecutedTime.isToday()
        default:
            return false
        }
    } else {
        switch tabSection {
        case .all:
            return true
        case .pinned:
            return false
        case .today:
            return dateLastExecutedTime.isToday()
        case .yesterday:
            return dateLastExecutedTime.isYesterday()
        case .lastWeek:
            return dateLastExecutedTime.isWithinLast7Days()
                && !(dateLastExecutedTime.isToday() || dateLastExecutedTime.isYesterday())
        case .lastMonth:
            return !dateLastExecutedTime.isWithinLast7Days()
                && dateLastExecutedTime.isWithinLastMonth()
        case .overAMonth:
            return !dateLastExecutedTime.isWithinLastMonth()
        }
    }
}
