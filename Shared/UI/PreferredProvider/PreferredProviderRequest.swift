// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum PreferredProviderRequestState {
    case inProgress
    case success
    case failed
}

public class PreferredProviderRequest: ObservableObject {
    @Published public var state: PreferredProviderRequestState = .inProgress

    private var preferredProvider: SetProviderPreferenceMutation
    private var completion: () -> Void

    public func setPreferredProvider() {
        GraphQLAPI.shared.perform(mutation: preferredProvider) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.state = .success
                self.completion()
            case .failure(let error):
                self.state = .failed
                logger.error(error)
            }
        }
    }

    public init(preference: SetProviderPreferenceMutation, completion: @escaping () -> Void) {
        self.preferredProvider = preference
        self.completion = completion
        setPreferredProvider()
    }
}
