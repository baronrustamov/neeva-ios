// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreSpotlight
import Foundation
import SDWebImage
import UIKit

public protocol SpaceStoreSpotlightEventDelegate: AnyObject {
    func willIndex(_ spaces: [Space])
    func willIndexEntities(for space: Space, count: Int)
    func didIndex(_ spaces: [Space], error: Error?)
    func didIndexEntities(for space: Space, error: Error?)
    func willClearIndex(for domainIdentifier: String)
    func didFailClearIndex(for domainIdentifier: String, error: Error)
}

extension SpaceStore {
    public enum CSConst {
        public static let spaceDomainIdentifier: String = "co.neeva.app.ios.browser.space"
        public static let spaceContentType: UTType = .urlBookmarkData

        public static let spacePageDomainIdentifier: String = "co.neeva.app.ios.browser.space.page"
        public static let spacePageContentType: UTType = .urlBookmarkData
    }

    static let searchableIndex = CSSearchableIndex(name: "co.neeva.app.ios.browser.spaces")
    // Serial queue to protect all indexing operations
    static let CSIndexQueue = DispatchQueue(
        label: "co.neeva.app.ios.browser.spaces.csqueue",
        qos: .utility,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )

    /// SDWebImageTransformer
    static let resizeTransformer = SDImageResizingTransformer(
        size: CGSize(width: 180, height: 270),
        scaleMode: .aspectFit
    )

    static var bookmarkImage: UIImage = {
        // start with symbol with white foreground
        let bookmarkImage = UIImage(systemSymbol: .bookmark)
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        let size = CGSize(width: 180, height: 180)

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.SpaceIconBackground.cgColor)
            context.fill(CGRect(size: size))
            bookmarkImage.draw(in: CGRect(size: size))
        }
    }()

    // MARK: - Space Methods
    /// Add or update spaces in index
    func addSpacesToCoreSpotlight(
        _ spaces: [Space],
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            // add spaces to CS
            DispatchQueue.main.async {
                self.spotlightEventDelegate?.willIndex(spaces)
            }

            Self.searchableIndex.indexSearchableItems(
                spaces.map { space in
                    let attributes = CSSearchableItemAttributeSet(
                        contentType: CSConst.spaceContentType)
                    attributes.title = space.name
                    attributes.contentDescription = space.description
                    let item = CSSearchableItem(
                        // Space.SpaceID.id
                        uniqueIdentifier: space.id.id,
                        domainIdentifier: CSConst.spaceDomainIdentifier,
                        attributeSet: attributes
                    )
                    item.expirationDate = .distantFuture
                    return item
                }
            ) { error in
                DispatchQueue.main.async {
                    self.spotlightEventDelegate?.didIndex(spaces, error: error)
                    completionHandler?(error)
                }
            }
        }
    }

    /// Remove spaces from corespoltight by id
    public class func removeSpacesFromCoreSpotlight(
        _ ids: [SpaceID],
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            Self.searchableIndex.deleteSearchableItems(
                withIdentifiers: ids.map { $0.id },
                completionHandler: completionHandler
            )
        }
    }

    // MARK: - Page Methods
    func addSpaceURLsToCoreSpotlight(
        from space: Space,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            // the data might have changed between when the func is called and when this executes
            // but it should always be correct to use the most recent data in the Space instance
            guard let data = space.contentData else { return }

            let group = DispatchGroup()

            var items: [CSSearchableItem?] = Array(repeating: nil, count: data.count)

            for (idx, entity) in data.enumerated() {
                guard let url = entity.url else { continue }
                group.enter()
                Self.getThumbnailData(for: entity) { image in
                    let attributes = CSSearchableItemAttributeSet(
                        contentType: CSConst.spacePageContentType
                    )
                    attributes.title = entity.displayTitle
                    attributes.contentDescription = entity.displayDescription
                    attributes.url = url
                    attributes.thumbnailData = (image ?? Self.bookmarkImage).pngData()
                    let item = CSSearchableItem(
                        uniqueIdentifier: url.absoluteString,
                        domainIdentifier: CSConst.spacePageDomainIdentifier,
                        attributeSet: attributes)
                    items[idx] = item
                    group.leave()
                }
            }

            // block the queue
            group.wait()

            DispatchQueue.main.async {
                self.spotlightEventDelegate?.willIndexEntities(
                    for: space,
                    count: items.compactMap { $0 }.count
                )
            }

            Self.searchableIndex.indexSearchableItems(
                items.compactMap { $0 }
            ) { error in
                DispatchQueue.main.async {
                    self.spotlightEventDelegate?.didIndexEntities(for: space, error: error)
                    completionHandler?(error)
                }
            }
        }
    }

    // MARK: - Clear Index
    // Remove all space items in the index
    public func removeAllSpacesFromCoreSpotlight(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            DispatchQueue.main.async {
                self.spotlightEventDelegate?.willClearIndex(for: CSConst.spaceDomainIdentifier)
            }
            Self.searchableIndex.deleteSearchableItems(
                withDomainIdentifiers: [CSConst.spaceDomainIdentifier]
            ) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.spotlightEventDelegate?.didFailClearIndex(
                            for: CSConst.spaceDomainIdentifier, error: error)
                    }
                    completionHandler?(error)
                }
            }
        }
    }

    public func removeAllSpaceURLsFromCoreSpotlight(
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            DispatchQueue.main.async {
                self.spotlightEventDelegate?.willClearIndex(for: CSConst.spacePageDomainIdentifier)
            }
            Self.searchableIndex.deleteSearchableItems(
                withDomainIdentifiers: [CSConst.spacePageDomainIdentifier]
            ) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.spotlightEventDelegate?.didFailClearIndex(
                            for: CSConst.spacePageDomainIdentifier, error: error)
                    }
                    completionHandler?(error)
                }
            }
        }
    }

    // Clear all items in the index
    public func clearIndex(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            DispatchQueue.main.async {
                self.spotlightEventDelegate?.willClearIndex(for: "")
            }
            Self.searchableIndex.deleteAllSearchableItems { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.spotlightEventDelegate?.didFailClearIndex(for: "", error: error)
                    }
                    completionHandler?(error)
                }
            }
        }
    }

    // MARK: - Helpers
    // Query Image from SDWebImage
    private class func getThumbnailData(
        for entity: SpaceEntityData,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        if let thumbnailData = entity.thumbnail?.dataURIBody {
            completionHandler(UIImage.imageFromDataThreadSafe(thumbnailData))
        } else if let thumbnailURL = entity.getThumbnailURL() {
            downloadHelperSDWebImage(imageURL: thumbnailURL) { image in
                completionHandler(image)
            }
        } else {
            completionHandler(nil)
        }
    }

    private class func downloadHelperSDWebImage(
        imageURL: URL,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        let manager = SDWebImageManager.shared
        let options: SDWebImageOptions = [.lowPriority, .fromCacheOnly]

        let onCompletedPageFavicon: SDInternalCompletionBlock = {
            (img, _, _, _, _, _) -> Void in
            completionHandler(img)
        }

        manager.loadImage(
            with: imageURL,
            options: options,
            context: [.imageTransformer: Self.resizeTransformer],
            progress: nil,
            completed: onCompletedPageFavicon
        )
    }

}

extension SpaceEntityData {
    static let imageExtensions = Set(["jpeg", "jpg", "png", "gif"])

    var isImage: Bool {
        guard let pathExtension = url?.pathExtension else {
            return false
        }
        return Self.imageExtensions.contains(pathExtension)
    }

    var displayTitle: String? {
        switch previewEntity {
        case .richEntity(let richEntity):
            return richEntity.title
        case .retailProduct(let product):
            return product.title
        case .techDoc(let doc):
            return doc.title
        case .newsItem(let newsItem):
            return newsItem.title
        case .recipe(let recipe):
            return recipe.title
        case .webPage, .spaceLink:
            return title
        }
    }

    var displayDescription: String? {
        switch previewEntity {
        case .richEntity(let richEntity):
            return richEntity.description
        case .retailProduct(let product):
            return product.description.first
        case .newsItem(let newsItem):
            return newsItem.snippet
        case .webPage, .spaceLink, .recipe, .techDoc:
            return snippet
        }
    }

    func getThumbnailURL() -> URL? {
        switch previewEntity {
        case let .recipe(recipe):
            return URL(string: recipe.imageURL)
        case let .richEntity(richEntity):
            return richEntity.imageURL
        case let .newsItem(newsItem):
            return newsItem.thumbnailURL
        default:
            break
        }
        if isImage {
            return url
        }
        return nil
    }
}
