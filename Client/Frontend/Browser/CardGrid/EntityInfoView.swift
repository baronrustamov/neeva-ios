// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct EntityInfoView: View {
    let url: URL
    let entity: PreviewEntity

    var body: some View {
        switch entity {
        case .newsItem(let newsItem):
            NewsInfoView(newsItem: newsItem)
        case .retailProduct(let product):
            ProductInfoView(product: product, url: url)
        case .richEntity:
            EmptyView()
        case .recipe(let recipe):
            RecipeInfoView(recipe: recipe, url: url)
        case .techDoc:
            ProviderInfo(url: url)
        case .webPage, .spaceLink:
            URLDisplayView(url: url)
        }
    }
}

struct ProviderInfo: View {
    let url: URL

    var body: some View {
        HStack(spacing: 6) {
            FaviconView(forSiteUrl: url)
                .frame(width: 16, height: 16)
            Text(url.baseDomain ?? "")
                .withFont(.bodySmall)
        }
    }
}

struct ProductInfoView: View {
    let product: PreviewEntity.RetailProduct
    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ProviderInfo(url: url)
            HStack {
                Text(product.formattedPrice)
                    .withFont(.headingSmall)
                    .foregroundColor(.label)
                if let productStars = product.ratingSummary?.productStars {
                    Image(systemSymbol: .starFill)
                        .renderingMode(.template)
                        .foregroundColor(Color.brand.red)
                        .font(.system(size: 12))
                        .padding(.trailing, -5)
                        .padding(.bottom, 2)
                    Text("\(String(round(productStars * 10) / 10.0))/5")
                        .withFont(.bodyMedium)
                        .foregroundColor(.label)
                }
                if let numReviews = product.ratingSummary?.numReviews {
                    if numReviews > 0 {
                        Text("(\(numReviews))")
                            .withFont(.bodyMedium)
                            .foregroundColor(.label)
                            .padding(.leading, -3)
                    }
                }
            }
        }
    }
}

struct NewsInfoView: View {
    let newsItem: PreviewEntity.NewsItem

    var body: some View {
        HStack(spacing: 4) {
            if let favicon = newsItem.faviconURL {
                FaviconView(forFavicon: Favicon(url: favicon))
                    .frame(width: 12, height: 12)
                    .cornerRadius(4)
            }
            Text(newsItem.providerName)
                .withFont(.bodySmall)
                .foregroundColor(.label)
        }
    }
}

struct RecipeInfoView: View {
    let recipe: Recipe
    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ProviderInfo(url: url)
            HStack {
                if let recipeRating = recipe.recipeRating {
                    if recipeRating.recipeStars > 0 {
                        Image(systemSymbol: .starFill)
                            .renderingMode(.template)
                            .foregroundColor(Color.brand.orange)
                            .withFont(unkerned: .bodySmall)
                            .padding(.trailing, -5)
                            .padding(.bottom, 2)
                        Text(String(round(recipeRating.recipeStars * 10) / 10.0))
                            .withFont(.bodySmall)
                            .foregroundColor(.label)
                        if let numReviews = recipeRating.numReviews {
                            if numReviews > 0 {
                                Text("(\(numReviews))")
                                    .withFont(.bodySmall)
                                    .foregroundColor(.label)
                                    .padding(.leading, -3)
                            }
                        }

                        if let _ = recipe.totalTime {
                            Text("·")
                                .withFont(.bodySmall)
                                .foregroundColor(.secondaryLabel)
                                .padding(.horizontal, -1)
                        }
                    }
                }
                if let totalTime = recipe.totalTime {
                    Text(totalTime)
                        .withFont(.bodySmall)
                        .foregroundColor(.label)
                }
            }
        }
    }
}
