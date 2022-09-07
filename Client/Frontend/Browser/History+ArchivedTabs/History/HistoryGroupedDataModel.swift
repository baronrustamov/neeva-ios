// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage
import SwiftUI

class HistoryGroupedDataModel: GroupedDataPanelModel {
    // MARK: - Properties
    typealias T = Site
    typealias Rows = EnumeratedSequence<[Site]>

    let tabManager: TabManager
    private let profile: Profile
    private let queryFetchLimit = 100
    private var currentFetchOffset = 0
    private var dataNeedsToBeReloaded = false

    @Published var isFetchInProgress = false
    @Published var groupedData = DateGroupedTableData<Site>()
    @Published var filteredGroupedData = DateGroupedTableData<Site>()

    // MARK: - Data
    private func reloadData() {
        groupedData = DateGroupedTableData<Site>()
        currentFetchOffset = 0

        loadData().uponQueue(.main) { [self] result in
            if dataNeedsToBeReloaded {
                dataNeedsToBeReloaded = false
                reloadData()
            }

            self.addSiteDataToGroupedSites(result)
        }
    }

    private func addSiteDataToGroupedSites(_ result: Maybe<Cursor<Site?>>) {
        if let sites = result.successValue {
            for site in sites {
                guard let site = site as? Site, let latestVisit = site.latestVisit else {
                    return
                }

                let date = Date(
                    timeIntervalSince1970: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
                self.groupedData.add(site, date: date)
            }
        }
    }

    func loadNextItemsIfNeeded(from index: Int) {
        guard index >= currentFetchOffset - 1, !isFetchInProgress else {
            return
        }

        loadData().uponQueue(.main) { result in
            self.addSiteDataToGroupedSites(result)
        }
    }

    private func searchForSites(with query: String) {
        loadData(filter: query).uponQueue(.main) { result in
            self.filteredGroupedData = DateGroupedTableData<Site>()

            if let sites = result.successValue {
                for site in sites {
                    guard let site = site as? Site, let latestVisit = site.latestVisit else {
                        return
                    }

                    let date = Date(
                        timeIntervalSince1970: TimeInterval.fromMicrosecondTimestamp(
                            latestVisit.date))
                    self.filteredGroupedData.add(site, date: date)
                }
            }
        }
    }

    func countOfPreviousSites(section: DateGroupedTableDataSection) -> Int {
        guard section.index > 0 else {
            return 0
        }

        let range = 0...(section.index - 1)
        let siteCounts = range.map {
            groupedData.numberOfItemsForSection(Int($0))
        }

        return siteCounts.reduce(0, +)
    }

    // MARK: - GroupedDataPanelModel Methods
    @discardableResult func loadData() -> Deferred<Maybe<Cursor<Site?>>> {
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

    @discardableResult func loadData(filter query: String) -> Deferred<Maybe<Cursor<Site?>>> {
        self.isFetchInProgress = true

        return profile.history.getSitesWithQuery(query: query) >>== { result in
            DispatchQueue.main.async {
                self.isFetchInProgress = false
            }

            return deferMaybe(result)
        }
    }

    func buildRows(with data: [Site], for section: DateGroupedTableDataSection) -> Rows {
        return data.enumerated()
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.tabManager = tabManager
        self.profile = tabManager.profile

        reloadData()
    }
}
