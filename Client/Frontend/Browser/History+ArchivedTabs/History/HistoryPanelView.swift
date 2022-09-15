// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct HistoryPanelView: View {
    @ObservedObject var model: HistoryPanelModel
    @Environment(\.onOpenURL) var openURL

    @State var showRecentlyClosedTabs = false
    @State var showClearBrowsingData = false

    // History search
    @StateObject var siteFilter = DebounceObject()
    var useFilteredSites: Bool {
        !siteFilter.debouncedText.isEmpty
    }

    let onDismiss: () -> Void

    var historyList: some View {
        ScrollView(showsIndicators: false) {
            SingleLineTextField(
                icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                placeholder: "Search your history", text: $siteFilter.text
            )
            .padding(.bottom)
            .accessibilityLabel(Text("History Search TextField"))
            .onChange(of: siteFilter.debouncedText) { newValue in
                model.searchForSites(with: newValue)
            }

            // Recently closed tabs and clear history
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    GroupedRowButtonView(label: "Clear Browsing Data", symbol: .chevronRight) {
                        showClearBrowsingData = true
                    }.disabled(model.groupedSites.isEmpty)

                    NavigationLink(isActive: $showClearBrowsingData) {
                        DataManagementView()
                    } label: {
                        EmptyView()
                    }

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(
                        label: "Recently Closed Tabs", symbol: .chevronRight
                    ) {
                        showRecentlyClosedTabs = true
                    }

                    NavigationLink(isActive: $showRecentlyClosedTabs) {
                        RecentlyClosedTabsPanelView(
                            model: RecentlyClosedTabsPanelModel(tabManager: model.tabManager),
                            onDismiss: onDismiss)
                    } label: {
                        EmptyView()
                    }
                }.accentColor(.label)
            }

            // History List
            if model.isFetchInProgress && model.groupedSites.isEmpty {
                Spacer()
                LoadingView("Loading your history...")
                Spacer()
            } else {
                VStack(spacing: 0) {
                    ForEach(DateGroupedTableDataSection.allCases, id: \.self) { section in
                        buildDaySections(section: section)
                    }
                }.padding(.top, 20)
            }
        }
        .padding(.horizontal)
        .background(
            Color.groupedBackground.ignoresSafeArea(.container)
        )
    }

    @ViewBuilder
    var content: some View {
        if model.groupedSites.isEmpty && !model.isFetchInProgress {
            Text("Websites you've visted\nrecently will show up here.")
                .multilineTextAlignment(.center)
                .accessibilityLabel(Text("History List Empty"))
        } else {
            if #available(iOS 15.0, *) {
                historyList
                    .refreshable {
                        model.reloadData()
                    }
            } else {
                historyList
            }
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                content
                    .accessibilityIdentifier("historyListPanel")
                    .navigationTitle("History")
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
            .onAppear {
                model.reloadData()
            }

            OverlayView(limitToOverlayType: [.toast(nil)])
        }
    }

    private func buildDaySections(section: DateGroupedTableDataSection) -> some View {
        Group {
            let itemsInSection =
                useFilteredSites
                ? model.filteredSites.itemsForSection(section)
                : model.groupedSites.itemsForSection(section)

            switch section {
            case .today, .yesterday:
                buildSiteList(
                    with: Array(itemsInSection[0].data), in: section,
                    sectionHeaderTitle: section.rawValue)
            case .older:
                VStack(spacing: 0) {
                    ForEach(itemsInSection, id: \.self) { item in
                        if let sites = item.data {
                            buildSiteList(
                                with: sites, in: section, sectionHeaderTitle: item.dateString)
                        }
                    }
                }
            }
        }
    }

    private func buildSiteList(
        with sites: [Site], in section: DateGroupedTableDataSection, sectionHeaderTitle: String
    ) -> some View {
        Group {
            if sites.count > 0 {
                Section(header: DateSectionHeaderView(text: sectionHeaderTitle)) {
                    SiteListView(
                        tabManager: model.tabManager,
                        historyPanelModel: model,
                        data: .sites(sites, section),
                        itemAtIndexAppeared: { index in
                            model.loadNextItemsIfNeeded(from: index)
                        },
                        deleteSite: { site in
                            model.removeItemFromHistory(site: site)
                        }
                    ).accessibilityLabel(Text("History List"))
                }
            }
        }
    }
}
