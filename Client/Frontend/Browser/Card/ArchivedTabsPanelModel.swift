// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

enum ArchivedTabTimeSection: Int, CaseIterable {
    case lastMonth
    case older

    var title: String? {
        switch self {
        case .lastMonth:
            return "Last Month"
        case .older:
            return "Older"
        }
    }
}

public struct ArchivedTabsData {
    var lastMonth: [Tab] = []
    var older: [Tab] = []
}

class ArchivedTabsPanelModel: ObservableObject {
    let tabManager: TabManager
    var groupedSites = ArchivedTabsData()

    func loadData() {
        //        groupedSites.lastMonth = tabManager.tabs.filter {
        //
        //        }
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
