// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ArchivedTabsCardView: View {
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void
    @EnvironmentObject var browserModel: BrowserModel

    let tab: ArchivedTab
    let tabManager: TabManager
    let model: ArchivedTabsGroupedDataModel
    let width: CGFloat

    private let padding: CGFloat = 4

    var tabURL: URL? {
        return tab.url
    }

    var body: some View {
        Button {
            tabManager.select(archivedTab: tab)
            selectionCompletion()
            browserModel.hideGridWithNoAnimation()
        } label: {
            HStack {
                HStack {
                    if let url = tabURL {
                        let roundedRectangle = RoundedRectangle(cornerRadius: 8)

                        FaviconView(forSiteUrl: url)
                            .frame(width: 32, height: 32)
                            .clipShape(roundedRectangle)
                            .overlay(
                                roundedRectangle
                                    .stroke(lineWidth: 0.5)
                                    .foregroundColor(.quaternaryLabel)
                            )
                    }

                    VStack(alignment: .leading, spacing: padding) {
                        Text(tab.displayTitle)
                            .withFont(.bodyMedium)
                            .foregroundColor(.label)
                            .multilineTextAlignment(.leading)
                    }
                    .lineLimit(2)
                    .padding(.leading, padding)

                    Spacer()
                }.frame(maxWidth: width)

                Spacer()
            }
            .padding(.trailing, -6)
        }.contextMenu {
            if #available(iOS 15.0, *) {
                Button(role: .destructive) {
                    model.removeArchivedTabs([tab])
                } label: {
                    Label("Delete", systemSymbol: .trash)
                }
            } else {
                Button {
                    model.removeArchivedTabs([tab])
                } label: {
                    Label("Delete", systemSymbol: .trash)
                }
            }
        }
        .accessibilityIdentifier("ArchivedTabCardView")
    }
}
