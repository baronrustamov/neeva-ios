// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI

public class CheatsheetMenuViewModel: ObservableObject {
    typealias RichResult = NeevaScopeSearch.SearchController.RichResult

    private weak var tab: Tab?

    private(set) var currentPageTitle: String?
    private(set) var currentPageURL: URL?
    private(set) var currentCheatsheetQuery: String?

    @Published private(set) var cheatsheetDataLoading: Bool
    private(set) var cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo?
    private(set) var searchRichResults: [RichResult]?
    private(set) var cheatsheetDataError: Error?
    private(set) var searchRichResultsError: Error?

    private(set) var placeViewModel: PlaceViewModel?
    private(set) var placeListViewModel: PlaceListViewModel?

    private var cheatsheetLoggerSubscription: AnyCancellable?
    // Workaround to indicate to SwiftUI view if it should log empty cheatsheet
    var hasFetchedOnce = false

    var cheatSheetIsEmpty: Bool {
        if let cheatsheetInfo = cheatsheetInfo {
            if let recipe = cheatsheetInfo.recipe {
                // recipeView
                if let ingredients = recipe.ingredients,
                    let instructions = recipe.instructions,
                    ingredients.count > 0,
                    instructions.count > 0
                {
                    return false
                }
            }
            // priceHistorySection
            if let priceHistory = cheatsheetInfo.priceHistory,
                priceHistory.Max.Price.isEmpty || !priceHistory.Min.Price.isEmpty
            {
                return false
            }
            // reviewURLSection
            if cheatsheetInfo.reviewURL?.count ?? 0 > 0 {
                return false
            }
            // memorizedQuerySection
            if cheatsheetInfo.memorizedQuery?.count ?? 0 > 0 {
                return false
            }
        }
        // renderRichResult views
        if let searchRichResults = searchRichResults,
            !searchRichResults.isEmpty
        {
            return false
        }
        return true
    }

    /// Debug dispaly URL for Neeva Search URL from query
    /// this property is not used in the network request
    var currentCheatsheetQueryAsURL: URL? {
        guard let query = currentCheatsheetQuery,
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed),
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
                value: currentPageURL?.absoluteString
            ),
            ClientLogCounterAttribute(
                key: LogConfig.CheatsheetAttribute.currentCheatsheetQuery,
                value: currentCheatsheetQuery
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

        hasFetchedOnce = true

        clearCheatsheetData()

        currentPageURL = tab?.url

        if let title = tab?.title {
            currentPageTitle = title
        } else {
            currentPageTitle = ""
        }

        self.cheatsheetDataLoading = true

        // Unwrap reader mode URLs
        if (currentPageURL?.isReaderModeURL ?? false)
            || (currentPageURL?.isSyncedReaderModeURL ?? false)
        {
            currentPageURL = currentPageURL?.decodeReaderModeURL
        }
        // unwrap session restore URL
        if let unwrapped = InternalURL.unwrapSessionRestore(url: currentPageURL) {
            currentPageURL = unwrapped
        }

        guard let url = currentPageURL,
            ["https", "http"].contains(url.scheme),
            !NeevaConstants.isInNeevaDomain(url)
        else {
            self.cheatsheetDataLoading = false
            return
        }

        CheatsheetQueryController.getCheatsheetInfo(
            url: url.absoluteString, title: currentPageTitle!
        ) { [self] result in
            switch result {
            case .success(let cheatsheetInfo):
                self.cheatsheetInfo = cheatsheetInfo.first

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
                ClientLogger.shared.logCounter(
                    .CheatsheetQueryFallback,
                    attributes: EnvironmentHelper.shared.getAttributes() + [
                        ClientLogCounterAttribute(
                            key: LogConfig.CheatsheetAttribute.cheatsheetQuerySource,
                            value: querySource.rawValue
                        )
                    ]
                )

                self.currentCheatsheetQuery = query
                self.getRichResultByQuery(query)
            case .failure(let error):
                Logger.browser.error("Error: \(error)")
                self.cheatsheetDataError = error
                self.cheatsheetDataLoading = false
            }
        }
    }

    private func getRichResultByQuery(_ query: String) {
        NeevaScopeSearch.SearchController.getRichResult(query: query) { searchResult in
            switch searchResult {
            case .success(let richResults):
                // log if a bad URL was received
                if richResults.lazy.map({ $0.dataComplete }).contains(false) {
                    ClientLogger.shared.logCounter(
                        .CheatsheetBadURLString,
                        attributes: EnvironmentHelper.shared.getAttributes()
                    )
                }
                self.searchRichResults = self.removeCurrentPageURLs(from: richResults)

                // Create Children ViewModels if corresponding results exist
                self.searchRichResults?.forEach { result in
                    switch result.result {
                    case .Place(let result):
                        if self.placeViewModel == nil {
                            self.placeViewModel = PlaceViewModel(result)
                        }
                    case .PlaceList(let result):
                        if self.placeListViewModel == nil {
                            self.placeListViewModel = PlaceListViewModel(result)
                        }
                    default:
                        return
                    }
                }
            case .failure(let error):
                Logger.browser.error("Error: \(error)")
                self.searchRichResultsError = error
            }
            self.cheatsheetDataLoading = false
        }
    }

    private func removeCurrentPageURLs(from richResults: [RichResult]) -> [RichResult] {
        let urlCompareOptions: [URL.EqualsOption] = [
            .ignoreFragment, .ignoreLastSlash, .normalizeHost, .ignoreScheme,
        ]
        return richResults.compactMap { richResult -> RichResult? in
            switch richResult.result {
            case .ProductCluster, .Place, .PlaceList, .RichEntity:
                return richResult
            case .RecipeBlock(let result):
                let filteredRecipes = result.filter {
                    !$0.url.equals(currentPageURL, with: urlCompareOptions)
                }
                guard !filteredRecipes.isEmpty else {
                    return nil
                }
                return RichResult(
                    id: richResult.id,
                    result: .RecipeBlock(result: filteredRecipes)
                )
            case .RelatedSearches:
                return richResult
            case .WebGroup(let result):
                let filteredResults = result.filter {
                    !$0.actionURL.equals(currentPageURL, with: urlCompareOptions)
                }
                guard !filteredResults.isEmpty else {
                    return nil
                }
                return RichResult(
                    id: richResult.id,
                    result: .WebGroup(result: filteredResults)
                )
            case .NewsGroup(let result):
                let filteredNews = result.news.filter {
                    !$0.url.equals(currentPageURL, with: urlCompareOptions)
                }
                guard !filteredNews.isEmpty else {
                    return nil
                }
                var newResult = result
                newResult.news = filteredNews
                return RichResult(
                    id: richResult.id,
                    result: .NewsGroup(result: newResult)
                )
            }
        }
    }

    // MARK: - Util Methods
    private func clearCheatsheetData() {
        cheatsheetInfo = nil
        searchRichResults = nil
        cheatsheetDataError = nil
        searchRichResultsError = nil

        placeViewModel = nil
        placeListViewModel = nil
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
