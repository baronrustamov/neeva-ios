// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ArchivedTabsSectionHeader: View {
    let section: ArchivedTabTimeSection

    var body: some View {
        HStack {
            Text(section.rawValue)
                .fontWeight(.medium)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading)
        .padding(.vertical, 8)
    }
}

struct ArchivedTabsPanelView: View {
    @ObservedObject var model: ArchivedTabsPanelModel
    @Default(.archivedTabsDuration) var archivedTabsDuration
    @State var showArchivedTabsSettings = false
    let onDismiss: () -> Void

    var archivedTabsLabel: String {
        switch archivedTabsDuration {
        case .week:
            return "After 7 Days"
        case .month:
            return "After 30 Days"
        case .forever:
            return "Never"
        }
    }

    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                Button(action: {
                    showArchivedTabsSettings = true
                }) {
                    HStack(spacing: 0) {
                        Text("Archive tabs")
                            .withFont(.bodyLarge)
                            .foregroundColor(.label)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 10)
                        Spacer()
                        Group {
                            Symbol(decorative: .chevronRight, size: 18)
                                .foregroundColor(.label)
                        }.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                }

                Color.groupedBackground.frame(height: 1)

                Button(action: {
                    model.clearArchivedTabs()
                }) {
                    HStack(spacing: 0) {
                        Text("Clear All Archived Tabs")
                            .withFont(.bodyLarge)
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 10)
                        Spacer()
                        Group {

                        }.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                }

                NavigationLink(isActive: $showArchivedTabsSettings) {
                    ArchivedTabSettings()
                } label: {
                    EmptyView()
                }

                Color.secondarySystemFill
                    .frame(height: 8)
            }

            // Archived tabs
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(ArchivedTabTimeSection.allCases, id: \.self) { section in
                    let itemsInSection = model.groupedSites.itemsForSection(section: section)

                    if itemsInSection.count > 0 {
                        Section(header: ArchivedTabsSectionHeader(section: section)) {
                            ArchivedTabsListSectionVIew(
                                tabManager: model.tabManager, tabs: itemsInSection, section: section
                            )
                            .environmentObject(model)
                        }
                    }
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
                .introspectNavigationController { target in
                    target.navigationBar.backgroundColor = UIColor.systemBackground
                }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            model.loadData()
        }
    }
}
