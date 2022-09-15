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

class TabCardModel: CardDropDelegate, CardModel {
    private var subscription: Set<AnyCancellable> = Set()

    private(set) var manager: TabManager
    private(set) var normalRows: [Row] = []
    private(set) var timeBasedNormalRows: [TabSection: [Row]] = [:]
    private(set) var incognitoRows: [Row] = []
    private(set) var timeBasedIncognitoRows: [TabSection: [Row]] = [:]
    private(set) var allDetails: [TabCardDetails] = []
    private(set) var allDetailsWithExclusionList: [TabCardDetails] = []  // Unused
    var columnCount: Int = 2 {
        didSet {
            updateRows()
        }
    }

    // Tab Group related members
    private(set) var representativeTabs: [Tab] = []
    private(set) var allTabGroupDetails: [TabGroupCardDetails] = []
    private(set) var tabsDidChange = false

    @Default(.tabGroupExpanded) private var tabGroupExpanded: Set<String>
    var needsUpdateRows: Bool = false

    // Find Tab
    @Published var isSearchingForTabs: Bool = false {
        didSet {
            // Reset the filter whenever the state changes.
            tabSearchFilter = ""
        }
    }
    @Published var tabSearchFilter = "" {
        didSet {
            if oldValue != tabSearchFilter {
                updateIfNeeded(forceUpdateRows: true)
            }
        }
    }
    @Published var rowsUpdated = 0

    struct Row: Identifiable {
        enum Cell: Identifiable {
            case tab(TabCardDetails)
            case tabGroupInline(TabGroupCardDetails)
            case tabGroupGridRow(TabGroupCardDetails, Range<Int>)
            case sectionHeader(TabSection)

            static let pinnedRowHeaderID: String = "pinned-header"
            static let todayRowHeaderID: String = "today-header"
            static let yesterdayRowHeaderID: String = "yesterday-header"
            static let lastweekRowHeaderID: String = "lastWeek-header"
            static let lastMonthRowHeaderID: String = "lastMonth-header"
            static let olderRowHeaderID: String = "older-header"

            var id: String {
                switch self {
                case .tab(let details):
                    return details.id
                case .tabGroupInline(let details):
                    return details.id
                case .tabGroupGridRow(let details, let range):
                    return details.allDetails[range].reduce("") { $0 + $1.id + ":" }
                case .sectionHeader(let section):
                    switch section {
                    case .all:
                        // No id for all.
                        return ""
                    case .pinned:
                        return Self.pinnedRowHeaderID
                    case .today:
                        return Self.todayRowHeaderID
                    case .yesterday:
                        return Self.yesterdayRowHeaderID
                    case .lastWeek:
                        return Self.lastweekRowHeaderID
                    case .lastMonth:
                        return Self.lastMonthRowHeaderID
                    case .overAMonth:
                        return Self.olderRowHeaderID
                    }
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
                case .sectionHeader:
                    return false
                }
            }

            var numTabs: Int {
                switch self {
                case .tab:
                    return 1
                case .tabGroupInline(let details):
                    return details.allDetails.count
                case .tabGroupGridRow(_, let range):
                    return range.count
                case .sectionHeader:
                    return 0
                }
            }

            var isTabGroup: Bool {
                switch self {
                case .tabGroupInline, .tabGroupGridRow:
                    return true
                default:
                    return false
                }
            }

            var tabGroupId: String? {
                switch self {
                case .tabGroupInline(let groupDetails):
                    return groupDetails.id
                case .tabGroupGridRow(let groupDetails, _):
                    return groupDetails.id
                default:
                    return nil
                }
            }
        }

        var id: Set<String> { Set(cells.map(\.id)) }
        var cells: [Cell]
        var index: Int
        var multipleCellTypes: Bool = false

        var numTabsInRow: Int {
            cells.reduce(
                0,
                { total, cell in
                    total + cell.numTabs
                })
        }
    }

    // MARK: Update Rows
    func updateIfNeeded(forceUpdateRows: Bool = false) {
        if needsUpdateRows || forceUpdateRows {
            updateRows()
        }
    }

    private func updateRows() {
        needsUpdateRows = false

        timeBasedNormalRows[.all] = buildRows(for: .all, incognito: false)
        timeBasedNormalRows[.pinned] = buildRows(for: .pinned, incognito: false)
        timeBasedNormalRows[.today] = buildRows(for: .today, incognito: false)
        timeBasedNormalRows[.yesterday] = buildRows(for: .yesterday, incognito: false)
        timeBasedNormalRows[.lastWeek] = buildRows(for: .lastWeek, incognito: false)

        if Defaults[.archivedTabsDuration] == .month {
            timeBasedNormalRows[.lastMonth] = buildRows(for: .lastMonth, incognito: false)
        } else if Defaults[.archivedTabsDuration] == .forever {
            timeBasedNormalRows[.lastMonth] = buildRows(for: .lastMonth, incognito: false)
            timeBasedNormalRows[.overAMonth] = buildRows(for: .overAMonth, incognito: false)
        }

        // TODO: in the future, we might apply time-based treatments to incognito mode.
        incognitoRows = buildRows(for: .all, incognito: true)

        // Defer signaling until after we have finished updating. This way our state is
        // completely consistent with TabManager prior to accessing allDetails, etc.
        self.rowsUpdated += 1
    }

    // MARK: Get Rows
    func getRows(for section: TabSection, incognito: Bool) -> [Row] {
        if incognito {
            return incognitoRows
        }

        return timeBasedNormalRows[section, default: []]
    }

    func getRowSectionsNeeded(incognito: Bool) -> [TabSection] {
        if incognito {
            return [.all]
        }

        var sections: [TabSection] = [.pinned, .today, .yesterday, .lastWeek]

        if Defaults[.archivedTabsDuration] == .month {
            sections.append(.lastMonth)
        }

        if Defaults[.archivedTabsDuration] == .forever {
            sections.append(.lastMonth)
            sections.append(.overAMonth)
        }

        // Prevents sections with no cards (only headers) from being shown.
        return sections.filter { (timeBasedNormalRows[$0]?.count ?? 0) > 1 }
    }

    // MARK: Build Rows
    private func buildRows(for section: TabSection, incognito: Bool) -> [Row] {
        func numberOfCellsInRow(row: Row) -> Int {
            row.cells.map { $0.numTabs }.reduce(0, +)
        }

        func addItemToRowOrCreateNewRowIfNeeded(rows: inout [Row], item: TabCell) {
            let lastRowIndex = rows.count - 1

            if numberOfCellsInRow(row: rows[lastRowIndex]) < columnCount {
                rows[lastRowIndex].cells.append(item)
            } else {
                rows.append(Row(cells: [item], index: rows.count))
            }
        }

        func willTabGroupFitInRow(tabGroup: TabGroupCardDetails) -> Bool {
            numberOfCellsInRow(row: rows[rows.count - 1]) + tabGroup.allDetails.count <= columnCount
        }

        func fillEmptySpotsInLastRow() {
            for key in singleTabs.keys {
                if numberOfCellsInRow(row: rows[rows.count - 1]) == columnCount {
                    return
                }

                addItemToRowOrCreateNewRowIfNeeded(rows: &rows, item: .tab(singleTabs[key]!))
                singleTabs.removeValue(forKey: key)
            }

            if numberOfCellsInRow(row: rows[rows.count - 1]) < columnCount {
                // If there weren't enough tabs to fill the row,
                // make sure the next tabs start on a new line.
                rows.append(Row(cells: [], index: rows.count))
            }
        }

        let addSectionHeader = !incognito && section != .all
        var rows: [Row] = [Row(cells: [], index: addSectionHeader ? 1 : 0)]
        var singleTabs: [String: TabCardDetails] = [:]

        if addSectionHeader {
            rows.insert(Row(cells: [.sectionHeader(section)], index: 0), at: 0)
        }

        let filteredDetails = allDetails.filter { detail in
            if !detail.isIncluded(in: section) || !tabIncludedInSearch(detail)
                || detail.isIncognito != incognito
            {
                return false
            }

            // Check if the tab is the "representative" or first tab in the TabGroup.
            // Makes sure the group is only added once, and that the group is included in the section.
            if let tabGroupDetails = allTabGroupDetails.first(where: { $0.id == detail.rootID }) {
                return detail == tabGroupDetails.allDetails.first
            } else {
                singleTabs[detail.id] = detail
            }

            return true
        }

        if filteredDetails.count == 0 {
            // If there aren't any tabs to create rows with, return early.
            return []
        }

        filteredDetails.forEach { detail in
            let rootID = detail.rootID
            if let tabGroupDetails = allTabGroupDetails.first(where: { $0.id == rootID }) {
                let isExpanded = Defaults[.tabGroupExpanded].contains(rootID)

                // If the tab group was expanded, or if it the tabs will fit in a row, expanded it.
                if isExpanded || tabGroupDetails.allDetails.count <= columnCount {
                    if !willTabGroupFitInRow(tabGroup: tabGroupDetails) {
                        fillEmptySpotsInLastRow()
                    }

                    var rowsAdded = 0

                    for index in stride(
                        from: 0, to: tabGroupDetails.allDetails.count, by: columnCount)
                    {
                        var max = index + columnCount
                        if max > tabGroupDetails.allDetails.count {
                            max = tabGroupDetails.allDetails.count
                        }

                        let range = index..<max
                        addItemToRowOrCreateNewRowIfNeeded(
                            rows: &rows, item: .tabGroupGridRow(tabGroupDetails, range))

                        rowsAdded += 1
                    }

                    if rowsAdded > 1 {
                        // Add other tabs to a new row so the don't appear in the last row of the `ExpandedCardGroupView`.
                        rows.append(Row(cells: [], index: rows.count))
                    }
                } else {
                    if columnCount - rows[rows.count - 1].cells.count <= 1 {
                        fillEmptySpotsInLastRow()
                    }

                    addItemToRowOrCreateNewRowIfNeeded(
                        rows: &rows, item: .tabGroupInline(tabGroupDetails))
                }
            } else if singleTabs[detail.id] != nil {  // Make sure tab hasn't already been used.
                singleTabs.removeValue(forKey: detail.id)
                addItemToRowOrCreateNewRowIfNeeded(rows: &rows, item: .tab(detail))
            }
        }

        return rows
    }

    func buildRowsForTesting() -> [Row] {
        timeBasedNormalRows[.pinned] = buildRows(for: .pinned, incognito: false)
        timeBasedNormalRows[.today] = buildRows(for: .today, incognito: false)
        timeBasedNormalRows[.yesterday] = buildRows(for: .yesterday, incognito: false)
        timeBasedNormalRows[.lastWeek] = buildRows(for: .lastWeek, incognito: false)

        return getRows(for: .all, incognito: false)
    }

    // MARK: Details
    var normalDetails: [TabCardDetails] {
        allDetails.filter {
            !$0.tab.isIncognito
        }
    }

    var incognitoDetails: [TabCardDetails] {
        allDetails.filter {
            $0.tab.isIncognito
        }
    }

    func tabIncludedInSearch(_ details: TabCardDetails) -> Bool {
        let tabSeachFilter = tabSearchFilter.lowercased()
        return
            (details.title.lowercased().contains(tabSeachFilter)
            || (details.url?.absoluteString.lowercased().contains(tabSeachFilter) ?? false)
            || tabSeachFilter.isEmpty)
    }

    func onDataUpdated() {
        allDetails = manager.activeTabs.map { TabCardDetails(tab: $0, manager: manager) }

        allTabGroupDetails =
            manager.activeTabGroups.map { _, group in
                TabGroupCardDetails(tabGroup: group, tabManager: manager)
            }

        // When the number of tabs in a tab group decreases and makes the group
        // unable to expand, we remove the group from the expanded list. A side-effect
        // of this resolves a problem where TabGroupHeader doesn't hide arrows button
        // when the number of tabs drops below columnCount.
        Defaults[.tabGroupExpanded].forEach { groupID in
            if let tabGroup = allTabGroupDetails.first(where: { groupID == $0.id }),
                tabGroup.allDetails.count <= columnCount
            {
                Defaults[.tabGroupExpanded].remove(groupID)
            }
        }

        updateRows()
    }

    override func dropEntered(info: DropInfo) {
        guard let draggingDetail = TabCardDetails.draggingDetail else {
            return
        }

        // If a Tab is dragged onto the base grid, reset it's rootUUID to remove it from a TabGroup.
        draggingDetail.tab.rootUUID = UUID().uuidString
        super.dropEntered(info: info)
    }

    // MARK: init
    init(manager: TabManager) {
        self.manager = manager
        super.init(tabManager: manager)

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

        manager.selectedTabPublisher.sink { [weak self] tab in
            guard let self = self, let _ = tab else {
                return
            }
            self.needsUpdateRows = true
        }.store(in: &subscription)

        _tabGroupExpanded.publisher.sink { [weak self] _ in
            self?.updateRows()
        }.store(in: &subscription)

        manager.updateArchivedTabsPublisher.sink { [weak self] _ in
            self?.onDataUpdated()
        }.store(in: &subscription)
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
            if let detailedSpace = detailedSpace {
                ClientLogger.shared.logCounter(
                    .SpacesDetailUIVisited,
                    attributes:
                        getLogCounterAttributesForSpaces(details: detailedSpace))

                // Collect separately. View definition depends on aggregate stats policy
                ClientLogger.shared.logCounter(
                    .space_app_view,
                    attributes:
                        getLogCounterAttributesForSpaces(details: detailedSpace))

                if let scene = scene, let id = detailedSpace.item?.id.id {
                    SceneDelegate.getCurrentSceneDelegate(with: scene)?.setSceneUIState(
                        to: .spaceDetailView(id))
                }
            } else if let id = spaceNeedsRefresh {
                manager.refreshSpace(spaceID: id, anonymous: false)
                spaceNeedsRefresh = nil

            }
        }
    }
    @Published var updatedItemIDs = [String]()
    var viewModel: SpaceCardViewModel = SpaceCardViewModel()

    var thumbnailURLCandidates = [URL: [URL]]()
    private var anyCancellable: AnyCancellable?
    private var recommendationSubscription: AnyCancellable?
    private var editingSubscription: AnyCancellable?
    private var detailsSubscriptions: Set<AnyCancellable> = Set()
    private var mutationSubscriptions: Set<AnyCancellable> = Set()
    private var spaceNeedsRefresh: String?
    private var scene: UIScene?

    init(manager: SpaceStore = SpaceStore.shared, scene: UIScene?) {
        self.manager = manager
        self.scene = scene
        manager.spotlightEventDelegate = SpotlightLogger.shared

        NeevaUserInfo.shared.$isUserLoggedIn.sink { isLoggedIn in
            self.manager = isLoggedIn ? .shared : .suggested
            self.listenManagerState()
            self.listenSpaceMutations()
            DispatchQueue.main.async {
                self.manager.refresh()
            }
        }.store(in: &detailsSubscriptions)
        viewModel.subscribe(to: $allDetails)
        listenManagerState()
        listenSpaceMutations()
    }

    private func listenManagerState() {
        self.anyCancellable = manager.$state.sink { [weak self] state in
            guard let self = self, case .ready = state,
                self.manager.updatedSpacesFromLastRefresh.count > 0
            else { return }

            if self.manager.updatedSpacesFromLastRefresh.count == 1,
                let id = self.manager.updatedSpacesFromLastRefresh.first?.id.id,
                self.allDetails.contains(where: { $0.id == id })
            {
                // If only one space is updated and it exists inside the current details, then just
                // update its contents and move it to the right place, instead of resetting all.
                self.viewModel.updateSpace(with: id)
                return
            }

            DispatchQueue.main.async {
                self.allDetails = self.manager.getAll().map {
                    SpaceCardDetails(
                        space: $0,
                        manager: self.manager,
                        showingDetails: self.detailedSpace?.item?.id.id == $0.id.id)
                }

                self.listenForShowingDetails()

                self.objectWillChange.send()
            }
        }
    }

    func listenForShowingDetails() {
        allDetails.forEach { details in
            self.subscribeToShowingDetails(for: details)
        }
    }

    private func subscribeToShowingDetails(for details: SpaceCardDetails) {
        details.$showingDetails.sink { [weak self] showingDetails in
            guard let space = self?.allDetails.first(where: { $0.id == details.id }) else {
                return
            }

            if showingDetails {
                self?.detailedSpace = space
            } else if self?.detailedSpace == space {
                self?.detailedSpace = nil
            }
        }.store(in: &detailsSubscriptions)
    }

    private func listenSpaceMutations() {
        manager.spaceLocalMutation.sink { [weak self] space in
            guard let self = self else { return }
            if let space = space {
                let details = SpaceCardDetails(space: space, manager: self.manager)
                self.allDetails.append(details)
                self.subscribeToShowingDetails(for: details)
            }
        }.store(in: &mutationSubscriptions)

    }

    func onDataUpdated() {
        allDetails = manager.getAll().map {
            SpaceCardDetails(space: $0, manager: manager)
        }

        listenForShowingDetails()
    }

    func add(
        spaceID: String, url: String, title: String, description: String? = nil
    ) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.addToSpaceWithURL(
                spaceID: spaceID, url: url, title: title, description: description)

            request?.$state.sink { state in
                if case .success = state {
                    SpaceStore.shared.refreshSpace(spaceID: spaceID, anonymous: false)
                }
            }.store(in: &self.mutationSubscriptions)
        }
    }

    func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String, thumbnail: String? = nil
    ) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.updateSpaceEntity(
                spaceID: spaceID, entityID: entityID, title: title, snippet: snippet,
                thumbnail: thumbnail)
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = spaceID
                }
            }.store(in: &self.mutationSubscriptions)
        }
    }

    func claimGeneratedItem(spaceID: String, entityID: String) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.claimGeneratedItem(
                spaceID: spaceID, entityID: entityID)
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = spaceID
                }
            }.store(in: &self.mutationSubscriptions)
        }
    }

    func delete(
        space spaceID: String, entities: [SpaceEntityData], from scene: UIScene,
        undoDeletion: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.deleteSpaceItems(
                spaceID: spaceID, ids: entities.map { $0.id })
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = spaceID
                }
            }.store(in: &self.mutationSubscriptions)

            ToastDefaults().showToastForRemoveFromSpace(
                bvc: SceneDelegate.getBVC(with: scene), request: request!
            ) {
                undoDeletion()

                // Undo deletion of Space item
                entities.forEach { entity in
                    self.add(
                        spaceID: spaceID, url: entity.url?.absoluteString ?? "",
                        title: entity.title ?? "", description: entity.pageMetadata?.description)
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
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = spaceID
                }
            }.store(in: &self.mutationSubscriptions)
        }
    }

    func changePublicACL(space: Space, add: Bool) {
        DispatchQueue.main.async {
            if add {
                let request = SpaceServiceProvider.shared.addPublicACL(spaceID: space.id.id)
                request?.$state.sink { [weak self] state in
                    if case .success = state {
                        self?.spaceNeedsRefresh = space.id.id
                        space.isPublic = true
                        self?.objectWillChange.send()
                    }
                }.store(in: &self.mutationSubscriptions)
            } else {
                let request = SpaceServiceProvider.shared.deletePublicACL(spaceID: space.id.id)
                request?.$state.sink { [weak self] state in
                    if case .success = state {
                        self?.spaceNeedsRefresh = space.id.id
                        space.isPublic = false
                        self?.objectWillChange.send()
                    }
                }.store(in: &self.mutationSubscriptions)
            }
        }
    }

    func addSoloACLs(space: Space, emails: [String], acl: SpaceACLLevel, note: String) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.addSoloACLs(
                spaceID: space.id.id, emails: emails, acl: acl, note: note)
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = space.id.id
                    space.isShared = true
                    self?.objectWillChange.send()
                }
            }.store(in: &self.mutationSubscriptions)
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
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = space.id.id
                    space.name = title
                    space.description = description
                    space.thumbnail = thumbnail
                    self?.objectWillChange.send()
                }
            }.store(in: &self.mutationSubscriptions)
        }
    }

    func deleteGeneratorFromSpace(spaceID: String, generatorID: String) {
        DispatchQueue.main.async {
            let request = SpaceServiceProvider.shared.deleteGenerator(
                spaceID: spaceID, generatorID: generatorID)
            request?.$state.sink { [weak self] state in
                if case .success = state {
                    self?.spaceNeedsRefresh = spaceID
                }
            }.store(in: &self.mutationSubscriptions)
        }
    }

    func removeSpace(spaceID: String, isOwner: Bool) {
        if isOwner {
            let request = SpaceServiceProvider.shared.deleteSpace(spaceID: spaceID)
            editingSubscription = request?.$state.sink { state in
                switch state {
                case .success:
                    self.editingSubscription?.cancel()
                    self.manager.deleteSpace(with: spaceID)
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
                    self.manager.deleteSpace(with: spaceID)
                case .failure:
                    self.editingSubscription?.cancel()
                case .initial:
                    Logger.browser.info("Waiting for success or failure")
                }
            }
        }
    }

}

class SpaceCardViewModel: ObservableObject {
    @Published var dataSource: [SpaceCardDetails] = []
    @Published var filterState: SpaceFilterState = .allSpaces
    @Published var sortType: SpaceSortType = .updatedDate
    @Published var sortOrder: SpaceSortOrder = .descending
    @Published private var sorted: [SpaceCardDetails] = []

    private var sortSubscription: AnyCancellable?
    private var filterSubscription: AnyCancellable?

    func subscribe(to allDetails: Published<[SpaceCardDetails]>.Publisher) {
        sortSubscription =
            allDetails
            .combineLatest($sortType, $sortOrder)
            .sink { [weak self] (arr, sort, order) in
                guard let self = self else { return }
                self.sorted =
                    arr.filter {
                        NeevaFeatureFlags[.enableSpaceDigestCard]
                            || $0.id != SpaceStore.dailyDigestID
                    }
                    .sortSpaces(by: sort, order: order)
            }
        filterSubscription =
            $sorted
            .combineLatest($filterState)
            .sink(receiveValue: {
                (arr, filter) in
                self.dataSource = arr.filterSpaces(by: filter)
            })
    }

    func updateSpace(with id: String) {
        guard let index = dataSource.firstIndex(where: { $0.id == id }) else {
            return
        }
        dataSource[index].updateSpace()
        if let toIndex = dataSource[index].findIndex(
            in: dataSource,
            sortType: sortType,
            sortOrder: sortOrder)
        {
            if toIndex != index {
                let space = dataSource.remove(at: index)
                dataSource.insert(space, at: toIndex)
            }
        }
    }
}
