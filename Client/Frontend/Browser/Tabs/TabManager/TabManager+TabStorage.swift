// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import Storage
import XCGLogger

private let log = Logger.browser

extension TabManager {
    func preserveTabs() {
        store.preserveTabs(
            tabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)
    }

    func storeChanges() {
        saveTabs(toProfile: profile, normalTabs)
        store.preserveTabs(
            tabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)
    }

    private func hasTabsToRestoreAtStartup() -> Bool {
        return store.getStartupTabs(for: scene).count > 0
    }

    private func saveTabs(toProfile profile: Profile, _ tabs: [Tab]) {
        // It is possible that not all tabs have loaded yet, so we filter out tabs with a nil URL.
        let storedTabs: [RemoteTab] = tabs.compactMap(Tab.toRemoteTab)

        // Don't insert into the DB immediately. We tend to contend with more important
        // work like querying for top sites.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            profile.storeTabs(storedTabs)
        }
    }

    /// - Returns: Returns a bool of whether a tab was selected.
    func restoreTabs(_ forced: Bool = false) -> Bool {
        log.info("Restoring tabs")

        guard forced || count == 0, !AppConstants.IsRunningTest, hasTabsToRestoreAtStartup()
        else {
            log.info("Skipping tab restore")
            tabsUpdatedPublisher.send()
            return false
        }

        let tabToSelect = store.restoreStartupTabs(
            for: scene, clearIncognitoTabs: Defaults[.closeIncognitoTabs], tabManager: self)

        if var tabToSelect = tabToSelect {
            if Defaults[.lastSessionPrivate], !tabToSelect.isIncognito {
                tabToSelect = addTab(isIncognito: true, notify: false)
            }

            selectTab(tabToSelect, notify: true)
        }

        updateAllTabDataAndSendNotifications(notify: true)

        return tabToSelect != nil
    }
}
