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

    init?(_ tab: Tab?) {
        guard let tab = tab,
            var url = tab.url
        else {
            return nil
        }

        // Unwrap reader mode URLs
        if url.isReaderModeURL || url.isSyncedReaderModeURL,
            let unwrapped = url.decodeReaderModeURL
        {
            url = unwrapped
        }

        // unwrap session restore URL
        if let unwrapped = InternalURL.unwrapSessionRestore(url: url) {
            url = unwrapped
        }

        self.title = tab.title
        self.url = url
    }
}

public class CheatsheetMenuViewModel: ObservableObject {
    typealias RichResult = NeevaScopeSearch.SearchController.RichResult

    private let service: CheatsheetDataService
    private weak var tab: Tab?

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
    init(tab: Tab?, service: CheatsheetDataService) {
        self.tab = tab
        self.service = service

        self.cheatsheetDataLoading = false
    }

    // MARK: - Load Methods
    func reload() {
        load()
    }

    func load() {
        guard !cheatsheetDataLoading else { return }

        // TODO: - Check what happens when navigating to another page in this tab
        hasFetchedOnce = true

        clearCheatsheetData()

        self.cheatsheetDataLoading = true

        guard let parsedPage = SourcePage(tab)
        else {
            self.cheatsheetDataLoading = false
            return
        }

        self.sourcePage = parsedPage

        guard ["https", "http"].contains(parsedPage.url.scheme),
            !NeevaConstants.isInNeevaDomain(parsedPage.url)
        else {
            self.cheatsheetDataLoading = false
            return
        }

        fetchCheatsheetInfo(
            url: parsedPage.url.absoluteString,
            title: parsedPage.title ?? ""
        )
    }

    private func clearCheatsheetData() {
        results = []
        sourcePage = nil
        cheatsheetDataError = nil
        searchRichResultsError = nil
    }

    private func fetchCheatsheetInfo(url: String, title: String) {
        service.getCheatsheetInfo(
            url: url, title: title
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let infoResult):
                // when cheatsheet data loads successfully
                // determine query and load other rich result
                let query: String
                let querySource: LogConfig.CheatsheetAttribute.QuerySource

                if let fetchedQuery = infoResult.query {
                    // U2Q
                    querySource = .uToQ
                    query = fetchedQuery
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
                    query = url
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
                self.results = infoResult.results

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

    private func getRichResultByQuery(_ query: String) {
        service.getRichResult(query: query) { [weak self] searchResult in
            guard let self = self else {
                return
            }
            switch searchResult {
            case .success(let result):
                self.results += result.results
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    self.logFetchError(error, api: .search)
                }
                self.searchRichResultsError = error
            }

            self.filterAndSortResults()
            DispatchQueue.main.async { [self] in
                self.cheatsheetDataLoading = false
            }
        }
    }

    // MARK: - Data Parsing Methods
    private func filterAndSortResults() {
        var transformedResults = self.results

        if let url = tab?.url {
            transformedResults = results.map { $0.filtered(by: url) }.filter { !$0.isEmpty }
        }

        self.results = transformedResults.sorted {
            $0.data.order < $1.data.order
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

// MARK: - Extensions
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

extension CheatsheetResult {
    var isEmpty: Bool {
        switch data {
        case .recipe(let recipe):
            guard let ingredients = recipe.ingredients,
                let instructions = recipe.instructions
            else {
                return true
            }
            return ingredients.isEmpty || instructions.isEmpty
        case .discussions(let discussions):
            return discussions.isEmpty
        case .priceHistory(let priceHistory):
            return priceHistory.Max.Price.isEmpty || priceHistory.Min.Price.isEmpty
        case .reviewURL(let reviewURLs):
            return reviewURLs.isEmpty
        case .memorizedQuery(let memorizedQuery):
            return memorizedQuery.isEmpty
        case .productCluster(let result):
            return result.isEmpty
        case .recipeBlock(let result):
            return result.isEmpty
        case .relatedSearches(let result):
            return result.isEmpty
        case .webGroup(let result):
            return result.isEmpty
        case .newsGroup(let result):
            return result.news.isEmpty
        case .placeList(let result):
            return result.isEmpty
        case .place, .richEntity:
            return false
        }
    }

    mutating func filter(by url: URL) {
        let urlCompareOptions: [URL.EqualsOption] = [
            .ignoreFragment, .ignoreLastSlash, .normalizeHost, .ignoreScheme,
        ]

        switch data {
        case .recipe, .discussions, .priceHistory, .reviewURL, .memorizedQuery:
            // Data from cheatsheet info is not filtered
            return
        case .place, .placeList, .richEntity, .relatedSearches:
            return
        case .productCluster(let result):
            let filteredResults = result.filter { product in
                product.getTargetURL(excluding: url, with: urlCompareOptions) != nil
            }
            self.data = .productCluster(result: filteredResults)
        case .recipeBlock(let result):
            let filteredResults = result.filter { recipe in
                !recipe.url.equals(url, with: urlCompareOptions)
            }
            self.data = .recipeBlock(result: filteredResults)
        case .webGroup(let result):
            let filteredResults = result.filter {
                !$0.actionURL.equals(url, with: urlCompareOptions)
            }
            self.data = .webGroup(result: filteredResults)
        case .newsGroup(let result):
            let filteredResults = result.news.filter { news in
                !news.url.equals(url, with: urlCompareOptions)
            }

            var newResult = result
            newResult.news = filteredResults
            self.data = .newsGroup(result: newResult)
        }
    }

    func filtered(by url: URL) -> Self {
        var copy = self
        copy.filter(by: url)
        return copy
    }
}
