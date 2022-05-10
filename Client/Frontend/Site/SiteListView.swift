// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct SiteListView: View {
    let tabManager: TabManager
    var historyPanelModel: HistoryPanelModel? = nil

    var sites: [Site]? = nil
    var siteTimeSection: TimeSection?

    var savedTabs: [SavedTab]? = nil

    var itemAtIndexAppeared: (Int) -> Void = { _ in }
    var tappedItemAtIndex: (Int) -> Void = { _ in }
    var deleteSite: (Site) -> Void = { _ in }

    var body: some View {
        GroupedCell.Decoration {
            LazyVStack(spacing: 0) {
                if let sites = sites {
                    ForEach(
                        Array(sites.enumerated()), id: \.element
                    ) { index, site in
                        SiteRowView(tabManager: tabManager, site: site, deleteSite: deleteSite) {
                            tappedItemAtIndex(index + countOfPreviousSites())
                        }.onAppear {
                            itemAtIndexAppeared(index + countOfPreviousSites())
                        }

                        Color.groupedBackground.frame(height: 1)
                    }
                } else if let savedTabs = savedTabs {
                    ForEach(
                        Array(savedTabs.enumerated()), id: \.element
                    ) { index, savedTab in
                        SiteRowView(tabManager: tabManager, savedTab: savedTab) {
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

    func countOfPreviousSites() -> Int {
        guard let siteTimeSection = siteTimeSection, siteTimeSection.rawValue > 0,
            let historyPanelModel = historyPanelModel
        else {
            return 0
        }

        var count = 0
        for i in 0...(siteTimeSection.rawValue - 1) {
            count += historyPanelModel.groupedSites.numberOfItemsForSection(i)
        }

        return count
    }
}
