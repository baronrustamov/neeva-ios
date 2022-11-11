// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

public struct AddToSpaceInput {
    public let url: URL
    public let title: String
    public let thumbnail: String?
    public let description: String?  // Meta description ("data" to GraphQL)

    public init(url: URL, title: String, thumbnail: String? = nil, description: String? = nil) {
        self.url = url
        self.title = title
        self.thumbnail = thumbnail
        self.description = description
    }

    public func toAddSpaceResultByURLInput(spaceID: String) -> AddSpaceResultByURLInput {
        AddSpaceResultByURLInput(
            spaceId: spaceID, url: url.absoluteString, title: title, thumbnail: thumbnail,
            data: description)
    }

    public func toSpaceURLInput() -> SpaceURLInput {
        SpaceURLInput(
            url: url.absoluteString, title: title, thumbnail: thumbnail, data: description)
    }
}
