// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import SwiftUI

/// An abstract class that provides useful tools for executing mutations inside of a view.
public class MutationController<Mutation, Container>: AbstractController, ObservableObject
where Mutation: GraphQLMutation {
    /// This contains the currently running mutation.
    @Published public private(set) var cancellable: Combine.Cancellable?

    /// `true` if a mutation is running, `false` otherwse
    public var isRunning: Bool { cancellable != nil }

    private var onUpdate: Updater<Container>
    private var onSuccess: () -> Void

    /// - Parameters:
    ///   - animation: the animation to wrap around the `onUpdate` and `onSuccess` calls.
    ///   - onUpdate: see `SpaceLoaderView`
    ///   - onSuccess: called when the mutation is successful.
    public init(
        animation: Animation? = nil, onUpdate: @escaping Updater<Container>,
        onSuccess: @escaping () -> Void = {}
    ) {
        self.onUpdate = onUpdate
        self.onSuccess = onSuccess
        super.init(animation: animation)
    }

    /// Called by subclasses to perform their mutation while updating relevant state
    /// - Parameter mutation: the mutation to perform
    public func execute(mutation: Mutation, using api: GraphQLAPI) {
        cancellable = api.perform(mutation: mutation) { result in
            self.withOptionalAnimation {
                self.cancellable = nil
                switch result {
                case .failure:
                    self.onUpdate(nil)
                case .success(let data):
                    self.onSuccess()
                    self.onUpdate {
                        self.update(&$0, from: data, after: mutation)
                    }
                }
            }
        }
    }

    /// Implemented by subclasses to compute an optimistic result after a successful mutation
    /// - Parameters:
    ///   - optimisticResult: the data object to update
    ///   - result: the output of the mutation
    ///   - mutation: the mutation request object
    public func update(
        _ optimisticResult: inout Container, from result: Mutation.Data, after mutation: Mutation
    ) {
        fatalError("\(self).\(#function) not implemented")
    }
}
