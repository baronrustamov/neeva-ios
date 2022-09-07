// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ArchivedTabsCardView: View {
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    let tab: ArchivedTab
    let tabManager: TabManager
    let width: CGFloat

    private let padding: CGFloat = 4

    var tabURL: URL? {
        return tab.url
    }

    var body: some View {
        Button {
            tabManager.select(archivedTab: tab)
            selectionCompletion()
        } label: {
            HStack {
                HStack {
                    if let url = tabURL {
                        if FeatureFlag[.archivedTabsRedesign] {
                            let roundedRectangle = RoundedRectangle(cornerRadius: 8)

                            FaviconView(forSiteUrl: url)
                                .frame(width: 32, height: 32)
                                .clipShape(roundedRectangle)
                                .overlay(
                                    roundedRectangle
                                        .stroke(lineWidth: 0.5)
                                        .foregroundColor(.quaternaryLabel)
                                )
                        } else {
                            FaviconView(forSiteUrl: url)
                                .frame(
                                    width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize
                                )
                                .cornerRadius(4)
                        }
                    }

                    VStack(alignment: .leading, spacing: padding) {
                        Text(tab.displayTitle)
                            .withFont(.bodyMedium)
                            .foregroundColor(.label)
                            .multilineTextAlignment(.leading)

                        if !FeatureFlag[.archivedTabsRedesign] {
                            Text(tabURL?.absoluteString ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .lineLimit(FeatureFlag[.archivedTabsRedesign] ? 2 : 1)
                    .padding(.leading, padding)

                    Spacer()
                }.if(FeatureFlag[.archivedTabsRedesign]) { view in
                    view.frame(maxWidth: width)
                }

                Spacer()
            }
            .padding(.trailing, -6)
            .if(!FeatureFlag[.archivedTabsRedesign]) { view in
                view
                    .padding(.horizontal, GroupedCellUX.padding)
                    .padding(.vertical, 6)
                    .frame(minHeight: GroupedCellUX.minCellHeight)
            }
        }
    }
}
