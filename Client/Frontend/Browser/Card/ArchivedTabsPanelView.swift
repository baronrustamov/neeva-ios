// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ArchivedTabsPanelView: View {
    @ObservedObject var model: ArchivedTabsPanelModel
    let onDismiss: () -> Void

    var content: some View {
        // TODO: what to show when there's no archived tab?

        ScrollView {
            VStack(spacing: 0) {
                Button(action: {}) {
                    HStack(spacing: 0) {
                        Text("Archive tabs")
                            .withFont(.bodyLarge)
                            .foregroundColor(.label)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 10)
                            .border(Color.red, width: 1)
                        Spacer()
                        Group {

                        }.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .border(Color.blue, width: 1)
                }

                Color.groupedBackground.frame(height: 1)

                Button(action: {}) {
                    HStack(spacing: 0) {
                        Text("Clear All Archived Tabs")
                            .withFont(.bodyLarge)
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 10)
                            .border(Color.red, width: 1)
                        Spacer()
                        Group {

                        }.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .border(Color.blue, width: 1)
                }

                Color.secondarySystemFill
                    .frame(height: 8)
            }

            // Archived tabs

            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(ArchivedTabTimeSection.allCases, id: \.self) { section in
                    let itemsInSection = model.groupedSites.itemsForSection(section.rawValue)
                }
            }

        }
    }

    var body: some View {
        NavigationView {
            content
                .accessibilityIdentifier("archivedTabsPanel")
                .navigationTitle("Archived Tabs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        onDismiss()
                    } label: {
                        Text("Done")
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}
