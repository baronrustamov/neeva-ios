// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared

enum ArchivedTabTimeSection: String, CaseIterable {
    case lastMonth = "Last Month"
    case overAMonth = "Older"
}

struct ArchivedTabsData {
    var sites: [ArchivedTabTimeSection: [Tab]] = [:]

    func itemsForSection(section: ArchivedTabTimeSection) -> [Tab] {
        return sites[section] ?? []
    }
}

class ArchivedTabsPanelModel: ObservableObject {
    let tabManager: TabManager
    var archivedTabs: [Tab]
    var archivedTabGroups: [String: TabGroup]
    var groupedSites = ArchivedTabsData()
    var numOfArchivedTabs: Int {
        return archivedTabs.count
    }
    private var updateArchivedTabsSubscription: AnyCancellable?

    func loadData() {
        archivedTabs = tabManager.archivedTabs
        archivedTabGroups = tabManager.archivedTabGroups

        groupedSites.sites[.lastMonth] = archivedTabs.filter {
            return $0.isIncluded(in: .lastMonth)
        }

        groupedSites.sites[.overAMonth] = archivedTabs.filter {
            return $0.isIncluded(in: .overAMonth)
        }
    }

    func clearArchivedTabs() {
        tabManager.removeTabs(
            tabManager.archivedTabs, updateSelectedTab: false,
            dontAddToRecentlyClosed: true, notify: false)
        loadData()
        self.objectWillChange.send()
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
        self.archivedTabs = tabManager.archivedTabs
        self.archivedTabGroups = tabManager.archivedTabGroups

        updateArchivedTabsSubscription = tabManager.updateArchivedTabsPublisher.sink {
            [weak self] _ in
            self?.loadData()
            self?.objectWillChange.send()
        }
    }
}
