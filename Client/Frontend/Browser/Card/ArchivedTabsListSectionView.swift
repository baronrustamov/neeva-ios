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
            tabManager.select(tab)
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

class ArchivedTabsListSectionViewModel {
    var itemsInSectionFiltered: [Tab] = []
    @Default(.tabGroupNames) private var tabGroupDict: [String: String]

    func getProcessedFromTabGroupDict() -> [String: Bool] {
        return tabGroupDict.reduce(into: [String: Bool]()) { dict, groupName in
            dict[groupName.key] = false
        }
    }

    init(itemsInSection: [Tab]) {
        var processed = getProcessedFromTabGroupDict()

        // Walk through 'itemInSection' and make sure only one child tab from
        // a tab group exist in the array. ArchivedTabsListSectionView will get
        // the tab group and display all child tabs in the corresponding section.
        itemsInSection.forEach { tab in
            if processed[tab.rootUUID] != nil {
                if processed[tab.rootUUID] == false {
                    itemsInSectionFiltered.append(tab)
                }
                processed[tab.rootUUID] = true
            } else {
                itemsInSectionFiltered.append(tab)
            }
        }
    }
}

struct ArchivedTabsListSectionView: View {
    @Environment(\.onOpenURL) var openURL
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void
    @EnvironmentObject var panelModel: ArchivedTabsPanelModel
    var listSectionModel: ArchivedTabsListSectionViewModel
    @Default(.tabGroupNames) private var tabGroupDict: [String: String]

    private let padding: CGFloat = 4
    let tabManager: TabManager
    let section: ArchivedTabTimeSection

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(listSectionModel.itemsInSectionFiltered, id: \.self) { tab in
                // A tab group can have child tabs spread across different archived sections.
                // Therefore, we need to filter to children by last executed time to prevent
                // child tabs from showing up twice in different sections.
                if let tabGroup = panelModel.archivedTabGroups[tab.rootUUID]?
                    .children.filter { child in
                        switch section {
                        case .lastMonth:
                            return child.wasLastExecuted(.lastMonth)
                        case .overAMonth:
                            return child.wasLastExecuted(.overAMonth)
                        }
                    }
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
