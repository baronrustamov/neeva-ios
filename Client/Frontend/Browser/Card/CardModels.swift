// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import Storage
import SwiftUI

protocol ThumbnailModel: ObservableObject {
    associatedtype Thumbnail: SelectableThumbnail
    var allDetails: [Thumbnail] { get }
    var allDetailsWithExclusionList: [Thumbnail] { get }
}

protocol CardModel: ThumbnailModel {
    associatedtype Manager: AccessingManager
    associatedtype Details: CardDetails where Details.Item == Manager.Item
    var manager: Manager { get }
    var allDetails: [Details] { get }
    var allDetailsWithExclusionList: [Details] { get }

    func onDataUpdated()
}

class TabCardModel: CardModel {
    private var subscription: Set<AnyCancellable> = Set()

    private(set) var manager: TabManager
    private(set) var normalRows: [Row] = []
    private(set) var timeBasedNormalRows: [TimeFilter: [Row]] = [:]
    private(set) var incognitoRows: [Row] = []
    private(set) var timeBasedIncognitoRows: [TimeFilter: [Row]] = [:]
    private(set) var allDetails: [TabCardDetails] = []
    private(set) var allDetailsWithExclusionList: [TabCardDetails] = []
    var columnCount: Int = 2 {
        didSet {
            updateRows()
        }
    }

    // Tab Group related members
    private(set) var representativeTabs: [Tab] = []
    private(set) var allTabGroupDetails: [TabGroupCardDetails] = []

    @Default(.tabGroupExpanded) private var tabGroupExpanded: Set<String>
    var needsUpdateRows: Bool = false
    static let todayRowHeaderID: String = "today-header"
    static let lastweekRowHeaderID: String = "lastWeek-header"

    private(set) var tabsDidChange = false

    private func updateRows() {
        if FeatureFlag[.enableTimeBasedSwitcher] {
            // Ensure representative tab is the most recently used tab in a tab group.
            updateRepresentativeTabs()
            timeBasedIncognitoRows[.today] = buildRows(incognito: true, byTime: .today)
            timeBasedNormalRows[.today] = buildRows(incognito: false, byTime: .today)
            timeBasedIncognitoRows[.lastWeek] = buildRows(
                incognito: true, byTime: .lastWeek)
            timeBasedNormalRows[.lastWeek] = buildRows(
                incognito: false, byTime: .lastWeek)
        } else {
            incognitoRows = buildRows(incognito: true)
            normalRows = buildRows(incognito: false)
        }

        // Defer signaling until after we have finished updating. This way our state is
        // completely consistent with TabManager prior to accessing allDetails, etc.
        self.objectWillChange.send()
    }

    func updateRowsIfNeeded() {
        if needsUpdateRows {
            needsUpdateRows = false
            updateRows()
        }
    }

    func getRows(incognito: Bool) -> [Row] {
        var returnValue: [Row] = []

        if FeatureFlag[.enableTimeBasedSwitcher] {
            if incognito {
                returnValue =
                    (timeBasedIncognitoRows[.today] ?? [])
                    + (timeBasedIncognitoRows[.lastWeek] ?? [])
            } else {
                returnValue =
                    (timeBasedNormalRows[.today] ?? []) + (timeBasedNormalRows[.lastWeek] ?? [])
            }
        } else {
            returnValue = incognito ? incognitoRows : normalRows
        }

        for id in 0..<returnValue.count {
            returnValue[id].index = id + 1
        }

        return returnValue
    }

    var normalDetails: [TabCardDetails] {
        allDetails.filter {
            $0.tab.isIncognito == false
        }
    }

    var incognitoDetails: [TabCardDetails] {
        allDetails.filter {
            $0.tab.isIncognito == true
        }
    }

    init(manager: TabManager) {
        self.manager = manager

        manager.tabsUpdatedPublisher.sink { [weak self] in
            self?.tabsDidChange = true
            self?.onDataUpdated()
            // 'tabsDidChange' is used by CardScrollContainer to set its animation
            // to .default. This is needed to handle a bug which the scroll view
            // doesn't get pushed down when the bottom tab is closed.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.tabsDidChange = false
            }
        }.store(in: &subscription)

        if FeatureFlag[.enableTimeBasedSwitcher] {
            manager.selectedTabPublisher.sink { [weak self] tab in
                guard let self = self, let _ = tab else {
                    return
                }
                self.needsUpdateRows = true
            }.store(in: &subscription)
        }

        _tabGroupExpanded.publisher.sink { [weak self] _ in
            self?.updateRows()
        }.store(in: &subscription)
    }

    struct Row: Identifiable {
        var id: Set<String> { Set(cells.map(\.id)) }
        var numTabsInRow: Int {
            cells.reduce(
                0,
                { total, cell in
                    total + cell.numTabs
                })
        }

        enum Cell: Identifiable {
            case tab(TabCardDetails)
            case tabGroupInline(TabGroupCardDetails)
            case tabGroupGridRow(TabGroupCardDetails, Range<Int>)
            case sectionHeader(TimeFilter)

            var id: String {
                switch self {
                case .tab(let details):
                    return details.id
                case .tabGroupInline(let details):
                    return details.id
                case .tabGroupGridRow(let details, let range):
                    return details.allDetails[range].reduce("") { $0 + $1.id + ":" }
                case .sectionHeader(let timeFilter):
                    return timeFilter.rawValue == "Last Week"
                        ? TabCardModel.lastweekRowHeaderID
                        : TabCardModel.todayRowHeaderID
                }
            }

            var isSelected: Bool {
                switch self {
                case .tab(let details):
                    return details.isSelected
                case .tabGroupInline(let details):
                    return details.isSelected
                case .tabGroupGridRow(let details, let range):
                    return details.allDetails[range].contains { $0.isSelected }
                case .sectionHeader(_):
                    return false
                }
            }

            var numTabs: Int {
                switch self {
                case .tab(_):
                    return 1
                case .tabGroupInline(let details):
                    return details.allDetails.count
                case .tabGroupGridRow(_, let range):
                    return range.count
                case .sectionHeader(_):
                    return 0
                }
            }
        }
        var cells: [Cell]
        var index: Int?
        var multipleCellTypes: Bool = false
    }

    func buildRows(incognito: Bool, byTime: TimeFilter? = nil) -> [Row] {
        var rows: [Row] = []

        var allDetailsFiltered = allDetails.filter { tabCard in
            let tab = tabCard.tab
            return
                (representativeTabs.contains(tab)
                || allDetailsWithExclusionList.contains { $0.id == tabCard.id })
                && tab.isIncognito == incognito
                && (FeatureFlag[.enableTimeBasedSwitcher]
                    ? tab.wasLastExecuted(byTime!) : true)
        }

        modifyAllDetailsFilteredPromotingPinnedTabs(&allDetailsFiltered)

        let lastPinnedIndex = allDetailsFiltered.lastIndex(where: { $0.isPinned })

        // An array to keep track of whether a CardDetail has been processed. This allows us to skip
        // the CardDetail that are pre-processed due to lookahead.
        var processed = Array(repeating: false, count: allDetailsFiltered.count)

        // This functions performs lookahead and checks if there are tab/tab groups that can be inserted
        // in the current row before a new row gets inserted.
        func PromoteCellsAfterIndex(currDetail: TabCardDetails, row: inout Row, index: Int) {
            var didPromote = false
            var id = index

            while id < allDetailsFiltered.count && row.numTabsInRow < columnCount {
                let details = allDetailsFiltered[id]

                // don't promote non-pinned tabs if we're still in pinned section
                if let lastPinnedIndex = lastPinnedIndex {
                    if let tabGroup = allTabGroupDetails.first(where: {
                        $0.id == currDetail.rootID
                    }), tabGroup.isPinned && index > lastPinnedIndex {
                        return
                    }
                    if currDetail.isPinned && index > lastPinnedIndex {
                        return
                    }
                }

                if let tabGroup = allTabGroupDetails.first(where: { $0.id == details.rootID }) {
                    // Expanded tab group won't get promoted
                    if !tabGroup.isExpanded
                        && (tabGroup.allDetails.count + row.numTabsInRow)
                            <= columnCount
                    {
                        row.cells.append(.tabGroupInline(tabGroup))
                        didPromote = true
                        processed[id] = true
                    }
                } else {
                    row.cells.append(.tab(details))
                    didPromote = true
                    processed[id] = true
                }

                id = id + 1
            }

            // Row.multipleCelltypes is needed for the UI to create spacing between different types of cells.
            // This value won't be evaluated in the UI if the row contains only individual tabs. So, it's
            // set to true as long as some tab/tab group is promoted.
            if didPromote {
                row.multipleCellTypes = true
            }
        }

        for (index, details) in allDetailsFiltered.enumerated() {
            if processed[index] { continue }
            let tabGroup = allTabGroupDetails.first(where: { $0.id == details.rootID })
            if rows.isEmpty || rows.last!.numTabsInRow >= columnCount
                || tabGroup != nil
            {
                if let tabGroup = tabGroup {
                    if tabGroup.isExpanded {
                        // Perform lookahead before we insert a new row.
                        if !rows.isEmpty {
                            PromoteCellsAfterIndex(
                                currDetail: allDetailsFiltered[index],
                                row: &rows[rows.endIndex - 1], index: index + 1)
                        }
                        // tabGroupGridRow always occupies a row by itself.
                        for index in stride(
                            from: 0, to: tabGroup.allDetails.count, by: columnCount)
                        {
                            var max = index + columnCount
                            if max > tabGroup.allDetails.count {
                                max = tabGroup.allDetails.count
                            }
                            let range = index..<max
                            rows.append(
                                Row(cells: [Row.Cell.tabGroupGridRow(tabGroup, range)]))
                        }
                    } else {
                        // If there's enough remaining columns, fit the tab group in the same row with individual tabs.
                        // Otherwise, build a horizontal scroll view in the next row.
                        if (tabGroup.allDetails.count + (rows.last?.numTabsInRow ?? 0))
                            <= columnCount && !rows.isEmpty
                            && !(!details.isPinned && allDetailsFiltered[index - 1].isPinned)
                        {
                            rows[rows.endIndex - 1].cells.append(
                                .tabGroupInline(tabGroup))
                            rows[rows.endIndex - 1].multipleCellTypes = true
                        } else {
                            // Perform lookahead before we insert a new row.
                            if !rows.isEmpty {
                                PromoteCellsAfterIndex(
                                    currDetail: allDetailsFiltered[index],
                                    row: &rows[rows.endIndex - 1],
                                    index: index + 1)
                            }
                            rows.append(
                                Row(cells: [Row.Cell.tabGroupInline(tabGroup)]))
                        }
                    }
                } else {
                    rows.append(Row(cells: [.tab(details)]))
                }
                // Insert a new row (following expanded tab group) for individual tabs
                if tabGroup != nil && tabGroup!.isExpanded {
                    rows.append(Row(cells: []))
                }
            } else {
                rows[rows.endIndex - 1].cells.append(.tab(details))
                rows[rows.endIndex - 1].multipleCellTypes = true
            }
        }

        rows = rows.filter {
            !$0.cells.isEmpty
        }

        if FeatureFlag[.enableTimeBasedSwitcher] && !rows.isEmpty, let byTime = byTime {
            rows.insert(Row(cells: [Row.Cell.sectionHeader(byTime)]), at: 0)
        }

        return rows
    }

    func onDataUpdated() {
        allDetails = manager.getAll()
            .map { TabCardDetails(tab: $0, manager: manager) }

        if FeatureFlag[.reverseChronologicalOrdering] {
            allDetails = allDetails.reversed()
        }

        allDetailsWithExclusionList = manager.getAll().filter {
            !manager.childTabs.contains($0)
        }
        .map { TabCardDetails(tab: $0, manager: manager) }

        // Tab Group related updates
        updateRepresentativeTabs()
        allTabGroupDetails = manager.getAllTabGroup().map {
            TabGroupCardDetails(tabGroup: $0, tabManager: manager)
        }

        // When the number of tabs in a tab group decreases and makes the group
        // unable to expand, we remove the group from the expanded list. A side-effect
        // of this resolves a problem where TabGroupHeader doesn't hide arrows button
        // when the number of tabs drops below columnCount.
        tabGroupExpanded.forEach { groupID in
            if let tabGroup = allTabGroupDetails.first(where: { groupID == $0.id }),
                tabGroup.allDetails.count <= columnCount
            {
                tabGroupExpanded.remove(groupID)
            }
        }

        updateRows()
    }

    private func updateRepresentativeTabs() {
        if FeatureFlag[.enableTimeBasedSwitcher] {
            representativeTabs = manager.getAllTabGroup()
                .reduce(into: [Tab]()) { $0.append(manager.getMostRecentChild($1)!) }
        } else {
            representativeTabs = manager.getAllTabGroup()
                .reduce(into: [Tab]()) { $0.append($1.children.first!) }
        }
    }

    private func modifyAllDetailsFilteredPromotingPinnedTabs(
        _ allDetailsFiltered: inout [TabCardDetails]
    ) {
        allDetailsFiltered = allDetailsFiltered.sorted(by: { lhs, rhs in
            let lhsPinnedTime = findDetailPinnedTime(lhs)
            let rhsPinnedTime = findDetailPinnedTime(rhs)
            if lhsPinnedTime == nil && rhsPinnedTime != nil {
                return false
            } else if lhsPinnedTime != nil && rhsPinnedTime == nil {
                return true
            } else if lhsPinnedTime != nil && rhsPinnedTime != nil {
                return lhsPinnedTime! < rhsPinnedTime!
            }
            return false
        })
    }

    private func findDetailPinnedTime(_ detail: TabCardDetails)
        -> Double?
    {
        if let tabGroup = allTabGroupDetails.first(where: { $0.id == detail.rootID }) {
            return tabGroup.pinnedTime
        } else {
            return detail.pinnedTime
        }
    }

    func getAllDetails(matchingIncognitoState: Bool?) -> [TabCardDetails] {
        if let matchingIncognitoState = matchingIncognitoState {
            return matchingIncognitoState ? incognitoDetails : normalDetails
        } else {
            return allDetails
        }
    }

    func rearrangeAllDetails(fromIndex: Int, toIndex: Int) {
        allDetails.rearrange(from: fromIndex, to: toIndex)
        updateRows()
    }

    func buildRowsForTesting() -> [Row] {
        buildRows(incognito: false)
    }
}

func getLogCounterAttributesForSpaces(details: SpaceCardDetails?) -> [ClientLogCounterAttribute] {
    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isPublic,
            value: String(details?.isSharedPublic ?? false)))
    if details?.isSharedPublic == true {
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.spaceID,
                value: String(details?.id ?? "")))
    }
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isShared,
            value: String(details?.isSharedWithGroup ?? false)))
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.numberOfSpaceEntities,
            value: String(details?.allDetails.count ?? 1)
        )

    )
    return attributes
}

class SpaceCardModel: CardModel {
    @Published private(set) var manager = SpaceStore.shared
    @Published var allDetails: [SpaceCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published private(set) var allDetailsWithExclusionList: [SpaceCardDetails] = []
    @Published var detailedSpace: SpaceCardDetails? {
        didSet {
            guard detailedSpace == nil else {
                ClientLogger.shared.logCounter(
                    .SpacesDetailUIVisited,
                    attributes:
                        getLogCounterAttributesForSpaces(details: detailedSpace!))
                // Collect separately. View definition depends on aggregate stats policy
                ClientLogger.shared.logCounter(
                    .space_app_view,
                    attributes:
                        getLogCounterAttributesForSpaces(details: detailedSpace!))
                return
            }

            if let id = spaceNeedsRefresh {
                manager.refreshSpace(spaceID: id)
                spaceNeedsRefresh = nil
            }
        }
    }
    @Published var updatedItemIDs = [String]()
    @Published var filterState: SpaceFilterState = .allSpaces

    var detailsMatchingFilter: [SpaceCardDetails] {
        let spaces = allDetails.filter {
            NeevaFeatureFlags[.enableSpaceDigestCard] || $0.id != SpaceStore.dailyDigestID
        }

        switch filterState {
        case .allSpaces:
            return spaces
        case .ownedByMe:
            return spaces.filter { $0.space?.userACL == .owner }
        }
    }

    var thumbnailURLCandidates = [URL: [URL]]()
    private var anyCancellable: AnyCancellable? = nil
    private var recommendationSubscription: AnyCancellable? = nil
    private var editingSubscription: AnyCancellable? = nil
    private var detailsSubscriptions: Set<AnyCancellable> = Set()
    private var spaceNeedsRefresh: String? = nil

    init(manager: SpaceStore = SpaceStore.shared) {
        self.manager = manager

        manager.spotlightEventDelegate = SpotlightLogger.shared

        NeevaUserInfo.shared.$isUserLoggedIn.sink { isLoggedIn in
            DispatchQueue.main.async {
                // Refresh to get spaces for logged in users and to clear cache for logged out users
                SpaceStore.shared.refresh()
            }

            if !isLoggedIn {
                self.allDetails = []
            }
        }.store(in: &detailsSubscriptions)

        self.anyCancellable = manager.$state.sink { [weak self] state in
            guard let self = self, self.detailedSpace == nil, case .ready = state,
                manager.updatedSpacesFromLastRefresh.count > 0
            else {
                return
            }

            if manager.updatedSpacesFromLastRefresh.count == 1,
                let id = manager.updatedSpacesFromLastRefresh.first?.id.id,
                let indexInStore = manager.allSpaces.firstIndex(where: { $0.id.id == id }),
                let indexInDetails = self.allDetails.firstIndex(where: { $0.id == id })
            {
                // If only one space is updated and it exists inside the current details, then just
                // update its contents and move it to the right place, instead of resetting all.
                self.allDetails.first(where: { $0.id == id })?.updateDetails()
                if indexInStore != indexInDetails {
                    let indices: IndexSet = [indexInDetails]
                    self.allDetails.move(fromOffsets: indices, toOffset: indexInStore)
                }
                return
            }

            DispatchQueue.main.async {
                self.allDetails = manager.getAll().map {
                    SpaceCardDetails(space: $0, manager: manager)
                }

                self.listenForShowingDetails()

                self.objectWillChange.send()
            }
        }
    }

    func onDataUpdated() {
        allDetails = manager.getAll().map {
            SpaceCardDetails(space: $0, manager: manager)
        }

        listenForShowingDetails()
    }

    func listenForShowingDetails() {
        allDetails.forEach { details in
            let detailID = details.id
            details.$showingDetails.sink { [weak self] showingDetails in
                guard let space = self?.allDetails.first(where: { $0.id == detailID }) else {
                    return
                }

                if showingDetails {
                    self?.detailedSpace = space
                } else if self?.detailedSpace == space {
                    self?.detailedSpace = nil
                }
            }.store(in: &detailsSubscriptions)
        }
    }

    func add(spaceID: String, url: String, title: String, description: String? = nil) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.addToSpaceWithURL(
                spaceID: spaceID, url: url, title: title, description: description)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String, thumbnail: String? = nil
    ) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.updateSpaceEntity(
                spaceID: spaceID, entityID: entityID, title: title, snippet: snippet,
                thumbnail: thumbnail)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func claimGeneratedItem(spaceID: String, entityID: String) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.claimGeneratedItem(
                spaceID: spaceID, entityID: entityID)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func delete(
        space spaceID: String, entities: [SpaceEntityThumbnail], from scene: UIScene,
        undoDeletion: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.deleteSpaceItems(
                spaceID: spaceID, ids: entities.map { $0.id })
            request?.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()

            ToastDefaults().showToastForRemoveFromSpace(
                bvc: SceneDelegate.getBVC(with: scene), request: request!
            ) {
                undoDeletion()

                // Undo deletion of Space item
                entities.forEach { entity in
                    self.add(
                        spaceID: spaceID, url: entity.data.url?.absoluteString ?? "",
                        title: entity.title, description: entity.description)
                }
            } retryDeletion: { [weak self] in
                guard let self = self else { return }
                self.delete(
                    space: spaceID, entities: entities, from: scene, undoDeletion: undoDeletion)
            }
        }
    }

    func reorder(space spaceID: String, entities: [String]) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.reorderSpace(spaceID: spaceID, ids: entities)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func changePublicACL(space: Space, add: Bool) {
        DispatchQueue.main.async {
            if add {
                let request = SpaceServiceProvider.shared.addPublicACL(spaceID: space.id.id)
                request?.$state.sink { state in
                    self.spaceNeedsRefresh = space.id.id
                    space.isPublic = true
                    self.objectWillChange.send()
                }.cancel()
            } else {
                let request = SpaceServiceProvider.shared.deletePublicACL(spaceID: space.id.id)
                request?.$state.sink { state in
                    self.spaceNeedsRefresh = space.id.id
                    space.isPublic = false
                    self.objectWillChange.send()
                }.cancel()
            }
        }
    }

    func addSoloACLs(space: Space, emails: [String], acl: SpaceACLLevel, note: String) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.addSoloACLs(
                spaceID: space.id.id, emails: emails, acl: acl, note: note)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = space.id.id
                space.isShared = true
                self.objectWillChange.send()
            }.cancel()
        }
    }

    func updateSpaceHeader(
        space: Space, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.updateSpace(
                spaceID: space.id.id, title: title,
                description: description, thumbnail: thumbnail)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = space.id.id
                space.name = title
                space.description = description
                space.thumbnail = thumbnail
                self.objectWillChange.send()
            }.cancel()
        }
    }

    func deleteGeneratorFromSpace(spaceID: String, generatorID: String) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.deleteGenerator(
                spaceID: spaceID, generatorID: generatorID)
            request?.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func removeSpace(spaceID: String, isOwner: Bool) {
        if isOwner {
            let request = SpaceServiceProvider.shared.deleteSpace(spaceID: spaceID)
            editingSubscription = request?.$state.sink { state in
                switch state {
                case .success:
                    self.editingSubscription?.cancel()
                    self.manager.refresh()
                case .failure:
                    self.editingSubscription?.cancel()
                case .initial:
                    Logger.browser.info("Waiting for success or failure")
                }
            }
        } else {
            let request = SpaceServiceProvider.shared.unfollowSpace(spaceID: spaceID)
            editingSubscription = request?.$state.sink { state in
                switch state {
                case .success:
                    self.editingSubscription?.cancel()
                    self.manager.refresh()
                case .failure:
                    self.editingSubscription?.cancel()
                case .initial:
                    Logger.browser.info("Waiting for success or failure")
                }
            }
        }
    }

    func promoCard() -> PromoCardType {
        return .blackFridayNotifyPromo(
            action: {
                ClientLogger.shared.logCounter(
                    .BlackFridayNotifyPromo)
                NotificationPermissionHelper.shared.requestPermissionIfNeeded(
                    callSite: .blackFriday
                ) { _ in
                    Defaults[.seenBlackFridayNotifyPromo] = true
                }
            },
            onClose: {
                ClientLogger.shared.logCounter(
                    .CloseBlackFridayNotifyPromo)
                Defaults[.seenBlackFridayNotifyPromo] = true
            })
    }

    func updateSpaceWithNoFollow(id: String, manager: SpaceStore) {
        manager.openSpaceWithNoFollow(spaceId: id) { [weak self] space in
            guard let self = self else { return }
            self.detailedSpace?.setSpace(space)
        }
    }
}

class SiteCardModel: CardModel {
    typealias Manager = SiteFetcher
    typealias Details = SiteCardDetails

    @Published var manager = SiteFetcher()
    @Published var allDetails: [SiteCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published var allDetailsWithExclusionList: [SiteCardDetails] = []
    var anyCancellable: AnyCancellable? = nil
    let tabManager: TabManager

    init(urls: [URL], tabManager: TabManager) {
        self.tabManager = tabManager

        self.allDetails = urls.reduce(into: []) {
            $0.append(SiteCardDetails(url: $1, fetcher: manager, tabManager: tabManager))
        }
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }

    func refresh(urls: [URL]) {
        self.allDetails = urls.reduce(into: []) {
            $0.append(SiteCardDetails(url: $1, fetcher: manager, tabManager: tabManager))
        }
    }

    func onDataUpdated() {}
}
