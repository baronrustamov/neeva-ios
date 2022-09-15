// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NewArchivedTabsRowView: View {
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    let tabs: [ArchivedTab]
    let tabManager: TabManager
    let tabGroup: ArchivedTabGroup?
    let archivedTabModel: ArchivedTabsGroupedDataModel

    let corners: CornerSet
    let isTopRow: Bool
    let isBottomRow: Bool

    @State private var width: CGFloat = 0

    private var isTabGroup: Bool {
        tabGroup != nil
    }

    var body: some View {
        VStack {
            if let tabGroup = tabGroup, isTopRow {
                HStack {
                    Menu {
                        Button {
                            tabManager.restore(archivedTabGroup: tabGroup)
                            selectionCompletion()
                        } label: {
                            Label("Restore Tab Group", systemSymbol: .plusApp)
                        }

                        if #available(iOS 15.0, *) {
                            Button(role: .destructive) {
                                tabManager.remove(archivedTabGroup: tabGroup)
                                archivedTabModel.loadData()
                            } label: {
                                Label("Delete Tab Group", systemSymbol: .trash)
                            }
                        } else {
                            Button {
                                tabManager.remove(archivedTabGroup: tabGroup)
                                archivedTabModel.loadData()
                            } label: {
                                Label("Delete Tab Group", systemSymbol: .trash)
                            }
                        }
                    } label: {
                        Label("ellipsis", systemImage: "ellipsis")
                            .foregroundColor(.label)
                            .labelStyle(.iconOnly)
                            .frame(height: 44)
                    }

                    Text(tabGroup.displayTitle)
                        .withFont(.labelLarge)
                        .foregroundColor(.label)

                    Spacer()
                }
            }

            HStack {
                ForEach(tabs, id: \.self) { tab in
                    ArchivedTabsCardView(tab: tab, tabManager: self.tabManager, width: width / 2)
                }
            }
        }
        .padding(.horizontal, GroupedCellUX.padding)
        .if(isTabGroup) { view in
            view
                .padding(.bottom, 18)
                .background(
                    Color.secondarySystemFill
                        .cornerRadius(GroupedCellUX.cornerRadius, corners: corners)
                )
        }
        .padding(.top, !isTabGroup ? 18 : 0)
        .onWidthOfViewChanged { newValue in
            width = newValue
        }
        .transition(.identity)
        .animation(nil)
    }
}
