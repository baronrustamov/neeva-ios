// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ArchivedTabsListSectionView: View {
    @Environment(\.onOpenURL) var openURL
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    let rows: [ArchivedTabRow]
    let tabManager: TabManager

    var body: some View {
        GroupedCell.Decoration {
            LazyVStack(spacing: 0) {
                ForEach(rows, id: \.id) { row in
                    switch row {
                    case .tab(let tab):
                        ArchivedTabsRowView(tab: tab, tabManager: tabManager)
                    case .tabGroup(let group):
                        LazyVStack(spacing: 0) {
                            HStack {
                                Text(group.displayTitle)
                                    .withFont(.labelMedium)
                                    .foregroundColor(.label)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.vertical, 8)
                                    .padding(.leading, 16)
                                Spacer()
                            }

                            ForEach(
                                group.children, id: \.self
                            ) { tab in
                                ArchivedTabsRowView(tab: tab, tabManager: tabManager)
                            }
                        }
                        .background(
                            Color.secondarySystemFill
                                .cornerRadius(GroupedCellUX.cornerRadius)
                        )
                    }
                }
            }
        }.padding(.bottom)
    }
}
