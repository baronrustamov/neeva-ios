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
    @Default(.archivedTabsDuration) var archivedTabsDuration
    @State var currentView: HistoryAndArchivedTabsPanelState
    @State private var showArchivedTabSettings = false
    @State private var showRecentlyClosedTabs = false

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

    var body: some View {
        NavigationView {
            GeometryReader { geom in
                VStack {
                    picker

                    ZStack {
                        GroupedDataPanelView(
                            model: HistoryGroupedDataModel(tabManager: browserModel.tabManager)
                        ) {
                            Button {
                                showRecentlyClosedTabs = true
                            } label: {
                                HStack {
                                    Text("Recently Closed Tabs")
                                    Spacer()
                                    Symbol(decorative: .chevronRight)
                                }
                            }
                        }.offset(x: currentView == .history ? 0 : -geom.size.width)

                        GroupedDataPanelView(
                            model: ArchivedTabsGroupedDataModel(tabManager: browserModel.tabManager)
                        ) {
                            Button {
                                showArchivedTabSettings = true
                            } label: {
                                HStack {
                                    Text("Archive Tabs")
                                    Spacer()

                                    Label {
                                        Symbol(decorative: .chevronRight)
                                    } icon: {
                                        Text(
                                            archivedTabsDuration.label
                                        )
                                        .foregroundColor(.secondaryLabel)
                                    }
                                }
                            }
                        }.offset(x: currentView == .archivedTabs ? 0 : geom.size.width)
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
