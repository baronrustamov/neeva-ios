// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared

class CardStripModel: ObservableObject {
    let incognitoModel: IncognitoModel
    let tabCardModel: TabCardModel
    let tabChromeModel: TabChromeModel

    @Published var shouldEmbedInScrollView = false

    var cells: [TabCell] {
        func filterHandledTabGroupsFromCells(cells: inout [TabCell]) {
            cells = cells.filter {
                if let id = $0.tabGroupId {
                    if handledTabGroups.contains(id) {
                        return false
                    }

                    handledTabGroups.append(id)
                }

                return true
            }
        }

        var handledTabGroups: [String] = []

        // Normal pinned tabs.
        let pinnedRows = tabCardModel.timeBasedNormalRows[.pinned] ?? []
        var pinnedCells: [TabCell] = Array(pinnedRows.map({ $0.cells }).joined())
        filterHandledTabGroupsFromCells(cells: &pinnedCells)
        // Use the binaryValue (0/1) instead of Bool for sorting.
        // Makes sure singular pinned tabs appear before those in a TabGroup.
        let pinnedCellsSorted = pinnedCells.sorted {
            $0.isTabGroup.asInt < $1.isTabGroup.asInt
        }

        // Normal tabs.
        let regularRows = tabCardModel.timeBasedNormalRows[.today] ?? []
        var regularCells: [TabCell] = Array(regularRows.map({ $0.cells }).joined())
        filterHandledTabGroupsFromCells(cells: &regularCells)

        // Incognito tabs.
        let incognitoRows = tabCardModel.incognitoRows
        var incognitoCells: [TabCell] = Array(incognitoRows.map({ $0.cells }).joined())
        filterHandledTabGroupsFromCells(cells: &incognitoCells)

        return incognitoModel.isIncognito ? incognitoCells : pinnedCellsSorted + regularCells
    }

    var todayTabsExists: Bool {
        tabCardModel.allDetails.filter { $0.tab.isIncluded(in: .today) }.count > 0
    }

    private var detailCount: Int {
        incognitoModel.isIncognito
            ? tabCardModel.incognitoDetails.count
            : tabCardModel.normalDetails.filter { $0.tab.isIncluded(in: [.pinned, .today]) }.count
    }

    var showCardStrip: Bool {
        tabChromeModel.inlineToolbar
            && !tabChromeModel.isEditingLocation
            && detailCount > 1
            && todayTabsExists
    }

    init(
        incognitoModel: IncognitoModel,
        tabCardModel: TabCardModel,
        tabChromeModel: TabChromeModel
    ) {
        self.incognitoModel = incognitoModel
        self.tabCardModel = tabCardModel
        self.tabChromeModel = tabChromeModel
    }
}
