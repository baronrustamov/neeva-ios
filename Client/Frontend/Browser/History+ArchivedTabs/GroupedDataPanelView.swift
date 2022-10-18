// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct GroupedDataPanelView<Model: GroupedDataPanelModel, NavigationButtons: View>: View {
    @EnvironmentObject var browserModel: BrowserModel
    @ObservedObject var model: Model
    @StateObject var searchQuery = DebounceObject()
    let navigationButtons: NavigationButtons

    var optionSections: some View {
        VStack {
            SingleLineTextField(
                useCapsuleBackground: false,
                icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                placeholder: "Search",
                text: $searchQuery.text
            )
            .accessibilityLabel(Text("Search TextField"))
            .onChange(of: searchQuery.debouncedText) { newValue in
                model.loadData(filter: newValue)
            }
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color.tertiarySystemFill))
            .padding(.horizontal)
            .padding(.vertical, 4)

            Color.tertiarySystemFill.frame(height: 8)
            navigationButtons

            if model.groupedData.isEmpty {
                Color.tertiarySystemFill.frame(height: 8)
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                optionSections

                if model.groupedData.isEmpty {
                    Text(model.emptyDataText)
                        .padding(.top, 20)
                        .accessibility(label: Text("Empty Rows"))
                } else {
                    ForEach(DateGroupedTableDataSection.allCases, id: \.self) { section in
                        buildDaySections(section: section)
                    }
                }
            }
        }
        .animation(.interactiveSpring())
        .transition(.identity)
    }

    @ViewBuilder
    private func buildDaySections(section: DateGroupedTableDataSection) -> some View {
        Group {
            let itemsInSection = model.groupedData.itemsForSection(section)

            switch section {
            case .today, .yesterday:
                buildSection(
                    with: Array(itemsInSection[0].data), in: section,
                    sectionHeaderTitle: section.rawValue)
            case .older:
                ForEach(itemsInSection, id: \.self) { item in
                    if let sites = item.data {
                        buildSection(
                            with: sites, in: section, sectionHeaderTitle: item.dateString)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func buildSection(
        with data: [Model.T], in section: DateGroupedTableDataSection, sectionHeaderTitle: String
    ) -> some View {
        LazyVStack(spacing: 0) {
            if data.count > 0 {
                Section(header: DateSectionHeaderView(text: sectionHeaderTitle)) {
                    if let model = model as? ArchivedTabsGroupedDataModel,
                        let data = data as? [ArchivedTabRow]
                    {
                        let (rows, tabGroups) = model.buildRows(with: data, for: section)

                        ForEach(Array(rows.enumerated()), id: \.1) { index, tabs in
                            let tabGroup: ArchivedTabGroup? = tabGroups[tabs.first?.rootUUID ?? ""]
                            let isTopRow: Bool =
                                tabs.first == nil
                                ? false
                                : tabGroups[tabs.first!.rootUUID]?.children.first == tabs.first
                            let isBottomRow: Bool =
                                tabs.last == nil
                                ? false : tabGroups[tabs.last!.rootUUID]?.children.last == tabs.last
                            let isLastRowInSection = index == rows.count - 1

                            let corners: CornerSet = {
                                var corners: CornerSet = []

                                if isTopRow {
                                    corners.insert(.top)
                                }

                                if isBottomRow {
                                    corners.insert(.bottom)
                                }

                                return corners
                            }()

                            NewArchivedTabsRowView(
                                tabs: tabs,
                                tabManager: browserModel.tabManager,
                                tabGroup: tabGroup,
                                archivedTabModel: model,
                                corners: corners,
                                isTopRow: isTopRow,
                                isBottomRow: isBottomRow
                            ).padding(.bottom, isLastRowInSection ? 8 : 0)
                        }
                    } else if let model = model as? HistoryGroupedDataModel,
                        let data = data as? [Site]
                    {
                        let rows = Array(model.buildRows(with: data, for: section))

                        ForEach(
                            rows, id: \.element
                        ) { index, site in
                            SiteRowView(
                                tabManager: browserModel.tabManager,
                                data: .site(
                                    site,
                                    { site in
                                        model.removeItemFromHistory(site: site)
                                    }
                                )
                            ).onAppear {
                                model.loadNextItemsIfNeeded(
                                    from: index + model.countOfPreviousSites(section: section))
                            }
                        }.padding(.top, 8)
                    }
                }
                .transition(.identity)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
    }

    init(
        model: Model,
        @ViewBuilder navigationButtons: () -> NavigationButtons
    ) {
        self.model = model
        self.navigationButtons = navigationButtons()
    }
}
