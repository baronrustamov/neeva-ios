// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage

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
    private var dataNeedsToBeReloaded = false

    @Published var groupedSites = DateGroupedTableData<Site>()
    @Published var isFetchInProgress = false

    // History search
    @Published var filteredSites = DateGroupedTableData<Site>()

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

    func addSiteDataToGroupedSites(_ result: Maybe<Cursor<Site?>>) {
        if let sites = result.successValue {
            for site in sites {
                guard let site = site as? Site, let latestVisit = site.latestVisit else {
                    return
                }

                let date = Date(
                    timeIntervalSince1970: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
                self.groupedSites.add(site, date: date)
            }
        }
    }

    func loadNextItemsIfNeeded(from index: Int) {
        guard index >= currentFetchOffset - 1, !isFetchInProgress else {
            return
        }

        loadSiteData().uponQueue(.main) { result in
            self.addSiteDataToGroupedSites(result)
        }
    }

    func searchForSites(with query: String) {
        loadSiteData(with: query).uponQueue(.main) { result in
            self.filteredSites = DateGroupedTableData<Site>()

            if let sites = result.successValue {
                for site in sites {
                    guard let site = site as? Site, let latestVisit = site.latestVisit else {
                        return
                    }

                    let date = Date(
                        timeIntervalSince1970: TimeInterval.fromMicrosecondTimestamp(
                            latestVisit.date))
                    self.filteredSites.add(site, date: date)
                }
            }
        }
    }

    // Retrieving
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

    func loadSiteData(with query: String) -> Deferred<Maybe<Cursor<Site?>>> {
        self.isFetchInProgress = true

        return profile.history.getSitesWithQuery(query: query) >>== { result in
            DispatchQueue.main.async {
                self.isFetchInProgress = false
            }

            return deferMaybe(result)
        }
    }

    // MARK: - User Action
    // History Items
    func removeItemFromHistory(site: Site) {
        profile.history.removeHistoryForURL(site.url).uponQueue(.main) { _ in
            self.groupedSites.remove(site)
        }
    }
   
    // MARK: - init
    init(tabManager: TabManager) {
        self.profile = tabManager.profile
        self.tabManager = tabManager
    }
}
