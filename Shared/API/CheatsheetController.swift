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

public class CheatsheetQueryController:
    QueryController<CheatsheetInfoQuery, [CheatsheetQueryController.CheatsheetInfo]>
{
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

    public struct CheatsheetInfo {
        public var reviewURL: [String]?
        public var priceHistory: PriceHistory?
        public var memorizedQuery: [String]?
        public var recipe: Recipe?
        public var backlinkURL: [CheatsheetInfoQuery.Data.GetCheatsheetInfo.BacklinkUrl]?
    }

    private var url: URL

    public init(url: URL) {
        self.url = url
        super.init()
    }

    public override func reload() {
        self.perform(query: CheatsheetInfoQuery(input: url.absoluteString))
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
            let title = recipe.title ?? ""
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
            // remove empty string
            result.backlinkURL = backlinks
        }

        return [result]
    }

    @discardableResult public static func getCheatsheetInfo(
        url: String, title: String, completion: @escaping (Result<[CheatsheetInfo], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: CheatsheetInfoQuery(input: url, title: title), completion: completion)
    }
}
