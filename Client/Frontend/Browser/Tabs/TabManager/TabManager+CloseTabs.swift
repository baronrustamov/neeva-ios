// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCGLogger

private let log = Logger.browser

extension TabManager {
    func removeTab(_ tab: Tab, showToast: Bool = false, updateSelectedTab: Bool = true) {
        // The index of the removed tab w.r.s to the normalTabs/incognitoTabs is
        // calculated in advance, and later used for finding rightOrLeftTab. In time-based
        // switcher, the normalTabs get filtered to make sure we only select tab in
        // today section.
        guard
            let index = tab.isIncognito
                ? incognitoTabs.firstIndex(where: { $0 == tab })
                : (FeatureFlag[.enableTimeBasedSwitcher]
                    ? normalTabs.filter {
                        $0.wasLastExecuted(.today)
                    }.firstIndex(where: { $0 == tab })
                    : normalTabs.firstIndex(where: { $0 == tab }))
        else { return }
        addTabsToRecentlyClosed([tab], showToast: showToast)
        removeTab(tab, flushToDisk: true, notify: true)

        if let selectedTab = selectedTab, selectedTab.isIncognito == tab.isIncognito,
            updateSelectedTab
        {
            updateSelectedTabAfterRemovalOf(tab, deletedIndex: index, notify: true)
        }
    }

    func removeTabs(
        _ tabsToBeRemoved: [Tab], showToast: Bool = true,
        updateSelectedTab: Bool = true, dontAddToRecentlyClosed: Bool = false, notify: Bool = true
    ) {
        guard tabsToBeRemoved.count > 0 else {
            return
        }

        if !dontAddToRecentlyClosed {
            addTabsToRecentlyClosed(tabsToBeRemoved, showToast: showToast)
        }

        let previous = selectedTab

        let lastTab = tabsToBeRemoved[tabsToBeRemoved.count - 1]
        let lastTabIndex = tabs.firstIndex(of: lastTab)
        let tabsToKeep = self.tabs.filter { !tabsToBeRemoved.contains($0) }
        self.tabs = tabsToKeep
        if let lastTabIndex = lastTabIndex, updateSelectedTab {
            updateSelectedTabAfterRemovalOf(lastTab, deletedIndex: lastTabIndex, notify: false)
        }

        tabsToBeRemoved.forEach { tab in
            tab.close()
            TabEvent.post(.didClose, for: tab)
        }

        if notify {
            updateTabGroupsAndSendNotifications(notify: true)
            sendSelectTabNotifications(previous: previous)
        } else {
            updateTabGroupsAndSendNotifications(notify: false)
        }

        storeChanges()
    }

    /// Removes the tab from TabManager, alerts delegates, and stores data.
    /// - Parameter notify: if set to true, will call the delegate after the tab
    ///   is removed.
    private func removeTab(_ tab: Tab, flushToDisk: Bool, notify: Bool) {
        guard let removalIndex = tabs.firstIndex(where: { $0 === tab }) else {
            log.error("Could not find index of tab to remove, tab count: \(count)")
            return
        }

        tabs.remove(at: removalIndex)
        tab.close()

        if tab.isIncognito && incognitoTabs.count < 1 {
            incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
        }

        if notify {
            TabEvent.post(.didClose, for: tab)
            updateTabGroupsAndSendNotifications(notify: notify)
        }

        if flushToDisk {
            storeChanges()
        }
    }

    private func updateSelectedTabAfterRemovalOf(_ tab: Tab, deletedIndex: Int, notify: Bool) {
        let closedLastNormalTab = !tab.isIncognito && normalTabs.isEmpty
        let closedLastIncognitoTab = tab.isIncognito && incognitoTabs.isEmpty
        // In time-based switcher, the normalTabs gets filtered to make sure we only
        // select tab in today section.
        let viableTabs: [Tab] =
            tab.isIncognito
            ? incognitoTabs
            : (FeatureFlag[.enableTimeBasedSwitcher]
                ? normalTabs.filter {
                    $0.wasLastExecuted(.today)
                } : normalTabs)
        let bvc = SceneDelegate.getBVC(with: scene)

        if closedLastNormalTab || closedLastIncognitoTab
            || (FeatureFlag[.enableTimeBasedSwitcher]
                ? !viableTabs.contains(where: { $0.wasLastExecuted(.today) }) : false)
        {
            DispatchQueue.main.async {
                self.selectTab(nil, notify: notify)
                bvc.showTabTray()
            }
        } else if let selectedTab = selectedTab, !viableTabs.contains(selectedTab) {
            if !selectParentTab(afterRemoving: selectedTab) {
                if let rightOrLeftTab = viableTabs[safe: deletedIndex]
                    ?? viableTabs[safe: deletedIndex - 1]
                {
                    selectTab(rightOrLeftTab, previous: selectedTab, notify: notify)
                } else {
                    selectTab(
                        mostRecentTab(inTabs: viableTabs) ?? viableTabs.last, previous: selectedTab,
                        notify: notify)
                }
            }
        }

    }

    // MARK: - Remove All Tabs
    func removeAllTabs() {
        removeTabs(tabs, showToast: false)
    }

    func removeAllIncognitoTabs() {
        removeTabs(incognitoTabs, updateSelectedTab: true)
        incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
    }

    // MARK: - Recently Closed Tabs
    func getRecentlyClosedTabForURL(_ url: URL) -> SavedTab? {
        assert(Thread.isMainThread)
        return recentlyClosedTabs.joined().filter({ $0.url == url }).first
    }

    func addTabsToRecentlyClosed(_ tabs: [Tab], showToast: Bool) {
        // Avoid remembering incognito tabs.
        let tabs = tabs.filter { !$0.isIncognito }
        if tabs.isEmpty {
            return
        }

        let savedTabs = tabs.map {
            SavedTab(
                tab: $0, isSelected: selectedTab === $0, tabIndex: self.tabs.firstIndex(of: $0))
        }
        recentlyClosedTabs.insert(savedTabs, at: 0)

        if showToast {
            closedTabsToShowToastFor.append(contentsOf: savedTabs)

            timerToTabsToast?.invalidate()
            timerToTabsToast = Timer.scheduledTimer(
                withTimeInterval: toastGroupTimerInterval, repeats: false,
                block: { _ in
                    ToastDefaults().showToastForClosedTabs(
                        self.closedTabsToShowToastFor, tabManager: self)
                    self.closedTabsToShowToastFor.removeAll()
                })
        }
    }

    // MARK: - Zombie Tabs
    /// Turns all but the newest x Tabs into Zombie Tabs.
    func makeTabsIntoZombies(tabsToKeepAlive: Int = 10) {
        // Filter tabs for each Scene
        let tabs = tabs.sorted {
            $0.lastExecutedTime ?? Timestamp() > $1.lastExecutedTime ?? Timestamp()
        }

        tabs.enumerated().forEach { index, tab in
            if tab != selectedTab, index >= tabsToKeepAlive {
                tab.close()
            }
        }
    }
}
