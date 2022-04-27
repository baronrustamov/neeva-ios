// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum PreviewEntity: Equatable {
    case richEntity(RichEntity)
    case recipe(Recipe)
    case techDoc(TechDoc)
    case retailProduct(RetailProduct)
    case newsItem(NewsItem)
    case webPage
    case spaceLink(SpaceID)

    public static func == (lhs: PreviewEntity, rhs: PreviewEntity) -> Bool {
        switch (lhs, rhs) {
        case (.richEntity, .richEntity):
            return true
        case (.recipe, .recipe):
            return true
        case (.techDoc, .techDoc):
            return true
        case (.retailProduct, .retailProduct):
            return true
        case (.newsItem, .newsItem):
            return true
        case (.webPage, .webPage):
            return true
        case (.spaceLink, .spaceLink):
            return true
        default:
            return false
        }
    }

    public struct NewsItem {
        public let title: String
        public let snippet: String
        public let url: URL
        public let thumbnailURL: URL?
        public let providerName: String
        public let datePublished: String
        public let faviconURL: URL?
        public let domain: String?

        public var formattedDatePublished: String {
            let originalDateFormatter = DateFormatter()
            originalDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            originalDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let convertedDate = originalDateFormatter.date(from: datePublished)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: convertedDate ?? Date())
        }
    }

    public struct RichEntity {
        public let id: String
        public let title: String
        public let description: String
        public let imageURL: URL?
    }

    public struct TechDoc {
        public let id: String
        public let title: String
        public let body: NSMutableAttributedString?
    }

    public struct ProductRating {
        public let numReviews: Int?
        public let productStars: Double
    }

    public struct RetailProduct {
        public let id: String
        public let url: URL
        public let title: String
        public let description: [String]
        public let currentPrice: Double
        public let ratingSummary: ProductRating?

        public var formattedPrice: String {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale(identifier: "en_US")
            return numberFormatter.string(from: (currentPrice as NSNumber)) ?? ""
        }
    }

}
