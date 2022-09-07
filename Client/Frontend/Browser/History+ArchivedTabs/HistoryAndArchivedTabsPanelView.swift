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
    @EnvironmentObject var tabCardModel: TabCardModel

    @Default(.archivedTabsDuration) var archivedTabsDuration
    @State var currentView: HistoryAndArchivedTabsPanelState
    @State private var showArchivedTabSettings = false
    @State private var showRecentlyClosedTabs = false
    @State private var showClearBrowsingData = false
    @State private var showCloseArchivedTabs = false

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
        Color.groupedBackground.frame(height: 1)
    }

    var historyView: some View {
        GroupedDataPanelView(model: HistoryGroupedDataModel(tabManager: browserModel.tabManager)) {
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
            }
        }
    }

    @ViewBuilder
    var archivedTabsView: some View {
        let archivedTabsModel = ArchivedTabsGroupedDataModel(
            tabCardModel: tabCardModel, tabManager: browserModel.tabManager)

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

                Button {
                    showCloseArchivedTabs = true
                } label: {
                    HStack {
                        Text("Clear All Archived Tabs")

                        Spacer()
                    }
                }
                .foregroundColor(.red)
                .padding(16)
            }
        }
    }

    var body: some View {
        NavigationView {
            GeometryReader { geom in
                VStack {
                    picker

                    ZStack {
                        historyView
                            .offset(x: currentView == .history ? 0 : -geom.size.width)

                        archivedTabsView
                            .offset(x: currentView == .archivedTabs ? 0 : geom.size.width)
                    }

                    Spacer()
                }
            }
            .highPriorityGesture(dragGesture)
            .navigationTitle(
                Text(currentView == .history ? "History" : "Archived Tabs")
            ).toolbar {
                Button {
                    browserModel.overlayManager.hide(overlay: .fullScreenSheet(AnyView(self)))
                } label: {
                    Text("Done")
                }
            }.navigationBarTitleDisplayMode(.inline)

            NavigationLink(isActive: $showArchivedTabSettings) {
                // TODO: (Evan) Navigate to ArchivedTabSettings.
            } label: {
                EmptyView()
            }

            NavigationLink(isActive: $showRecentlyClosedTabs) {
                // TODO: (Evan) Navigate to RecentlyClosedTabsPanelView.
            } label: {
                EmptyView()
            }
        }
    }
}

struct HistoryAndArchivedTabsPanelView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryAndArchivedTabsPanelView(currentView: .history)
        HistoryAndArchivedTabsPanelView(currentView: .archivedTabs)
    }
}
