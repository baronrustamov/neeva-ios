// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public struct Collection: Codable {
    public static let scrapeForOpenSeaLink = """
        Array.prototype.map.call(document.querySelectorAll('div a'), function links(element) {var link=element['href']; return link}).filter(function(el) {return el.startsWith('https://opensea.io')}).map(function(el) { return el.split('opensea.io/collection/')[1]})
        """

    public let bannerImageURL: URL?
    public let description: String?
    public let externalURL: URL?
    public let safelistRequestStatus: SafelistRequestStatus
    public let imageURL: URL?
    public let largeImageURL: URL?
    public let name: String?
    public let stats: CollectionStats?

    public let openSeaSlug: String
    public var openSeaURL: URL {
        return URL(string: "https://opensea.io/collection/" + openSeaSlug)!
    }
    public let discordURL: URL?
    public let twitterHandle: String?
    public var twitterURL: URL? {
        guard let handle = twitterHandle else { return nil }
        return URL(string: "https://twitter.com/" + handle)
    }
    public let instagramHandle: String?
    public var instagramURL: URL? {
        guard let handle = instagramHandle else { return nil }
        return URL(string: "https://instagram.com/" + handle)
    }

    enum CodingKeys: String, CodingKey {
        case bannerImageURL = "banner_image_url"
        case description = "description"
        case externalURL = "external_url"
        case safelistRequestStatus = "safelist_request_status"
        case imageURL = "image_url"
        case largeImageURL = "large_image_url"
        case name = "name"
        case openSeaSlug = "slug"
        case discordURL = "discord_url"
        case twitterHandle = "twitter_username"
        case instagramHandle = "instagram_username"
        case stats = "stats"
    }
}

extension Collection: Equatable {
    public static func == (lhs: Collection, rhs: Collection) -> Bool {
        return lhs.openSeaSlug == rhs.openSeaSlug
    }
}

extension Collection: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(openSeaSlug)
    }
}

public struct CollectionStats: Codable, Hashable {
    public let oneDayVolume: Double
    public let oneDaySales: Double
    public let oneDayAveragePrice: Double
    public let weekVolume: Double
    public let weekSales: Double
    public let weekAveragePrice: Double
    public let monthVolume: Double
    public let monthSales: Double
    public let monthAveragePrice: Double
    public let overallVolume: Double
    public let overallSales: Double
    public let overallAveragePrice: Double
    public let count: Int
    public let numOwners: Int
    public let floorPrice: Double?
    public let marketCap: Double?

    enum CodingKeys: String, CodingKey {
        case oneDayVolume = "one_day_volume"
        case oneDaySales = "one_day_sales"
        case oneDayAveragePrice = "one_day_average_price"
        case weekVolume = "seven_day_volume"
        case weekSales = "seven_day_sales"
        case weekAveragePrice = "seven_day_average_price"
        case monthVolume = "thirty_day_volume"
        case monthSales = "thirty_day_sales"
        case monthAveragePrice = "thirty_day_average_price"
        case overallVolume = "total_volume"
        case overallSales = "total_sales"
        case overallAveragePrice = "average_price"
        case count = "count"
        case numOwners = "num_owners"
        case floorPrice = "floor_price"
        case marketCap = "market_cap"
    }
}

public enum SafelistRequestStatus: String, Codable {
    case not_requested, requested, approved, verified
}

extension SafelistRequestStatus: Comparable {
    public static func < (_ lhs: SafelistRequestStatus, _ rhs: SafelistRequestStatus) -> Bool {
        switch lhs {
        case .verified:
            return false
        case .approved:
            return rhs == .verified
        case .requested:
            return rhs == .verified || rhs == .approved
        case .not_requested:
            return rhs == .verified || rhs == .approved || rhs == .requested
        }
    }
}

public func >= (_ lhs: SafelistRequestStatus?, _ rhs: SafelistRequestStatus) -> Bool {
    if let lhs = lhs {
        return lhs >= rhs
    } else {
        return false
    }
}

public func < (_ lhs: SafelistRequestStatus?, _ rhs: SafelistRequestStatus) -> Bool {
    !(lhs >= rhs)
}
