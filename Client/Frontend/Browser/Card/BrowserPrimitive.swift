// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

/// The intention for a browser primitive is to represent any metadata or entity tied to a url with a card in a heterogenous UI. Tabs are
/// the canonical browser primitive, but Spaces, a single entry in a Space, a History entry, a product in a web page can be a browser
/// primitive as well. The framework here tries to establish rules around how these primitives should be represented and how they can
/// interact with the user and each other. Ex: Dragging a product on top of a tab card should save that product as metadata in the tab,
/// or links within a page can be cards and dragging them to a space card should add them to the Space.

/// If you are adding a new BrowserPrimitive via an extension, think of the best Managers for that primitive and add those, too. Different
/// managers for the same primitive do not have to be of the same type. Ex: Clicking on a History item should navigate to that url in the
/// current tab (SelectingManager is Tab), but swiping it away should delete it from history (ClosingManager is History DB)

/// As a principle, BrowserPrimitive should stay as a data model rather and a ViewModel. Any details about presentation of the primitive
/// should live inside the corresponding CardDetails. (That's why we have image as a UIImage but thumbnail as a View. Thumbnail can
/// be derived from any of the data provided by the primitive. (We can choose image as the thumbnail but can also fallback to using a
/// mediaUrl inside the pageMetadata). This is also why CardDetails is the DropDelegate rather than the BrowserPrimitive.

/// If you need access to more specific BrowserPrimitive for building cards, use thumbnail inside CardDetails by setting
/// thumbnailDrawsHeader

protocol BrowserPrimitive: Identifiable {
    var primitiveUrl: URL? { get }
    var displayTitle: String { get }
    var displayFavicon: Favicon? { get }
    var image: UIImage? { get }
    var pageMetadata: PageMetadata? { get }

    var isSharedWithGroup: Bool { get }
    var isSharedPublic: Bool { get }
    var ACL: SpaceACLLevel { get }
}

extension BrowserPrimitive {
    var isSharedWithGroup: Bool { false }
    var isSharedPublic: Bool { false }
    var ACL: SpaceACLLevel { .owner }
}

protocol Closeable {
    associatedtype Manager: ClosingManager where Manager.Item == Self

    func close(with manager: Manager)
}

protocol Selectable {
    associatedtype Manager: SelectingManager where Manager.Item == Self

    func select(with manager: Manager)
}

protocol AccessingManagerProvider {
    associatedtype Manager: AccessingManager
    var manager: Manager { get }
}

protocol AccessingManager {
    associatedtype Item: BrowserPrimitive
    func getAll() -> [Item]
}

protocol ClosingManagerProvider {
    associatedtype Manager: ClosingManager
    var manager: Manager { get set }
}

protocol ClosingManager {
    associatedtype Item
    func close(_ item: Item)
}

protocol SelectingManagerProvider {
    associatedtype Manager: SelectingManager
    var manager: Manager { get set }
}

protocol SelectingManager {
    associatedtype Item
    func select(_ item: Item)
}

// MARK: Tab: BrowserPrimitive
extension Tab: Closeable, Selectable, BrowserPrimitive {
    public var id: String {
        tabUUID
    }

    var primitiveUrl: URL? {
        url
    }

    var displayFavicon: Favicon? {
        favicon
    }

    var image: UIImage? {
        screenshot
    }

    typealias Manager = TabManager

    func close(with manager: TabManager) {
        manager.close(self)
    }

    func select(with manager: TabManager) {
        manager.select(self)
    }
}

extension TabManager: ClosingManager, SelectingManager, AccessingManager {
    typealias Item = Tab

    func close(_ tab: Tab) {
        withAnimation {
            removeTab(tab, showToast: true)
        }
    }

    func select(_ tab: Tab) {
        selectTab(tab, notify: true)
    }

    func getAll() -> [Tab] {
        return tabs
    }
}

// MARK: Space: BrowserPrimitive
extension Space: BrowserPrimitive {
    var primitiveUrl: URL? {
        url
    }

    var displayTitle: String {
        name
    }

    var displayFavicon: Favicon? {
        nil
    }

    var image: UIImage? {
        if let thumbnail = thumbnail?.dataURIBody {
            return UIImage(data: thumbnail)
        }
        return nil
    }

    var pageMetadata: PageMetadata? {
        return nil
    }

    var isSharedWithGroup: Bool { isShared }
    var isSharedPublic: Bool { isPublic }
    var ACL: SpaceACLLevel { userACL }
}

extension SpaceStore: AccessingManager {
    typealias Item = Space

    func get(for id: String) -> Space? {
        allSpaces.first(where: { $0.id.id == id })
    }

    func getAll() -> [Space] {
        allSpaces
    }
}

extension SpaceEntityData: BrowserPrimitive {
    var primitiveUrl: URL? {
        url
    }

    var displayTitle: String {
        title ?? url?.absoluteString ?? ""
    }

    var displayFavicon: Favicon? {
        nil
    }

    var image: UIImage? {
        guard let data = thumbnail?.dataURIBody else {
            return nil
        }
        return UIImage(data: data)
    }

    var pageMetadata: PageMetadata? {
        return PageMetadata.fromDictionary([
            MetadataKeys.pageURL.rawValue: primitiveUrl?.absoluteString as Any,
            MetadataKeys.provider.rawValue: primitiveUrl?.baseDomain as Any,
            MetadataKeys.description.rawValue: snippet as Any,
        ])
    }
}

extension Space: AccessingManager {
    func get(for id: String) -> SpaceEntityData? {
        contentData?.first {
            $0.id == id
        }
    }

    func getAll() -> [SpaceEntityData] {
        contentData ?? []
    }

    typealias Item = SpaceEntityData
}

// MARK: Site: BrowserPrimitive
extension Site: BrowserPrimitive {
    var primitiveUrl: URL? {
        url
    }

    var displayTitle: String {
        title
    }

    var displayFavicon: Favicon? {
        icon
    }

    var image: UIImage? {
        nil
    }

    var pageMetadata: PageMetadata? {
        metadata
    }
}

class SiteFetcher: AccessingManager, ObservableObject {
    typealias Item = Site

    @Published private var cache: [String: Site] = [:]
    private var sites: [Site?] = [] {
        didSet {
            self.cache = self.sites.compactMap { $0 }.reduce(into: [:]) { dict, site in
                dict[site!.url.absoluteString] = site
            }
        }
    }

    func load(url: URL, profile: Profile) {
        let sql = profile.metadata
        sql.metadata(for: url).uponQueue(.main) { val in
            guard let metadata = val.successValue?.asArray().first else {
                return
            }

            let site = Site(url: url, title: metadata?.title ?? "")
            site.metadata = metadata
            self.sites.append(site)
        }
    }

    func get(for id: String) -> Site? {
        cache[id]
    }

    func getAll() -> [Site] {
        Array(cache.values)
    }
}

extension Tab: SelectingManager {
    typealias Item = Site

    func select(_ item: Site) {
        loadRequest(URLRequest(url: item.url))
    }
}
