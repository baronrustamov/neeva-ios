// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import Storage

private let log = Logger.browser
private let URLBeforePathRegex = try! NSRegularExpression(
    pattern: "^https?://([^/]+)/", options: [])
private let defaultRecencyDuration: UInt64 = 2 * OneDayInMilliseconds * 1000
private let numSuggestionsToFetch: Int = 40
private let maxSuggestRequestCount: Int = 5

class SuggestionModel: ObservableObject {
    let bvc: BrowserViewController

    private(set) var queryModel: SearchQueryModel
    private var searchQueryListener: AnyCancellable?

    private var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                if searchQuery.count == 0 {
                    canceledSuggestRequestCount = 0
                    suggestStartTime = nil
                    timeToFirstScreen = nil
                }
                if suggestionQuery != nil {
                    canceledSuggestRequestCount += 1
                }
                reload()
            }
        }
    }

    private var canceledSuggestRequestCount = 0
    private var suggestStartTime: Date?
    private var timeToFirstScreen: Int?

    // MARK: Neeva Suggestions
    // Displayed in linear order
    @Published private(set) var tabSuggestions: [Suggestion] = []
    @Published private(set) var autocompleteSuggestion: Suggestion?
    @Published private(set) var rowQuerySuggestions: [Suggestion] = []
    // these two get set by tests
    @Published var urlSuggestions: [Suggestion] = []
    @Published var navSuggestions: [Suggestion] = []
    @Published private(set) var findInPageSuggestion: Suggestion?
    @Published private(set) var xyzQuerySuggestions: [Suggestion] = []
    @Published private(set) var activeLensBang: ActiveLensBangInfo?
    @Published private(set) var error: Error?
    @Published private(set) var keyboardFocusedSuggestion: Suggestion?
    @Published private(set) var memorizedSuggestionMap = [String: String]()
    @Published private(set) var querySuggestionIndexMap = [String: Int]()
    private var keyboardFocusedSuggestionIndex = -1

    private var isIncognito: Bool {
        bvc.browserModel.incognitoModel.isIncognito
    }

    var shouldShowSearchSuggestions: Bool {
        !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions]
            && !searchQuery.looksLikeAURL
    }

    fileprivate var suggestionQuery: Cancellable?

    fileprivate var suggestionQueryQueue = [(query: String, suggestionQuery: Cancellable)]()

    var suggestions: [Suggestion] {
        var top = tabSuggestions

        if let autocompleteSuggestion = autocompleteSuggestion {
            top.append(autocompleteSuggestion)
        }

        rowQuerySuggestions = rowQuerySuggestions.filter { suggestion in
            if case let .navigation(autocompleteNavSuggestion) = autocompleteSuggestion,
                case let .url(urlSuggestion) = suggestion
            {
                return URL(string: urlSuggestion.suggestedUrl)?.normalizedHostAndPathForDisplay
                    != autocompleteNavSuggestion.url.normalizedHostAndPathForDisplay
            }
            return true
        }

        hasMemorizedResult =
            rowQuerySuggestions.filter { suggestion in
                if case let .url(urlSuggestion) = suggestion {
                    return !(urlSuggestion.subtitle?.isEmpty ?? true)
                }
                return false
            }.count > 0

        let mid = rowQuerySuggestions + urlSuggestions
        return top + mid + navCombinedSuggestions
    }

    var shouldShowPlaceholderSuggestions: Bool {
        [rowQuerySuggestions].allSatisfy {
            $0?.isEmpty == true
        } && !suggestionQueryQueue.isEmpty
    }

    // MARK: - History Suggestions
    @Published private(set) var completion: String?
    @Published private(set) var sites: [Site]?
    @Published private(set) var recentSites: [Site]?

    private var shouldSkipNextAutocomplete = false
    private let frecentHistory: FrecentHistory

    // `weak` usage here allows deferred queue to be the owner. The deferred is always filled and this set to nil,
    // this is defensive against any changes to queue (or cancellation) behaviour in future.
    private weak var currentDeferredHistoryQuery: CancellableDeferred<Maybe<Cursor<Site?>>>?
    private var searchTextSubscription: AnyCancellable?

    // MARK: - Nav Suggestions
    static let numOfDisplayNavSuggestions = 5

    var navCombinedSuggestions: [Suggestion] {
        let recentSites = recentSites?.compactMap { NavSuggestion(site: $0) } ?? []
        let sites = sites?.compactMap { NavSuggestion(site: $0) } ?? []

        var convertedNavSuggestions = [NavSuggestion]()
        for suggestion in navSuggestions {
            switch suggestion {
            case .url(let suggestion):
                convertedNavSuggestions.append(NavSuggestion(suggestion: suggestion)!)
            default:
                break
            }
        }

        var navSuggestions = Array(
            (recentSites + convertedNavSuggestions + sites).removeDuplicates().prefix(
                SuggestionModel.numOfDisplayNavSuggestions))
        if case let .navigation(autocompleteNavSuggestion) = self.autocompleteSuggestion {
            navSuggestions = navSuggestions.filter { $0 != autocompleteNavSuggestion }
        }
        return navSuggestions.compactMap { Suggestion.navigation($0) }
    }

    var hasMemorizedResult = false

    // MARK: - Loading Suggestions
    func reload() {
        // cap the # of queries in the sliding window
        if suggestionQueryQueue.count >= maxSuggestRequestCount {
            suggestionQueryQueue[maxSuggestRequestCount - 1].suggestionQuery.cancel()
        }

        keyboardFocusedSuggestion = nil
        keyboardFocusedSuggestionIndex = -1

        guard shouldShowSearchSuggestions else {
            clearSearchSuggestions()
            return
        }

        if suggestStartTime == nil {
            suggestStartTime = Date()
        }

        let suggestionQuery =
            SearchEngine.current.isNeeva
            ? fetchNeevaSuggestions(for: searchQuery)
            : fetchGenericSuggestions(for: searchQuery)

        if NeevaConstants.currentTarget == .xyz && FeatureFlag[.newWeb3Features] {
            fetchNFTSuggestions(for: searchQuery)
        }
        // always insert the most recent query to the beginning of the array
        suggestionQueryQueue.insert((searchQuery, suggestionQuery), at: 0)
    }

    private func clearSearchSuggestions() {
        rowQuerySuggestions = []
        urlSuggestions = []
        navSuggestions = []
        xyzQuerySuggestions = []
        findInPageSuggestion = nil
        activeLensBang = nil
        error = nil
        memorizedSuggestionMap = [:]
        querySuggestionIndexMap = [:]
    }

    private func fetchNeevaSuggestions(for searchQuery: String) -> Cancellable {
        SuggestionsController.getSuggestions(for: searchQuery) { [searchQuery] result in
            // cancel and remove any pending requests that's older than the current one
            if let requestIdx =
                self.suggestionQueryQueue.firstIndex(where: { query, _ in
                    return searchQuery == query
                })
            {
                let oldRequestRange = requestIdx..<self.suggestionQueryQueue.count
                self.suggestionQueryQueue[oldRequestRange].forEach { _, suggestionQuery in
                    suggestionQuery.cancel()
                }
                self.suggestionQueryQueue.removeSubrange(oldRequestRange)
            }
            switch result {
            case .failure(let error):
                ClientLogger.shared.logCounter(
                    .SuggestionErrorLoginViewImpression,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                let nsError = error as NSError
                if nsError.domain != NSURLErrorDomain || nsError.code != NSURLErrorCancelled {
                    self.error = error
                }
            case .success(
                let (
                    rowQuerySuggestions, urlSuggestions, navSuggestions, lensOrBang,
                    memorizedSuggestionMap, querySuggestionIndexMap
                )):
                if let suggestStartTime = self.suggestStartTime,
                    self.timeToFirstScreen == nil
                {
                    self.timeToFirstScreen =
                        suggestStartTime.timeDiffInMilliseconds(from: Date())
                }
                self.error = nil
                self.rowQuerySuggestions = rowQuerySuggestions
                // Add a search query suggestion for the URL if it doesn't exist
                if URLFixup.getURL(searchQuery) != nil,
                    !(rowQuerySuggestions.compactMap {
                        switch $0 {
                        case .query(let query):
                            return query.suggestedQuery
                        default:
                            return nil
                        }
                    }).contains(searchQuery)
                {
                    self.rowQuerySuggestions.insert(
                        Suggestion.query(
                            SuggestionsQuery.Data.Suggest.QuerySuggestion(
                                type: .standard,
                                suggestedQuery: searchQuery,
                                boldSpan: [],
                                source: .elastic
                            )), at: 0)
                }

                self.urlSuggestions = urlSuggestions
                self.navSuggestions = navSuggestions
                self.findInPageSuggestion = .findInPage(searchQuery)
                self.activeLensBang = lensOrBang
                self.memorizedSuggestionMap = memorizedSuggestionMap
                self.querySuggestionIndexMap = querySuggestionIndexMap
            }
            if self.suggestions.isEmpty {
                if let lensOrBang = self.activeLensBang,
                    let shortcut = lensOrBang.shortcut,
                    let description = lensOrBang.description,
                    let type = lensOrBang.type,
                    type == .lens || type == .bang,
                    searchQuery.trimmingCharacters(in: .whitespaces) == type.sigil + shortcut
                {
                    switch lensOrBang.type {
                    case .lens:
                        self.rowQuerySuggestions = [
                            .lens(Suggestion.Lens(shortcut: shortcut, description: description))
                        ]
                    case .bang:
                        self.rowQuerySuggestions = [
                            .bang(
                                Suggestion.Bang(
                                    shortcut: shortcut, description: description,
                                    domain: lensOrBang.domain))
                        ]
                    default:
                        print("Unexpected lens/bang type \(lensOrBang.type?.rawValue ?? "(nil)")")
                        self.rowQuerySuggestions = []
                    }
                } else {
                    let emptyQuerySuggestion: Suggestion = .query(
                        .init(
                            type: .standard,
                            suggestedQuery: searchQuery,
                            boldSpan: [
                                .init(startInclusive: 0, endExclusive: searchQuery.count)
                            ],
                            source: .unknown
                        )
                    )
                    self.rowQuerySuggestions = [emptyQuerySuggestion]
                }
            }
        }
    }

    private func fetchGenericSuggestions(for searchQuery: String) -> Cancellable {
        guard let suggestURL = SearchEngine.current.suggestURLForQuery(searchQuery) else {
            clearSearchSuggestions()
            return AnyCancellable({})
        }
        return URLSession.shared
            .dataTaskPublisher(for: suggestURL)
            .failureToNil()
            .receive(on: RunLoop.main)
            .sink { [self] result in
                clearSearchSuggestions()
                guard
                    let data = result?.data,
                    let suggestionResult = try? JSONDecoder().decode(
                        GenericSuggestionResult.self, from: data)
                else { return }
                rowQuerySuggestions = suggestionResult.suggestions.prefix(5).map { suggestedQuery in
                    .query(
                        .init(
                            type: .standard,
                            suggestedQuery: suggestedQuery,
                            boldSpan: [],
                            source: .unknown,
                            annotation: nil
                        ))
                }
            }
    }

    private func fetchNFTSuggestions(for searchQuery: String) {
        guard let suggestURL = SearchEngine.nft.suggestURLForQuery(searchQuery) else {
            return
        }
        var request = URLRequest(url: suggestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            guard error == nil, let data = data else { return }
            DispatchQueue.main.async { [self] in
                xyzQuerySuggestions = []
                guard
                    let suggestionResult = try? JSONDecoder().decode(
                        NFTSuggestionResult.self, from: data), let groups = suggestionResult.groups,
                    !groups.isEmpty
                else { return }
                xyzQuerySuggestions = groups[0].suggestions.prefix(3).map { suggestedQuery in
                    .xyzQuery(suggestedQuery)
                }
            }
        }.resume()
    }

    private func subscribe() {
        searchTextSubscription = queryModel.$value.withPrevious().sink {
            [weak self] oldQuery, query in
            guard let self = self else { return }

            self.currentDeferredHistoryQuery?.cancel()

            self.autocompleteSuggestion = nil
            self.completion = nil

            log.info(
                "previous query: \(oldQuery), current query: \(query), completion: \(String(describing: self.completion))"
            )

            if query.isEmpty {
                self.sites = []
                self.shouldSkipNextAutocomplete = false
                return
            }

            guard
                let deferredHistory = self.frecentHistory.getSites(
                    matchingSearchQuery: query, limit: numSuggestionsToFetch)
                    as? CancellableDeferred
            else {
                assertionFailure("FrecentHistory query should be cancellable")
                return
            }

            self.currentDeferredHistoryQuery = deferredHistory

            deferredHistory.uponQueue(.main) { result in
                log.info("current query: \(query)")

                defer {
                    self.currentDeferredHistoryQuery = nil
                }

                guard !deferredHistory.cancelled else {
                    log.info("canceled query: \(query)")
                    return
                }

                // Exclude Neeva search url suggestions from history suggest, since they should
                // readily be coming as query suggestions.
                let deferredHistorySites = (result.successValue?.asArray() ?? [])
                    .compactMap { $0 }
                    .filter {
                        !($0.url.absoluteString.hasPrefix(
                            NeevaConstants.appSearchURL.absoluteString))
                    }

                // Split the data to frequent visits from recent history and everything else
                self.recentSites =
                    deferredHistorySites
                    .filter {
                        $0.latestVisit != nil
                            && $0.latestVisit!.date
                                > (Date.nowMicroseconds() - defaultRecencyDuration)
                    }
                self.sites =
                    deferredHistorySites
                    .filter {
                        $0.latestVisit == nil
                            || $0.latestVisit!.date
                                <= (Date.nowMicroseconds() - defaultRecencyDuration)
                    }

                // If we should skip the next autocomplete, reset
                // the flag and bail out here.
                guard !self.shouldSkipNextAutocomplete else {
                    self.shouldSkipNextAutocomplete = false
                    return
                }

                let query = query.stringByTrimmingLeadingCharactersInSet(.whitespaces)

                // First, see if the query matches any URLs from the user's search history
                // and it has a domain only site entry so that we have the correct title
                for site in deferredHistorySites {
                    if let domainOnlySite =
                        deferredHistorySites.first(where: { s in
                            s.url.pathComponents.count == 1
                                && s.url.domainURL == site.url.domainURL
                        })
                    {
                        if self.setCompletion(
                            to: self.completionForURL(
                                domainOnlySite.url,
                                from: query,
                                site: domainOnlySite),
                            from: query)
                        {
                            return
                        }
                    }
                }
            }
        }
    }

    // MARK: - Autocomplete
    @discardableResult func clearCompletion() -> Bool {
        let cleared = completion != nil
        completion = nil
        return cleared
    }

    func skipNextAutocomplete() {
        shouldSkipNextAutocomplete = true
    }

    private func setCompletion(to completion: String?, from query: String) -> Bool {
        if let completion = completion, completion != query {
            precondition(
                completion.lowercased().starts(with: query.lowercased()),
                "Expected completion '\(completion)' to start with '\(query)'")
            log.info("Set autocomplete suggestion '\(completion)' for query \(query)")
            self.completion = String(completion.dropFirst(query.count))
            return true
        }

        return false
    }

    fileprivate func completionForURL(_ url: URL, from query: String, site: Site) -> String? {
        let url = url.absoluteString as NSString
        // Extract the pre-path substring from the URL. This should be more efficient than parsing via
        // NSURL since we need to only look at the beginning of the string.
        // Note that we won't match non-HTTP(S) URLs.
        guard
            let match = URLBeforePathRegex.firstMatch(
                in: url as String, options: [], range: NSRange(location: 0, length: url.length))
        else {
            return nil
        }

        // If the pre-path component (including the scheme) starts with the query, just use it as is.
        var prePathURL = url.substring(with: match.range(at: 0))
        if prePathURL.hasPrefix(query) {
            // Trailing slashes in the autocompleteTextField cause issues with Swype keyboard. Bug 1194714
            if prePathURL.hasSuffix("/"), !query.hasSuffix("/") {
                prePathURL.remove(at: prePathURL.index(before: prePathURL.endIndex))
            }
            return prePathURL
        }

        // Otherwise, find and use any matching domain.
        // To simplify the search, prepend a ".", and search the string for ".query".
        // For example, for http://en.m.wikipedia.org, domainWithDotPrefix will be ".en.m.wikipedia.org".
        // This allows us to use the "." as a separator, so we can match "en", "m", "wikipedia", and "org",
        let domain = (url as NSString).substring(with: match.range(at: 1))
        return completionForDomain(domain, from: query, site: site)
    }

    fileprivate func completionForDomain(
        _ domain: String,
        from query: String,
        site: Site? = nil
    ) -> String? {
        let domainWithDotPrefix: String = ".\(domain)"
        if let range = domainWithDotPrefix.range(
            of: ".\(query)", options: .caseInsensitive, range: nil, locale: nil)
        {
            let matchedDomain = String(
                domainWithDotPrefix[domainWithDotPrefix.index(range.lowerBound, offsetBy: 1)...])
            // We don't actually want to match the top-level domain ("com", "org", etc.) by itself, so
            // so make sure the result includes at least one ".".
            if matchedDomain.contains(".") {
                autocompleteSuggestion = Suggestion.navigation(
                    NavSuggestion(
                        url: URL(string: "https://\(matchedDomain)")!,
                        title: site?.title,
                        isMemorizedNav: false,
                        isAutocomplete: true
                    )
                )
                return matchedDomain
            }
        }

        return nil
    }

    // MARK: - Suggestion Location Logging Attributes
    private func findSuggestionLocationInfo(_ suggestion: Suggestion) -> SuggestionPositionInfo? {
        if let idx = suggestions.firstIndex(of: suggestion) {
            return SuggestionPositionInfo(positionIndex: idx)
        }

        return nil
    }

    private func annotationTypeAttribute(
        suggestion: Suggestion,
        suggestionIdx: Int
    ) -> ClientLogCounterAttribute? {
        switch suggestion {
        case .query(let suggestion):
            if let annotationType = suggestion.annotation?.annotationType {
                return
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.annotationTypeAtPosition)\(suggestionIdx)",
                        value: annotationType
                    )
            }
        default:
            break
        }
        return nil
    }

    private func finishEditingAndSubmit(url: URL, for suggestedQuery: String? = nil) {
        bvc.finishEditingAndSubmit(
            url,
            visitType: VisitType.link,
            forTab: bvc.tabManager.selectedTab,
            with: suggestedQuery
        )
    }

    // MARK: - Suggestion Handling
    public func handleSuggestionSelected(_ suggestion: Suggestion) {
        var suggestionLocationAttributes =
            findSuggestionLocationInfo(suggestion)?.loggingAttributes() ?? []
        var hideZeroQuery = true

        var interaction: LogConfig.Interaction?

        var querySuggestionIndex: Int?
        var suggestedUrl: String?
        var suggestedQuery: String?
        var isSearchHistoryQuery: Bool = false

        switch suggestion {
        case .query(let suggestion):
            interaction =
                activeLensBang != nil
                ? .BangSuggestion : .QuerySuggestion
            bvc.urlBar(didSubmitText: suggestion.suggestedQuery, isSearchQuerySuggestion: true)

            if let index = querySuggestionIndexMap[suggestion.suggestedQuery] {
                querySuggestionIndex = index
                suggestedQuery = suggestion.suggestedQuery
                if let memorizedUrl = memorizedSuggestionMap.first(where: { k, v in
                    v == suggestedQuery
                }) {
                    suggestedUrl = memorizedUrl.key
                }
            }
            isSearchHistoryQuery = suggestion.type == .searchHistory
        case .url(let suggestion):
            interaction =
                suggestion.title?.isEmpty ?? false ? .PersonalSuggestion : .MemorizedSuggestion
            suggestedQuery = memorizedSuggestionMap[suggestion.suggestedUrl]
            if let suggestedQuery = suggestedQuery {
                if let index = querySuggestionIndexMap[suggestedQuery] {
                    querySuggestionIndex = index
                    suggestedUrl = suggestion.suggestedUrl
                }
            }

            if let suggestedUrl = URL(string: suggestion.suggestedUrl) {
                finishEditingAndSubmit(url: suggestedUrl, for: suggestedQuery)
            } else {
                log.error(
                    "Malformed memorized url \(suggestion.suggestedUrl) for query \(suggestedQuery ?? "empty")"
                )
            }

        case .lens(let suggestion):
            hideZeroQuery = false

            interaction = .LensSuggestion
            queryModel.value = "@\(suggestion.shortcut) "
        case .bang(let suggestion):
            hideZeroQuery = false

            interaction = .BangSuggestion
            queryModel.value = "!\(suggestion.shortcut) "
        case .navigation(let nav):
            interaction =
                nav.isMemorizedNav
                ? LogConfig.Interaction.MemorizedSuggestion
                : (nav.isAutocomplete
                    ? LogConfig.Interaction.AutocompleteSuggestion
                    : LogConfig.Interaction.HistorySuggestion)
            if nav.isAutocomplete {
                suggestionLocationAttributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.SuggestionAttribute.autocompleteSelectedFromRow,
                        value: String(nav.isAutocomplete)
                    )
                )
            }
            finishEditingAndSubmit(url: nav.url)
        case .editCurrentURL(let tab):
            interaction = LogConfig.Interaction.editCurrentURL
            hideZeroQuery = false

            let tabURL = tab.url
            let url =
                tabURL?.decodeReaderModeURL != nil
                ? tabURL?.decodeReaderModeURL
                : InternalURL.isValid(url: tabURL)
                    ? InternalURL(tabURL)?.originalURLFromErrorPage : tabURL
            bvc.searchQueryModel.value = url?.absoluteString ?? ""
            bvc.zeroQueryModel.targetTab = .currentTab
        case .tabSuggestion(let tabCardToSelect):
            interaction = LogConfig.Interaction.tabSuggestion
            tabCardToSelect.manager.select(tabCardToSelect.tab)
        case .findInPage(let query):
            interaction = .FindOnPageSuggestion
            bvc.updateFindInPageVisibility(visible: true, query: query)
        case .xyzQuery(let suggestion):
            interaction = .XYZSearchSuggestion
            bvc.urlBar(didSubmitText: suggestion.displayText, isSearchQuerySuggestion: false)
        case .editCurrentQuery(let query, let url):
            hideZeroQuery = false

            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            bvc.searchQueryModel.value = query
            bvc.searchQueryModel.queryItems = components?.queryItems
            bvc.zeroQueryModel.targetTab = .currentTab
        }

        if let interaction = interaction {
            let queryAttributes = buildQueryAttributes(
                typedQuery: bvc.searchQueryModel.value,
                suggestedQuery: suggestedQuery,
                index: querySuggestionIndex,
                suggestedUrl: suggestedUrl,
                isFromSearchHistory: isSearchHistoryQuery
            )

            ClientLogger.shared.logCounter(
                interaction,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + suggestionLocationAttributes
                    + suggestionSnapshotAttributes()
                    + queryAttributes)
        }

        if hideZeroQuery {
            bvc.dismissEditingAndHideZeroQuery()
        }
    }

    // MARK: - Keyboard Shortcut
    public func handleKeyboardShortcut(input: String) {
        switch input {
        case UIKeyCommand.inputUpArrow:
            moveFocus(amount: -1)
        case UIKeyCommand.inputDownArrow:
            moveFocus(amount: 1)
        case "\r":
            if let keyboardFocusedSuggestion = keyboardFocusedSuggestion {
                // searches for suggestion
                handleSuggestionSelected(keyboardFocusedSuggestion)
            } else {
                // searches for text in address bar
                bvc.urlBar(
                    didSubmitText: bvc.searchQueryModel.value
                        + (bvc.suggestionModel.completion ?? ""))
            }
        default:
            break
        }
    }

    /// Moves the focusedKeyboardShortcut up/down by the input amount
    private func moveFocus(amount: Int) {
        let allSuggestionsCount = suggestions.count

        guard allSuggestionsCount > 0 else {
            return
        }

        keyboardFocusedSuggestionIndex += amount

        if keyboardFocusedSuggestionIndex >= allSuggestionsCount {
            keyboardFocusedSuggestionIndex = -1
            keyboardFocusedSuggestion = nil
        } else if keyboardFocusedSuggestionIndex < -1 {
            keyboardFocusedSuggestionIndex = allSuggestionsCount - 1
            keyboardFocusedSuggestion = suggestions[allSuggestionsCount - 1]
        } else if keyboardFocusedSuggestionIndex > -1 {
            keyboardFocusedSuggestion = suggestions[keyboardFocusedSuggestionIndex]
        } else {
            keyboardFocusedSuggestion = nil
        }
    }

    public func isFocused(_ suggestion: Suggestion) -> Bool {
        return suggestion == keyboardFocusedSuggestion
    }

    // MARK: - Initlization
    init(bvc: BrowserViewController, profile: Profile, queryModel: SearchQueryModel) {
        self.bvc = bvc
        self.frecentHistory = profile.history.getFrecentHistory()
        self.queryModel = queryModel

        searchQueryListener = queryModel.$value.sink(receiveValue: { updatedQuery in
            self.searchQuery = updatedQuery
        })

        subscribe()
        KeyboardHelper.defaultHelper.addDelegate(self)
    }

    convenience init(
        bvc: BrowserViewController, previewSites: [Site]? = nil, previewCompletion: String? = nil,
        queryModel: SearchQueryModel = SearchQueryModel(previewValue: ""),
        searchQueryForTesting: String = "",
        previewLensBang: ActiveLensBangInfo? = nil,
        rowQuerySuggestions: [Suggestion] = []
    ) {
        self.init(bvc: bvc, profile: BrowserProfile(localName: "profile"), queryModel: queryModel)
        self.sites = previewSites
        self.completion = previewCompletion
        self.rowQuerySuggestions = rowQuerySuggestions
        self.activeLensBang = previewLensBang
        self.searchQuery = searchQueryForTesting
        self.sites = previewSites
    }
}

extension SuggestionModel: KeyboardHelperDelegate {
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState
    ) {
        animateSearchEnginesWithKeyboard(state)
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState
    ) {
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState
    ) {
        animateSearchEnginesWithKeyboard(state)
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidHideWithState state: KeyboardState
    ) {
    }

    func animateSearchEnginesWithKeyboard(_ keyboardState: KeyboardState) {
        keyboardState.animateAlongside {
            self.objectWillChange.send()
        }
    }
}

// Analytics

// See https://paper.dropbox.com/doc/Suggestion-Logging--BRKRJ~Nh4Swy4qpS2YznTGHxAg-090AYbHRKr5TsjKPDG406
// for the attribute format of suggestion
extension SuggestionModel {
    enum SuggestionLoggingType: String {
        case tabSuggestion = "TabSuggestion"
        case rowQuerySuggestion = "RowQuerySuggestion"
        case personalSuggestion = "PersonalSuggestion"
        case memorizedSuggestion = "MemorizedSuggestion"
        case historySuggestion = "HistorySuggestion"
        case bangSuggestion = "BangSuggestion"
        case lensSuggestion = "LensSuggestion"
    }

    func suggestionSnapshotAttributes() -> [ClientLogCounterAttribute] {
        var implLogAttributes = [ClientLogCounterAttribute]()
        var snapshotLogAttributes = [ClientLogCounterAttribute]()
        var suggestionIdx = 0

        var numberOfMemorizedSuggestions = 0
        var numberOfHistorySuggestions = 0
        var numberOfPersonalSuggestions = 0
        var numberOfCalculatorAnnotations = 0
        var numberOfWikiAnnotations = 0
        var numberOfStockAnnotations = 0
        var numberOfDictionaryAnnotations = 0

        suggestions.enumerated().forEach { (index, suggestion) in
            switch suggestion {
            case .tabSuggestion(_):
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.tabSuggestion.rawValue)
                )
            case .query(let query):
                switch AnnotationType(annotation: query.annotation) {
                case .calculator:
                    numberOfCalculatorAnnotations += 1
                case .wikipedia:
                    numberOfWikiAnnotations += 1
                case .stock:
                    numberOfStockAnnotations += 1
                case .dictionary:
                    numberOfDictionaryAnnotations += 1
                default:
                    break
                }
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.rowQuerySuggestion.rawValue
                    )
                )
                if let attribute = annotationTypeAttribute(
                    suggestion: suggestion,
                    suggestionIdx: suggestionIdx
                ) {
                    snapshotLogAttributes.append(attribute)
                }
            case .url(let url):
                if !(url.subtitle?.isEmpty ?? true) {
                    numberOfMemorizedSuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.memorizedSuggestion.rawValue)
                    )
                } else {
                    numberOfPersonalSuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.personalSuggestion.rawValue)
                    )
                }
            case .navigation(let nav):
                if nav.isMemorizedNav {
                    numberOfMemorizedSuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.memorizedSuggestion.rawValue)
                    )
                } else {
                    numberOfHistorySuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.historySuggestion.rawValue)
                    )
                }
            case .bang(_):
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.bangSuggestion.rawValue)
                )
            case .lens(_):
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.lensSuggestion.rawValue)
                )
            default:
                break
            }
            suggestionIdx += 1
        }

        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfMemorizedSuggestions,
                value: String(numberOfMemorizedSuggestions))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfHistorySuggestions,
                value: String(numberOfHistorySuggestions))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfPersonalSuggestions,
                value: String(numberOfPersonalSuggestions))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfCalculatorAnnotations,
                value: String(numberOfCalculatorAnnotations))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfWikiAnnotations,
                value: String(numberOfWikiAnnotations))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfStockAnnotations,
                value: String(numberOfStockAnnotations))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfDictionaryAnnotations,
                value: String(numberOfDictionaryAnnotations))
        )

        // we only log the first 6 positions which should cover what's appear on most screens without scrolling
        return snapshotLogAttributes + Array(implLogAttributes.prefix(6))
    }

    func buildQueryAttributes(
        typedQuery: String,
        suggestedQuery: String?,
        index: Int?,
        suggestedUrl: String?,
        isFromSearchHistory: Bool
    ) -> [ClientLogCounterAttribute] {
        var queryAttributes =
            [
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.queryInputForSelectedSuggestion,
                    value: typedQuery
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.fromSearchHistory,
                    value: String(isFromSearchHistory)
                ),
            ]

        if let suggestedQuery = suggestedQuery {
            queryAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.selectedQuerySuggestion,
                    value: suggestedQuery
                )
            )
        }

        if let suggestedUrl = suggestedUrl {
            queryAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.selectedMemorizedURLSuggestion,
                    value: suggestedUrl
                )
            )
        }

        if let index = index {
            queryAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.querySuggestionPosition,
                    value: String(index)
                )
            )
        }

        if let suggestStartTime = suggestStartTime {
            if let timeToFirstScreen = timeToFirstScreen {
                queryAttributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.SuggestionAttribute.timeToFirstScreen,
                        value: String(timeToFirstScreen)
                    )
                )
            }
            let timeToSelectSuggestionInMs =
                suggestStartTime.timeDiffInMilliseconds(from: Date())
            queryAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.timeToSelectSuggestion,
                    value: String(timeToSelectSuggestionInMs)
                )
            )
            queryAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.numberOfCanceledRequest,
                    value: String(canceledSuggestRequestCount)
                )
            )
        }

        return queryAttributes
    }
}
