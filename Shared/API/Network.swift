// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

// Neeva API access is restricted. Contact Neeva to request approval
// before extending this list.
private let approvedBundleIDs = Set([
    "co.neeva.app.ios.browser",
    "co.neeva.app.ios.browser-dev",
    "xyz.neeva.app.ios.browser",
    "xyz.neeva.app.ios.browser-dev",
])

// MARK: - GraphQLAPI
/// This singleton class manages access to the Neeva GraphQL API
public class GraphQLAPI {
    /// A `GraphQLAPI.Error` is returned when the HTTP request was successful
    /// but there are one or more error messages in the `errors` array.
    public class Error: Swift.Error, CustomStringConvertible {
        /// the underlying errors
        public let errors: [GraphQLError]
        init(_ errors: [GraphQLError]) {
            self.errors = errors
        }

        public var description: String { localizedDescription }
        public var localizedDescription: String {
            "GraphQLAPI.Error(\(errors.map(\.message)))"
        }
    }

    // MARK: - Public Properties
    /// Access the API through this instance
    public static let shared = GraphQLAPI(
        urlSessionConfig: .default,
        sessionName: "GraphQLAPI.shared"
    )
    public static let anonymous = GraphQLAPI(
        urlSessionConfig: .ephemeral,
        sessionName: "GraphQLAPI.anonymous",
        anonymous: true
    )
    public let isAnonymous: Bool

    // MARK: - Private Properties
    /// The `ApolloClient` does the actual work of performing GraphQL requests.
    private var apollo: ApolloClient

    // MARK: - Static Methods
    /// Make the raw result of a GraphQL API call more useful
    static func unwrap<Data>(
        result: Result<GraphQLResult<Data>, Swift.Error>
    ) -> Result<Data, Swift.Error> {
        switch result {
        case .success(let result):
            if let errors = result.errors, !errors.isEmpty {
                return .failure(Error(errors))
            } else if let data = result.data {
                return .success(data)
            } else {
                return .failure(GraphQLError(["message": "No data provided"]))
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Private Methods
    /// Initialize instance by creating a new `ApolloClient`
    /// - Parameters:
    ///     - urlSessionConfig: Configuration for the underlying `URLSession` used by Apollo
    ///     - sessionName: Name of the `URLSession` for debugging
    ///     - callbackQueue: `OperationQueue` for the `URLSession` to execute callbacks on `ApolloClient`
    ///     - anonymous: passed to `NeevaInterceptProvider`
    private init(
        urlSessionConfig: URLSessionConfiguration,
        sessionName: String? = nil,
        callbackQueue: OperationQueue? = nil,
        anonymous: Bool = false
    ) {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)

        let client = NeevaURLSessionClient(
            sessionConfiguration: urlSessionConfig,
            callbackQueue: callbackQueue
        )
        client.sessionName = sessionName
        let provider = NeevaInterceptProvider(client: client, store: store, anonymous: anonymous)

        guard approvedBundleIDs.contains(AppInfo.baseBundleIdentifier) else {
            fatalError(
                """
                    Bundle ID \(AppInfo.baseBundleIdentifier) cannot access the Neeva API.
                    Contact Neeva to request approval for API access.
                """
            )
        }
        let transport = NeevaNetworkTransport(
            interceptorProvider: provider,
            endpointURL: NeevaConstants.appURL / "graphql"
        )

        self.apollo = ApolloClient(networkTransport: transport, store: store)
        self.isAnonymous = anonymous
    }

    // MARK: - public Methods
    /// Perform a GraphQL fetch
    /// - Parameters:
    ///     - query: Query object
    ///     - cachPolicy: cache policy to be used for this request
    ///     - contextIdentifier: contextIdentifier for the request
    ///     - queue: `DispatchQueue` on which `resultHandler` will be called
    ///     - resultHandler: callback when the request is finished
    @discardableResult
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main,
        resultHandler: ((Result<Query.Data, Swift.Error>) -> Void)? = nil
    ) -> Combine.Cancellable {
        apollo.fetch(
            query: query,
            cachePolicy: cachePolicy,
            contextIdentifier: contextIdentifier,
            queue: queue
        ) { result in
            resultHandler?(Self.unwrap(result: result))
        }.combine
    }

    /// Perform a GraphQL fetch
    /// - Parameters:
    ///     - mutation: Mutation object
    ///     - publishResultToStore: if `false`, cache is ignored
    ///     - queue: `DispatchQueue` on which `resultHandler` will be called
    ///     - resultHandler: callback when the request is finished
    @discardableResult
    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true,
        queue: DispatchQueue = .main,
        resultHandler: ((Result<Mutation.Data, Swift.Error>) -> Void)? = nil
    ) -> Combine.Cancellable {
        apollo.perform(
            mutation: mutation,
            publishResultToStore: publishResultToStore,
            queue: queue
        ) { result in
            resultHandler?(Self.unwrap(result: result))
        }.combine
    }
}

// MARK: - NeevaURLSessionClient
// This subclass is used to get access URLSession Properties
class NeevaURLSessionClient: URLSessionClient {
    var cookieStorage: HTTPCookieStorage? {
        self.session.configuration.httpCookieStorage
    }

    var sessionName: String? {
        get {
            self.session.sessionDescription
        }
        set {
            self.session.sessionDescription = newValue
        }
    }
}

// MARK: - NeevaInterceptProvider
class NeevaInterceptProvider: InterceptorProvider {
    private let client: NeevaURLSessionClient
    private let store: ApolloStore
    private let shouldInvalidateClientOnDeinit: Bool
    private let anonymous: Bool

    init(
        client: NeevaURLSessionClient = NeevaURLSessionClient(),
        shouldInvalidateClientOnDeinit: Bool = true,
        store: ApolloStore,
        anonymous: Bool = false
    ) {
        self.client = client
        self.shouldInvalidateClientOnDeinit = shouldInvalidateClientOnDeinit
        self.store = store
        self.anonymous = anonymous
    }

    deinit {
        if self.shouldInvalidateClientOnDeinit {
            self.client.invalidate()
        }
    }

    func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [ApolloInterceptor] {
        var preFlightInterceptors: [ApolloInterceptor] = [
            MaxRetryInterceptor(),
            CacheReadInterceptor(store: self.store),
        ]
        if self.anonymous {
            preFlightInterceptors.append(AnonymizeHTTPCookieStorageIntercept(client: client))
        } else {
            preFlightInterceptors.append(LogInCookieIntercept(client: client, userInfo: .shared))
        }

        let postFlightInterceptors: [ApolloInterceptor] = [
            ResponseCodeInterceptor(),
            JSONResponseParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
            AutomaticPersistedQueryInterceptor(),
            CacheWriteInterceptor(store: self.store),
        ]

        return preFlightInterceptors
            + [NetworkFetchInterceptor(client: self.client)]
            + postFlightInterceptors
    }

    open func additionalErrorInterceptor<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> ApolloErrorInterceptor? {
        return nil
    }
}

// MARK: - AnonymizeHTTPCookieStorageIntercept
class AnonymizeHTTPCookieStorageIntercept: ApolloInterceptor {
    let client: NeevaURLSessionClient

    init(client: NeevaURLSessionClient) {
        self.client = client
    }

    func interceptAsync<Operation: Apollo.GraphQLOperation>(
        chain: Apollo.RequestChain,
        request: Apollo.HTTPRequest<Operation>,
        response: Apollo.HTTPResponse<Operation>?,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        client.cookieStorage?.removeLogInCookies()
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
}

// MARK: - LogInCookieIntercept
class LogInCookieIntercept: ApolloInterceptor {
    let client: NeevaURLSessionClient
    let userInfo: NeevaUserInfo

    init(
        client: NeevaURLSessionClient,
        userInfo: NeevaUserInfo
    ) {
        self.client = client
        self.userInfo = userInfo
    }

    func interceptAsync<Operation: Apollo.GraphQLOperation>(
        chain: Apollo.RequestChain,
        request: Apollo.HTTPRequest<Operation>,
        response: Apollo.HTTPResponse<Operation>?,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        // Read keychain on main
        precondition(Thread.isMainThread)

        if let cookie = userInfo.getLoginCookie() {
            client.cookieStorage?.setCookie(NeevaConstants.loginCookie(for: cookie))
        } else if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
            let devTokenPath = Bundle.main.path(forResource: "dev-token", ofType: "txt")
        {
            // if in an Xcode preview, use the cookie from `dev-token.txt`.
            // See `README.md` for more details.
            // only works on the second try for some reason
            _ = try? String(contentsOf: URL(fileURLWithPath: devTokenPath))
            if let cookie = try? String(contentsOf: URL(fileURLWithPath: devTokenPath)) {
                client.cookieStorage?.setCookie(
                    NeevaConstants.loginCookie(
                        for: cookie.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                )
            }
        } else {
            // Else, let this request fail with an authentication error.
            client.cookieStorage?.removeLogInCookies()
        }
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
}

// MARK: - NeevaNetworkTransport
/// Provide relevant headers and cookies, and update the URL based on the latest preferences
class NeevaNetworkTransport: RequestChainNetworkTransport {
    override func constructRequest<Operation>(
        for operation: Operation, cachePolicy: CachePolicy,
        contextIdentifier: UUID? = nil
    ) -> HTTPRequest<Operation> where Operation: GraphQLOperation {
        // Read `NeevaConstants` on main
        precondition(Thread.isMainThread)

        let req = super.constructRequest(
            for: operation, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier)
        req.graphQLEndpoint = NeevaConstants.appURL / "graphql" / operation.operationName

        req.addHeader(name: "User-Agent", value: "NeevaBrowserIOS")
        req.addHeader(
            name: NeevaConstants.Header.deviceType.name,
            value: NeevaConstants.Header.deviceType.value)
        req.addHeader(name: "X-Neeva-Client-ID", value: "co.neeva.app.ios.browser")
        req.addHeader(name: "X-Neeva-Client-Version", value: AppInfo.appVersionReportedToNeeva)

        return req
    }
}

// MARK: - HTTPCookieStorage Extensions
extension HTTPCookieStorage {
    func removeLogInCookies() {
        if let cookies = self.cookies(for: NeevaConstants.appURL) {
            if let loginCookie = cookies.first(where: { $0.name == "httpd~login" }) {
                self.deleteCookie(loginCookie)
            }

            // we are not storing preview~login, but there is an older version of our app
            // that would store the preview cookie, adding this delete to make sure
            // we clean up things properly
            if let previewCookie = cookies.first(where: { $0.name == "preview~login" }) {
                self.deleteCookie(previewCookie)
            }
        }
    }
}
