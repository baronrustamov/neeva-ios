// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage

class HistoryGroupedDataModel: GroupedDataPanelModel {
    typealias T = Site

    let tabManager: TabManager
    @Published var groupedData = DateGroupedTableData<Site>()
    @Published var filteredGroupedData = DateGroupedTableData<Site>()

    func loadData() {
        // TODO: (Evan) Load data from profile.
        // See `HistoryPanelModel.loadData()`.
    }

    func loadData(filter query: String) {
        // TODO: (Evan) Load data from profile, only matching query.
        // See `HistoryPanelModel.loadData(with query: String)`.
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
