/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import CoreSpotlight
import Defaults
import Foundation
import SDWebImage
import Shared
import WebKit

private let log = Logger.browser

// A base protocol for something that can be cleared.
protocol Clearable {
    func clear() -> Success
}

// Clears our browsing history, including favicons, thumbnails, and spotlight indexed items.
class HistoryClearable: Clearable {
    let profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    func clear() -> Success {

        // Treat desktop sites as part of browsing history.
        Tab.ChangeUserAgent.clear()

        SceneDelegate.getAllBVCs().forEach { $0.tabManager.recentlyClosedTabs.removeAll() }

        return profile.history.clearHistory().bindQueue(.main) { success in
            SDImageCache.shared.clearDisk()
            SDImageCache.shared.clearMemory()
            UserActivityHandler.clearIndexedItems()
            NotificationCenter.default.post(name: .PrivateDataClearedHistory, object: nil)
            log.debug("HistoryClearable succeeded: \(success).")
            return Deferred(value: success)
        }
    }
}

// Clear the web cache. Note, this has to close all open tabs in order to ensure the data
// cached in them isn't flushed to disk.
class CacheClearable: Clearable {
    func clear() -> Success {
        let dataTypes = Set([
            WKWebsiteDataTypeFetchCache, WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeServiceWorkerRegistrations,
        ])
        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})

        MemoryReaderModeCache.sharedInstance.clear()
        DiskReaderModeCache.sharedInstance.clear()

        log.debug("CacheClearable succeeded.")
        return succeed()
    }
}

// Remove all cookies stored by the site. This includes localStorage, sessionStorage, and WebSQL/IndexedDB.
class CookiesClearable: Clearable {
    func clear() -> Success {
        let dataTypes = Set([
            WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeWebSQLDatabases,
            WKWebsiteDataTypeIndexedDBDatabases,
        ])
        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})

        log.debug("CookiesClearable succeeded.")
        return succeed()
    }
}

class TrackingProtectionClearable: Clearable {
    func clear() -> Success {
        let result = Success()
        ContentBlocker.shared.clearSafelist {
            result.fill(Maybe(success: ()))
        }
        return result
    }
}

class ConnectedDAppsClearable: Clearable {
    func clear() -> Success {
        for session in Defaults[.sessionsPeerIDs] {
            Defaults[.dAppsSession(session)] = nil
        }
        Defaults[.sessionsPeerIDs].removeAll()
        return succeed()
    }
}

class CookieCutterExclusionsClearable: Clearable {
    func clear() -> Success {
        // TODO: Actually clear this data
        let result = Success()
        return result
    }
}
