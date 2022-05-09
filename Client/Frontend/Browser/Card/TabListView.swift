// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct TabListView: View {
    @Environment(\.onOpenURL) var openURL
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void
    @EnvironmentObject var model: ArchivedTabsPanelModel
    
    let tabManager: TabManager
    private let padding: CGFloat = 4
    let tabs: [Tab]
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                if let url = tab.url { // should get rid of this unwrapping
                    // if tab is in a tab group, Do a LazyVStack of Buttons                    
                    Button {
                        tabManager.select(tab)
                        selectionCompletion()
                    } label: {
                        HStack {
                            FaviconView(forSiteUrl: url)
                                .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                                .padding(.trailing, padding)
                            
                            VStack(alignment: .leading, spacing: padding) {
                                Text(tab.title ?? "")
                                    .foregroundColor(.label)

                                Text(url.absoluteString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }.lineLimit(1)

                            Spacer()
                        }
                        .padding(.trailing, -6)
                        .padding(.horizontal, GroupedCellUX.padding)
                        .padding(.vertical, 10)
                        .frame(minHeight: GroupedCellUX.minCellHeight)
                    }
                }
            }
        }
    }
}
