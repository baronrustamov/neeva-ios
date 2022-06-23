// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

protocol SelectableThumbnail {
    associatedtype ThumbnailView: View

    var thumbnail: ThumbnailView { get }
    func onSelect()
}

protocol CardDetails: ObservableObject, DropDelegate, SelectableThumbnail, Identifiable, Equatable {
    associatedtype Item: BrowserPrimitive
    associatedtype FaviconViewType: View

    var id: String { get }
    var item: Item? { get }
    var closeButtonImage: UIImage? { get }
    var title: String { get }
    var description: String? { get }
    var accessibilityLabel: String { get }
    var defaultIcon: String? { get }
    var favicon: FaviconViewType { get }
    var isSelected: Bool { get }
    var thumbnailDrawsHeader: Bool { get }
    var isSharedWithGroup: Bool { get }
    var isSharedPublic: Bool { get }
    var ACL: SpaceACLLevel { get }

    func onClose()
}

extension CardDetails {
    var isSelected: Bool {
        false
    }

    func performDrop(info: DropInfo) -> Bool {
        return false
    }

    var thumbnailDrawsHeader: Bool {
        true
    }

    var defaultIcon: String? {
        nil
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension CardDetails
where
    Item: Selectable, Self: SelectingManagerProvider, Self.Manager.Item == Item,
    Manager: AccessingManager
{
    func onSelect() {
        if let item = item {
            manager.select(item)
        }
    }
}

extension CardDetails
where
    Item: Closeable, Self: ClosingManagerProvider, Self.Manager.Item == Item,
    Manager: AccessingManager
{

    var closeButtonImage: UIImage? {
        UIImage(systemName: "xmark")
    }

    func onClose() {
        if let item = item {
            manager.close(item)
        }
    }
}

extension CardDetails where Self: AccessingManagerProvider, Self.Manager.Item == Item {
    var title: String {
        item?.displayTitle ?? ""
    }

    var description: String? {
        return item?.pageMetadata?.description
    }

    var isSharedWithGroup: Bool { item?.isSharedWithGroup ?? false }
    var isSharedPublic: Bool { item?.isSharedPublic ?? false }
    var ACL: SpaceACLLevel { item?.ACL ?? .owner }

    @ViewBuilder var thumbnail: some View {
        if let image = item?.image {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
        } else {
            Color.white
        }
    }

    @ViewBuilder var favicon: some View {
        if let item = item {
            if let favicon = item.displayFavicon {
                FaviconView(forFavicon: favicon)
                    .background(Color.white)
            } else if let icon = defaultIcon {
                Image(systemName: icon)
            } else if let url = item.primitiveUrl {
                FaviconView(forSiteUrl: url)
                    .background(Color.white)
            }
        }
    }
}

public class TabCardDetails: CardDetails, AccessingManagerProvider,
    ClosingManagerProvider, SelectingManagerProvider
{
    typealias Item = Tab
    typealias Manager = TabManager

    public let id: String
    private var subscriptions: Set<AnyCancellable> = []

    let tab: Tab
    var item: Tab? { tab }

    struct DragState {
        var tabCardModel: TabCardModel?
        var draggingDetail: TabCardDetails?
    }

    static var dragState: DragState?

    var manager: TabManager
    var isChild: Bool

    var isPinned: Bool {
        tab.isPinned
    }

    var pinnedTime: Double? {
        tab.pinnedTime
    }

    var url: URL? {
        tab.url ?? tab.sessionData?.currentUrl
    }

    var closeButtonImage: UIImage? {
        isPinned ? UIImage(systemName: "pin.fill") : UIImage(systemName: "xmark")
    }

    var isSelected: Bool {
        self.manager.selectedTab?.tabUUID == id
    }

    var rootID: String? {
        tab.rootUUID
    }

    var accessibilityLabel: String {
        "\(title), Tab"
    }

    var thumbnailDrawsHeader: Bool {
        false
    }

    // Override Equatable implementation since we store a Tab instance, and as a result of
    // tab restore, it is possible for two Tab instances to have the same ID.
    public static func == (lhs: TabCardDetails, rhs: TabCardDetails) -> Bool {
        lhs.tab == rhs.tab
    }

    // Avoiding keeping a reference to classes both to minimize surface area these Card classes have
    // access to, but also to not worry about reference copying while using CardDetails for View updates.
    init(tab: Tab, manager: TabManager, isChild: Bool = false) {
        self.id = tab.id
        self.tab = tab
        self.manager = manager
        self.isChild = isChild

        tab.$isPinned.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)

        manager.selectedTabPublisher
            .prepend(nil)
            .withPrevious()
            .sink { (prev, current) in
                if current?.id == self.id && prev?.tabUUID != self.id {
                    self.objectWillChange.send()
                } else if prev?.tabUUID == self.id && current?.id != self.id {
                    self.objectWillChange.send()
                }
            }
            .store(in: &subscriptions)
    }

    // This function is called when the user drop their item
    public func performDrop(info: DropInfo) -> Bool {
        Self.dragState = nil
        return true
    }

    // This function is called right when an item is dragged onto another item
    public func dropEntered(info: DropInfo) {
        guard let _ = Self.dragState?.tabCardModel,
            let draggingDetail = Self.dragState?.draggingDetail
        else {
            return
        }

        let fromIndex =
            manager.tabs.firstIndex {
                $0.tabUUID == draggingDetail.id
            } ?? 0

        let toIndex =
            manager.tabs.firstIndex {
                $0.tabUUID == self.id
            } ?? 0

        if fromIndex != toIndex {
            if interactWithGroupOrPinnedTabs() {
                return
            }
            manager.rearrangeTabs(fromIndex: fromIndex, toIndex: toIndex, notify: true)
        }
    }

    private func interactWithGroupOrPinnedTabs() -> Bool {
        guard let tabCardModel = Self.dragState?.tabCardModel,
            let draggingDetail = Self.dragState?.draggingDetail
        else {
            return false
        }

        let toIndex =
            tabCardModel.allDetails.firstIndex {
                $0.id == self.id
            } ?? 0

        // disable dropping on tab groups or pinned tabs
        return tabCardModel.allTabGroupDetails.contains(where: { $0.id == self.rootID })
            || tabCardModel.allDetails[toIndex].isPinned

    }

    // this function will be called when the dragging state of an item has changed, including
    // the location that it is getting dragged.
    public func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func onClose() {
        if !tab.isPinned {
            manager.close(tab)
        }
    }

    @ViewBuilder func contextMenu() -> some View {
        if !tab.isIncognito {
            Button { [self] in
                manager.duplicateTab(tab, incognito: tab.isIncognito)
            } label: {
                Label("Duplicate Tab", systemSymbol: .plusSquareOnSquare)
            }.disabled(url == nil)

            Button { [self] in
                manager.duplicateTab(tab, incognito: true)
            } label: {
                Label("Open in Incognito", image: "incognito")
            }.disabled(url == nil)

            Button(action: { [self] in
                tab.showAddToSpacesSheet()
            }) {
                Label("Save to Spaces", systemSymbol: .bookmark)
            }.disabled(url == nil)

            if tab.canonicalURL?.displayURL != nil, let bvc = tab.browserViewController {
                Button {
                    bvc.share(tab: self.tab, from: bvc.view, presentableVC: bvc)
                } label: {
                    Label("Share", systemSymbol: .squareAndArrowUp)
                }
            } else {
                Button(action: {}) {
                    Label("Share", systemSymbol: .squareAndArrowUp)
                }.disabled(true)
            }

            if isChild {
                Button(
                    action: { [self] in
                        ClientLogger.shared.logCounter(.tabRemovedFromGroup)
                        manager.removeTabFromTabGroup(tab)
                        ToastDefaults().showToastForPinningTab(
                            pinning: isPinned, tabManager: manager)
                    },
                    label: {
                        Label("Remove from group", systemSymbol: .arrowUpForwardSquare)
                    }
                )
            }

            Button(
                action: { [self] in
                    manager.toggleTabPinnedState(tab)
                },
                label: {
                    isPinned
                        ? Label("Unpin tab", systemSymbol: .pinSlash)
                        : Label("Pin tab", systemSymbol: .pin)
                }
            )

            Divider()

            if #available(iOS 15.0, *) {
                Button(
                    role: .destructive,
                    action: { [self] in
                        manager.close(tab)
                    },
                    label: {
                        Label("Close Tab", systemSymbol: .trash)
                    }
                )
            } else {
                Button(
                    action: { [self] in
                        manager.close(tab)
                    },
                    label: {
                        Label("Close Tab", systemSymbol: .trash)
                    }
                )
            }
        }
    }
}

class SpaceEntityThumbnail: CardDetails, AccessingManagerProvider {
    typealias Item = SpaceEntityData
    typealias Manager = Space

    var manager: Space {
        space ?? SpaceStore.shared.get(for: spaceID) ?? SpaceStore.suggested.get(for: spaceID)
            ?? .empty()
    }

    let spaceID: String
    let space: Space?
    var data: SpaceEntityData

    var id: String
    var item: SpaceEntityData? { manager.get(for: id) }
    var closeButtonImage: UIImage? = nil
    var accessibilityLabel: String = "Space Item"

    var ACL: SpaceACLLevel {
        manager.ACL
    }

    var isImage: Bool {
        return data.url?.isImage ?? false
    }

    var richEntityPreviewURL: URL? {
        guard case .richEntity(let richEntity) = data.previewEntity else {
            return nil
        }
        let spaceURL = NeevaConstants.appSpacesURL.appendingPathComponent(spaceID).absoluteString
        return URL(string: "\(spaceURL)#kg-entity-\(richEntity.id)")

    }

    var productPreviewURL: URL? {
        guard case .retailProduct(let product) = data.previewEntity else {
            return nil
        }
        let spaceURL = NeevaConstants.appSpacesURL.appendingPathComponent(spaceID).absoluteString
        return URL(string: "\(spaceURL)#retail-widget-\(product.id)")
    }

    var techDocURL: URL? {
        guard case .techDoc(let techDoc) = data.previewEntity else {
            return nil
        }
        let spaceURL = NeevaConstants.appSpacesURL.appendingPathComponent(spaceID).absoluteString
        return URL(string: "\(spaceURL)#techdoc-\(techDoc.id)-\(techDoc.id)")
    }

    var previewURL: URL? {
        techDocURL ?? productPreviewURL ?? richEntityPreviewURL
    }

    init(data: SpaceEntityData, spaceID: String, space: Space? = nil) {
        self.spaceID = spaceID
        self.data = data
        self.id = data.id
        self.space = space
    }

    func webImage(url: URL) -> some View {
        WebImage(
            url: url,
            context: [
                .imageThumbnailPixelSize: CGSize(
                    width: SpaceViewUX.DetailThumbnailSize * 4,
                    height: SpaceViewUX.DetailThumbnailSize * 4)
            ]
        )
        .resizable()
        .aspectRatio(contentMode: .fill)
    }

    @ViewBuilder var thumbnail: some View {
        if case .recipe(let recipe) = data.previewEntity,
            let imageURL = URL(string: recipe.imageURL)
        {
            webImage(url: imageURL)
        } else if case .richEntity(let richEntity) = data.previewEntity,
            let imageURL = richEntity.imageURL
        {
            webImage(url: imageURL)
        } else if case .newsItem(let newsItem) = data.previewEntity,
            let imageURL = newsItem.thumbnailURL
        {
            webImage(url: imageURL)
        } else if isImage, let imageURL = data.url {
            webImage(url: imageURL)
        } else if let thumbnail = data.thumbnail,
            let imageUrl = URL(string: thumbnail)
        {
            webImage(url: imageUrl)
        } else {
            GeometryReader { geom in
                Symbol(decorative: .bookmarkOnBookmark, size: geom.size.width / 3)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.spaceIconBackground)
            }
        }
    }

    func onClose() {}
    func onSelect() {}
}

class SpaceCardDetails: CardDetails, AccessingManagerProvider, ThumbnailModel {
    typealias Item = Space
    typealias Manager = SpaceStore
    typealias Thumbnail = SpaceEntityThumbnail

    @Published var manager: SpaceStore
    @Published var showingDetails = false

    var id: String
    var isPinnable: Bool = true
    @Published var allDetails: [SpaceEntityThumbnail] = []
    @Published var allDetailsWithExclusionList: [SpaceEntityThumbnail] = []
    @Published var item: Space?
    @Published private(set) var refreshSpaceSubscription: AnyCancellable? = nil

    var isFollowing: Bool {
        manager.allSpaces.contains { $0.id.id == id }
    }

    var accessibilityLabel: String {
        "\(title), Space"
    }

    var title: String {
        item?.displayTitle ?? ""
    }

    var closeButtonImage: UIImage? {
        guard let item = item, item.isPinned else { return nil }
        return UIImage(systemName: "pin.fill")
    }

    // This is used to manage some of the Combine subscriptions in
    // this class. `subscriptionCount` is a simple ref counter,
    // and when all of our subscriptions are complete, we clear out
    // the `Set` and let the garbage collector do its thing.
    var subscriptions: Set<AnyCancellable> = []
    var subscriptionCount: Int = 0 {
        didSet {
            if subscriptionCount == 0 {
                subscriptions.removeAll()
            }
        }
    }

    init(id: String, manager: SpaceStore) {
        self.id = id
        self.manager = manager
        updateSpace()
    }

    init(space: Space, manager: SpaceStore, isPinnable: Bool = true) {
        self.item = space
        self.id = space.id.id
        self.manager = manager
        self.isPinnable = isPinnable
        updateDetails()
    }

    var thumbnail: some View {
        VStack(spacing: 0) {
            ThumbnailGroupView(model: self)
            HStack {
                Spacer(minLength: 12)
                Text(title)
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .foregroundColor(Color.label)
                    .frame(height: CardUX.HeaderSize)
                if let space = item, !space.isPublic {
                    Symbol(decorative: .lock, style: .labelMedium)
                        .foregroundColor(.secondaryLabel)
                }
                Spacer(minLength: 12)
            }
        }.shadow(radius: 0)
    }

    func refresh(completion: @escaping (Bool) -> Void = { _ in }) {
        guard !(self.item?.isDigest ?? false) else { return }

        if isFollowing {
            manager.refreshSpace(spaceID: self.id)
        }

        refreshSpaceSubscription = manager.$state.sink { state in
            switch state {
            case .ready:
                if self.manager.updatedSpacesFromLastRefresh.first?.id.id ?? ""
                    == self.id || !self.isFollowing
                {
                    self.updateSpace()
                }

                withAnimation(.easeOut) {
                    self.refreshSpaceSubscription = nil
                }
                completion(true)
            case .refreshing:
                return
            case .failed:
                completion(false)
            }
        }
    }

    func updateSpace() {
        manager.getSpaceDetails(spaceId: id) { [weak self] space in
            guard let self = self else { return }
            self.item = space
            self.updateDetails()
        }
    }

    func updateDetails() {
        allDetails =
            item?.contentData?.map {
                SpaceEntityThumbnail(data: $0, spaceID: id, space: self.item)
            } ?? []
        allDetailsWithExclusionList = allDetails.filter({
            $0.data.url?.absoluteString.hasPrefix(NeevaConstants.appSpacesURL.absoluteString)
                ?? false
        })
    }

    func onSelect() {
        showingDetails = true
    }

    func onClose() {}

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.text", "public.url"]) else {
            return false
        }

        let items = info.itemProviders(for: ["public.url"])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url, let space = self.manager.get(for: self.id) {
                    DispatchQueue.main.async {
                        let request = AddToSpaceRequest(
                            title: "Link from \(url.baseDomain ?? "page")",
                            description: "", url: url)
                        request.addToExistingSpace(id: space.id.id, name: space.name)
                    }
                }
            }
        }

        return true
    }

    func deleteSpace() {
        let request = manager.deleteSpace(spaceId: id)
        subscriptionCount += 1
        request?.$state.sink { [self] state in
            switch state {
            case .initial:
                Logger.browser.info("Waiting for result from deleting space")
            case .success:
                manager.refresh(force: true)
                fallthrough
            case .failure:
                subscriptionCount -= 1
            }
        }.store(in: &subscriptions)
    }

    func unfollowSpace() {
        let request = manager.unfollowSpace(spaceId: id)
        subscriptionCount += 1
        request?.$state.sink { [self] state in
            switch state {
            case .initial:
                Logger.browser.info("Waiting for result from unfollowing space")
            case .success:
                manager.refresh(force: true)
                fallthrough
            case .failure:
                subscriptionCount -= 1
            }
        }.store(in: &subscriptions)
    }

    func pinSpace() {
        let request = manager.pinSpace(spaceId: id)
        subscriptionCount += 1
        request?.$state.sink { [self] state in
            switch state {
            case .initial:
                Logger.browser.info("Waiting for result from toggling space pin")
            case .success:
                manager.refresh(force: true) { [self] in
                    // Keep our state up-to-date and propagate
                    // changes to the UI
                    item = manager.allSpaces.first { $0.id.id == id }
                }
                fallthrough
            case .failure:
                subscriptionCount -= 1
            }
        }.store(in: &subscriptions)
    }
}

class SiteCardDetails: CardDetails, AccessingManagerProvider {
    typealias Item = Site
    typealias Manager = SiteFetcher

    @Published var manager: SiteFetcher
    var anyCancellable: AnyCancellable? = nil
    var id: String
    var item: Site? { manager.get(for: id) }
    var closeButtonImage: UIImage?
    var tabManager: TabManager

    var accessibilityLabel: String {
        "\(title), Link"
    }

    init(url: URL, fetcher: SiteFetcher, tabManager: TabManager) {
        self.id = url.absoluteString
        self.manager = fetcher
        self.tabManager = tabManager

        self.anyCancellable = fetcher.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }

        fetcher.load(url: url, profile: tabManager.profile)
    }

    func thumbnail(size: CGFloat) -> some View {
        return WebImage(
            url:
                URL(string: manager.get(for: id)?.pageMetadata?.mediaURL ?? "")
        )
        .resizable().aspectRatio(contentMode: .fill)
    }

    func onSelect() {
        guard let site = manager.get(for: id) else {
            return
        }

        tabManager.selectedTab?.select(site)
    }

    func onClose() {}
}

// TabGroupCardDetails are not to be used for storing data because they can be recreated.
class TabGroupCardDetails: ObservableObject {

    @Default(.tabGroupExpanded) private var tabGroupExpanded: Set<String>

    @Published var manager: TabManager
    @Published var isShowingDetails = false

    var isSelected: Bool {
        manager.selectedTab?.rootUUID == id
    }

    var isExpanded: Bool {
        get {
            tabGroupExpanded.contains(id)
        }
        set {
            if newValue {
                tabGroupExpanded.insert(id)
            } else {
                tabGroupExpanded.remove(id)
            }
        }
    }
    var id: String

    var isPinned: Bool {
        return allDetails.contains {
            $0.isPinned
        }
    }

    var pinnedTime: Double? {
        let pinnedTimeList = allDetails.filter {
            $0.isPinned
        }.map {
            $0.pinnedTime ?? 0
        }

        return pinnedTimeList.min()
    }

    var customTitle: String? {
        get {
            Defaults[.tabGroupNames][id] ?? manager.getTabGroup(for: id)?.inferredTitle
        }
        set {
            Defaults[.tabGroupNames][id] = newValue
            objectWillChange.send()
        }
    }

    var defaultTitle: String? {
        manager.getTabForUUID(uuid: id)?.displayTitle
    }

    var title: String {
        Defaults[.tabGroupNames][id] ?? manager.getTabForUUID(uuid: id)?.displayTitle ?? ""
    }

    @Published var allDetails: [TabCardDetails] = []

    var thumbnailDrawsHeader: Bool {
        false
    }

    var accessibilityLabel: String {
        "\(title), Tab Group"
    }

    var defaultIcon: String? {
        id == manager.getTabGroup(for: id)?.children.first?.parentSpaceID
            ? "bookmark.fill" : "square.grid.2x2.fill"
    }

    init(tabGroup: TabGroup, tabManager: TabManager) {
        self.id = tabGroup.id
        self.manager = tabManager

        if FeatureFlag[.reverseChronologicalOrdering] {
            allDetails = allDetails.reversed()
        }

        allDetails =
            tabGroup.children
            .sorted(by: { lhs, rhs in
                if lhs.isPinned && rhs.isPinned {
                    // Note: We should make it impossible for `pinnedTime` to be nil when
                    // the tab is pinned. Consider changing how this is stored.
                    return (lhs.pinnedTime ?? 0) < (rhs.pinnedTime ?? 0)
                } else if lhs.isPinned && !rhs.isPinned {
                    return true
                } else if !lhs.isPinned && rhs.isPinned {
                    return false
                } else {
                    return false
                }
            })
            .map({
                TabCardDetails(
                    tab: $0,
                    manager: manager,
                    isChild: true)
            })
    }

    func onSelect() {
        isShowingDetails = true
    }

    func onClose(showToast: Bool) {
        if let item = manager.getTabGroup(for: id) {
            manager.closeTabGroup(item, showToast: showToast)
        }
    }
}
