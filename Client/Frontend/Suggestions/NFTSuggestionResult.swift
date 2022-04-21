// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

struct NFTSuggestionResult: Codable {
    let groups: [NFTSuggestionGroup]?

    enum CodingKeys: String, CodingKey {
        case groups = "Groups"
    }
}

struct NFTSuggestionGroup: Codable {
    let title: String?
    let suggestions: [NFTSuggestion]

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case suggestions = "Suggestions"
    }
}

public struct NFTSuggestion: Codable {
    let type: NFTSuggestionType
    let displayText: String
    let image: String?
    let actionURL: String?

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case displayText = "DisplayText"
        case image = "ImageURL"
        case actionURL = "ActionURL"
    }

    var suggestionURL: URL? {
        guard let actionURL = actionURL else {
            return nil
        }

        return URL(string: "https://neeva.xyz\(actionURL)")
    }
}

enum NFTSuggestionType: String, Codable, CaseIterable {
    case query, collection, wallet, token
}
