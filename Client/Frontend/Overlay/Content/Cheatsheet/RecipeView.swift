// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RecipeView: View {
    @State private var expanded: Bool = false

    let title: String?
    let imageURL: String?
    let totalTime: String?
    let prepTime: String?
    let ingredients: [String]?
    let instructions: [String]?
    let yield: String?
    let recipeRating: RecipeRating?
    let reviews: [Review]?
    let faviconURL: URL?
    let currentURL: URL?
    let tabUUID: String?

    var body: some View {
        ScrollViewReader { scrollViewReader in
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        if let title = title {
                            Text(title)
                                .withFont(.headingXLarge)
                                .foregroundColor(Color.label)
                                .lineLimit(1)
                                .id("Top")
                        }
                        ratingStarsComp
                        HStack {
                            if let faviconURL = faviconURL {
                                WebImage(url: faviconURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 16, height: 16)
                                    .clipShape(Circle())
                                    .cornerRadius(6)
                            }
                            if let currentURL = currentURL {
                                Text(currentURL.baseDomain ?? "")
                                    .withFont(.bodySmall)
                                    .foregroundColor(Color.label)
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        if let imageURL = imageURL {
                            WebImage(url: URL(string: imageURL))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 68, height: 68)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
                Divider()
                    .padding(.vertical, 6)
                VStack(alignment: .leading, spacing: 6) {
                    if let totalTime = totalTime {
                        ScrollView(.horizontal) {
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemSymbol: .clock)
                                    .renderingMode(.template)
                                    .foregroundColor(Color.secondaryLabel)
                                    .font(.system(size: 14))
                                    .padding(.leading, 3)
                                    .padding(.trailing, 10)
                                Text("\(totalTime) (Total Time)")
                                if let prepTime = prepTime {
                                    Text(", \(prepTime) (Prep Time)")
                                }
                            }
                            .withFont(unkerned: .bodyMedium)
                        }
                    }
                    if let yield = yield {
                        ScrollView(.horizontal) {
                            HStack(alignment: .center) {
                                Image(systemSymbol: .person2)
                                    .renderingMode(.template)
                                    .foregroundColor(Color.secondaryLabel)
                                    .font(.system(size: 14))
                                Text(constructYieldString(input: yield))
                                    .withFont(.bodyMedium)
                            }
                        }
                    }
                }
                .padding(.bottom, 2)
                Divider()
                    .padding(.vertical, 6)
                listings

                expandButton
                    .onChange(of: expanded) { _ in
                        if !expanded {
                            scrollViewReader.scrollTo("Top", anchor: .bottom)
                        }
                    }
            }
            .onDisappear(perform: onDisappearCleanup)
        }
    }

    @ViewBuilder
    var ratingStarsComp: some View {
        HStack(alignment: .center) {
            if let recipeRating = recipeRating {
                let normalizedRating = Int(
                    floor(
                        normalizeRating(
                            stars: recipeRating.recipeStars, maxStars: recipeRating.maxStars
                        )))
                if recipeRating.recipeStars > 0, normalizedRating >= 1 {
                    ForEach(
                        (1...normalizedRating), id: \.self
                    ) { _ in
                        Image(systemSymbol: .starFill)
                            .renderingMode(.template)
                            .foregroundColor(Color.brand.orange)
                            .font(.system(size: 12))
                            .padding(.trailing, -4)
                    }
                    if round(
                        normalizeRating(
                            stars: recipeRating.recipeStars, maxStars: recipeRating.maxStars))
                        > floor(
                            normalizeRating(
                                stars: recipeRating.recipeStars, maxStars: recipeRating.maxStars))
                    {
                        Image(systemSymbol: .starLeadinghalfFill)
                            .renderingMode(.template)
                            .foregroundColor(Color.brand.orange)
                            .font(.system(size: 12))
                    }
                    if let numReviews = recipeRating.numReviews {
                        if numReviews > 0 {
                            Text("\(numReviews) Reviews")
                                .withFont(.bodySmall)
                                .foregroundColor(Color.secondaryLabel)
                                .padding(.top, 3)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    var listings: some View {
        if let ingredients = ingredients {
            Text("Ingredients")
                .withFont(.headingMedium)
            ForEach(
                (expanded || ingredients.count < 3)
                    ? ingredients[..<ingredients.count]
                    : ingredients[..<3],
                id: \.self
            ) {
                Text(cleanupText(input: $0))
                    .withFont(.bodyMedium)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        if expanded {
            Divider()
                .padding(.vertical, 6)
            if let instructions = instructions {
                Text("Instructions")
                    .withFont(.headingMedium)
                ForEach(instructions.indices, id: \.self) { i in
                    HStack(alignment: .top) {
                        Text("\(i+1). ")
                        Text("\(cleanupText(input: instructions[i]))")
                    }
                    .withFont(unkerned: .bodyMedium)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    var expandButton: some View {
        Button(action: toggleShowMoreRecipeButton) {
            HStack(alignment: .center) {
                Text("\(expanded ? "Hide" : "See") Full Recipe")
                Image(systemSymbol: expanded ? .chevronUp : .chevronDown)
                    .renderingMode(.template)
                    .font(.system(size: 16))
            }
            .withFont(unkerned: .bodyLarge)
            .frame(maxWidth: .infinity, maxHeight: 48)
            .foregroundColor(Color.label)
            .background(Capsule().fill(Color.ui.quarternary))
        }
        .frame(maxWidth: .infinity, minHeight: 48)
        .background(
            Rectangle()
                .fill(Color.DefaultBackground)
                .blur(radius: 20, opaque: false)
                .frame(height: 90)
                .opacity(expanded ? 0 : 1)
        )
    }

    func toggleShowMoreRecipeButton() {
        if !expanded {
            ClientLogger.shared.logCounter(
                .RecipeCheatsheetShowMoreRecipe,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
        }
        expanded.toggle()
    }

    func normalizeRating(stars: Double, maxStars: Double) -> Double {
        let standardStars = 5.0

        if maxStars <= standardStars {
            return stars
        }

        return stars / maxStars * standardStars
    }

    func cleanupText(input: String) -> String {
        return
            input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    func constructYieldString(input: String) -> String {
        let prefix = input.lowercased().hasPrefix("make") ? "" : "Makes "
        return "\(prefix)\(cleanupText(input: input))"
    }

    func onDisappearCleanup() {
        expanded = false
    }
}
