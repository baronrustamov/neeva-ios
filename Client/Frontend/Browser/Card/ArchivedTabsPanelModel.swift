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
    var allTabsFiltered: [Tab] = []
    var groupedSites = ArchivedTabsData()

    func loadData() {
        groupedSites.sites[.lastMonth] = allTabsFiltered.filter {
            $0.wasLastExecuted(.lastMonth)
        }                

        groupedSites.sites[.overAMonth] = allTabsFiltered.filter {
            $0.wasLastExecuted(.overAMonth)
        }
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
        
        let representativeTabs = self.tabManager.getAllTabGroup()
            .reduce(into: [Tab]()) { $0.append($1.children.first!) }
        let tabsWithExclusionList = self.tabManager.getAll().filter {
            !self.tabManager.childTabs.contains($0)
        }

        allTabsFiltered = tabManager.tabs.filter { tab in
            return (representativeTabs.contains(tab)
                    || tabsWithExclusionList.contains{$0.id == tab.id}) && !tab.isIncognito
        }

    }
}
