// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

public struct Asset: Codable, Identifiable {
    public let id: Int
    public let tokenID: String
    public let imageURL: URL?
    public let name: String?
    public let description: String?
    public let contract: AssetContract?
    public let collection: Collection?
    public let traits: [Trait]?
    public let creator: Web3Profile?
    public let owner: Web3Profile?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case tokenID = "token_id"
        case imageURL = "image_url"
        case name = "name"
        case description = "description"
        case contract = "asset_contract"
        case collection = "collection"
        case traits = "traits"
        case creator = "creator"
        case owner = "owner"
    }
}

public struct Web3Profile: Codable {
    public let address: String
}

public struct AssetContract: Codable {
    public let address: String?
    public let schemaName: String?
    public let externalURL: URL?
    public let payoutAddress: String?

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case schemaName = "schema_name"
        case externalURL = "external_link"
        case payoutAddress = "payout_address"
    }
}

public struct Trait: Codable {
    public let type: String?
    public let traitCount: Int?

    enum CodingKeys: String, CodingKey {
        case type = "trait_type"
        case traitCount = "trait_count"
    }
}
