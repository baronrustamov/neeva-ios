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
        // Normal pinned tabs.
        let pinnedRows = tabCardModel.timeBasedNormalRows[.pinned] ?? []
        let pinnedCells: [TabCell] = Array(pinnedRows.map({ $0.cells }).joined())
        // Use the binaryValue (0/1) instead of Bool for sorting.
        // Makes sure singular pinned tabs appear before those in a TabGroup.
        let pinnedCellsSorted = pinnedCells.sorted {
            $0.isTabGroup.asInt < $1.isTabGroup.asInt
        }

        // Normal tabs.
        let regularRows = tabCardModel.timeBasedNormalRows[.today] ?? []
        let regularCells: [TabCell] = Array(regularRows.map({ $0.cells }).joined())

        // Incognito tabs.
        let incognitoRows = tabCardModel.incognitoRows
        let incognitoCells: [TabCell] = Array(incognitoRows.map({ $0.cells }).joined())

        return incognitoModel.isIncognito ? incognitoCells : pinnedCellsSorted + regularCells
    }

    var todayTabsExists: Bool {
        tabCardModel.allDetails.filter { $0.tab.isIncluded(in: .today) }.count > 0
    }

    private var detailCount: Int {
        incognitoModel.isIncognito
            ? tabCardModel.incognitoDetails.count
            : tabCardModel.allDetails.filter { $0.tab.isIncluded(in: [.pinned, .today]) }.count
    }

    var showCardStrip: Bool {
        return tabChromeModel.inlineToolbar
            && !tabChromeModel.isEditingLocation
            && detailCount > 1
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
