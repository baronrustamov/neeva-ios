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
    var representativeTabsInAMonth: [Tab] = []
    var representativeTabsOverAMonth: [Tab] = []
    var tabsWithExclusionList: [Tab] = []
    var allTabsFiltered: [Tab] = []
    var groupedSites = ArchivedTabsData()

    func getRepresentativeTabs(section: ArchivedTabTimeSection) -> [Tab] {
        switch section {
        case .lastMonth:
            return representativeTabsInAMonth
        case .overAMonth:
            return representativeTabsOverAMonth
        }
    }

    func loadData() {
        groupedSites.sites[.lastMonth] = tabManager.tabs.filter {
            return (representativeTabsInAMonth.contains($0) || tabsWithExclusionList.contains($0))
                && !$0.isIncognito && $0.wasLastExecuted(.lastMonth)
        }

        groupedSites.sites[.overAMonth] = tabManager.tabs.filter {
            return (representativeTabsOverAMonth.contains($0) || tabsWithExclusionList.contains($0))
                && !$0.isIncognito && $0.wasLastExecuted(.overAMonth)
        }
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager

        representativeTabsInAMonth = self.tabManager.getAllTabGroup()
            .reduce(into: [Tab]()) {
                if let tab = tabManager.getChildLastUsedInAMonth($1) {
                    $0.append(tab)
                }
            }
        representativeTabsOverAMonth = self.tabManager.getAllTabGroup()
            .reduce(into: [Tab]()) {
                if let tab = tabManager.getChildLastUsedOverAMonth($1) {
                    $0.append(tab)
                }
            }
        tabsWithExclusionList = self.tabManager.getAll().filter {
            !self.tabManager.childTabs.contains($0)
        }
    }
}
