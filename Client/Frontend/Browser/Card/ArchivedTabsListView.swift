// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ArchivedTabsRowView: View {
    let tab: Tab
    let tabManager: TabManager

    private let padding: CGFloat = 4

    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    var body: some View {
        Button {
            tabManager.selectTabFromArchive(tab)
            selectionCompletion()
        } label: {
            HStack {
                if let url = tab.url {
                    FaviconView(forSiteUrl: url)
                        .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                        .padding(.trailing, padding)
                }

                VStack(alignment: .leading, spacing: padding) {
                    Text(tab.title ?? "")
                        .foregroundColor(.label)

                    Text(tab.url?.absoluteString ?? "")
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

struct ArchivedTabsListView: View {
    @Environment(\.onOpenURL) var openURL
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void
    @EnvironmentObject var model: ArchivedTabsPanelModel
    @Default(.tabGroupNames) private var tabGroupDict: [String: String]

    private let padding: CGFloat = 4
    let tabManager: TabManager
    let tabs: [Tab]
    let section: ArchivedTabTimeSection

    func getProcessedFromTabGroupDict() -> [String: Bool] {
        return tabGroupDict.reduce(into: [String: Bool]()) { dict, groupName in
            dict[groupName.key] = false
        }
    }

    var body: some View {
        LazyVStack(spacing: 8) {
            var processed = getProcessedFromTabGroupDict()
            ForEach(tabs, id: \.self) { tab in
                if processed[tab.rootUUID] != nil {
                    if processed[tab.rootUUID] == false {
                        if let tabGroup = model.tabManager.archivedTabGroups[tab.rootUUID]?
                            .children
                        {
                            LazyVStack(spacing: 0) {
                                HStack {
                                    Text(getTabGroupTitle(id: tab.rootUUID))
                                        .withFont(.labelMedium)
                                        .foregroundColor(.label)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.vertical, 8)
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                                ForEach(
                                    tabGroup, id: \.self
                                ) { filteredTab in
                                    ArchivedTabsRowView(tab: filteredTab, tabManager: tabManager)
                                }
                            }
                            .background(
                                Color.secondarySystemFill
                                    .cornerRadius(16)
                            )
                        }
                        let _ = processed[tab.rootUUID] = true
                    }
                } else {
                    ArchivedTabsRowView(tab: tab, tabManager: tabManager)
                }
            }
        }
    }

    func getTabGroupTitle(id: String) -> String {
        return Defaults[.tabGroupNames][id] ?? tabManager.getTabForUUID(uuid: id)?.displayTitle
            ?? ""
    }
}
