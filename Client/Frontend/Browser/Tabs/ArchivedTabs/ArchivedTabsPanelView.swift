// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ArchivedTabsPanelView: View {
    @ObservedObject var model: ArchivedTabsPanelModel

    @Default(.archivedTabsDuration) var archivedTabsDuration
    @State var showArchivedTabsSettings = false
    @State private var confirmationShow = false

    let onDismiss: () -> Void
    private let clearAllArchiveButtonTitle = "Are you sure you want to close all archived tabs?"

    var archivedTabsLabel: LocalizedStringKey {
        switch archivedTabsDuration {
        case .week:
            return "After 7 Days"
        case .month:
            return "After 30 Days"
        case .forever:
            return "Never"
        }
    }

    var clearAllArchivesButton: some View {
        GroupedRowButtonView(
            label: "Clear All Archived Tabs", symbol: .trash
        ) {
            confirmationShow = true
        }
        .accentColor(model.numOfArchivedTabs < 1 ? .tertiaryLabel : .red)
        .disabled(model.numOfArchivedTabs < 1)
    }

    var clearAllArchiveButtonText: String {
        return "Close \(model.numOfArchivedTabs) \(model.numOfArchivedTabs > 1 ? "Tabs" : "Tab")"
    }

    var content: some View {
        ScrollView {
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    GroupedRowButtonView(
                        label: "Auto Archive Tabs", symbolLabel: archivedTabsLabel,
                        symbol: .chevronRight
                    ) {
                        showArchivedTabsSettings = true
                    }.accentColor(.label)

                    NavigationLink(isActive: $showArchivedTabsSettings) {
                        ArchivedTabSettings()
                    } label: {
                        EmptyView()
                    }

                    Color.groupedBackground.frame(height: 1)

                    if #available(iOS 15.0, *) {
                        clearAllArchivesButton
                            .confirmationDialog(
                                clearAllArchiveButtonTitle,
                                isPresented: $confirmationShow,
                                titleVisibility: .visible
                            ) {
                                Button(
                                    clearAllArchiveButtonText,
                                    role: .destructive
                                ) {
                                    model.clearArchivedTabs()
                                    ClientLogger.shared.logCounter(
                                        .clearArchivedTabs,
                                        attributes: EnvironmentHelper.shared.getAttributes())
                                }
                            }
                    } else {
                        clearAllArchivesButton
                            .actionSheet(isPresented: $confirmationShow) {
                                ActionSheet(
                                    title: Text(clearAllArchiveButtonTitle),
                                    buttons: [
                                        .destructive(
                                            Text(clearAllArchiveButtonText)
                                        ) {
                                            model.clearArchivedTabs()
                                        },
                                        .cancel(),
                                    ]
                                )
                            }
                    }
                }
            }

            VStack(spacing: 0) {
                // None of the tabs will be today/yesterday, fine to just call for older tabs.
                ForEach(model.groupedRows.itemsForSection(.older), id: \.self) { section in
                    if section.data.count > 0 {
                        Section(header: DateSectionHeaderView(text: section.dateString)) {
                            ArchivedTabsListSectionView(
                                rows: section.data, tabManager: model.tabManager)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(
            Color.groupedBackground.ignoresSafeArea(.container)
        )
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
                    target.navigationBar.backgroundColor = UIColor.systemGroupedBackground
                }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            model.loadData()
        }
    }
}
