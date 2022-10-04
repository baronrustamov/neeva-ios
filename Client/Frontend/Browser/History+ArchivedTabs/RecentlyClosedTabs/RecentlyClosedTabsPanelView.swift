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
                ForEach(
                    Array(model.recentlyClosedTabs.enumerated()), id: \.element
                ) { index, savedTab in
                    SiteRowView(tabManager: model.tabManager, data: .savedTab(savedTab)) {
                        model.restoreTab(at: index)
                        onDismiss()
                    }

                    Color.groupedBackground.frame(height: 1)
                }
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
            }
        }.navigationTitle("Recently Closed Tabs")
    }
}
