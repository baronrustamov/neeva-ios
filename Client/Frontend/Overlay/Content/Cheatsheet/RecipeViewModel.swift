// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

class RecipeViewModel: ObservableObject {
    @Published private(set) var recipe: Recipe =
        Recipe(
            title: "",
            imageURL: "",
            totalTime: nil,
            prepTime: nil,
            yield: nil,
            ingredients: nil,
            instructions: nil,
            recipeRating: nil,
            reviews: nil,
            preference: .noPreference
        )
    @Published private(set) var relatedQuery: String? = nil

    init(tabManager: TabManager) {
        if let url = tabManager.selectedTab?.url?.absoluteString {
            setupRecipeData(url: url)
        }
    }

    static public func isRecipeAllowed(url: URL) -> Bool {
        guard let host = url.host, let baseDomain = url.baseDomain else { return false }
        return DomainAllowList.recipeDomains[host] ?? false
            || DomainAllowList.recipeDomains[baseDomain] ?? false
    }

    public func updateContentWithURL(url: URL) {
        if Self.isRecipeAllowed(url: url) {
            setupRecipeData(url: url.absoluteString)
        } else {
            reset()
        }
    }

    private func reset() {
        self.recipe = Recipe(
            title: "",
            imageURL: "",
            totalTime: nil,
            prepTime: nil,
            yield: nil,
            ingredients: nil,
            instructions: nil,
            recipeRating: nil,
            reviews: nil,
            preference: .noPreference
        )
        self.relatedQuery = nil
    }

    private func setupRecipeData(url: String) {
        GraphQLAPI.shared.isAnonymous = true
        CheatsheetQueryController.getCheatsheetInfo(url: url, title: "") { result in
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
