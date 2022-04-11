// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct SiteListView: View {
    let tabManager: TabManager

    var sites: [Site]? = nil
    var savedTabs: [SavedTab]? = nil

    var itemAtIndexAppeared: (Int) -> Void = { _ in }
    var tappedItemAtIndex: (Int) -> Void = { _ in }
    var deleteSite: (Site) -> Void = { _ in }

    var body: some View {
        GroupedCell.Decoration {
            VStack(spacing: 0) {
                if let sites = sites {
                    ForEach(
                        Array(sites.enumerated()), id: \.element
                    ) { index, site in
                        SiteRowView(tabManager: tabManager, site: site) {
                            tappedItemAtIndex(index)
                        }.onAppear {
                            itemAtIndexAppeared(index)
                        }

                        Color.groupedBackground.frame(height: 1)
                    }.onDelete { indexSet in
                        indexSet.forEach { index in
                            deleteSite(sites[index])
                        }
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
        }
    }
}
