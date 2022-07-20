// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum CheatsheetResultData {
    // Data from getCheatsheetInfo
    case recipe(Recipe)
    case discussions(UGCDiscussion)
    case priceHistory(CheatsheetQueryController.PriceHistory)
    case reviewURL([URL])
    case memorizedQuery([String])
    // Data from search
    case productCluster(result: NeevaScopeSearch.ProductClusterResult)
    case recipeBlock(result: NeevaScopeSearch.RecipeBlockResult)
    case relatedSearches(result: NeevaScopeSearch.RelatedSearchesResult)
    case webGroup(result: NeevaScopeSearch.WebResults)
    case newsGroup(result: NeevaScopeSearch.NewsResults)
    case place(result: NeevaScopeSearch.PlaceResult)
    case placeList(result: NeevaScopeSearch.PlaceListResult)
    case richEntity(result: NeevaScopeSearch.RichEntityResult)
}

struct CheatsheetResult: Identifiable {
    let id = UUID()
    var data: CheatsheetResultData
}

struct CheatsheetResultView: View {
    @ObservedObject var viewModel: CheatsheetMenuViewModel

    let result: CheatsheetResult

    var body: some View {
        switch result.data {
        case .recipe(let recipe):
            RecipeView(recipe: recipe)
        case .discussions(let ugcDiscussion):
            UGCDiscussionView(ugcDiscussion)
        case .priceHistory(let priceHistory):
            PriceHistoryView(priceHistory: priceHistory)
        case .reviewURL(let reviewURLs):
            BuyingGuideView(reviewURLs: reviewURLs)
        case .memorizedQuery(let memorizedQuery):
            RelatedSearchesView(title: "Keep Looking", searches: memorizedQuery.prefix(5))
        case .productCluster(let productCluster):
            ProductClusterList(
                model: viewModel,
                products: productCluster
            )
        case .recipeBlock(let recipes):
            RelatedRecipeList(recipes: recipes)
        case .relatedSearches(let relatedSearches):
            RelatedSearchesView(title: "People Also Search", searches: relatedSearches)
        case .webGroup(let result):
            WebResultList(
                webResult: result,
                currentCheatsheetQueryAsURL: viewModel.currentQueryAsURL
            )
        case .newsGroup(let newsResults):
            NewsResultsView(newsResults: newsResults)
        case .place(result: let placeResult):
            PlaceView(place: placeResult)
        case .placeList(result: let placeListResult):
            PlaceListView(placeList: placeListResult)
        case .richEntity(result: let richEntityResult):
            KnowledgeCardView(richEntity: richEntityResult)
        }
    }
}
