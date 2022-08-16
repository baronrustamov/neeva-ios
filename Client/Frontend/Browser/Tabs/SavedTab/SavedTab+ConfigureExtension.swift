/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage

// This cannot be easily imported into extension targets, so we break it out here.
extension SavedTab {
    func configureTab(_ tab: Tab, imageStore: DiskImageStore? = nil) {
        if sessionData == nil {
            // If there's no session data, the tab was never loaded,
            // set the URL to be what the tab was opened too.
            tab.setURL(url)
        } else {
            // Since this is a restored tab, reset the URL to be,
            // loaded as that will be handled by the SessionRestoreHandler
            tab.setURL(nil)
        }

        if let faviconURL = faviconURL {
            let icon = Favicon(url: faviconURL, date: Date())
            icon.width = 1
            tab.favicon = icon
        }

        if let screenshotUUID = screenshotUUID,
            let imageStore = imageStore
        {
            tab.screenshotUUID = screenshotUUID
            imageStore.get(screenshotUUID.uuidString) { screenshot in
                if tab.screenshotUUID == screenshotUUID {
                    tab.setScreenshot(screenshot, revUUID: false)
                }
            }
        }

        tab.sessionData = sessionData
        // Use current URL as lastTitle when the tab loads a PDF, for example.
        tab.lastTitle =
            (title?.trim() ?? "").count > 0 ? title : sessionData?.currentUrl?.absoluteString
        tab.isPinned = isPinned
        tab.pinnedTime = pinnedTime
        tab.lastExecutedTime = lastExecutedTime ?? Date.nowMilliseconds()
        tab.parentUUID = parentUUID
        if let uuid = UUID {
            tab.tabUUID = uuid
        }
        tab.rootUUID = rootUUID ?? ""
        tab.parentSpaceID = parentSpaceID ?? ""
        tab.pageZoom = pageZoom ?? 1.0
        tab.url = url
        tab.title = title
    }
}
