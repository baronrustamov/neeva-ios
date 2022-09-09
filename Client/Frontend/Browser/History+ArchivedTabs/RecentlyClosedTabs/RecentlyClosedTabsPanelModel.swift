// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class RecentlyClosedTabsPanelModel {
    let tabManager: TabManager

    var recentlyClosedTabs: [SavedTab] {
        Array(tabManager.recentlyClosedTabs.joined())
    }

    func restoreTab(at index: Int) {
        tabManager.restoreSavedTabs([recentlyClosedTabs[index]])
    }

    func deleteRecentlyClosedTabs() {
        tabManager.recentlyClosedTabs.removeAll()
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
