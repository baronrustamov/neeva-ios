// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage

enum HistoryClearableTimeFrame: String, CaseIterable {
    case lastHour = "Last Hour"
    case today = "Today"
    case todayAndYesterday = "Today & Yesterday"
    case all = "Everything"

    var hours: Int? {
        switch self {
        case .lastHour:
            return 1
        case .today:
            return 24
        case .todayAndYesterday:
            return 48
        default:
            return nil
        }
    }
}

enum HistoryPanelUX {
    static let IconSize: CGFloat = 23
}

class FetchInProgressError: MaybeErrorType {
    internal var description: String {
        return "Fetch is already in-progress"
    }
}

class HistoryPanelModel: ObservableObject {
    private let profile: Profile
    let tabManager: TabManager

    private let queryFetchLimit = 100
    private var currentFetchOffset = 0
    private var isFetchInProgress = false
    private var dataNeedsToBeReloaded = false

    @Published var groupedSites = DateGroupedTableData<Site>()

    var recentlyClosedTabs: [SavedTab] {
        Array(tabManager.recentlyClosedTabs.joined())
    }

    // MARK: - Data
    func reloadData() {
        groupedSites = DateGroupedTableData<Site>()
        currentFetchOffset = 0

        loadSiteData().uponQueue(.main) { [self] result in
            if dataNeedsToBeReloaded {
                dataNeedsToBeReloaded = false
                reloadData()
            }

            self.addSiteDataToGroupedSites(result)
        }
    }

    func loadSiteData() -> Deferred<Maybe<Cursor<Site?>>> {
        guard !isFetchInProgress, !profile.isShutdown else {
            dataNeedsToBeReloaded = true
            return deferMaybe(FetchInProgressError())
        }

        isFetchInProgress = true

        return profile.history.getSitesByLastVisit(
            limit: queryFetchLimit, offset: currentFetchOffset) >>== { result in
                // Force 100ms delay between resolution of the last batch of results
                // and the next time `fetchData()` can be called.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.currentFetchOffset += self.queryFetchLimit
                    self.isFetchInProgress = false
                }

                return deferMaybe(result)
            }
    }

    func addSiteDataToGroupedSites(_ result: Maybe<Cursor<Site?>>) {
        if let sites = result.successValue {
            for site in sites {
                guard let site = site as? Site, let latestVisit = site.latestVisit else {
                    return
                }

                self.groupedSites.add(
                    site, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
            }
        }
    }

    func loadNextItemsIfNeeded(from index: Int) {
        guard index >= currentFetchOffset - 1 else {
            return
        }

        loadSiteData().uponQueue(.main) { result in
            self.addSiteDataToGroupedSites(result)
        }
    }

    // MARK: - User Action
    // History Items
    func removeItemsFromHistory(timeFrame: HistoryClearableTimeFrame) {
        if let hours = timeFrame.hours {
            if let date = Calendar.current.date(byAdding: .hour, value: -hours, to: Date()) {
                let types = WKWebsiteDataStore.allWebsiteDataTypes()
                WKWebsiteDataStore.default().removeData(
                    ofTypes: types, modifiedSince: date, completionHandler: {})

                self.profile.history.removeHistoryFromDate(date).uponQueue(.main) { _ in
                    // we don't keep persistent identifiers to the activities so we can only delete all
                    UserActivityHandler.clearIndexedItems()
                    self.reloadData()
                }
            }
        } else {
            self.profile.history.clearHistory().uponQueue(.main) { _ in
                UserActivityHandler.clearIndexedItems()

                self.reloadData()
                self.tabManager.recentlyClosedTabs.removeAll()
            }
        }
    }

    func removeHistoryForURLAtIndexPath(site: Site) {
        profile.history.removeHistoryForURL(site.url).uponQueue(.main) { result in
            self.reloadData()
        }
    }

    // Recently Closed Tabs
    func restoreTab(at index: Int) {
        _ = tabManager.restoreSavedTabs([recentlyClosedTabs[index]])
    }

    func deleteRecentlyClosedTabs() {
        tabManager.recentlyClosedTabs.removeAll()
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.profile = tabManager.profile
        self.tabManager = tabManager
    }
}
