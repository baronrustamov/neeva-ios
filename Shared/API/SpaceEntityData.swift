// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit

public struct SpaceEntityData {
    typealias SpaceEntity = GetSpacesDataQuery.Data.GetSpace.Space.Space.Entity.SpaceEntity
    typealias EntityRecipe = GetSpacesDataQuery.Data.GetSpace.Space.Space.Entity.SpaceEntity.Content
        .TypeSpecific.AsWeb.Web.Recipe
    typealias EntityRichEntity = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsRichEntity.RichEntity
    typealias EntityRetailProduct = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsWeb.Web.RetailerProduct
    typealias EntityProductRating = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsWeb.Web.RetailerProduct.Review
        .RatingSummary
    typealias EntityTechDoc = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsTechDoc.TechDoc
    typealias EntityNewsItem = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsNewsItem.NewsItem

    typealias NewsItem = PreviewEntity.NewsItem
    typealias RichEntity = PreviewEntity.RichEntity
    typealias RetailProduct = PreviewEntity.RetailProduct
    typealias TechDoc = PreviewEntity.TechDoc
    typealias ProductRating = PreviewEntity.ProductRating

    public let id: String
    public let url: URL?
    public let title: String?
    public let snippet: String?
    public let thumbnail: String?
    public let previewEntity: PreviewEntity
    public var generatorID: String?

    public init(
        id: String, url: URL?, title: String?, snippet: String?,
        thumbnail: String?, previewEntity: PreviewEntity, generatorID: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.snippet = snippet
        self.thumbnail = thumbnail
        self.previewEntity = previewEntity
        self.generatorID = generatorID
    }

    static func previewEntity(from entity: SpaceEntity) -> PreviewEntity {
        if let recipe = recipe(from: entity.content?.typeSpecific?.asWeb?.web?.recipes?.first) {
            return PreviewEntity.recipe(recipe)
        } else if let richEntity = richEntity(
            from: entity.content?.typeSpecific?.asRichEntity?.richEntity, with: entity.content?.id)
        {
            return PreviewEntity.richEntity(richEntity)
        } else if let retailProduct = retailProduct(
            from: entity.content?.typeSpecific?.asWeb?.web?.retailerProduct,
            with: entity.content?.actionUrl.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed))
        {
            return PreviewEntity.retailProduct(retailProduct)
        } else if let techDoc = techDoc(
            from: entity.content?.typeSpecific?.asTechDoc?.techDoc,
            with: entity.content?.actionUrl.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed))
        {
            return PreviewEntity.techDoc(techDoc)
        } else if let newsItem = newsItem(
            from: entity.content?.typeSpecific?.asNewsItem?.newsItem
        ) {
            return PreviewEntity.newsItem(newsItem)
        } else {
            return PreviewEntity.webPage
        }
    }

    private static func newsItem(from entity: EntityNewsItem?) -> NewsItem? {
        guard let entity = entity, let url = URL(string: entity.url) else {
            return nil
        }

        return NewsItem(
            title: entity.title, snippet: entity.snippet, url: url,
            thumbnailURL: URL(string: entity.thumbnailImage.url),
            providerName: entity.providerName, datePublished: entity.datePublished,
            faviconURL: URL(string: entity.favIconUrl ?? ""),
            domain: entity.domain)
    }

    private static func recipe(from entity: EntityRecipe?) -> Recipe? {
        guard let entity = entity, let title = entity.title, let imageURL = entity.imageUrl else {
            return nil
        }

        return Recipe(
            title: title, imageURL: imageURL, totalTime: entity.totalTime, prepTime: nil,
            yield: nil, ingredients: nil, instructions: nil,
            recipeRating: RecipeRating(
                maxStars: 0, recipeStars: entity.recipeRating?.recipeStars ?? 0,
                numReviews: entity.recipeRating?.numReviews ?? 0), reviews: nil,
            preference: .noPreference)
    }

    private static func richEntity(from entity: EntityRichEntity?, with id: String?) -> RichEntity?
    {
        guard let id = id, let entity = entity, let title = entity.title,
            let subtitle = entity.subTitle,
            let imageURL = URL(string: entity.images?.first?.thumbnailUrl ?? "")
        else {
            return nil
        }

        return RichEntity(id: id, title: title, description: subtitle, imageURL: imageURL)
    }

    private static func retailProduct(from entity: EntityRetailProduct?, with id: String?)
        -> RetailProduct?
    {
        guard let id = id, let entity = entity, let url = URL(string: entity.url ?? ""),
            let title = entity.name,
            let price = entity.priceHistory?.currentPrice
        else {
            return nil
        }

        return RetailProduct(
            id: id,
            url: url, title: title, description: entity.description ?? [], currentPrice: price,
            ratingSummary: productRating(from: entity.reviews?.ratingSummary))
    }

    private static func techDoc(from entity: EntityTechDoc?, with id: String?) -> TechDoc? {
        guard let id = id, let entity = entity, let title = entity.name else {
            return nil
        }

        let data = entity.sections?.first?.body?.data(using: String.Encoding.utf8)

        var attributedString = NSMutableAttributedString(string: "")
        if let data = data {
            do {
                attributedString = try NSMutableAttributedString(
                    data: data,
                    options: [
                        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString
                            .DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber(
                            value: String.Encoding.utf8.rawValue),
                    ], documentAttributes: nil)
            } catch {
                Logger.browser.info("Already initialized to blank. Ignoring...")
            }
        }

        attributedString.addAttribute(
            NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel,
            range: NSRange(location: 0, length: attributedString.string.count))

        return TechDoc(id: id, title: title, body: attributedString)
    }

    private static func productRating(from rating: EntityProductRating?) -> ProductRating? {
        guard let rating = rating, let productStars = rating.rating?.productStars else {
            return nil
        }

        return ProductRating(numReviews: rating.numReviews, productStars: productStars)
    }
}
