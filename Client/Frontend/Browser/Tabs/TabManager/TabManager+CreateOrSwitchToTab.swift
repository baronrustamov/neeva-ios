// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage

extension TabManager {
    enum CreateOrSwitchToTabResult {
        case createdNewTab
        case switchedToExistingTab
    }

    @discardableResult func createOrSwitchToTab(
        for url: URL,
        query: String? = nil, suggestedQuery: String? = nil,
        visitType: VisitType? = nil
    )
        -> CreateOrSwitchToTabResult
    {
        if let tab = selectedTab {
            ScreenshotHelper(controller: SceneDelegate.getBVC(with: scene)).takeScreenshot(tab)
        }

        if let existingTab = getTabFor(url) {
            selectTab(existingTab, notify: true)
            existingTab.browserViewController?
                .postLocationChangeNotificationForTab(existingTab, visitType: visitType)
            return .switchedToExistingTab
        } else {
            let newTab = addTab(
                URLRequest(url: url),
                flushToDisk: true,
                zombie: false,
                isIncognito: isIncognito,
                query: query,
                suggestedQuery: suggestedQuery,
                visitType: visitType
            )

            selectTab(newTab, notify: true)

            return .createdNewTab
        }
    }

    @discardableResult func createOrSwitchToTabForSpace(for url: URL, spaceID: String)
        -> CreateOrSwitchToTabResult
    {
        if let tab = selectedTab {
            ScreenshotHelper(controller: SceneDelegate.getBVC(with: scene)).takeScreenshot(tab)
        }

        if let existingTab = getTabFor(url) {
            existingTab.parentSpaceID = spaceID
            existingTab.rootUUID = spaceID
            selectTab(existingTab, notify: true)
            return .switchedToExistingTab
        } else {
            let newTab = addTab(
                URLRequest(url: url), flushToDisk: true, zombie: false, isIncognito: isIncognito)
            newTab.parentSpaceID = spaceID
            newTab.rootUUID = spaceID
            selectTab(newTab, notify: true)
            updateAllTabDataAndSendNotifications(notify: true)
            return .createdNewTab
        }
    }
}
