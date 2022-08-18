// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ArchivedTabsRowView: View {
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    let tab: Tab
    let tabManager: TabManager
    private let padding: CGFloat = 4

    var tabURL: URL? {
        return tab.url ?? tab.sessionData?.currentUrl
    }

    var body: some View {
        Button {
            tabManager.select(tab)
            selectionCompletion()
        } label: {
            HStack {
                if let url = tabURL {
                    FaviconView(forSiteUrl: url)
                        .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                        .cornerRadius(4)
                        .padding(.trailing, padding)
                }

                VStack(alignment: .leading, spacing: padding) {
                    Text(tab.title ?? "")
                        .foregroundColor(.label)

                    Text(tabURL?.absoluteString ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }.lineLimit(1)

                Spacer()
            }
            .padding(.trailing, -6)
            .padding(.horizontal, GroupedCellUX.padding)
            .padding(.vertical, 6)
            .frame(minHeight: GroupedCellUX.minCellHeight)
        }
    }
}
