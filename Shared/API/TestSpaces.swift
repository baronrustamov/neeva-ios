// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Constant spaces and thumbnail images for use in previews.

extension Space {
    public static func empty() -> Space {
        Space(
            id: .init(value: "page-id"),
            name: "Empty Space",
            lastModifiedTs: "2020-12-18T16:31:52Z",
            thumbnail: nil,
            resultCount: 0,
            isDefaultSpace: false,
            isShared: false,
            isPublic: false,
            userACL: .owner
        )
    }
    public static let stackOverflow = Space(
        id: .init(value: "page-id-0"),
        name: "Test Space",
        lastModifiedTs: "2020-12-18T15:57:47Z",
        thumbnail: SpaceThumbnails.stackOverflowThumbnail,
        resultCount: 1,
        isDefaultSpace: false,
        isShared: false,
        isPublic: false,
        userACL: .owner
    )
    public static let savedForLater = Space(
        id: .init(value: "page-id-1"),
        name: "Saved For Later",
        lastModifiedTs: "2020-12-18T16:31:52Z",
        thumbnail: SpaceThumbnails.githubThumbnail,
        resultCount: 1,
        isDefaultSpace: true,
        isShared: false,
        isPublic: false,
        userACL: .owner
    )

    public static let savedForLaterEmpty = Space(
        id: .init(value: "page-id-2"),
        name: "Saved For Later",
        lastModifiedTs: "2020-12-18T16:31:52Z",
        thumbnail: SpaceThumbnails.githubThumbnail,
        resultCount: 0,
        isDefaultSpace: true,
        isShared: false,
        isPublic: false,
        userACL: .owner
    )

    public static let shared = Space(
        id: .init(value: "page-id-3"),
        name: "Shared Space",
        lastModifiedTs: "2020-12-18T15:57:47Z",
        thumbnail: SpaceThumbnails.stackOverflowThumbnail,
        resultCount: 1,
        isDefaultSpace: false,
        isShared: true,
        isPublic: false,
        userACL: .edit
    )

    public static let `public` = Space(
        id: .init(value: "page-id-4"),
        name: "Public Space",
        lastModifiedTs: "2020-12-18T15:57:47Z",
        thumbnail: SpaceThumbnails.stackOverflowThumbnail,
        resultCount: 1,
        isDefaultSpace: false,
        isShared: false,
        isPublic: true,
        userACL: .owner
    )

    public static let sharedAndPublic = Space(
        id: .init(value: "page-id-5"),
        name: "Shared, Public Space. Yes, this space is in fact both shared and public!",
        lastModifiedTs: "2020-12-18T15:57:47Z",
        thumbnail: SpaceThumbnails.stackOverflowThumbnail,
        resultCount: 1,
        isDefaultSpace: false,
        isShared: true,
        isPublic: true,
        userACL: .edit
    )
}

public enum SpaceThumbnails {
    public static let stackOverflowThumbnail =
        "data:image/jpeg;base64,/9j/2wCEAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDIBCQkJDAsMGA0NGDIhHCEyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMv/AABEIAUABQAMBIgACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APn+iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKu2ekahqFvcXFraySw26b5XUcKP8AH2ql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"

    public static let githubThumbnail =
        "data:image/jpeg;base64,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"
}
