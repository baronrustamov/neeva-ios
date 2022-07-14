// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCGLogger

private let log = Logger.browser

extension TabManager {
    func removeTab(_ tab: Tab?, showToast: Bool = false, updateSelectedTab: Bool = true) {
        guard let tab = tab else {
            return
        }

        // The index of the removed tab w.r.s to the normalTabs/incognitoTabs is
        // calculated in advance, and later used for finding rightOrLeftTab. In time-based
        // switcher, the normalTabs get filtered to make sure we only select tab in
        // today section.
        let normalTabsToday = normalTabs.filter {
            $0.wasLastExecuted(.today)
        }

        let index =
            tab.isIncognito
            ? incognitoTabs.firstIndex(where: { $0 == tab })
            : normalTabsToday.firstIndex(where: { $0 == tab })

        addTabsToRecentlyClosed([tab], showToast: showToast)
        removeTab(tab, flushToDisk: true, notify: true)

        if (selectedTab?.isIncognito ?? false) == tab.isIncognito, updateSelectedTab {
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
            removeTab(tab, flushToDisk: false, notify: false)
        }

        if notify {
            updateAllTabDataAndSendNotifications(notify: true)
            sendSelectTabNotifications(previous: previous)
        } else {
            updateAllTabDataAndSendNotifications(notify: false)
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
        tab.closeWebView()

        if tab.isIncognito && incognitoTabs.count < 1 {
            incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
        }

        if notify {
            TabEvent.post(.didClose, for: tab)
            updateAllTabDataAndSendNotifications(notify: notify)
        }

        if flushToDisk {
            storeChanges()
        }
    }

    private func updateSelectedTabAfterRemovalOf(
        _ tab: Tab, deletedIndex: Int?, notify: Bool
    ) {
        let closedLastNormalTab = !tab.isIncognito && normalTabs.isEmpty
        let closedLastIncognitoTab = tab.isIncognito && incognitoTabs.isEmpty
        // In time-based switcher, the normalTabs gets filtered to make sure we only
        // select tab in today section.
        let viableTabs: [Tab] =
            tab.isIncognito
            ? incognitoTabs
            : normalTabs.filter {
                $0.wasLastExecuted(.today)
            }
        let bvc = SceneDelegate.getBVC(with: scene)

        if let selectedTab = selectedTab, viableTabs.contains(selectedTab) {
            // The selectedTab still exists, no need to find another tab to select.
            return
        }

        if closedLastNormalTab || closedLastIncognitoTab
            || !viableTabs.contains(where: { $0.wasLastExecuted(.today) })
        {
            DispatchQueue.main.async {
                self.selectTab(nil, notify: notify)
                bvc.showTabTray()
            }
        } else if let selectedTab = selectedTab, let deletedIndex = deletedIndex {
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
        } else {
            selectTab(nil, notify: false)
            SceneDelegate.getBVC(with: scene).browserModel.showGridWithNoAnimation()
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
            $0.saveSessionDataAndCreateSavedTab(
                isSelected: selectedTab === $0, tabIndex: self.tabs.firstIndex(of: $0))
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
        // Filter down the `tabs` array to just those with WKWebViews in order
        // to optimize subsequent loops.
        let tabsWithWebViews = tabs.filter { $0.webView != nil }
            .sorted {
                // `selectedTab` always comes first.
                if $0 == selectedTab || $1 == selectedTab { return $0 == selectedTab }
                return $0.lastExecutedTime ?? 0 > $1.lastExecutedTime ?? 0
            }

        // Prevent an exception if `tabsToKeepAlive` > `tabsWithWebViews.count`.
        let tabsWithWebViewsCap = min(tabsToKeepAlive, tabsWithWebViews.count)
        // Close all Tabs that exceed the cap.
        for index in tabsWithWebViewsCap..<tabsWithWebViews.count {
            tabsWithWebViews[index].closeWebView()
        }
    }

    /// Used when the user logs out. Clears any Neeva tabs so they are logged out there too.
    func clearNeevaTabs() {
        let neevaTabs = tabs.filter { $0.url?.isNeevaURL() ?? false }
        neevaTabs.forEach { tab in
            if tab == selectedTab {
                tab.reload()
            } else {
                tab.closeWebView()
            }

            // Clear the tab's screenshot by setting it to nil.
            // Will be erased from memory when `storeChanges` is called.
            tab.setScreenshot(nil)
        }
    }

    // MARK: - Blank Tabs
    /// Removes any tabs with the location `about:blank`. Seen when clicking web links that open native apps.
    func removeBlankTabs() {
        removeTabs(tabs.filter { $0.url == URL.aboutBlank }, showToast: false)
    }
}
