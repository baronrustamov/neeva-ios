// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared

class RecipeViewModel: ObservableObject {
    @Published private(set) var currentURL: URL?
    private var currentRequest: Cancellable?

    @Published private(set) var recipe: Recipe?
    @Published private(set) var relatedQuery: String? = nil

    static public func isRecipeAllowed(url: URL) -> Bool {
        guard let host = url.host, let baseDomain = url.baseDomain else { return false }
        return DomainAllowList.recipeDomains[host] ?? false
            || DomainAllowList.recipeDomains[baseDomain] ?? false
    }

    public func updateContentWithURL(url: URL?) {
        currentURL = url
        guard let url = url,
            Self.isRecipeAllowed(url: url)
        else {
            reset()
            return
        }
        setupRecipeData(url: url.absoluteString)
    }

    private func reset() {
        currentRequest?.cancel()
        currentRequest = nil
        self.recipe = nil
        self.relatedQuery = nil
    }

    private func setupRecipeData(url: String) {
        GraphQLAPI.shared.isAnonymous = true
        currentRequest = CheatsheetQueryController.getCheatsheetInfo(
            url: url, title: ""
        ) { result in
            switch result {
            case .success(let cheatsheetInfo):
                let data = cheatsheetInfo[0]
                if data.recipe != nil {
                    self.recipe = data.recipe!

                    if let memorizedQuery = data.memorizedQuery {
                        if memorizedQuery.count > 0 {
                            self.relatedQuery = memorizedQuery[0]
                        }
                    }
                }
                break
            case .failure(_):
                self.reset()
                break
            }

        }
        GraphQLAPI.shared.isAnonymous = false
    }
}
