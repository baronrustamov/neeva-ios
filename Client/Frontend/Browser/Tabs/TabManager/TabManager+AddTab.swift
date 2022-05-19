// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import WebKit

extension TabManager {
    @discardableResult func addTabsForURLs(
        _ urls: [URL], zombie: Bool = true, shouldSelectTab: Bool = true, incognito: Bool = false,
        rootUUID: String? = nil
    ) -> [Tab] {
        assert(Thread.isMainThread)

        if urls.isEmpty {
            return []
        }

        var newTabs: [Tab] = []
        for url in urls {
            newTabs.append(
                self.addTab(
                    URLRequest(url: url), flushToDisk: false, zombie: zombie,
                    isIncognito: incognito, notify: false))
        }

        if let rootUUID = rootUUID {
            for tab in newTabs {
                tab.rootUUID = rootUUID
            }

            self.updateTabGroupsAndSendNotifications(notify: false)
        }

        // Select the most recent.
        if shouldSelectTab {
            selectTab(newTabs.last, notify: true)
        }

        // Okay now notify that we bulk-loaded so we can adjust counts and animate changes.
        tabsUpdatedPublisher.send()

        // Flush.
        storeChanges()

        return newTabs
    }

    @discardableResult func addTab(
        _ request: URLRequest! = nil, configuration: WKWebViewConfiguration! = nil,
        afterTab: Tab? = nil, isIncognito: Bool = false,
        query: String? = nil, suggestedQuery: String? = nil,
        visitType: VisitType? = nil, notify: Bool = true
    ) -> Tab {
        return self.addTab(
            request, configuration: configuration, afterTab: afterTab, flushToDisk: true,
            zombie: false, isIncognito: isIncognito,
            query: query, suggestedQuery: suggestedQuery,
            visitType: visitType, notify: notify
        )
    }

    func addTab(
        _ request: URLRequest? = nil, webView: WKWebView? = nil,
        configuration: WKWebViewConfiguration? = nil, atIndex: Int? = nil, afterTab: Tab? = nil,
        flushToDisk: Bool, zombie: Bool, isIncognito: Bool = false,
        query: String? = nil, suggestedQuery: String? = nil,
        visitType: VisitType? = nil, notify: Bool = true
    ) -> Tab {
        assert(Thread.isMainThread)

        // Take the given configuration. Or if it was nil, take our default configuration for the current browsing mode.
        let configuration: WKWebViewConfiguration =
            configuration ?? (isIncognito ? incognitoConfiguration : self.configuration)

        let bvc = SceneDelegate.getBVC(with: scene)
        let tab = Tab(bvc: bvc, configuration: configuration, isIncognito: isIncognito)
        configureTab(
            tab, request: request, webView: webView, atIndex: atIndex, afterTab: afterTab,
            flushToDisk: flushToDisk, zombie: zombie,
            query: query, suggestedQuery: suggestedQuery,
            visitType: visitType,
            notify: notify)

        return tab
    }

    func configureTab(
        _ tab: Tab, request: URLRequest?, webView: WKWebView? = nil, atIndex: Int? = nil,
        afterTab parent: Tab? = nil, flushToDisk: Bool, zombie: Bool, isPopup: Bool = false,
        query: String? = nil, suggestedQuery: String? = nil,
        queryLocation: QueryForNavigation.Query.Location = .suggestion,
        visitType: VisitType? = nil, notify: Bool
    ) {
        assert(Thread.isMainThread)

        // If network is not available webView(_:didCommit:) is not going to be called
        // We should set request url in order to show url in url bar even no network
        tab.setURL(request?.url)

        insertTab(tab, atIndex: atIndex, parent: parent, notify: notify)

        if let webView = webView {
            tab.restore(webView)
        } else if !zombie {
            tab.createWebview()
        }

        tab.navigationDelegate = self.navDelegate

        if let query = query {
            tab.queryForNavigation.currentQuery = .init(
                typed: query,
                suggested: suggestedQuery,
                location: queryLocation
            )
        }

        if let request = request {
            if let nav = tab.loadRequest(request), let visitType = visitType {
                tab.browserViewController?.recordNavigationInTab(
                    tab, navigation: nav, visitType: visitType
                )
            }
        } else if !isPopup {
            let url = InternalURL.baseUrl / "about" / "home"
            tab.loadRequest(PrivilegedRequest(url: url) as URLRequest)
            tab.setURL(url)
        }

        if flushToDisk {
            storeChanges()
        }
    }

    private func insertTab(_ tab: Tab, atIndex: Int? = nil, parent: Tab? = nil, notify: Bool) {
        if let atIndex = atIndex, atIndex <= tabs.count {
            tabs.insert(tab, at: atIndex)
        } else if parent == nil || parent?.isIncognito != tab.isIncognito {
            var insertIndex: Int? = nil

            for possibleChildTab in isIncognito ? incognitoTabs : normalTabs {
                if addTabToTabGroupIfNeeded(newTab: tab, possibleChildTab: possibleChildTab) {
                    guard let childTabIndex = tabs.firstIndex(of: possibleChildTab) else {
                        continue
                    }

                    // Insert the tab where the child tab is so it appears
                    // before it in the Tab Group.
                    insertIndex = childTabIndex

                    break
                }
            }

            if let insertIndex = insertIndex {
                tabs.insert(tab, at: insertIndex)
            } else {
                tabs.append(tab)
            }
        } else if let parent = parent, var insertIndex = tabs.firstIndex(of: parent) {
            insertIndex += 1
            while insertIndex < tabs.count && tabs[insertIndex].isDescendentOf(parent) {
                insertIndex += 1
            }

            tab.parent = parent
            tab.parentUUID = parent.tabUUID
            tab.rootUUID = parent.rootUUID
            tabs.insert(tab, at: insertIndex)
        }

        if notify {
            updateTabGroupsAndSendNotifications(notify: notify)
        }
    }

    // MARK: - Tab Groups
    /// Checks if the new tab URL matches the origin URL for the tab and if so,
    /// then the two tabs should be in a Tab Group together.
    @discardableResult func addTabToTabGroupIfNeeded(
        newTab: Tab, possibleChildTab: Tab
    ) -> Bool {
        guard
            let childTabInitialURL = possibleChildTab.initialURL,
            let newTabURL = newTab.url
        else {
            return false
        }

        let options: [URL.EqualsOption] = [
            .normalizeHost, .ignoreFragment, .ignoreLastSlash, .ignoreScheme,
        ]
        let shouldCreateTabGroup = childTabInitialURL.equals(newTabURL, with: options)

        /// TODO: To make this more effecient, we should refactor `TabGroupManager`
        /// to be apart of `TabManager`. That we can quickly check if the ChildTab is in a Tab Group.
        /// See #3088 + #3098 for more info.
        let childTabIsInTabGroup: Bool = {
            let tabs = tabs.filter { $0 != possibleChildTab }
            for tab in tabs where tab.rootUUID == possibleChildTab.rootUUID {
                return true
            }

            return false
        }()

        if shouldCreateTabGroup {
            if !childTabIsInTabGroup {
                // Create a Tab Group by setting the child tab's rootID.
                possibleChildTab.rootUUID = newTab.rootUUID
            } else {
                // Set the new tab's root ID the same as the current tab,
                // since they should both be in the same Tab Group.
                newTab.rootUUID = possibleChildTab.rootUUID
            }
        }

        return shouldCreateTabGroup
    }

    // MARK: - Restore Tabs
    func restoreSavedTabs(
        _ savedTabs: [SavedTab], isIncognito: Bool = false, shouldSelectTab: Bool = true
    ) -> Tab? {
        // makes sure at least one tab is selected
        // if no tab selected, select the last one (most recently closed)
        var selectedSavedTab: Tab?

        for index in 0..<savedTabs.count {
            let savedTab = savedTabs[index]
            let urlRequest: URLRequest? = savedTab.url != nil ? URLRequest(url: savedTab.url!) : nil

            var tab: Tab!
            if let tabIndex = savedTab.tabIndex {
                tab = addTab(
                    urlRequest, atIndex: tabIndex, flushToDisk: false, zombie: true,
                    isIncognito: isIncognito, notify: false)
            } else {
                tab = addTab(
                    urlRequest, afterTab: getTabForUUID(uuid: savedTab.parentUUID ?? ""),
                    flushToDisk: false, zombie: true, isIncognito: isIncognito, notify: false)
            }

            savedTab.configureTab(tab, imageStore: store.imageStore)

            if savedTab.isSelected {
                selectedSavedTab = tab
            } else if index == savedTabs.count - 1 && selectedSavedTab == nil {
                selectedSavedTab = tab
            }
        }

        updateTabGroupsAndSendNotifications(notify: true)

        // Prevents a sticky tab tray
        SceneDelegate.getBVC(with: scene).browserModel.cardTransitionModel.update(to: .hidden)

        if let selectedSavedTab = selectedSavedTab, shouldSelectTab, selectedTab == nil {
            self.selectTab(selectedSavedTab, notify: true)
        }

        // remove restored tabs from recently closed
        if let index = recentlyClosedTabs.firstIndex(of: savedTabs) {
            recentlyClosedTabs.remove(at: index)
        }

        closedTabsToShowToastFor.removeAll { savedTabs.contains($0) }

        return selectedSavedTab
    }

    func restoreAllClosedTabs() {
        _ = restoreSavedTabs(Array(recentlyClosedTabs.joined()))
    }
}
