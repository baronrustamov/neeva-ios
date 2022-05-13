// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

enum TimeSection: Int, CaseIterable, Decodable, Encodable {
    case today
    case yesterday
    case lastWeek
    case lastMonth
    case overAMonth

    var title: String? {
        switch self {
        case .today:
            return Strings.TableDateSectionTitleToday
        case .yesterday:
            return Strings.TableDateSectionTitleYesterday
        case .lastWeek:
            return Strings.TableDateSectionTitleLastWeek
        case .lastMonth:
            return Strings.TableDateSectionTitleLastMonth
        case .overAMonth:
            return Strings.TableDateSectionTitleOverAMonth
        }
    }
}

struct HistorySectionHeader: View {
    let section: TimeSection

    var title: some View {
        HStack {
            Text(section.title ?? "")
                .fontWeight(.medium)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading)
        .padding(.vertical, 8)
    }

    var body: some View {
        title.background(Color.groupedBackground)
    }
}

struct HistoryPanelView: View {
    @ObservedObject var model: HistoryPanelModel
    @Environment(\.onOpenURL) var openURL

    @State var showRecentlyClosedTabs = false
    @State var showClearHistoryMenu = false

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
                    GroupedRowButtonView(label: "Clear Recent History", symbol: .trash) {
                        showClearHistoryMenu = true
                    }.disabled(model.groupedSites.isEmpty)

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(
                        label: "Recently Closed Tabs", symbol: .chevronRight
                    ) {
                        showRecentlyClosedTabs = true
                    }

                    NavigationLink(isActive: $showRecentlyClosedTabs) {
                        RecentlyClosedTabsPanelView(model: model, onDismiss: onDismiss)
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
                    ForEach(TimeSection.allCases, id: \.self) { section in
                        let itemsInSection =
                            useFilteredSites
                            ? model.filteredSites.itemsForSection(section.rawValue)
                            : model.groupedSites.itemsForSection(section.rawValue)

                        if itemsInSection.count > 0 {
                            Section(header: HistorySectionHeader(section: section)) {
                                SiteListView(
                                    tabManager: model.tabManager,
                                    historyPanelModel: model,
                                    sites: itemsInSection,
                                    siteTimeSection: section,
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
                    }.confirmationDialog(
                        Strings.ClearHistoryMenuTitle, isPresented: $showClearHistoryMenu
                    ) {
                        ForEach(HistoryClearableTimeFrame.allCases, id: \.self) { timeFrame in
                            Button(role: .destructive) {
                                model.removeItemsFromHistory(timeFrame: timeFrame)
                            } label: {
                                Text(timeFrame.rawValue)
                            }
                        }
                    } message: {
                        Text(Strings.ClearHistoryMenuTitle)
                    }
            } else {
                historyList
                    .actionSheet(isPresented: $showClearHistoryMenu) {
                        ActionSheet(
                            title: Text(Strings.ClearHistoryMenuTitle),
                            buttons: [
                                .destructive(Text(HistoryClearableTimeFrame.lastHour.rawValue)) {
                                    model.removeItemsFromHistory(timeFrame: .lastHour)
                                },
                                .destructive(Text(HistoryClearableTimeFrame.today.rawValue)) {
                                    model.removeItemsFromHistory(timeFrame: .today)
                                },
                                .destructive(
                                    Text(HistoryClearableTimeFrame.todayAndYesterday.rawValue)
                                ) {
                                    model.removeItemsFromHistory(timeFrame: .todayAndYesterday)
                                },
                                .destructive(Text(HistoryClearableTimeFrame.all.rawValue)) {
                                    model.removeItemsFromHistory(timeFrame: .all)
                                },
                                .cancel(),
                            ]
                        )
                    }
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
}
