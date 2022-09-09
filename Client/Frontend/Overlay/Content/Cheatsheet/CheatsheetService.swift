// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    private lazy var cookieFetcher = PreviewCookieFetcher()
    private lazy var previewClient: GraphQLAPI = {
        let configuration = GraphQLAPI.Configuration(
            urlSessionConfig: .ephemeral,
            sessionName: "CheatsheetServiceProvider.GraphQLAPI.preview",
            callbackQueue: nil,
            authConfig: .preview
        )
        return GraphQLAPI(configuration)
    }()

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
        completion: @escaping (Result<SearchResult, Error>) -> Void
    ) {
        if let cachedResult = store.getRichResult(query: query) {
            completion(.success(cachedResult))
            return
        }

        fetchRichResult(query: query) { [weak self] result in
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

    // MARK: - Private Methods
    private func fetchRichResult(
        query: String,
        completion: @escaping (Result<[NeevaScopeSearch.SearchController.RichResult], Error>) ->
            Void
    ) {
        // Read keychain values on main
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [self] in
                self.fetchRichResult(query: query, completion: completion)
            }
            return
        }

        // isUserLoggedIn is optimistically true, cannot use that value on first launch
        if NeevaUserInfo.shared.getLoginCookie() != nil {
            NeevaScopeSearch.SearchController.getRichResult(
                using: .shared,
                query: query,
                completion: completion
            )
        } else {
            fetchPreviewResults(
                query: query,
                forceFetchCookie: false,
                retryOnAuthError: true,
                completion: completion
            )
        }
    }

    private func fetchPreviewResults(
        query: String,
        forceFetchCookie: Bool,
        retryOnAuthError: Bool,
        completion: @escaping (Result<[NeevaScopeSearch.SearchController.RichResult], Error>) ->
            Void
    ) {
        // Completion handler to handle retry on auth error
        func handleResult(_ result: Result<[NeevaScopeSearch.SearchController.RichResult], Error>) {
            if case .failure(let failure) = result,
                failure.isAuthError
            {
                let callFetchPreviewResults = { [self] in
                    self.fetchPreviewResults(
                        query: query,
                        // Ping "preview" to get new cookie on retry
                        forceFetchCookie: true,
                        // Max 1 retry
                        retryOnAuthError: false,
                        completion: completion
                    )
                }
                if Thread.isMainThread {
                    callFetchPreviewResults()
                } else {
                    DispatchQueue.main.async {
                        callFetchPreviewResults()
                    }
                }
            } else {
                completion(result)
            }
        }

        // Fetch preview cookie before making the request
        if forceFetchCookie || (try? NeevaConstants.getPreviewCookie()) == nil {
            self.cookieFetcher.fetch(receiveOn: .main) { [self] result in
                // return to main to set cookie and initiate request
                if case .success(let cookie) = result {
                    try? NeevaConstants.setPreviewCookie(cookie.value)
                }

                NeevaScopeSearch.SearchController.getRichResult(
                    using: self.previewClient,
                    query: query,
                    completion: handleResult
                )
            }
        } else {
            NeevaScopeSearch.SearchController.getRichResult(
                using: self.previewClient,
                query: query,
                completion: handleResult
            )
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

/// Util to ping the preview endpoint and read the preview cookie response
private class PreviewCookieFetcher {
    enum PreviewCookieError: Error {
        case previewCookieNotFound
    }

    // Synchronization Properties
    /*
     * This class needs synchronization to make sure that calls to `fetch` are thread safe,
     * and that callers are not blocked by the fetch calls.
     * All calls to `fetch` share a `URLSession`. At the start of each request, it erases all
     * the cookies in the `URLSession`. Then it fires a network request, which asynchronously
     * writes to the cookie storage without a callback. Then, the session fires a completion
     * callback when the network request finishes.
     *
     * In order to support submitting `fetch` tasks without data races between concurrent tasks,
     * all the tasks must be serialized. In addition, the caller shouldn't be blocked, and
     * and thread explosions should be avoided.
     *
     * The final implementation uses a serial background queue and submits synchronous network
     * calls to receive and return cookies
     */
    private let queue: DispatchQueue

    // Networking Properties
    private let session: URLSession

    init(_ qos: DispatchQoS = .userInitiated) {
        // This must be a serial queue because each fetch action blocks the queue until the request
        // is complete. Otherwise, this could lead to thread explosion
        queue = DispatchQueue(
            label: "co.neeva.app.ios.browser.PreviewCookieFetcher",
            qos: qos
        )

        session = URLSession(configuration: .ephemeral)
    }

    /// method to fetch cookie
    ///
    /// Caller needs to retain reference to the fetcher object until the completion is called
    func fetch(
        receiveOn queue: DispatchQueue? = nil,
        completion: @escaping (Result<HTTPCookie, Error>) -> Void
    ) {
        // Read app host URL at invocation before scheduling onto queue
        precondition(Thread.isMainThread)
        let url = NeevaConstants.buildAppURL("preview?pid=neeva_scope")

        // This call must be `async` in case the caller is on a concurrent queue which will cause
        // a thread explostion
        self.queue.async { [weak self] in
            guard let self = self else {
                return
            }

            // Clear cookie storage
            self.session.configuration.httpCookieStorage?.removeCookies(since: .distantPast)

            // Pin endpoint to get new cookie synchronously
            let (_, _, error) = self.session.dataTaskSync(url: url, timeout: .distantFuture)

            // Create result object
            let result: Result<HTTPCookie, Error> = {
                do {
                    if let error = error {
                        throw error
                    }

                    // Read new cookie
                    guard let storage = self.session.configuration.httpCookieStorage,
                        let cookies = storage.cookies(for: url),
                        let previewCookie = cookies.previewCookies.first
                    else {
                        throw PreviewCookieError.previewCookieNotFound
                    }

                    return .success(previewCookie)
                } catch {
                    return .failure(error)
                }
            }()

            // Make callback
            if let queue = queue {
                queue.async {
                    completion(result)
                }
            } else {
                completion(result)
            }
        }
    }
}

extension Array where Element == HTTPCookie {
    fileprivate var previewCookies: Self {
        self.filter { cookie in
            cookie.name == "httpd~preview"
        }
    }
}

extension Error {
    fileprivate var isAuthError: Bool {
        guard let graphQLError = self as? GraphQLAPI.Error else {
            return false
        }

        let errors = graphQLError.errors.compactMap(\.message)
        guard errors.count == 1 else {
            return false
        }

        let authErrorStrings = ["login required to access this field", "unauthorized access"]
        return authErrorStrings.contains(errors.first!)
    }
}

extension URLSession {
    fileprivate func dataTaskSync(
        url: URL,
        timeout: DispatchTime
    ) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        let _ = semaphore.wait(timeout: timeout)

        return (data, response, error)
    }
}
