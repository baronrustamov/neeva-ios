// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import SwiftUI

struct ReviewURLButton: View {
    let url: URL
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    var body: some View {
        Button(action: {
            onOpenURLForCheatsheet(url, String(describing: Self.self))
        }) {
            getHostName()
        }
    }

    @ViewBuilder
    func getHostName() -> some View {
        let host = url.baseDomain?.replacingOccurrences(of: ".com", with: "")
        let lastPath = url.lastPathComponent
            .replacingOccurrences(of: ".html", with: "")
            .replacingOccurrences(of: "-", with: " ")
        if host != nil {
            HStack {
                Text(host!).bold()
                if !lastPath.isEmpty {
                    Text("(")
                        + Text(lastPath)
                        + Text(")")
                }
            }
            .withFont(unkerned: .bodyMedium)
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1).padding(-6)
            )
            .padding(6)
            .foregroundColor(.secondaryLabel)
        }
    }
}

struct RedditBacklinkButton: View {
    let url: URL
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    var body: some View {
        Button(action: {
            onOpenURLForCheatsheet(url, String(describing: Self.self))
        }) {
            getHostName()
        }
    }

    @ViewBuilder
    func getHostName() -> some View {
        let lastPath = url.lastPathComponent
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "_", with: " ")

        HStack {
            Text(lastPath).bold()
        }
        .withFont(unkerned: .bodyMedium)
        .lineLimit(1)
        .padding(4)
    }

}

struct CheatsheetNoResultView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Sorry, we couldn't find any results related to your search")
                .withFont(.headingLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            Text("If this persists, let us know what happened, and we'll fix it soon.")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
            Image("question-mark", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(minHeight: 50, maxHeight: 300)
                .accessibilityHidden(true)
                .padding(.bottom)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 10)
        .padding(.horizontal, 27)
    }
}

struct CheatsheetLoadingView: View {
    public var body: some View {
        VStack(alignment: .center, spacing: 36) {
            Spacer()
            NeevaScopeLoadingView()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 100)
            Text("Your NeevaScope is coming into focus...")
                .withFont(.headingLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 170)
            Spacer()
        }
    }
}

public struct CheatsheetMenuView: View {
    @Default(.seenCheatsheetIntro) var seenCheatsheetIntro: Bool
    @Default(.showTryCheatsheetPopover) var defaultShowTryCheatsheetPopover: Bool
    @Default(.cheatsheetDebugQuery) var cheatsheetDebugQuery: Bool

    @Environment(\.hideOverlay) private var hideOverlay
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet
    @EnvironmentObject private var model: CheatsheetMenuViewModel

    @State var height: CGFloat = 0
    @State var openSupport: Bool = false

    private let menuAction: (OverflowMenuAction) -> Void

    init(menuAction: @escaping (OverflowMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    public var body: some View {
        ZStack {
            // Show Cheatsheet Info if on Neeva domain page
            if NeevaConstants.isInNeevaDomain(model.currentPageURL) {
                CheatsheetInfoViewOnSRP {
                    hideOverlay()
                    defaultShowTryCheatsheetPopover = !seenCheatsheetIntro
                }
            } else if !seenCheatsheetIntro {
                CheatsheetInfoViewOnPage {
                    seenCheatsheetIntro = true
                }
                .onDisappear {
                    seenCheatsheetIntro = true
                }
            } else if model.cheatsheetDataLoading {
                CheatsheetLoadingView()
            } else if let error = model.cheatsheetDataError {
                ErrorView(error, in: self, tryAgain: { model.reload() })
            } else if let error = model.searchRichResultsError {
                ErrorView(error, in: self, tryAgain: { model.reload() })
            } else if model.cheatSheetIsEmpty {
                VStack(alignment: .center) {
                    CheatsheetNoResultView()
                        .onAppear {
                            guard model.hasFetchedOnce else { return }
                            ClientLogger.shared.logCounter(
                                .CheatsheetEmpty,
                                attributes: EnvironmentHelper.shared.getAttributes()
                                    + model.loggerAttributes
                            )
                        }
                    if cheatsheetDebugQuery {
                        VStack(alignment: .leading) {
                            Button(action: {
                                if let url = model.currentCheatsheetQueryAsURL {
                                    onOpenURLForCheatsheet(url, "debug")
                                }
                            }) {
                                HStack {
                                    Text("View Query")
                                    Symbol(decorative: .arrowUpForward)
                                        .scaledToFit()
                                }
                                .foregroundColor(.label)
                            }

                            Button(action: {
                                if let string = model.currentCheatsheetQueryAsURL?.absoluteString {
                                    UIPasteboard.general.string = string
                                }
                            }) {
                                HStack(alignment: .top) {
                                    Symbol(decorative: .docOnDoc)
                                        .frame(width: 20, height: 20, alignment: .center)
                                    Text(model.currentCheatsheetQueryAsURL?.absoluteString ?? "nil")
                                        .withFont(.bodySmall)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .foregroundColor(.secondaryLabel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                cheatsheetContent
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(of: openSupport) { newValue in
                                    if newValue {
                                        let image =
                                            self
                                            .environmentObject(model)
                                            .takeScreenshot(
                                                origin: proxy.frame(in: .global).origin,
                                                size: proxy.size
                                            )
                                        openSupport = false
                                        ClientLogger.shared.logCounter(
                                            .OpenCheatsheetSupport,
                                            attributes: EnvironmentHelper.shared.getAttributes()
                                                + model.loggerAttributes
                                        )
                                        menuAction(.support(screenshot: image))
                                    }
                                }
                        }
                    )
                    .onHeightOfViewChanged { height in
                        self.height = height
                    }
                    .onAppear {
                        ClientLogger.shared.logCounter(
                            .ShowCheatsheetContent,
                            attributes: EnvironmentHelper.shared.getAttributes()
                        )
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: height < 200 ? 200 : height)
    }

    @ViewBuilder
    var cheatsheetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isRecipeAllowed() {
                recipeView
                    .padding()
            }

            if let richResults = model.searchRichResults {
                VStack(alignment: .leading) {
                    ForEach(richResults) { richResult in
                        renderRichResult(for: richResult)
                    }
                }
                .padding()

            }
            if NeevaFeatureFlags[.enableBacklink] {
                redditBacklinkSession
            }
            priceHistorySection
            reviewURLSection
            memorizedQuerySection

            Divider()
                .padding(.horizontal)

            supportSection
        }
    }

    @ViewBuilder
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Support").withFont(.headingXLarge)
                .padding(.bottom, 12)
            Text("Have questions or feedback for NeevaScope?")
                .withFont(.bodyMedium)
                .fixedSize(horizontal: false, vertical: true)
            Button(
                action: {
                    openSupport = true
                },
                label: {
                    HStack {
                        Text("Contact us via Support \(Image(systemName: "bubble.left"))")
                            .foregroundColor(.blue)
                            .underline()
                            .withFont(.bodyMedium)
                        Spacer()
                    }
                })
        }
        .padding()
    }

    @ViewBuilder
    var recipeView: some View {
        if let recipe = model.cheatsheetInfo?.recipe {
            if let ingredients = recipe.ingredients, let instructions = recipe.instructions {
                if ingredients.count > 0 && instructions.count > 0 {
                    RecipeView(
                        title: recipe.title,
                        imageURL: recipe.imageURL,
                        totalTime: recipe.totalTime,
                        prepTime: recipe.prepTime,
                        ingredients: ingredients,
                        instructions: instructions,
                        yield: recipe.yield,
                        recipeRating: RecipeRating(
                            maxStars: recipe.recipeRating?.maxStars ?? 0,
                            recipeStars: recipe.recipeRating?.recipeStars ?? 0,
                            numReviews: recipe.recipeRating?.numReviews ?? 0),
                        reviews: constructReviewList(recipe: recipe),
                        faviconURL: nil,
                        currentURL: nil,
                        tabUUID: nil
                    )
                }
            }
        }
    }

    func constructReviewList(recipe: Recipe) -> [Review] {
        guard let reviewList = recipe.reviews else { return [] }
        return reviewList.map { item in
            Review(
                body: item.body,
                reviewerName: item.reviewerName,
                rating: Rating(
                    maxStars: item.rating.maxStars,
                    actualStarts: item.rating.actualStarts
                )
            )
        }
    }

    @ViewBuilder
    func renderRichResult(for richResult: SearchController.RichResult) -> some View {
        switch richResult.resultType {
        case .ProductCluster(let productCluster):
            ProductClusterList(
                products: productCluster, currentURL: model.currentPageURL?.absoluteString ?? ""
            )
        case .RecipeBlock(let recipes):
            // filter out result already showing on the current page
            RelatedRecipeList(recipes: recipes)
                .padding(.bottom, 20)
        case .RelatedSearches(let relatedSearches):
            RelatedSearchesView(relatedSearches: relatedSearches)
        case .WebGroup(let result):
            // filter out result already showing on the current page
            WebResultList(
                webResult: result,
                currentCheatsheetQueryAsURL: model.currentCheatsheetQueryAsURL,
                showQueryString: cheatsheetDebugQuery
            )
        case .NewsGroup(let newsResults):
            NewsResultsView(
                newsResults: newsResults
            )
        }
    }

    @ViewBuilder
    var redditBacklinkSession: some View {
        if model.cheatsheetInfo?.backlinkURL?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 20) {
                Text("From Reddit").withFont(.headingMedium)
                ForEach(model.cheatsheetInfo?.backlinkURL ?? [], id: \.self) { backlink in
                    if let url = URL(string: backlink) {
                        // construct reddit link
                        RedditBacklinkButton(url: url)
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var reviewURLSection: some View {
        if model.cheatsheetInfo?.reviewURL?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 20) {
                Text("Buying Guide").withFont(.headingMedium)
                ForEach(model.cheatsheetInfo?.reviewURL ?? [], id: \.self) { review in
                    if let url = URL(string: review) {
                        ReviewURLButton(url: url)
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var memorizedQuerySection: some View {
        if model.cheatsheetInfo?.memorizedQuery?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 10) {
                Text("Keep Looking").withFont(.headingXLarge)
                ForEach(model.cheatsheetInfo?.memorizedQuery?.prefix(5) ?? [], id: \.self) {
                    query in
                    QueryButtonView(query: query)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var priceHistorySection: some View {
        if let priceHistory = model.cheatsheetInfo?.priceHistory,
            !priceHistory.Max.Price.isEmpty || !priceHistory.Min.Price.isEmpty
        {
            VStack(alignment: .leading, spacing: 10) {
                Text("Price History").withFont(.headingMedium)
                if let max = priceHistory.Max,
                    !max.Price.isEmpty
                {
                    HStack {
                        Text("Highest: ").bold()
                        Text("$")
                            + Text(max.Price)

                        if !max.Date.isEmpty {
                            Text("(")
                                + Text(max.Date)
                                + Text(")")
                        }
                    }
                    .foregroundColor(.hex(0xCC3300))
                    .withFont(unkerned: .bodyMedium)
                }

                if let min = priceHistory.Min,
                    !min.Price.isEmpty
                {
                    HStack {
                        Text("Lowest: ").bold()
                        Text("$")
                            + Text(min.Price)

                        if !min.Date.isEmpty {
                            Text("(")
                                + Text(min.Date)
                                + Text(")")
                        }
                    }
                    .foregroundColor(.hex(0x008800))
                    .withFont(unkerned: .bodyMedium)
                }

                if let average = priceHistory.Average,
                    !average.Price.isEmpty
                {
                    HStack {
                        Text("Average: ").bold()
                        Text("$")
                            + Text(average.Price)
                    }
                    .foregroundColor(.hex(0x555555))
                    .withFont(unkerned: .bodyMedium)
                }
            }
            .padding()
        }
    }

    func isRecipeAllowed() -> Bool {
        guard let host = model.currentPageURL?.host,
            let baseDomain = model.currentPageURL?.baseDomain
        else { return false }
        return DomainAllowList.recipeDomains[host] ?? false
            || DomainAllowList.recipeDomains[baseDomain] ?? false
    }
}

struct CheatsheetMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CheatsheetMenuView(menuAction: { _ in })
    }
}
