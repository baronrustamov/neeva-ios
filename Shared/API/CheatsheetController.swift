// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

public struct Rating {
    public let maxStars: Double
    public let actualStarts: Double

    public init(maxStars: Double, actualStarts: Double) {
        self.maxStars = maxStars
        self.actualStarts = actualStarts
    }
}

public struct Review {
    public let body: String
    public let reviewerName: String
    public let rating: Rating

    public init(body: String, reviewerName: String, rating: Rating) {
        self.body = body
        self.reviewerName = reviewerName
        self.rating = rating
    }
}

public struct RecipeRating {
    public let maxStars: Double
    public let recipeStars: Double
    public let numReviews: Int?

    public init(maxStars: Double, recipeStars: Double, numReviews: Int?) {
        self.maxStars = maxStars
        self.recipeStars = recipeStars
        self.numReviews = numReviews
    }
}

public struct Recipe {
    public var title: String
    public var imageURL: String
    public var totalTime: String?
    public var prepTime: String?
    public var yield: String?
    public var ingredients: [String]?
    public var instructions: [String]?
    public var recipeRating: RecipeRating?
    public var reviews: [Review]?
    public var preference: UserPreference?

    public init(
        title: String, imageURL: String, totalTime: String?,
        prepTime: String?, yield: String?,
        ingredients: [String]?, instructions: [String]?, recipeRating: RecipeRating?,
        reviews: [Review]?, preference: UserPreference
    ) {
        self.title = title
        self.imageURL = imageURL
        self.totalTime = totalTime
        self.prepTime = prepTime
        self.yield = yield
        self.ingredients = ingredients
        self.instructions = instructions
        self.recipeRating = recipeRating
        self.reviews = reviews
        self.preference = preference
    }
}

public struct RelatedRecipe {
    public var title: String
    public var imageURL: String
    public var url: URL
    public var totalTime: String?
    public var recipeRating: RecipeRating?

    public init(
        title: String, imageURL: String, url: URL, totalTime: String?, recipeRating: RecipeRating?
    ) {
        self.title = title
        self.imageURL = imageURL
        self.url = url
        self.totalTime = totalTime
        self.recipeRating = recipeRating
    }
}

public class CheatsheetQueryController: QueryController<
    CheatsheetInfoQuery, [CheatsheetQueryController.CheatsheetInfo]
>
{
    /// Parses date in format like `2019-10-08 03:07:19 +0000 UTC`
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z v"
        return formatter
    }()

    private static let queue = DispatchQueue(
        label: "co.neeva.app.ios.shared.CheatsheetQueryController",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: nil
    )

    public struct PriceHistory {
        public var InStock: Bool
        public var Max: PriceDate
        public var Min: PriceDate
        public var Current: PriceDate
        public var Average: PriceDate
    }

    public struct PriceDate {
        public var Date: String
        public var Price: String
    }

    public struct Backlink {
        public struct Comment {
            public let body: String
            public let url: URL?
            public let score: Int?
            public let date: Date?

            init?(
                from comment: CheatsheetInfoQuery.Data.GetCheatsheetInfo.BacklinkUrl.Forum.Comment
            ) {
                guard let body = comment.body,
                    body.isNotBlank
                else {
                    return nil
                }
                self.body = body
                self.url = {
                    guard let urlString = comment.url else {
                        return nil
                    }
                    return URL(string: urlString)
                }()
                self.score = comment.score
                self.date = {
                    guard let date = comment.date else {
                        return nil
                    }
                    return CheatsheetQueryController.dateFormatter.date(from: date)
                }()
            }
        }

        public let title: String
        public let url: URL
        public let domain: String?
        public let snippet: String?
        public let score: Int?
        public let date: Date?
        public let numComments: Int?
        public let comments: [Comment]?

        init?(from backlink: CheatsheetInfoQuery.Data.GetCheatsheetInfo.BacklinkUrl) {
            guard let title = backlink.title,
                let urlString = backlink.url,
                let url = URL(string: urlString),
                let snippet = backlink.snippet
            else {
                return nil
            }

            self.title = title
            self.url = url
            self.domain = backlink.domain
            self.snippet = snippet

            self.score = nil
            self.date = nil
            self.numComments = nil
            self.comments = nil
        }

        init?(from forum: CheatsheetInfoQuery.Data.GetCheatsheetInfo.BacklinkUrl.Forum) {
            guard let title = forum.title,
                let urlString = forum.url ?? forum.source,
                let url = URL(string: urlString)
            else {
                return nil
            }

            self.title = title
            self.url = url
            self.domain = forum.domain
            self.snippet = forum.body
            self.score = forum.score
            self.date = {
                guard let date = forum.date else {
                    return nil
                }
                return CheatsheetQueryController.dateFormatter.date(from: date)
            }()
            self.numComments = forum.numComments
            self.comments = forum.comments?.compactMap({
                Comment(from: $0)
            })
        }
    }

    public struct CheatsheetInfo {
        public var reviewURL: [String]?
        public var priceHistory: PriceHistory?
        public var memorizedQuery: [String]?
        public var recipe: Recipe?
        public var backlinks: [Backlink]?
    }

    private var url: URL

    public init(url: URL) {
        self.url = url
        super.init()
    }

    @available(*, unavailable)
    public override func reload() {
        fatalError("reload() has not been implemented")
    }

    public override class func processData(_ data: CheatsheetInfoQuery.Data) -> [CheatsheetInfo] {
        var result: CheatsheetInfo = CheatsheetInfo()

        if let reviewUrl = data.getCheatsheetInfo?.reviewUrl {
            result.reviewURL = reviewUrl
        }

        if let memorizedQuery = data.getCheatsheetInfo?.memorizedQuery {
            result.memorizedQuery = memorizedQuery
        }

        if let priceHistory = data.getCheatsheetInfo?.priceHistory {
            let inStock = priceHistory.inStock ?? false
            let max = PriceDate(
                Date: priceHistory.max?.date ?? "",
                Price: priceHistory.max?.priceUsd ?? "")
            let min = PriceDate(
                Date: priceHistory.min?.date ?? "",
                Price: priceHistory.min?.priceUsd ?? "")
            let current = PriceDate(
                Date: priceHistory.current?.date ?? "",
                Price: priceHistory.current?.priceUsd ?? "")
            let average = PriceDate(
                Date: priceHistory.average?.date ?? "",
                Price: priceHistory.average?.priceUsd ?? "")

            result.priceHistory = PriceHistory(
                InStock: inStock, Max: max, Min: min, Current: current, Average: average)
        }

        if let recipe = data.getCheatsheetInfo?.recipe {
            let title = recipe.title?.removingHTMLencoding ?? ""
            let imageURL = recipe.imageUrl ?? ""

            var ingredients: [String] = []
            if let ingredientList = recipe.ingredients {
                for item in ingredientList {
                    if let text = item.text {
                        ingredients.append(text)
                    }
                }
            }

            var instrutions: [String] = []
            if let instructionList = recipe.instructions {
                for item in instructionList {
                    if let text = item.text {
                        instrutions.append(text)
                    }
                }
            }

            var reviews: [Review] = []
            if let reviewList = recipe.reviews {
                for r in reviewList {
                    let maxStars = r.rating?.maxStars ?? 0
                    let actualStars = r.rating?.actualStars ?? 0
                    let rating = Rating(maxStars: maxStars, actualStarts: actualStars)
                    reviews.append(
                        Review(
                            body: r.body ?? "",
                            reviewerName: r.reviewerName ?? "",
                            rating: rating
                        )
                    )
                }
            }

            let maxStars = recipe.recipeRating?.maxStars ?? 0
            let recipeStars = recipe.recipeRating?.recipeStars ?? 0
            let numReviews = recipe.recipeRating?.numReviews ?? 0
            let preference = recipe.preference ?? .noPreference

            result.recipe = Recipe(
                title: title, imageURL: imageURL, totalTime: recipe.totalTime,
                prepTime: recipe.prepTime, yield: recipe.yield, ingredients: ingredients,
                instructions: instrutions,
                recipeRating: RecipeRating(
                    maxStars: maxStars, recipeStars: recipeStars, numReviews: numReviews),
                reviews: reviews, preference: preference)
        }

        if let backlinks = data.getCheatsheetInfo?.backlinkUrl {
            result.backlinks = backlinks.compactMap { backlink in
                guard let forum = backlink.forum,
                    let result = Backlink(from: forum)
                else {
                    return Backlink(from: backlink)
                }
                return result
            }
        }

        return [result]
    }

    @discardableResult public static func getCheatsheetInfo(
        using api: GraphQLAPI = .shared,
        url: String,
        title: String,
        completion: @escaping (Result<[CheatsheetInfo], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(
            query: CheatsheetInfoQuery(input: url, title: title),
            using: api,
            on: queue,
            completion: completion
        )
    }
}
