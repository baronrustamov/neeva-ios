// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ButtonView: View {
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
                FaviconView(forSiteUrl: tab.url ?? "")
                    .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                    .padding(.trailing, padding)
                
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
            .padding(.vertical, 10)
            .frame(minHeight: GroupedCellUX.minCellHeight)
        }
    }
}

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
                    if model.representativeTabs.contains(tab) {
                        if let tabGroup = model.tabManager.getTabGroup(for: tab.rootUUID)?.children {
                            LazyVStack {
                                ForEach(tabGroup.filter {
                                    return $0.wasLastExecuted(.lastMonth)
                                }, id: \.self) { filteredTab in
                                    ButtonView(tab: filteredTab, tabManager: tabManager)
                                }
                            }
                            .background(Color.blue)
                        }
                    } else {
                        ButtonView(tab: tab, tabManager: tabManager)
                    }
                }
            }
        }
    }
}
