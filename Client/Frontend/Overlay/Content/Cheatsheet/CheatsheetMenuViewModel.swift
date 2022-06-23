// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

struct SourcePage {
    let title: String?
    let url: URL
}

public class CheatsheetMenuViewModel: ObservableObject {
    typealias RichResult = NeevaScopeSearch.SearchController.RichResult

    private weak var tab: Tab?

    static let promoModel = CheatsheetPromoModel()

    // Store the data used to initiate the request in case the values changes
    private(set) var sourcePage: SourcePage?

    @Published private(set) var cheatsheetDataLoading: Bool
    private(set) var query: String?
    private(set) var results: [CheatsheetResult] = []
    private(set) var cheatsheetDataError: Error?
    private(set) var searchRichResultsError: Error?
    var cheatSheetIsEmpty: Bool { results.isEmpty }

    private var cheatsheetLoggerSubscription: AnyCancellable?
    // Workaround to indicate to SwiftUI view if it should log empty cheatsheet
    var hasFetchedOnce = false

    /// Debug dispaly URL for Neeva Search URL from query
    /// this property is not used in the network request
    var currentQueryAsURL: URL? {
        guard let query = query,
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            !encodedQuery.isEmpty
        else {
            return nil
        }
        return URL(string: "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)")
    }

    var loggerAttributes: [ClientLogCounterAttribute] {
        [
            ClientLogCounterAttribute(
                key: LogConfig.CheatsheetAttribute.currentPageURL,
                value: sourcePage?.url.absoluteString
            ),
            ClientLogCounterAttribute(
                key: LogConfig.CheatsheetAttribute.currentCheatsheetQuery,
                value: query
            ),
        ]
    }

    // MARK: - Init
    init(tab: Tab?) {
        self.tab = tab

        self.cheatsheetDataLoading = false
    }

    // MARK: - Load Methods
    func reload() {
        fetchCheatsheetInfo()
    }

    func fetchCheatsheetInfo() {
        guard !cheatsheetDataLoading else { return }

        // TODO: - Check what happens when navigating to another page in this tab
        hasFetchedOnce = true

        clearCheatsheetData()

        var unwrappedURL = tab?.url
        let pageTitle = tab?.title

        self.cheatsheetDataLoading = true

        // Unwrap reader mode URLs
        if (unwrappedURL?.isReaderModeURL ?? false)
            || (unwrappedURL?.isSyncedReaderModeURL ?? false)
        {
            unwrappedURL = unwrappedURL?.decodeReaderModeURL
        }
        // unwrap session restore URL
        if let unwrapped = InternalURL.unwrapSessionRestore(url: unwrappedURL) {
            unwrappedURL = unwrapped
        }

        guard let url = unwrappedURL else {
            self.cheatsheetDataLoading = false
            return
        }
        sourcePage = SourcePage(title: pageTitle, url: url)

        guard ["https", "http"].contains(url.scheme),
            !NeevaConstants.isInNeevaDomain(url)
        else {
            self.cheatsheetDataLoading = false
            return
        }

        CheatsheetQueryController.getCheatsheetInfo(
            url: url.absoluteString, title: pageTitle ?? ""
        ) { [self] result in
            // Apollo calls call back on main
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                switch result {
                case .success(let cheatsheetInfo):
                    // when cheatsheet data fetched successfully
                    // fetch other rich result
                    let query: String
                    let querySource: LogConfig.CheatsheetAttribute.QuerySource

                    if let queries = cheatsheetInfo.first?.memorizedQuery,
                        let firstQuery = queries.first
                    {
                        // U2Q
                        querySource = .uToQ
                        query = firstQuery
                    } else if let recentQuery = self.tab?.getMostRecentQuery(
                        restrictToCurrentNavigation: true)
                    {
                        // Fallback
                        // if we don't have memorized query from the url
                        // use last tab query
                        if let suggested = recentQuery.suggested {
                            querySource = .fastTapQuery
                            query = suggested
                        } else {
                            querySource = .typedQuery
                            query = recentQuery.typed
                        }
                    } else {
                        // Second Fallback
                        // use current url as query for fallback
                        querySource = .pageURL
                        query = url.absoluteString
                    }

                    // Log fallback level
                    DispatchQueue.main.async {
                        ClientLogger.shared.logCounter(
                            .CheatsheetQueryFallback,
                            attributes: EnvironmentHelper.shared.getAttributes() + [
                                ClientLogCounterAttribute(
                                    key: LogConfig.CheatsheetAttribute.cheatsheetQuerySource,
                                    value: querySource.rawValue
                                )
                            ]
                        )
                    }

                    self.query = query
                    if let data = cheatsheetInfo.first {
                        self.results = self.parseResults(from: data).map {
                            CheatsheetResult(data: $0)
                        }
                    }
                    self.getRichResultByQuery(query)
                case .failure(let error):
                    self.cheatsheetDataError = error
                    DispatchQueue.main.async { [self] in
                        self.logFetchError(error, api: .getInfo)
                        self.cheatsheetDataLoading = false
                    }
                }
            }
        }
    }

    private func clearCheatsheetData() {
        results = []
        cheatsheetDataError = nil
        searchRichResultsError = nil
    }

    // MARK: - Data Parsing Methods
    private func getRichResultByQuery(_ query: String) {
        NeevaScopeSearch.SearchController.getRichResult(query: query) { searchResult in
            // Apollo calls call back on main
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                switch searchResult {
                case .success(let richResults):
                    // log if a bad URL was received
                    if richResults.lazy.map({ $0.dataComplete }).contains(false) {
                        DispatchQueue.main.async {
                            ClientLogger.shared.logCounter(
                                .CheatsheetBadURLString,
                                attributes: EnvironmentHelper.shared.getAttributes()
                            )
                        }
                    }
                    self.results += self.parseResults(from: richResults).map {
                        CheatsheetResult(data: $0)
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        self.logFetchError(error, api: .search)
                    }
                    self.searchRichResultsError = error
                }

                self.results.sort {
                    $0.data.order < $1.data.order
                }
                DispatchQueue.main.async { [self] in
                    self.cheatsheetDataLoading = false
                }
            }
        }
    }

    private func parseResults(from cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo)
        -> [CheatsheetResultData]
    {
        var results: [CheatsheetResultData] = []

        if let recipe = cheatsheetInfo.recipe,
            let pageURL = sourcePage?.url,
            DomainAllowList.isRecipeAllowed(url: pageURL),
            let ingredients = recipe.ingredients,
            !ingredients.isEmpty,
            let instructions = recipe.instructions,
            !instructions.isEmpty
        {
            results.append(.recipe(recipe))
        }

        if let priceHistory = cheatsheetInfo.priceHistory,
            !priceHistory.Max.Price.isEmpty || !priceHistory.Min.Price.isEmpty
        {
            results.append(.priceHistory(priceHistory))
        }

        if let reviewURLs = cheatsheetInfo.reviewURL?.compactMap({ URL(string: $0) }),
            !reviewURLs.isEmpty
        {
            results.append(.reviewURL(reviewURLs))
        }

        if let memorizedQuery = cheatsheetInfo.memorizedQuery,
            !memorizedQuery.isEmpty
        {
            results.append(.memorizedQuery(memorizedQuery))
        }

        if NeevaFeatureFlags[.enableBacklink] {
            let ugcDiscussion = UGCDiscussion(backlinks: cheatsheetInfo.backlinks)
            if !ugcDiscussion.isEmpty {
                results.append(.discussions(ugcDiscussion))
            }
        }

        return results
    }

    private func parseResults(from richResults: [NeevaScopeSearch.SearchController.RichResult])
        -> [CheatsheetResultData]
    {
        let currentPageURL = tab?.url
        let urlCompareOptions: [URL.EqualsOption] = [
            .ignoreFragment, .ignoreLastSlash, .normalizeHost, .ignoreScheme,
        ]

        return richResults.compactMap { richResult -> CheatsheetResultData? in
            switch richResult.result {
            case .ProductCluster(let result):
                // for each product, we need an actionable URL outside of the current page
                let filteredResults = result.filter { product in
                    product.getTargetURL(excluding: currentPageURL, with: urlCompareOptions) != nil
                }
                guard !filteredResults.isEmpty else {
                    return nil
                }
                return .productCluster(result: filteredResults)
            case .Place(let result):
                return .place(result: result)
            case .PlaceList(let result):
                return .placeList(result: result)
            case .RichEntity(let result):
                return .richEntity(result: result)
            case .RecipeBlock(let result):
                let filteredRecipes = result.filter {
                    !$0.url.equals(currentPageURL, with: urlCompareOptions)
                }
                guard !filteredRecipes.isEmpty else {
                    return nil
                }
                return .recipeBlock(result: filteredRecipes)
            case .RelatedSearches(let result):
                return .relatedSearches(result: result)
            case .WebGroup(let result):
                let filteredResults = result.filter {
                    !$0.actionURL.equals(currentPageURL, with: urlCompareOptions)
                }
                guard !filteredResults.isEmpty else {
                    return nil
                }
                return .webGroup(result: filteredResults)
            case .NewsGroup(let result):
                let filteredNews = result.news.filter {
                    !$0.url.equals(currentPageURL, with: urlCompareOptions)
                }
                guard !filteredNews.isEmpty else {
                    return nil
                }
                var newResult = result
                newResult.news = filteredNews
                return .newsGroup(result: newResult)
            }
        }
    }

    // MARK: - Util Methods
    func targetURLForProduct(_ product: NeevaScopeSearch.Product) -> URL? {
        return product.getTargetURL(
            excluding: tab?.url,
            with: [
                .ignoreFragment, .ignoreLastSlash, .normalizeHost, .ignoreScheme,
            ]
        )
    }

    private func logFetchError(_ error: Error, api: LogConfig.CheatsheetAttribute.API) {
        ClientLogger.shared.logCounter(
            .CheatsheetFetchError,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.CheatsheetAttribute.currentPageURL,
                    value: sourcePage?.url.absoluteString ?? "nil"
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.CheatsheetAttribute.currentCheatsheetQuery,
                    value: query ?? "nil"
                ),
                ClientLogCounterAttribute(
                    key: "error",
                    value: "\(error)"
                ),
            ]
        )
    }

    private func setupCheatsheetLoaderLogger() {
        guard cheatsheetLoggerSubscription == nil else { return }
        cheatsheetLoggerSubscription =
            $cheatsheetDataLoading
            .withPrevious()
            .sink { [weak self] (prev, next) in
                // only process cases where loading changed to false from a true
                // which indicates that a loading activity has finished
                guard prev, !next, let self = self else { return }
                if self.cheatSheetIsEmpty {
                    let errorString =
                        self.cheatsheetDataError?.localizedDescription
                        ?? self.searchRichResultsError?.localizedDescription
                    ClientLogger.shared.logCounter(
                        .CheatsheetEmpty,
                        attributes: EnvironmentHelper.shared.getAttributes()
                            + self.loggerAttributes
                            + [
                                ClientLogCounterAttribute(
                                    key: "Error",
                                    value: errorString
                                )
                            ]
                    )
                }
            }
    }
}

extension NeevaScopeSearch.Product {
    fileprivate func getTargetURL(
        excluding url: URL?,
        with urlCompareOptions: [URL.EqualsOption]
    ) -> URL? {
        return
            (sellers?.lazy
            .compactMap({ URL(string: $0.url) })
            .first(where: { !$0.equals(url, with: urlCompareOptions) })
            ?? buyingGuideReviews?.lazy
            .compactMap({ URL(string: $0.reviewURL) })
            .first(where: { !$0.equals(url, with: urlCompareOptions) }))
    }
}

extension CheatsheetResultData {
    fileprivate var order: Int {
        // recipe
        // entity search results
        // Discussions
        // price history
        // review url
        // other search results
        // memorized query
        switch self {
        case .recipe:
            return 0
        case .recipeBlock:
            return 1
        case .richEntity:
            return 2
        case .newsGroup:
            return 3
        case .place:
            return 4
        case .placeList:
            return 4
        case .productCluster:
            return 5
        case .discussions:
            return 6
        case .priceHistory:
            return 7
        case .webGroup:
            return 8
        case .reviewURL:
            return 9
        case .relatedSearches:
            return 10
        case .memorizedQuery:
            return 11
        }
    }
}
