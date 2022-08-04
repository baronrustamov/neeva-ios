// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

open class MutationRequest<Mutation: GraphQLMutation>: ObservableObject {
    private var subcription: Combine.Cancellable? = nil

    public enum State {
        case initial
        case success
        case failure
    }

    @Published public var state: State = .initial
    @Published public var error: Error?

    public init(mutation: Mutation, testMode: Bool = false) {
        guard !testMode else {
            return
        }

        assert(subcription == nil)

        self.subcription = GraphQLAPI.shared.perform(mutation: mutation) { result in
            self.subcription = nil
            switch result {
            case .failure(let error):
                self.error = error
                self.state = .failure
            case .success(_):
                self.state = .success
            }
        }
    }
}
