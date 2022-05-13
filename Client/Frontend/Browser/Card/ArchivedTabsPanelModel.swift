// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

enum ArchivedTabTimeSection: String, CaseIterable {
    case lastMonth = "Last Month"
    case overAMonth = "More"
}

public struct ArchivedTabsData {
    var sites: [ArchivedTabTimeSection: [Tab]] = [:]

    func itemsForSection(section: ArchivedTabTimeSection) -> [Tab] {
        return sites[section] ?? []
    }
}

class ArchivedTabsPanelModel: ObservableObject {
    let tabManager: TabManager
    var groupedSites = ArchivedTabsData()

    func loadData() {
        groupedSites.sites[.lastMonth] = tabManager.archivedTabs.filter {
            return $0.wasLastExecuted(.lastMonth)
        }

        groupedSites.sites[.overAMonth] = tabManager.archivedTabs.filter {
            return $0.wasLastExecuted(.overAMonth)
        }
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
