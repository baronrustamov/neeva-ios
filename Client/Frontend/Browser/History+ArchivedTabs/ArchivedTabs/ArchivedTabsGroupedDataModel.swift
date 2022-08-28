// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

class ArchivedTabsGroupedDataModel: GroupedDataPanelModel {
    typealias T = ArchivedTab

    let tabManager: TabManager
    @Published var groupedData = DateGroupedTableData<ArchivedTab>()
    @Published var filteredGroupedData = DateGroupedTableData<ArchivedTab>()

    func loadData() {
        // TODO: (Evan) Load data from TabManager.
        // See `ArchivedTabsPanelModel.loadData()`.
    }

    func loadData(filter query: String) {
        // TODO: (Evan) Load data from TabManager filtering by title/URL.
        // No current implementation but similar to FindInGrid.
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
