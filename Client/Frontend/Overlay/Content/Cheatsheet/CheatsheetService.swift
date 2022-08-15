// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared

// MARK: - Interface
public struct CheatsheetInfo {
    let query: String?
    let results: [CheatsheetResult]
}

public struct SearchResult {
    let results: [CheatsheetResult]
}

protocol CheatsheetDataService {
    func getCheatsheetInfo(
        url: String,
        title: String,
        completion: @escaping (Result<CheatsheetInfo, Error>) -> Void
    )

    func getRichResult(
        query: String,
        completion: @escaping (Result<SearchResult, Error>) -> Void
    )
}

final class CheatsheetServiceProvider: CheatsheetDataService {
    // MARK: - Static Properties
    static let shared = CheatsheetServiceProvider()
    static private let infoTTL: TimeInterval = .minutes(60)
    static private let searchTTL: TimeInterval = .minutes(60)

    // MARK: - Private Properties
    private let store: CheatsheetDataStore

    // MARK: - Public Methods
    init(store: CheatsheetDataStore? = nil) {
        if let store = store {
            self.store = store
        } else {
            self.store = CheatsheetDataStore(infoTTL: Self.infoTTL, searchTTL: Self.searchTTL)
        }
    }

    func getCheatsheetInfo(
        url: String,
        title: String,
        completion: @escaping (Result<CheatsheetInfo, Error>) -> Void
    ) {
        if let cachedResult = store.getCheatsheetInfo(url: url, title: title) {
            completion(.success(cachedResult))
            return
        }

        CheatsheetQueryController.getCheatsheetInfo(url: url, title: title) { [weak self] result in
            switch result {
            case .success(let cheatsheetInfo):
                let result = CheatsheetInfo(
                    query: cheatsheetInfo.first?.memorizedQuery?.first,
                    results: Self.parseResults(from: cheatsheetInfo.first, on: url).map {
                        CheatsheetResult(data: $0)
                    }
                )
                self?.store.insertCheatsheetInfo(result, url: url, title: title)
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getRichResult(
        query: String,
        completion: @escaping (Result<SearchResult, Error>) ->
            Void
    ) {
        if let cachedResult = store.getRichResult(query: query) {
            completion(.success(cachedResult))
            return
        }

        DispatchQueue.main.async {
            NeevaScopeSearch.SearchController.getRichResult(query: query) { [weak self] result in
                switch result {
                case .success(let richResults):
                    if richResults.lazy.map({ $0.dataComplete }).contains(false) {
                        let attribute = ClientLogCounterAttribute(
                            key: LogConfig.CheatsheetAttribute.currentCheatsheetQuery,
                            value: query
                        )
                        DispatchQueue.main.async {
                            ClientLogger.shared.logCounter(
                                .CheatsheetBadURLString,
                                attributes: EnvironmentHelper.shared.getAttributes()
                                    + [attribute]
                            )
                        }
                    }

                    let result = SearchResult(
                        results: Self.parseResults(from: richResults).map {
                            CheatsheetResult(data: $0)
                        }
                    )
                    self?.store.insertRichResult(result, query: query)
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Class Methods
    private static func parseResults(
        from cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo?,
        on inputURL: String
    )
        -> [CheatsheetResultData]
    {
        guard let cheatsheetInfo = cheatsheetInfo else {
            return []
        }
        var results: [CheatsheetResultData] = []

        if let recipe = cheatsheetInfo.recipe,
            let pageURL = URL(string: inputURL),
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

        let ugcDiscussion = UGCDiscussion(backlinks: cheatsheetInfo.backlinks)
        if !ugcDiscussion.isEmpty {
            results.append(.discussions(ugcDiscussion))
        }

        return results
    }

    private static func parseResults(
        from richResults: [NeevaScopeSearch.SearchController.RichResult]
    )
        -> [CheatsheetResultData]
    {
        return richResults.compactMap { richResult -> CheatsheetResultData? in
            switch richResult.result {
            case .ProductCluster(let result):
                return .productCluster(result: result)
            case .Place(let result):
                return .place(result: result)
            case .PlaceList(let result):
                return .placeList(result: result)
            case .RichEntity(let result):
                return .richEntity(result: result)
            case .RecipeBlock(let result):
                return .recipeBlock(result: result)
            case .RelatedSearches(let result):
                return .relatedSearches(result: result)
            case .WebGroup(let result):
                return .webGroup(result: result)
            case .NewsGroup(let result):
                return .newsGroup(result: result)
            }
        }
    }
}
