// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import Storage
import SwiftUI

class ArchivedTabsGroupedDataModel: GroupedDataPanelModel {
    typealias T = ArchivedTabRow
    typealias Rows = ([[ArchivedTab]], [String: ArchivedTabGroup])
    let emptyDataText: LocalizedStringKey = "Your Archived Tabs will appear here"

    @Published var groupedData = DateGroupedTableData<T>()

    let tabCardModel: TabCardModel
    let tabManager: TabManager
    var numOfArchivedTabs: Int {
        return tabManager.archivedTabs.count
    }

    // MARK: - GroupedDataPanelModel Methods
    @discardableResult func loadData(filter query: String? = nil) -> Deferred<Maybe<Cursor<T?>>> {
        groupedData = DateGroupedTableData<T>()

        tabManager.archivedTabGroups.forEach {
            let tabGroup = $0.value
            let name = Defaults[.tabGroupNames][$0.key]

            if let query = query, !query.isEmpty, let name = name?.lowercased(),
                !name.contains(query.lowercased())
            {
                return
            }

            // lastExecutedTime is in milliseconds, needs to be converted to seconds.
            let lastExecutedTimeSeconds = tabGroup.lastExecutedTime / 1000
            groupedData.add(
                .tabGroup(tabGroup),
                date: Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds)))
        }

        // Add the rest of the tabs as long as they weren't already added with a TabGroup.
        tabManager.archivedTabs.forEach {
            if let query = query, !query.isEmpty,
                !$0.displayTitle.lowercased().contains(query.lowercased())
            {
                return
            }

            if tabManager.archivedTabGroups[$0.rootUUID] == nil {
                let lastExecutedTimeSeconds = $0.lastExecutedTime / 1000
                groupedData.add(
                    .tab($0),
                    date: Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds)))
            }
        }

        return .init()
    }

    func buildRows(
        with data: [ArchivedTabRow],
        for section: DateGroupedTableDataSection
    ) -> Rows {
        let tabsPerRow = tabCardModel.columnCount

        func addItemToRowOrCreateNewRowIfNeeded(rows: inout [[ArchivedTab]], item: ArchivedTab) {
            let lastRowIndex = rows.count - 1

            if rows[lastRowIndex].count < tabsPerRow {
                rows[lastRowIndex].append(item)
            } else {
                rows.append([item])
            }
        }

        // Create rows filled with the same number of columns as CardGrid.
        var rows: [[ArchivedTab]] = [[]]
        var tabGroups: [String: ArchivedTabGroup] = [:]

        data.forEach {
            switch $0 {
            case .tab(let tab):
                addItemToRowOrCreateNewRowIfNeeded(rows: &rows, item: tab)
            case .tabGroup(let tabGroup):
                rows.append([])

                tabGroup.children.forEach { tab in
                    addItemToRowOrCreateNewRowIfNeeded(rows: &rows, item: tab)
                }

                rows.append([])
                tabGroups[tabGroup.id] = tabGroup
            }
        }

        return (rows, tabGroups)
    }

    // MARK: - Archived Tab Methods
    func removeArchivedTabs(_ tabs: [ArchivedTab]) {
        tabManager.remove(archivedTabs: tabs)
        loadData()
    }

    func removeArchivedTabGroup(_ group: ArchivedTabGroup) {
        tabManager.remove(archivedTabGroup: group)
        loadData()
    }

    func clearArchivedTabs() {
        tabManager.remove(archivedTabs: tabManager.archivedTabs)
        loadData()

        ClientLogger.shared.logCounter(
            .clearArchivedTabs,
            attributes: EnvironmentHelper.shared.getAttributes())
    }

    // MARK: - init
    init(tabCardModel: TabCardModel) {
        self.tabCardModel = tabCardModel
        self.tabManager = tabCardModel.manager

        loadData()
    }
}
