// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage

extension TabManager: TabEventHandler {
    func tab(_ tab: Tab, didLoadFavicon favicon: Favicon?, with: Data?) {
        // Write the tabs out again to make sure we preserve the favicon update.
        store.preserveTabs(
            tabs, existingSavedTabs: recentlyClosedTabsFlattened,
            selectedTab: selectedTab, for: scene)
    }

    func tabDidChangeContentBlocking(_ tab: Tab) {
        tab.removeContentScript(name: CookieCutterHelper.name())

        if FeatureFlag[.cookieCutter],
            let domain = tab.currentURL()?.host,
            !TrackingPreventionConfig.trackersAllowedFor(domain),
            let cookieCutterModel = cookieCutterModel
        {
            tab.addContentScript(
                CookieCutterHelper(cookieCutterModel: cookieCutterModel),
                name: CookieCutterHelper.name())
        }

        tab.reload()
    }
}
