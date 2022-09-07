// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared

enum ArchivedTabRow: Equatable {
    case tab(ArchivedTab)
    case tabGroup(ArchivedTabGroup)

    var lastExcecutedTime: Timestamp {
        switch self {
        case .tab(let tab):
            return tab.lastExecutedTime
        case .tabGroup(let group):
            return group.lastExecutedTime
        }
    }

    var id: String {
        switch self {
        case .tab(let tab):
            return tab.id
        case .tabGroup(let group):
            return group.id
        }
    }

    var isTabGroup: Bool {
        switch self {
        case .tab(let archivedTab):
            return false
        case .tabGroup(let archivedTabGroup):
            return true
        }
    }

    static func == (lhs: ArchivedTabRow, rhs: ArchivedTabRow) -> Bool {
        switch (lhs, rhs) {
        case (.tab(let tabLhs), .tab(let tabRhs)):
            return tabLhs.id == tabRhs.id
        case (.tabGroup(let groupLhs), .tabGroup(let groupRhs)):
            return groupLhs.id == groupRhs.id
        default:
            return false
        }
    }
}

class ArchivedTabsPanelModel: ObservableObject {
    let tabManager: TabManager
    var groupedRows = DateGroupedTableData<ArchivedTabRow>()
    var numOfArchivedTabs: Int {
        return tabManager.archivedTabs.count
    }

    private var updateArchivedTabsSubscription: AnyCancellable?

    func loadData() {
        groupedRows = DateGroupedTableData<ArchivedTabRow>()

        // Once all the tab groups are added, no need to also add duplicate tabs.
        // This prevents any tab with a RootID already added from being inserted into the rows again.
        var handledRootIDs: [String] = []

        tabManager.archivedTabGroups.forEach {
            handledRootIDs.append($0.key)

            let tabGroup = $0.value
            // lastExecutedTime is in milliseconds, needs to be converted to seconds.
            let lastExecutedTimeSeconds = tabGroup.lastExecutedTime / 1000
            groupedRows.add(
                .tabGroup(tabGroup),
                date: Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds)))
        }

        // Add the rest of the tabs as long as they weren't already added with a TabGroup.
        tabManager.archivedTabs.forEach {
            if !handledRootIDs.contains($0.rootUUID) {
                let lastExecutedTimeSeconds = $0.lastExecutedTime / 1000
                groupedRows.add(
                    .tab($0),
                    date: Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds)))
            }
        }

        self.objectWillChange.send()
    }

    func clearArchivedTabs() {
        tabManager.remove(archivedTabs: tabManager.archivedTabs)
        loadData()
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager

        updateArchivedTabsSubscription = tabManager.updateArchivedTabsPublisher.sink {
            [weak self] _ in
            self?.loadData()
        }
    }
}
