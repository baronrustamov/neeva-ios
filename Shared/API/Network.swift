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
    /// - Tag: AuthConfig
    public enum AuthConfig {
        /// Use [LogInCookieIntercept](x-source-tag://LogInCookieIntercept)
        case shared
        /// Use [AnonymizeHTTPCookieStorageIntercept](x-source-tag://AnonymizeHTTPCookieStorageIntercept)
        case anonymous
        /// Use [PreviewCookieIntercept](x-source-tag://PreviewCookieIntercept)
        case preview
    }

    public struct Configuration {
        let urlSessionConfig: URLSessionConfiguration
        let sessionName: String?
        let callbackQueue: OperationQueue?
        let authConfig: AuthConfig?

        /// Configuration to initialize a new GraphQLAPI instance
        /// - Parameters:
        ///     - urlSessionConfig: Configuration for the underlying `URLSession` used by Apollo
        ///     - sessionName: Name of the `URLSession` for debugging
        ///     - callbackQueue: `OperationQueue` on which the `URLSession` will execute callbacks to `ApolloClient`
        ///     - authConfig: if not `nil`, this will add an interceptor to the apollo request chain to manage login cookies. See [AuthConfig](x-source-tag://AuthConfig)
        public init(
            urlSessionConfig: URLSessionConfiguration,
            sessionName: String? = nil,
            callbackQueue: OperationQueue? = nil,
            authConfig: AuthConfig? = .shared
        ) {
            self.urlSessionConfig = urlSessionConfig
            self.sessionName = sessionName
            self.callbackQueue = callbackQueue
            self.authConfig = authConfig
        }

        public static let shared = Self.init(
            urlSessionConfig: .default,
            sessionName: "GraphQLAPI.shared",
            callbackQueue: nil,
            authConfig: .shared
        )

        public static let anonymous = Self.init(
            urlSessionConfig: .ephemeral,
            sessionName: "GraphQLAPI.anonymous",
            callbackQueue: nil,
            authConfig: .anonymous
        )
    }

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
    public static let shared = GraphQLAPI(.shared)
    public static let anonymous = GraphQLAPI(.anonymous)

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
    public init(
        _ configuration: Configuration
    ) {
        guard approvedBundleIDs.contains(AppInfo.baseBundleIdentifier) else {
            fatalError(
                """
                    Bundle ID \(AppInfo.baseBundleIdentifier) cannot access the Neeva API.
                    Contact Neeva to request approval for API access.
                """
            )
        }

        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)

        let client = NeevaURLSessionClient(
            sessionConfiguration: configuration.urlSessionConfig,
            callbackQueue: configuration.callbackQueue
        )
        client.sessionName = configuration.sessionName
        let provider = NeevaInterceptProvider(
            client: client, store: store, authConfig: configuration.authConfig
        )

        let transport = NeevaNetworkTransport(
            interceptorProvider: provider,
            endpointURL: NeevaConstants.appURL / "graphql"
        )

        self.apollo = ApolloClient(networkTransport: transport, store: store)
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
    private let authConfig: GraphQLAPI.AuthConfig?

    init(
        client: NeevaURLSessionClient = NeevaURLSessionClient(),
        shouldInvalidateClientOnDeinit: Bool = true,
        store: ApolloStore,
        authConfig: GraphQLAPI.AuthConfig?
    ) {
        self.client = client
        self.shouldInvalidateClientOnDeinit = shouldInvalidateClientOnDeinit
        self.store = store
        self.authConfig = authConfig
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

        if let authConfig = self.authConfig {
            switch authConfig {
            case .shared:
                preFlightInterceptors.append(
                    LogInCookieIntercept(client: client, userInfo: .shared)
                )
            case .anonymous:
                preFlightInterceptors.append(
                    AnonymizeHTTPCookieStorageIntercept(client: client)
                )
            case .preview:
                preFlightInterceptors.append(
                    PreviewCookieIntercept(client: client)
                )
            }
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
/// This removes log in cookies from the client's cookie storage
/// - Tag: AnonymizeHTTPCookieStorageIntercept
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
/// This reads sign in cookies from ``NeevaUserInfo`` and inserts it into the client's cookie storage
/// - Tag: LogInCookieIntercept
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

        // WKWebKit can leak cookies into URLSessions if both are using persistent
        // cookie storages on physical devices. Remove these preview cookies
        client.cookieStorage?.removePreviewCookie()

        chain.proceedAsync(request: request, response: response, completion: completion)
    }
}

// MARK: - PreviewCookieIntercept
/// This reads sign in cookies from ``NeevaConstants`` and inserts it into the client's cookie storage
/// - Tag: PreviewCookieIntercept
class PreviewCookieIntercept: ApolloInterceptor {
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
        // Read keychain on main
        precondition(Thread.isMainThread)

        if let cookie = try? NeevaConstants.getPreviewCookie() {
            client.cookieStorage?.setCookie(NeevaConstants.previewCookie(for: cookie))
        } else {
            // Else, let this request fail with an authentication error.
            client.cookieStorage?.removePreviewCookie()
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

    func removePreviewCookie() {
        if let cookies = self.cookies(for: NeevaConstants.appURL) {
            if let loginCookie = cookies.first(where: { $0.name == "httpd~preview" }) {
                self.deleteCookie(loginCookie)
            }
        }
    }
}
