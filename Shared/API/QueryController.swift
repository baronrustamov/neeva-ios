// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import SwiftUI

public typealias Updater<T> = (((inout T) -> Void)?) -> Void

/// An abstract class that provides useful tools for executing queries inside of a view.
open class QueryController<Query, Data>: AbstractController, ObservableObject
where Query: GraphQLQuery {
    public enum State {
        case running
        case success(Data)
        case failure(Error)

        public var isRunning: Bool {
            switch self {
            case .running: return true
            default: return false
            }
        }

        public var data: Data? {
            switch self {
            case .success(let data): return data
            default: return nil
            }
        }
    }
    /// The current state of the query
    @Published public private(set) var state = State.running

    /// - Parameter animation: the animation to apply when updating the `state` property
    public override init(animation: Animation? = nil) {
        super.init(animation: animation)
        self.reload()
    }

    // MARK: - Instance Methods
    /// Called by subclasses to perform their query, updating the `state` property to reflect its progress
    /// - Parameter query: the query to perform
    /// - Parameter queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
    @discardableResult open func perform(
        query: Query,
        on queue: DispatchQueue = DispatchQueue.main
    ) -> Combine.Cancellable {
        Self.perform(
            query: query,
            on: queue
        ) { result in
            self.withOptionalAnimation {
                switch result {
                case .failure(let error):
                    self.state = .failure(error)
                case .success(let data):
                    self.state = .success(data)
                }
            }
        }
    }

    /// Implemented by subclasses. Call `perform(query:)` with a query to execute.
    open func reload() {
        fatalError("\(self).\(#function) not implemented")
    }

    /// If `optimisticResult` is provided, set the current state to `.success(optimisticResult)`
    /// then run `reload()`.
    ///
    /// # Background on optimisticResult
    ///
    /// If `nil` is passed in, a regular reload takes place.
    /// However, it is often possible to know in advance what the result of the query will look like after the reload occurs (likely because you just performed a successful mutation).
    /// The provided result will be rendered by your views while you wait for the results to be validated by a fetch.
    ///
    /// This results in a better user experience, since their changes appear to take effect quicker, while still ensuring correctness by replacing the `optimisticResult` with the actual response from the server as soon as possible.
    open func reload(optimisticResult: Data?) {
        if let optimisticResult = optimisticResult {
            withOptionalAnimation {
                state = .success(optimisticResult)
            }
        }
        self.reload()
    }

    // MARK: - Class Methods
    /// Implement this function to convert the raw result of the query into a value that’s useful to your views.
    /// If you just want the query data, the extension at the bottom of the file should handle that for you if
    /// your code is structured like this:
    /// ```
    /// class MyController: QueryController<MyQuery, MyQuery.Data> { ... }
    /// ```
    /// - Parameter data: the result of the query, which you will process to generate a relevant output.
    open class func processData(_ data: Query.Data) -> Data {
        fatalError("\(self).\(#function) not implemented")
    }

    /// If you want to access the original query in addition to the response, implement this instead of `processData(_:)`.
    open class func processData(_ data: Query.Data, for query: Query) -> Data {
        processData(data)
    }

    /// This is called by the instance `perform` method, and you can use it to implement one-off helper methods
    /// on your controller class to run queries outside of the SwiftUI data flow.
    @discardableResult open class func perform(
        query: Query,
        using api: GraphQLAPI = .shared,
        on queue: DispatchQueue = DispatchQueue.main,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> Combine.Cancellable {
        api.fetch(query: query, queue: queue) { result in
            switch result {
            case .success(let data):
                completion(.success(processData(data, for: query)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension QueryController where Data == Query.Data {
    public static func processData(_ data: Query.Data) -> Data { data }
}
