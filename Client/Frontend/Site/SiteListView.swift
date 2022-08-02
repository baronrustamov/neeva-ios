// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

enum SiteListData {
    case sites([Site], DateGroupedTableDataSection)
    case savedTabs([SavedTab])
}

struct SiteListView: View {
    let tabManager: TabManager
    var historyPanelModel: HistoryPanelModel? = nil

    var data: SiteListData
    var itemAtIndexAppeared: (Int) -> Void = { _ in }
    var tappedItemAtIndex: (Int) -> Void = { _ in }
    var deleteSite: (Site) -> Void = { _ in }

    var body: some View {
        GroupedCell.Decoration {
            LazyVStack(spacing: 0) {
                switch data {
                case .sites(let sites, let section):
                    ForEach(
                        Array(sites.enumerated()), id: \.element
                    ) { index, site in
                        SiteRowView(
                            tabManager: tabManager, data: .site(site, deleteSite)
                        ) {
                            tappedItemAtIndex(index + countOfPreviousSites(section: section))
                        }.onAppear {
                            itemAtIndexAppeared(index + countOfPreviousSites(section: section))
                        }

                        Color.groupedBackground.frame(height: 1)
                    }
                case .savedTabs(let savedTabs):
                    ForEach(
                        Array(savedTabs.enumerated()), id: \.element
                    ) { index, savedTab in
                        SiteRowView(tabManager: tabManager, data: .savedTab(savedTab)) {
                            tappedItemAtIndex(index)
                        }.onAppear {
                            itemAtIndexAppeared(index)
                        }

                        Color.groupedBackground.frame(height: 1)
                    }
                }
            }
        }.padding(.bottom)
    }

    func countOfPreviousSites(section: DateGroupedTableDataSection) -> Int {
        guard section.index > 0,
            let historyPanelModel = historyPanelModel
        else {
            return 0
        }

        let range = 0...(section.index - 1)
        let siteCounts = range.map {
            historyPanelModel.groupedSites.numberOfItemsForSection(Int($0))
        }

        return siteCounts.reduce(0, +)
    }
}
