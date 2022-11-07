/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage

/*
 * A class that adheres to all the requirements for a profile's history property
 * with all of the methods set to fatalError. Use this class if you're looking to
 * mock out parts of the history API
 */
class MockableHistory: BrowserHistory, AccountRemovalDelegate, ResettableSyncStorage {
    func getFrecentHistory() -> FrecentHistory { fatalError() }
    func getTopSitesWithLimit(_ limit: Int) -> Deferred<Maybe<Cursor<Site?>>> { fatalError() }
    func addLocalVisit(_ visit: SiteVisit) -> Success { fatalError() }
    func clearHistory() -> Success { fatalError() }
    func removeHistoryFromDate(_ date: Date) -> Success { fatalError() }
    func removeHistoryForURL(_ url: URL) -> Success { fatalError() }
    func removeSiteFromTopSites(_ site: Site) -> Success { fatalError() }
    func removeHostFromTopSites(_ host: String) -> Success { fatalError() }
    func clearTopSitesCache() -> Success { fatalError() }
    func getSitesByLastVisit(limit: Int, offset: Int) -> Deferred<Maybe<Cursor<Site?>>> {
        fatalError()
    }
    func getSitesWithQuery(query: String) -> Deferred<Maybe<Cursor<Site?>>> {
        fatalError()
    }
    func setTopSitesNeedsInvalidation() { fatalError() }
    func updateTopSitesCacheIfInvalidated() -> Deferred<Maybe<Bool>> { fatalError() }
    func setTopSitesCacheSize(_ size: Int32) { fatalError() }
    func onRemovedAccount() -> Success { fatalError() }
    func resetClient() -> Success { fatalError() }
}
