// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage
import SwiftUI

class ArchivedTabsGroupedDataModel: GroupedDataPanelModel {
    typealias T = ArchivedTabRow
    typealias Rows = ([[ArchivedTab]], [String: ArchivedTabGroup])

    @Published var groupedData = DateGroupedTableData<T>()
    @Published var filteredGroupedData = DateGroupedTableData<T>()

    let tabCardModel: TabCardModel
    let tabManager: TabManager
    var numOfArchivedTabs: Int {
        return tabManager.archivedTabs.count
    }

    @discardableResult func loadData() -> Deferred<Maybe<Cursor<T?>>> {
        groupedData = DateGroupedTableData<T>()

        tabManager.archivedTabGroups.forEach {
            let tabGroup = $0.value
            // lastExecutedTime is in milliseconds, needs to be converted to seconds.
            let lastExecutedTimeSeconds = tabGroup.lastExecutedTime / 1000
            groupedData.add(
                .tabGroup(tabGroup),
                date: Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds)))
        }

        // Add the rest of the tabs as long as they weren't already added with a TabGroup.
        tabManager.archivedTabs.forEach {
            if tabManager.archivedTabGroups[$0.rootUUID] == nil {
                let lastExecutedTimeSeconds = $0.lastExecutedTime / 1000
                groupedData.add(
                    .tab($0),
                    date: Date(timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds)))
            }
        }

        return .init()
    }

    @discardableResult func loadData(filter query: String) -> Deferred<Maybe<Cursor<T?>>> {
        // TODO: (Evan) Load data from TabManager filtering by title/URL.
        // No current implementation but similar to FindInGrid.

        return .init()
    }

    func buildRows(
        with data: [ArchivedTabRow],
        for section: DateGroupedTableDataSection
    ) -> Rows {
        let tabsPerRow = tabCardModel.columnCount

        // TODO: (Evan) Rename ArchivedTabRow since it's very confusing now.
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

    init(tabCardModel: TabCardModel, tabManager: TabManager) {
        self.tabCardModel = tabCardModel
        self.tabManager = tabManager

        loadData()
    }
}
