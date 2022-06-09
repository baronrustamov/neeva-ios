// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RelatedRecipeItem: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let recipe: RelatedRecipe

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading) {
                WebImage(url: URL(string: recipe.imageURL))
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 175, height: 100, alignment: .center)
                    .clipped()
                    .cornerRadius(11, corners: .top)
                Text(recipe.title)
                    .withFont(.headingMedium)
                    .foregroundColor(Color.label)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 12)
                HStack(alignment: .center) {
                    if let recipeRating = recipe.recipeRating {
                        if recipeRating.recipeStars > 0 {
                            Image(systemSymbol: .starFill)
                                .renderingMode(.template)
                                .foregroundColor(Color.brand.orange)
                                .font(.system(size: 12))
                                .padding(.trailing, -5)
                                .padding(.bottom, 2)
                            Text(String(round(recipeRating.recipeStars * 10) / 10.0))
                            if let numReviews = recipeRating.numReviews {
                                if numReviews > 0 {
                                    Text("(\(String(numReviews)))")
                                        .padding(.leading, -3)
                                }
                            }
                            if let _ = recipe.totalTime {
                                Text("·")
                                    .padding(.horizontal, -1)
                            }
                        }
                    }
                    if let totalTime = recipe.totalTime {
                        Text(String(totalTime))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .withFont(unkerned: .bodyMedium)
                .foregroundColor(Color.ui.gray30)
                Spacer()
                if let baseDomain = recipe.url.baseDomain {
                    HStack(alignment: .center) {
                        FaviconView(forSiteUrl: recipe.url)
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                        Text(baseDomain)
                            .withFont(.bodySmall)
                            .lineLimit(1)
                            .foregroundColor(Color.label)
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.bottom, 10)
            .frame(width: 175, height: 240)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(Color(light: Color.ui.gray91, dark: Color(hex: 0x383b3f)), lineWidth: 1)
            )
        }
    }

    func onClick() {
        onOpenURLForCheatsheet(recipe.url, String(describing: Self.self))
    }
}

struct RelatedRecipeList: View {
    let recipes: [RelatedRecipe]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Recipes")
                .withFont(.headingXLarge)
                .foregroundColor(Color.label)
                .padding(.bottom, 8)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recipes, id: \.url) { recipe in
                        RelatedRecipeItem(recipe: recipe)
                    }
                }
            }
        }
    }
}
