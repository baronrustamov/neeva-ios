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

public class TabCardDetails: CardDropDelegate, CardDetails, AccessingManagerProvider,
    ClosingManagerProvider, SelectingManagerProvider
{
    typealias Item = Tab
    typealias Manager = TabManager

    public let id: String
    private var subscriptions: Set<AnyCancellable> = []

    let tab: Tab
    var item: Tab? { tab }

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
        super.init(tabManager: manager)

        tab.$isPinned.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)

        tab.$title.sink { [weak self] _ in
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

    public override func dropEntered(info: DropInfo) {
        guard let draggingDetail = CardDropDelegate.draggingDetail else {
            return
        }

        let fromIndex =
            manager.activeTabs.firstIndex {
                $0.tabUUID == draggingDetail.id
            } ?? 0

        let toIndex =
            manager.activeTabs.firstIndex {
                $0.tabUUID == self.id
            } ?? 0

        if fromIndex != toIndex {
            if manager[toIndex]?.isPinned ?? false {
                return
            }

            // super.dropEntered, sends notifications, no need to send them here.
            manager.rearrangeTabs(fromIndex: fromIndex, toIndex: toIndex, notify: false)
        }

        super.dropEntered(info: info)
    }

    func onClose() {
        if !tab.isPinned {
            manager.close(tab)
        }
    }

    @ViewBuilder func contextMenu() -> some View {
        let bvc = SceneDelegate.getBVC(with: manager.scene)

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

            Button { [self] in
                tab.showAddToSpacesSheet()
            } label: {
                Label("Save to Spaces", systemSymbol: .bookmark)
            }.disabled(url == nil)

            if tab.canonicalURL?.displayURL != nil {
                Button {
                    bvc.share(tab: self.tab, from: bvc.view, presentableVC: bvc)
                } label: {
                    Label("Share", systemSymbol: .squareAndArrowUp)
                }
            }

            if let url = tab.url?.absoluteString {
                Button {
                    copySuggestion(value: url, scene: self.manager.scene)
                } label: {
                    Label("Copy Link", systemSymbol: .link)
                }
            }

            if isChild {
                Button { [self] in
                    ClientLogger.shared.logCounter(.tabRemovedFromGroup)
                    manager.removeTabFromTabGroup(tab)
                } label: {
                    Label("Remove from group", systemSymbol: .arrowUpForwardSquare)
                }
            }

            ContextMenuActionsBuilder.TogglePinnedTabAction(
                tabManager: manager, tab: tab, isPinned: tab.isPinned)

            Divider()

            if #available(iOS 15.0, *) {
                Button(role: .destructive) { [self] in
                    manager.close(tab)
                } label: {
                    Label("Close Tab", systemSymbol: .trash)
                }
            } else {
                Button { [self] in
                    manager.close(tab)
                } label: {
                    Label("Close Tab", systemSymbol: .trash)
                }
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

    init(space: Space, manager: SpaceStore, showingDetails: Bool = false, isPinnable: Bool = true) {
        self.item = space
        self.id = space.id.id
        self.manager = manager
        self.isPinnable = isPinnable
        self.showingDetails = showingDetails
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
            manager.refreshSpace(spaceID: self.id, anonymous: false)
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
            case .refreshing, .mutatingLocally:
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
        let request = manager.sendDeleteSpaceRequest(spaceId: id)
        subscriptionCount += 1
        request?.$state.sink { [self] state in
            switch state {
            case .initial:
                Logger.browser.info("Waiting for result from deleting space")
            case .success:
                manager.deleteSpace(with: id)
                fallthrough
            case .failure:
                subscriptionCount -= 1
            }
        }.store(in: &subscriptions)
    }

    func unfollowSpace() {
        let request = manager.sendUnfollowSpaceRequest(spaceId: id)
        subscriptionCount += 1
        request?.$state.sink { [self] state in
            switch state {
            case .initial:
                Logger.browser.info("Waiting for result from unfollowing space")
            case .success:
                manager.deleteSpace(with: id)
                fallthrough
            case .failure:
                subscriptionCount -= 1
            }
        }.store(in: &subscriptions)
    }

    func pinSpace() {
        let request = manager.sendPinSpaceRequest(spaceId: id)
        subscriptionCount += 1
        request?.$state.sink { [self] state in
            switch state {
            case .initial:
                Logger.browser.info("Waiting for result from toggling space pin")
            case .success:
                manager.togglePinSpace(with: id)
                fallthrough
            case .failure:
                subscriptionCount -= 1
            }
        }.store(in: &subscriptions)
    }

    func findIndex(
        in collection: [SpaceCardDetails],
        sortType: SpaceSortType,
        sortOrder: SpaceSortOrder
    ) -> Int? {
        guard let item = item else {
            return nil
        }
        let pinnedItemCount = collection.filter({ $0.item?.isPinned ?? false }).count
        let filteredCollection = collection.filter({ $0.item?.isPinned == item.isPinned })
        let firstSortItem = item[keyPath: sortType.keyPath]
        for index in filteredCollection.indices {
            guard let secondSortItem = filteredCollection[index].item?[keyPath: sortType.keyPath]
            else { return nil }
            if sortOrder.makeComparator()(firstSortItem, secondSortItem) {
                return item.isPinned ? index : index + pinnedItemCount
            }
        }
        return item.isPinned
            ? pinnedItemCount - 1 : collection.count - 1
    }
}

// TabGroupCardDetails are not to be used for storing data because they can be recreated.
class TabGroupCardDetails: CardDropDelegate, ObservableObject {
    @Default(.tabGroupExpanded) private var tabGroupExpanded: Set<String>

    @Published var manager: TabManager
    @Published var isShowingDetails = false
    @Published var isSelected: Bool = false

    private var selectedTabListener: AnyCancellable?

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
    @Published var renaming = false
    @Published var deleting = false {
        didSet {
            if deleting {
                guard Defaults[.confirmCloseAllTabs] else {
                    onClose(showToast: true)
                    deleting = false
                    return
                }
            }
        }
    }

    @ViewBuilder func contextMenu() -> some View {
        if let title = customTitle {
            Text("\(allDetails.count) tabs from “\(title)”")
        } else {
            Text("\(allDetails.count) Tabs")
        }

        Button {
            ClientLogger.shared.logCounter(.tabGroupRenameThroughThreeDotMenu)
            self.renaming = true
        } label: {
            Label("Rename", systemSymbol: .pencil)
        }

        if #available(iOS 15.0, *) {
            Button(
                role: .destructive,
                action: {
                    ClientLogger.shared.logCounter(.tabGroupDeleteThroughThreeDotMenu)
                    self.deleting = true
                }
            ) {
                Label("Close All", systemSymbol: .trash)
            }
        } else {
            Button {
                ClientLogger.shared.logCounter(.tabGroupDeleteThroughThreeDotMenu)
                self.deleting = true
            } label: {
                Label("Close All", systemSymbol: .trash)
            }
        }
    }

    init(tabGroup: TabGroup, tabManager: TabManager) {
        self.id = tabGroup.id
        self.manager = tabManager
        super.init(tabManager: tabManager)

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

        setIsSelected(tab: tabManager.selectedTab)
        selectedTabListener = tabManager.selectedTabPublisher.sink { [weak self] selectedTab in
            self?.setIsSelected(tab: selectedTab)
        }
    }

    func onClose(showToast: Bool) {
        if let item = manager.getTabGroup(for: id) {
            manager.closeTabGroup(item, showToast: showToast)
        }
    }

    func setIsSelected(tab: Tab?) {
        self.isSelected = tab?.rootUUID == self.id
    }

    override func dropEntered(info: DropInfo) {
        guard let draggingDetail = CardDropDelegate.draggingDetail else {
            return
        }

        // If a Tab is dragged onto the TabGroup, assign it's rootUUID so it joins the TabGroup.
        draggingDetail.tab.rootUUID = id

        super.dropEntered(info: info)
    }
}

extension Array where Element: SpaceCardDetails {
    func sortSpaces(
        by sortType: SpaceSortType,
        order: SpaceSortOrder
    ) -> Self {
        var temp = self
        return temp.sorted(
            by: {
                guard let firstItem = $0.item, let secondItem = $1.item else { return true }
                return firstItem.isPinned && !secondItem.isPinned
            },
            {
                guard let firstItem = $0.item?[keyPath: sortType.keyPath],
                    let secondItem = $1.item?[keyPath: sortType.keyPath]
                else {
                    return true
                }
                return order.makeComparator()(firstItem, secondItem)
            })
    }

    func filterSpaces(by filterType: SpaceFilterState) -> Self {
        switch filterType {
        case .allSpaces:
            return self
        case .ownedByMe:
            return self.filter { $0.item?.userACL == .owner }
        }
    }

    mutating private func sorted(
        by firstPredicate: (Element, Element) -> Bool,
        _ secondPredicate: (Element, Element) -> Bool
    ) -> [Self.Element] {
        sorted(by:) { lhs, rhs in
            if firstPredicate(lhs, rhs) { return true }
            if firstPredicate(rhs, lhs) { return false }
            if secondPredicate(lhs, rhs) { return true }
            if secondPredicate(rhs, lhs) { return false }
            return false
        }
    }

}
