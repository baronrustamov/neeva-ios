// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import CoreGraphics

extension URL {
    fileprivate init?(from apiResponse: String) {
        if let url = URL(string: apiResponse) {
            self = url
            return
        }

        // Check for malformed fragment component
        if let firstIndex = apiResponse.firstIndex(of: "#") {
            // everything after the first # is the fragment
            let fragment = apiResponse.suffix(from: apiResponse.index(after: firstIndex))
            if let escapedFragment = fragment.addingPercentEncoding(
                withAllowedCharacters: .urlFragmentAllowed),
                let url = URL(string: apiResponse.prefix(through: firstIndex) + escapedFragment)
            {
                self = url
                return
            }
        }

        return nil
    }
}

public enum NeevaScopeSearch {
    public typealias ProductClusterResult = ([Product])
    public typealias RecipeBlockResult = ([RelatedRecipe])
    public typealias RelatedSearchesResult = ([String])
    public typealias WebResults = ([WebResult])
    public struct NewsResults {
        public var news: [NewsResult]
        public let title: String?
        public let snippet: String?
        public let actionURL: URL
    }
    public typealias PlaceResult = (PlaceItem)
    public typealias PlaceListResult = ([PlaceItem])
    public typealias RichEntityResult = (RichEntity)

    public enum RichSearchResult {
        case ProductCluster(result: ProductClusterResult)
        case RecipeBlock(result: RecipeBlockResult)
        case RelatedSearches(result: RelatedSearchesResult)
        case WebGroup(result: WebResults)
        case NewsGroup(result: NewsResults)
        case Place(result: PlaceResult)
        case PlaceList(result: PlaceListResult)
        case RichEntity(result: RichEntityResult)
    }

    fileprivate struct PartialResult<T> {
        // TODO: - Expand this to use enum and support aggregating over many results
        /// Used to indicate if a result was omitted because a string cannot be parsed into a URL object
        let skippedItem: Bool
        let result: T?

        init(skippedItem: Bool = false, result: T? = nil) {
            self.skippedItem = skippedItem
            self.result = result
        }
    }

    public struct Seller {
        public let url: String
        public let price: Double
        public let displayName: String
        public let providerCode: String
    }

    public struct BuyingGuideReviewHeader {
        public let title: String
        public let summary: String
    }

    public struct BuyingGuideReview {
        public let source: String
        public let reviewURL: String
        public let header: BuyingGuideReviewHeader
    }

    public struct Product {
        public let productName: String
        public let thumbnailURL: String
        public let buyingGuideReviews: [BuyingGuideReview]?
        public let sellers: [Seller]?
        public let priceLow: Double?
    }

    public struct InlineSearchProduct {
        public let productName: String
        public let thumbnailURL: String
        public let actionURL: URL
        public let price: String?
    }

    public struct BuyingGuide {
        public let reviewType: String?
        public let thumbnailURL: String
        public let productName: String
        public let actionURL: URL
        public let reviewSummary: String?
        public let price: String?
    }

    public struct WebResult {
        public let faviconURL: String
        public let displayURLHost: String
        public let displayURLPath: String
        public let actionURL: URL
        public let title: String
        public let snippet: String?
        public let publicationDate: String?
        public let inlineSearchProducts: [InlineSearchProduct]
        public let buyingGuides: [BuyingGuide]
    }

    public struct NewsResult {
        public struct Provider {
            public let name: String?
            public let site: String?
        }
        public let title: String
        public let snippet: String
        public let url: URL
        public let thumbnailURL: String
        public let thumbnailSize: CGSize
        public let datePublished: String
        public let faviconURL: String?
        public let provider: Provider
    }

    public struct PlaceItem {
        public struct Address {
            public let street: String
            public let full: String
        }
        public struct Coordinate {
            public let lat: Double
            public let lon: Double
        }
        public struct Hour {
            public let isOvernight: Bool
            public let start: String
            public let end: String
            public let day: Int
        }
        public struct SpecialHour {
            public let isOvernight: Bool
            public let isClosed: Bool
            public let start: String
            public let end: String
            public let date: String
        }
        public struct MapImage {
            public let url: URL?
            public let darkURL: URL?
        }
        public struct MapQuery {
            public let query: String
            public let placeID: String
        }
        // basic info
        public let name: String
        public let address: Address
        public let position: Coordinate
        public let telephone: String?
        public let telephonePretty: String?
        public let price: String?
        public let categories: [String]

        // review
        public let rating: Double?
        public let reviewCount: Int?

        // hours
        public let articulatedOperatingStatus: String?
        public let articulatedHour: String?
        public let specialHours: [SpecialHour]?
        public let hours: [Hour]?
        public let isOpenNow: Bool

        // urls
        public let websiteURL: URL?
        public let yelpURL: URL?
        public let imageURL: URL?

        public let mapImage: MapImage?
        public let mapImageLarge: MapImage?

        public let mapQuery: MapQuery?
    }

    public struct RichEntity {
        public struct SocialNetwork {
            public let text: String
            public let url: URL
            public let icon: EntitySocialNetworkProfileIcon

            init?(text: String?, url: String?, icon: EntitySocialNetworkProfileIcon?) {
                guard let text = text,
                    let urlString = url,
                    let url = URL(string: urlString),
                    let icon = icon
                else {
                    return nil
                }

                self.text = text
                self.url = url
                self.icon = icon
            }

            init?(
                _ data: SearchQuery.Data.Search.ResultGroup.Result.TypeSpecific.AsRichEntity
                    .RichEntity.SocialNetwork
            ) {
                self.init(text: data.text, url: data.url, icon: data.icon)
            }

            init?(
                _ data: SearchQuery.Data.Search.ResultGroup.Result.TypeSpecific.AsRichEntity
                    .RichEntity.SecondarySocialNetwork
            ) {
                self.init(text: data.text, url: data.url, icon: data.icon)
            }
        }

        public let title: String
        public let subtitle: String?
        public let description: String
        public let imageURL: URL?
        public let socials: [SocialNetwork]
        public let secondarySocials: [SocialNetwork]
    }

    public class SearchController: QueryController<SearchQuery, [SearchController.RichResult]> {
        public struct RichResult: Identifiable {
            public var id = UUID()
            public var result: RichSearchResult
            public var dataComplete: Bool

            public init(id: UUID = UUID(), result: RichSearchResult, dataComplete: Bool = true) {
                self.id = id
                self.result = result
                self.dataComplete = true
            }
        }

        private static let queue = DispatchQueue(
            label: "co.neeva.app.ios.shared.SearchController",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .inherit,
            target: nil
        )

        private var query: String

        public init(query: String) {
            self.query = query
            super.init()
        }

        @available(*, unavailable)
        public override func reload() {
            fatalError("reload() has not been implemented")
        }

        private class func constructProductCluster(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        )
            -> PartialResult<ProductClusterResult>
        {
            guard
                let products = result.typeSpecific?
                    .asProductClusters?
                    .productClusters?
                    .products
            else {
                return PartialResult()
            }

            let productItems = products.compactMap { product -> Product? in
                guard let productName = product.productName,
                    let thumbnailURL = product.thumbnailUrl
                else {
                    return nil
                }

                let sellers: [Seller]? = product.sellers?.compactMap { seller in
                    guard let url = seller.url,
                        let price = seller.price,
                        let displayName = seller.displayName,
                        let providerCode = seller.providerCode
                    else {
                        return nil
                    }
                    return Seller(
                        url: url, price: price, displayName: displayName, providerCode: providerCode
                    )
                }

                let buyingGuideReviews: [BuyingGuideReview]? = product.buyingGuideReviews?
                    .compactMap { review in
                        guard let source = review.source,
                            let reviewURL = review.reviewUrl,
                            let title = review.header?.title,
                            let summary = review.header?.summary
                        else {
                            return nil
                        }
                        return BuyingGuideReview(
                            source: source,
                            reviewURL: reviewURL,
                            header: BuyingGuideReviewHeader(
                                title: title,
                                summary: summary
                            ))
                    }

                return Product(
                    productName: productName,
                    thumbnailURL: thumbnailURL,
                    buyingGuideReviews: buyingGuideReviews,
                    sellers: sellers,
                    priceLow: product.priceLow
                )
            }

            guard !productItems.isEmpty else {
                return PartialResult()
            }

            return PartialResult(skippedItem: false, result: ProductClusterResult(productItems))
        }

        private class func constructRecipeBlock(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        )
            -> PartialResult<RecipeBlockResult>
        {
            guard
                let recipes = result.typeSpecific?
                    .asRecipeBlock?
                    .recipeBlock?
                    .recipes
            else {
                return PartialResult()
            }

            var skippedItem = false

            let relatedRecipes =
                recipes
                .compactMap { recipe -> RelatedRecipe? in
                    guard let title = recipe.title,
                        let imageURL = recipe.imageUrl,
                        let urlString = recipe.url
                    else {
                        return nil
                    }

                    guard let url = URL(from: urlString) else {
                        skippedItem = true
                        return nil
                    }

                    var recipeRating: RecipeRating?
                    if let maxStars = recipe.recipeRating?.maxStars,
                        let recipeStars = recipe.recipeRating?.recipeStars,
                        let numReviews = recipe.recipeRating?.numReviews
                    {
                        recipeRating = RecipeRating(
                            maxStars: maxStars, recipeStars: recipeStars,
                            numReviews: numReviews)
                    }

                    return RelatedRecipe(
                        title: title,
                        imageURL: imageURL,
                        url: url,
                        totalTime: recipe.totalTime,
                        recipeRating: recipeRating
                    )
                }

            guard !relatedRecipes.isEmpty else {
                return PartialResult(skippedItem: skippedItem, result: nil)
            }

            return PartialResult(
                skippedItem: skippedItem, result: RecipeBlockResult(relatedRecipes))
        }

        private class func constructRelatedSearch(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        )
            -> PartialResult<RelatedSearchesResult>
        {
            guard
                let relatedSearches = result.typeSpecific?
                    .asRelatedSearches?
                    .relatedSearches?
                    .entries
            else {
                return PartialResult()
            }

            let searchTexts = relatedSearches.compactMap { item in
                return item.searchText
            }

            guard !searchTexts.isEmpty else {
                return PartialResult()
            }

            return PartialResult(skippedItem: false, result: RelatedSearchesResult(searchTexts))
        }

        private class func constructWebResult(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        )
            -> PartialResult<WebResult>
        {
            guard
                let web = result.typeSpecific?
                    .asWeb?
                    .web
            else {
                return PartialResult()
            }

            guard let faviconURL = web.favIconUrl,
                let title = result.title,
                let hostname = web.structuredUrl?.hostname,
                let paths = web.structuredUrl?.paths
            else {
                return PartialResult()
            }

            guard let actionURL = URL(from: result.actionUrl) else {
                return PartialResult(skippedItem: true, result: nil)
            }

            var skippedItem = false

            let displayURLHost = hostname
            let displayURLPath = paths.joined(separator: " > ")

            let snippet = web.highlightedSnippet?.segments?.compactMap { segment in
                return segment.text
            }.joined()

            let inlineSearchProducts =
                web.inlineSearchProducts?.compactMap { item -> InlineSearchProduct? in
                    guard let productName = item.productName,
                        let thumbnailURL = item.thumbnailUrl,
                        let productActionURLString = item.actionUrl
                    else {
                        return nil
                    }

                    guard let productActionURL = URL(from: productActionURLString) else {
                        skippedItem = true
                        return nil
                    }

                    return InlineSearchProduct(
                        productName: productName,
                        thumbnailURL: thumbnailURL,
                        actionURL: productActionURL,
                        price: item.priceLow
                    )
                } ?? []

            let buyingGuides =
                web.buyingGuideProducts?.compactMap { item -> BuyingGuide? in
                    guard let productName = item.productName,
                        let thumbnailURL = item.thumbnailUrl
                    else {
                        return nil
                    }

                    return BuyingGuide(
                        reviewType: item.reviewType,
                        thumbnailURL: thumbnailURL,
                        productName: productName,
                        actionURL: actionURL,
                        reviewSummary: item.reviewSummary,
                        price: item.priceLow)
                } ?? []

            let webResult = WebResult(
                faviconURL: faviconURL,
                displayURLHost: displayURLHost,
                displayURLPath: displayURLPath,
                actionURL: actionURL,
                title: title,
                snippet: snippet,
                publicationDate: web.publicationDate,
                inlineSearchProducts: inlineSearchProducts,
                buyingGuides: buyingGuides
            )
            return PartialResult(skippedItem: skippedItem, result: webResult)
        }

        private class func constructNewsResult(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        )
            -> PartialResult<NewsResults>
        {
            guard let subResults = result.subResults,
                let actionURL = URL(from: result.actionUrl)
            else {
                return PartialResult(skippedItem: true, result: nil)
            }

            var skippedItem = false

            let newsResults =
                subResults
                .compactMap { subResult -> NewsResult? in
                    guard let news = subResult.asNews?.news else {
                        return nil
                    }
                    guard let url = URL(from: news.url) else {
                        skippedItem = true
                        return nil
                    }
                    return NewsResult(
                        title: news.title,
                        snippet: news.snippet,
                        url: url,
                        thumbnailURL: news.thumbnailImage.url,
                        thumbnailSize: CGSize(
                            width: news.thumbnailImage.width, height: news.thumbnailImage.height),
                        datePublished: news.datePublished,
                        faviconURL: news.favIconUrl,
                        provider: NewsResult.Provider(
                            name: news.provider?.name,
                            site: news.provider?.site
                        )
                    )
                }

            guard !newsResults.isEmpty else {
                return PartialResult(skippedItem: skippedItem, result: nil)
            }

            return PartialResult(
                skippedItem: skippedItem,
                result: NewsResults(
                    news: newsResults,
                    title: result.title,
                    snippet: result.snippet,
                    actionURL: actionURL
                )
            )
        }

        private class func constructPlace(
            from data: SearchQuery.Data.Search.ResultGroup.Result.TypeSpecific.AsPlace.Place
        ) -> PlaceItem? {
            guard let streetAddress = data.address.streetAddress,
                let fullAddress = data.address.fullAddress
            else {
                return nil
            }
            let address = PlaceItem.Address(street: streetAddress, full: fullAddress)
            let coordinate = PlaceItem.Coordinate(lat: data.position.lat, lon: data.position.lon)
            let specialHours = data.specialHours?.map {
                return PlaceItem.SpecialHour(
                    isOvernight: $0.isOvernight,
                    isClosed: $0.isClosed,
                    start: $0.start,
                    end: $0.end,
                    date: $0.date
                )
            }
            let hours = data.hours?.open.map {
                return PlaceItem.Hour(
                    isOvernight: $0.isOvernight,
                    start: $0.start,
                    end: $0.end,
                    day: $0.day
                )
            }

            var mapImage: PlaceItem.MapImage?
            if let mapImageURLString = data.mapImage?.url,
                let mapImageDarkURLString = data.mapImage?.darkUrl
            {
                mapImage = .init(
                    url: URL(string: mapImageURLString),
                    darkURL: URL(string: mapImageDarkURLString)
                )
            }

            var mapImageLarge: PlaceItem.MapImage?
            if let mapImageURLString = data.mapImageLarge?.url,
                let mapImageDarkURLString = data.mapImageLarge?.darkUrl
            {
                mapImageLarge = .init(
                    url: URL(string: mapImageURLString),
                    darkURL: URL(string: mapImageDarkURLString)
                )
            }

            return PlaceItem(
                name: data.name,
                address: address,
                position: coordinate,
                telephone: data.telephone.isEmpty ? nil : data.telephone,
                telephonePretty: data.telephonePretty.isEmpty ? nil : data.telephonePretty,
                price: data.price.isEmpty ? nil : data.price,
                categories: data.categories.filter { !$0.isEmpty },
                rating: data.rating > 0 ? data.rating : nil,
                reviewCount: data.reviewCount > 0 ? data.reviewCount : nil,
                articulatedOperatingStatus: data.articulatedOperatingStatus,
                articulatedHour: data.articulatedHour,
                specialHours: specialHours,
                hours: hours,
                isOpenNow: data.isOpenNow ?? !data.isClosed,
                websiteURL: URL(string: data.websiteUrl),
                yelpURL: URL(string: data.yelpUrl),
                imageURL: URL(string: data.imageUrl),
                mapImage: mapImage,
                mapImageLarge: mapImageLarge,
                mapQuery: nil
            )
        }

        private class func constructPlace(
            from data: SearchQuery.Data.Search.ResultGroup.Result.TypeSpecific.AsPlaceList.PlaceList
                .Place.Place
        ) -> PlaceItem? {
            guard let streetAddress = data.address.streetAddress,
                let fullAddress = data.address.fullAddress,
                let mapQueryString = data.neevaMapsQuery?.query,
                let mapQueryPlaceID = data.neevaMapsQuery?.placeId
            else {
                return nil
            }
            let address = PlaceItem.Address(street: streetAddress, full: fullAddress)
            let coordinate = PlaceItem.Coordinate(lat: data.position.lat, lon: data.position.lon)

            let specialHours = data.specialHours?.map {
                return PlaceItem.SpecialHour(
                    isOvernight: $0.isOvernight,
                    isClosed: $0.isClosed,
                    start: $0.start,
                    end: $0.end,
                    date: $0.date
                )
            }
            let hours = data.hours?.open.map {
                return PlaceItem.Hour(
                    isOvernight: $0.isOvernight,
                    start: $0.start,
                    end: $0.end,
                    day: $0.day
                )
            }

            var mapImage: PlaceItem.MapImage?
            if let mapImageURLString = data.mapImage?.url,
                let mapImageDarkURLString = data.mapImage?.darkUrl
            {
                mapImage = .init(
                    url: URL(string: mapImageURLString),
                    darkURL: URL(string: mapImageDarkURLString)
                )
            }

            var mapImageLarge: PlaceItem.MapImage?
            if let mapImageURLString = data.mapImageLarge?.url,
                let mapImageDarkURLString = data.mapImageLarge?.darkUrl
            {
                mapImageLarge = .init(
                    url: URL(string: mapImageURLString),
                    darkURL: URL(string: mapImageDarkURLString)
                )
            }

            return PlaceItem(
                name: data.name,
                address: address,
                position: coordinate,
                telephone: data.telephone.isEmpty ? nil : data.telephone,
                telephonePretty: data.telephonePretty.isEmpty ? nil : data.telephonePretty,
                price: data.price.isEmpty ? nil : data.price,
                categories: data.categories.filter { !$0.isEmpty },
                rating: data.rating > 0 ? data.rating : nil,
                reviewCount: data.reviewCount > 0 ? data.reviewCount : nil,
                articulatedOperatingStatus: data.articulatedOperatingStatus,
                articulatedHour: data.articulatedHour,
                specialHours: specialHours,
                hours: hours,
                isOpenNow: data.isOpenNow ?? data.isClosed,
                websiteURL: URL(string: data.websiteUrl),
                yelpURL: URL(string: data.yelpUrl),
                imageURL: URL(string: data.imageUrLs?.first ?? data.imageUrl),
                mapImage: mapImage,
                mapImageLarge: mapImageLarge,
                mapQuery: PlaceItem.MapQuery(query: mapQueryString, placeID: mapQueryPlaceID)
            )
        }

        private class func constructPlaceResult(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        ) -> PartialResult<PlaceResult> {
            guard let place = result.typeSpecific?.asPlace?.place,
                let parsedPlace = constructPlace(from: place)
            else {
                return PartialResult()
            }

            // purely to conform to the Result type alias
            let placeResult = parsedPlace as PlaceResult

            return PartialResult(skippedItem: false, result: placeResult)
        }

        private class func constructPlaceListResult(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        ) -> PartialResult<PlaceListResult> {
            guard
                let placeList = result
                    .typeSpecific?
                    .asPlaceList?
                    .placeList
            else {
                return PartialResult()
            }

            let results = placeList.places.map({ $0.place }).compactMap(constructPlace)

            guard !results.isEmpty else {
                return PartialResult()
            }

            return PartialResult(
                skippedItem: false,
                result: PlaceListResult(results)
            )
        }

        private class func constructRichEntity(
            from result: SearchQuery.Data.Search.ResultGroup.Result
        ) -> PartialResult<RichEntityResult> {
            guard let richEntity = result.typeSpecific?.asRichEntity?.richEntity
            else {
                return PartialResult()
            }

            guard let title = richEntity.title,
                let description = richEntity.description
            else {
                return PartialResult()
            }

            var imageURL: URL?
            if let urlString = richEntity.images?.first?.thumbnailUrl {
                imageURL = URL(string: urlString)
            }

            let socials = richEntity.socialNetworks?.compactMap { RichEntity.SocialNetwork($0) }
            let secondarySocials = richEntity.secondarySocialNetworks?.compactMap {
                RichEntity.SocialNetwork($0)
            }

            let result = RichEntity(
                title: title,
                subtitle: richEntity.subTitle,
                description: description,
                imageURL: imageURL,
                socials: socials ?? [],
                secondarySocials: secondarySocials ?? []
            )

            return PartialResult(skippedItem: false, result: result)
        }

        public override class func processData(_ data: SearchQuery.Data) -> [RichResult] {
            var richResults: [RichResult] = []
            // recipe and web results need to be merged into single RichResult objects
            // recipeblocks are flipped and then concatenated
            var recipeBlocks: [RecipeBlockResult] = []
            var webResults: [WebResult] = []
            var recipeDataComplete = true
            var webResultsDataComplete = true

            data.search?.resultGroup?
                // [ResultGroup?]
                .compactMap { group in
                    return group?.result
                }
                // [[Result?]]
                .flatMap { $0 }
                // [Result?]
                .compactMap { $0 }
                // [Result]
                .forEach { result in
                    // assume that, for results with non-empty subresults
                    // every subresult has the same typename
                    if let subResultTypeName = result.subResults?.first?.__typename {
                        switch subResultTypeName {
                        case "News":
                            let newsResults = constructNewsResult(from: result)
                            if let parsedData = newsResults.result {
                                richResults.append(
                                    RichResult(
                                        result: .NewsGroup(result: parsedData),
                                        dataComplete: !newsResults.skippedItem
                                    )
                                )
                            }
                        default:
                            return
                        }
                    } else if let typename = result.typeSpecific?.__typename {
                        switch typename {
                        case "ProductClusters":
                            let productClusterResult = constructProductCluster(from: result)
                            if let parsedData = productClusterResult.result {
                                richResults.append(
                                    RichResult(
                                        result: .ProductCluster(result: parsedData),
                                        dataComplete: !productClusterResult.skippedItem
                                    )
                                )
                            }
                        case "RelatedSearches":
                            let relatedSearchesResult = constructRelatedSearch(from: result)
                            if let parsedData = relatedSearchesResult.result {
                                richResults.append(
                                    RichResult(
                                        result: .RelatedSearches(result: parsedData),
                                        dataComplete: !relatedSearchesResult.skippedItem
                                    )
                                )
                            }
                        case "Place":
                            let placeResult = constructPlaceResult(from: result)
                            if let parsedData = placeResult.result {
                                richResults.append(
                                    RichResult(
                                        result: .Place(result: parsedData),
                                        dataComplete: !placeResult.skippedItem
                                    )
                                )
                            }
                        case "PlaceList":
                            let placeListResult = constructPlaceListResult(from: result)
                            if let parsedData = placeListResult.result {
                                richResults.append(
                                    RichResult(
                                        result: .PlaceList(result: parsedData),
                                        dataComplete: !placeListResult.skippedItem
                                    )
                                )
                            }
                        case "RecipeBlock":
                            let recipeBlockResult = constructRecipeBlock(from: result)
                            if let parsedData = recipeBlockResult.result {
                                recipeBlocks.append(parsedData)
                            }
                            recipeDataComplete =
                                !recipeBlockResult.skippedItem && recipeDataComplete
                        case "Web":
                            let webResult = constructWebResult(from: result)
                            if let parsedData = webResult.result {
                                webResults.append(parsedData)
                            }
                            webResultsDataComplete =
                                !webResult.skippedItem && webResultsDataComplete
                        case "RichEntity":
                            let richEntityResult = constructRichEntity(from: result)
                            if let parsedData = richEntityResult.result {
                                richResults.append(
                                    RichResult(
                                        result: .RichEntity(result: parsedData),
                                        dataComplete: !richEntityResult.skippedItem
                                    )
                                )
                            }
                        default:
                            return
                        }
                    }
                }

            if !recipeBlocks.isEmpty {
                // merge recipe blocks
                let recipeRichResult = RichResult(
                    result: .RecipeBlock(
                        result:
                            RecipeBlockResult(
                                recipeBlocks.reversed().flatMap { $0 }
                            )
                    ),
                    dataComplete: recipeDataComplete
                )
                richResults.append(recipeRichResult)
            }

            if !webResults.isEmpty {
                // merge web result blocks
                let webRichResult = RichResult(
                    result: .WebGroup(result: WebResults(webResults)),
                    dataComplete: webResultsDataComplete
                )
                richResults.append(webRichResult)
            }

            return richResults
        }

        @discardableResult public static func getRichResult(
            query: String, completion: @escaping (Result<[RichResult], Error>) -> Void
        ) -> Combine.Cancellable {
            Self.perform(
                query: SearchQuery(query: query),
                on: queue,
                completion: completion
            )
        }
    }
}
