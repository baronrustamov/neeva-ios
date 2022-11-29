// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

enum HistoryAndArchivedTabsPanelState {
    case archivedTabs
    case history
}

struct HistoryAndArchivedTabsPanelView: View {
    @EnvironmentObject var browserModel: BrowserModel

    // MARK: - Properties
    @Default(.archivedTabsDuration) var archivedTabsDuration
    @State var currentView: HistoryAndArchivedTabsPanelState
    @State private var showArchivedTabSettings = false
    @State private var showRecentlyClosedTabs = false
    @State private var showClearBrowsingData = false
    @State private var showCloseArchivedTabs = false

    let archivedTabsModel: ArchivedTabsGroupedDataModel
    let historyModel: HistoryGroupedDataModel

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let horizontalAmount = value.predictedEndTranslation.width

                if abs(horizontalAmount) > 200 {
                    currentView = horizontalAmount < 0 ? .archivedTabs : .history
                }
            }
    }

    var picker: some View {
        Picker(selection: $currentView, label: Text("")) {
            Symbol(decorative: .clock)
                .tag(HistoryAndArchivedTabsPanelState.history)

            Symbol(decorative: .archivebox)
                .tag(HistoryAndArchivedTabsPanelState.archivedTabs)
        }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal)
    }

    var divider: some View {
        Color.tertiarySystemFill.frame(height: 1)
    }

    // MARK: - History
    @ViewBuilder
    var historyView: some View {
        GroupedDataPanelView(model: historyModel) {
            VStack {
                Button {
                    showRecentlyClosedTabs = true
                } label: {
                    HStack {
                        Text("Recently Closed Tabs")
                        Spacer()
                        Symbol(decorative: .chevronRight)
                    }
                }
                .foregroundColor(.label)
                .padding(16)

                divider

                Button {
                    showClearBrowsingData = true
                } label: {
                    HStack {
                        Text("Clear Browsing Data")

                        Spacer()
                    }
                }
                .foregroundColor(.red)
                .padding(16)

                NavigationLink(isActive: $showRecentlyClosedTabs) {
                    RecentlyClosedTabsPanelView(
                        model: RecentlyClosedTabsPanelModel(tabManager: browserModel.tabManager),
                        onDismiss: {
                            browserModel.overlayManager.hide(
                                overlay: .fullScreenSheet(AnyView(self)))
                        })
                } label: {
                    EmptyView()
                }

                NavigationLink(isActive: $showClearBrowsingData) {
                    DataManagementView().onDisappear {
                        // Reloads all the data if the user cleared it.
                        historyModel.reloadData()
                    }
                } label: {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Archived Tabs
    var archivedTabsAfterLabel: LocalizedStringKey {
        switch archivedTabsDuration {
        case .week:
            return "After 7 Days"
        case .month:
            return "After 30 Days"
        case .forever:
            return "Never"
        }
    }

    @ViewBuilder
    var clearAllArchivedTabsButton: some View {
        Button {
            showCloseArchivedTabs = true
        } label: {
            HStack {
                Text("Clear All Archived Tabs")
                Spacer()
            }
        }.padding(16)
    }

    @ViewBuilder
    var archivedTabsView: some View {
        let clearAllArchiveButtonTitle: LocalizedStringKey =
            "Are you sure you want to close all archived tabs?"
        let clearAllArchiveButtonText: LocalizedStringKey =
            "Close \(archivedTabsModel.numOfArchivedTabs) \(archivedTabsModel.numOfArchivedTabs > 1 ? "Tabs" : "Tab")"

        GroupedDataPanelView(model: archivedTabsModel) {
            VStack {
                Button {
                    showArchivedTabSettings = true
                } label: {
                    HStack {
                        Text("Auto Archive Tabs")
                        Spacer()

                        Label {
                            Symbol(decorative: .chevronRight)
                        } icon: {
                            Text(archivedTabsAfterLabel)
                                .foregroundColor(.secondaryLabel)
                        }
                    }
                }
                .foregroundColor(.label)
                .padding(16)

                divider

                Group {
                    if #available(iOS 15.0, *) {
                        clearAllArchivedTabsButton
                            .confirmationDialog(
                                clearAllArchiveButtonTitle,
                                isPresented: $showCloseArchivedTabs,
                                titleVisibility: .visible
                            ) {
                                Button(
                                    clearAllArchiveButtonText,
                                    role: .destructive
                                ) {
                                    archivedTabsModel.clearArchivedTabs()
                                }
                            }
                    } else {
                        clearAllArchivedTabsButton
                            .actionSheet(isPresented: $showCloseArchivedTabs) {
                                ActionSheet(
                                    title: Text(clearAllArchiveButtonTitle),
                                    buttons: [
                                        .destructive(
                                            Text(clearAllArchiveButtonText)
                                        ) {
                                            archivedTabsModel.clearArchivedTabs()
                                        },
                                        .cancel(),
                                    ]
                                )
                            }
                    }
                }.foregroundColor(
                    archivedTabsModel.numOfArchivedTabs < 1 ? .tertiaryLabel : .red
                ).disabled(archivedTabsModel.numOfArchivedTabs < 1)

                NavigationLink(isActive: $showArchivedTabSettings) {
                    ArchivedTabSettings()
                } label: {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geom in
                VStack {
                    picker

                    ZStack {
                        historyView
                            .offset(x: currentView == .history ? 0 : -geom.size.width)
                            .accessibilityHidden(currentView == .archivedTabs)

                        archivedTabsView
                            .offset(x: currentView == .archivedTabs ? 0 : geom.size.width)
                            .accessibilityHidden(currentView == .history)
                    }

                    Spacer()
                }
            }
            .highPriorityGesture(dragGesture)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(
                Text(currentView == .history ? "History" : "Archived Tabs")
            ).toolbar {
                Button {
                    browserModel.overlayManager.hide(overlay: .fullScreenSheet(AnyView(self)))
                } label: {
                    Text("Done")
                }
            }
            .environment(\.onOpenURL) { url in
                browserModel.tabManager.createOrSwitchToTab(for: url)
            }
        }
    }

    // MARK: - init
    init(
        currentView: HistoryAndArchivedTabsPanelState,
        tabCardModel: TabCardModel
    ) {
        self.currentView = currentView
        self.archivedTabsModel = ArchivedTabsGroupedDataModel(tabCardModel: tabCardModel)
        self.historyModel = HistoryGroupedDataModel(tabManager: tabCardModel.manager)
    }
}
