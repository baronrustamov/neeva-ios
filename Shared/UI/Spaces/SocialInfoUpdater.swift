// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import SDWebImageSwiftUI

public enum SocialInfoType: String, CaseIterable {
    case twitter = "twitter.com"
    case instagram = "instagram.com"
}

public class SocialInfoUpdater: ObservableObject {
    let type: SocialInfoType
    let ogTitle: String
    let ogDescription: String
    var ogImage: String
    let updateReady: (Range<Int>, SpaceEntityData, SpaceID) -> Void

    var thumbnail: String? = nil
    var subscription: AnyCancellable? = nil
    var updateAfterDownload = false
    var cachedEntityID: String? = nil
    var cachedSpaceID: String? = nil

    @Published var state: UpdateSpaceEntityRequest.State = .initial

    public init(
        type: SocialInfoType, ogTitle: String, ogDescription: String, ogImage: String,
        updateReady: @escaping (Range<Int>, SpaceEntityData, SpaceID) -> Void
    ) {
        self.type = type
        self.ogTitle = ogTitle
        self.ogDescription = ogDescription
        self.ogImage = ogImage
        self.updateReady = updateReady

        if case .twitter = type, let imageURL = URL(string: ogImage) {
            if imageURL.lastPathComponent.localizedCaseInsensitiveContains("_normal.jpg") {
                let withoutLast = imageURL.deletingLastPathComponent().absoluteString
                let last = imageURL.lastPathComponent
                self.ogImage = withoutLast + last.dropLast("_normal.jpg".count) + ".jpg"
            }
        }

        SDWebImageManager.shared.loadImage(
            with: URL(string: self.ogImage),
            options: .highPriority,
            progress: nil
        ) { (image, data, error, cacheType, isFinished, imageUrl) in
            DispatchQueue.global(qos: .userInitiated).async {
                guard
                    let image = image,
                    let data = image.jpegData(
                        compressionQuality: 0.7
                            - min(
                                0.4,
                                0.2 * floor(image.size.width / 1000)))
                else {
                    return
                }

                let string = data.base64EncodedString()

                DispatchQueue.main.async {
                    self.thumbnail = "data:image/jpeg;base64," + string
                    if self.updateAfterDownload {
                        self.update(entity: self.cachedEntityID!, within: self.cachedSpaceID!)
                    }
                }
            }
        }
    }

    public var title: String {
        switch type {
        case .twitter:
            return ogTitle
        case .instagram:
            let index = ogTitle.firstIndex(of: ":")
            return String(ogTitle.prefix(upTo: index ?? ogTitle.endIndex))
        }
    }

    public var description: String? {
        switch type {
        case .twitter:
            return ogDescription
        case .instagram:
            let index = ogTitle.firstIndex(of: ":")
            return index == nil
                ? ""
                : String(
                    ogTitle.suffix(from: ogTitle.index(after: index ?? ogTitle.startIndex))
                        .dropFirst(2).dropLast())
        }
    }

    public func update(entity: String, within spaceID: String) {
        guard let space = SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID }),
            let thumbnail = thumbnail
        else {
            updateAfterDownload = true
            cachedSpaceID = spaceID
            cachedEntityID = entity
            return
        }

        let oldData = (space.contentData?.first(where: { $0.id == entity }))!
        let index = (space.contentData?.firstIndex(where: { $0.id == entity }))!
        let newData = SpaceEntityData(
            id: oldData.id,
            url: oldData.url,
            title: title,
            snippet: description,
            thumbnail: thumbnail,
            previewEntity: .webPage)
        space.contentData?.replaceSubrange(
            index..<(index + 1), with: [newData])
        updateReady(index..<(index + 1), newData, space.id)
        let request = SpaceServiceProvider.shared.updateSpaceEntity(
            spaceID: spaceID, entityID: entity,
            title: title, snippet: description, thumbnail: thumbnail)
        subscription = request?.$state.sink { state in
            self.state = state
            if case .success = state {
                SpaceStore.shared.refresh()
            }
        }
    }

    public static func from(
        url: URL, ogInfo: [String]?, title: String,
        updateReady: @escaping (Range<Int>, SpaceEntityData, SpaceID) -> Void
    ) -> SocialInfoUpdater? {
        guard let type = SocialInfoType(rawValue: url.baseDomain ?? ""), let ogTitle = ogInfo?[0],
            let ogDescription = ogInfo?[1], let ogImage = ogInfo?[2]
        else {
            return nil
        }
        return SocialInfoUpdater(
            type: type, ogTitle: ogTitle, ogDescription: ogDescription, ogImage: ogImage,
            updateReady: updateReady)
    }
}
