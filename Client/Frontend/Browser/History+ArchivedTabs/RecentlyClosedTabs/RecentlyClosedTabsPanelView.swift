// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct RecentlyClosedTabsPanelView: View {
    let model: RecentlyClosedTabsPanelModel
    @State var showDeleteAllConfirmation = false

    let onDismiss: () -> Void

    var listContent: some View {
        ScrollView {
            // Recently closed tabs and clear history
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    GroupedRowButtonView(label: "Delete All", symbol: .trash) {
                        showDeleteAllConfirmation = true
                    }
                }.accentColor(.label)
            }.padding(.horizontal)

            LazyVStack(spacing: 0) {
                SiteListView(
                    tabManager: model.tabManager,
                    data: .savedTabs(model.recentlyClosedTabs),
                    tappedItemAtIndex: { index in
                        model.restoreTab(at: index)
                        onDismiss()
                    })
            }.padding(.horizontal)
        }
        .background(Color.groupedBackground.ignoresSafeArea(.container))
        .accessibilityIdentifier("recentlyClosedPanel")
    }

    var body: some View {
        Group {
            if model.recentlyClosedTabs.isEmpty {
                Text("Websites you've closed\nrecently will show up here.")
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(Text("Recently Closed List Empty"))
            } else {
                if #available(iOS 15.0, *) {
                    listContent
                        .confirmationDialog("", isPresented: $showDeleteAllConfirmation) {
                            Button(role: .destructive) {
                                model.deleteRecentlyClosedTabs()
                            } label: {
                                Text("Delete All")
                            }
                        } message: {
                            Text("Are you sure you want to delete all recently closed tabs?")
                        }
                } else {
                    listContent
                        .actionSheet(isPresented: $showDeleteAllConfirmation) {
                            ActionSheet(
                                title: Text(
                                    "Are you sure you want to delete all recently closed tabs?"),
                                buttons: [
                                    .destructive(Text("Delete All")) {
                                        model.deleteRecentlyClosedTabs()
                                    },
                                    .cancel(),
                                ]
                            )
                        }
                }
            }
        }.navigationTitle("Recently Closed Tabs")
    }
}
