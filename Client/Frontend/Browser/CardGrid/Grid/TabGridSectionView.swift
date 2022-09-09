// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SingleLevelTabCardsViewUX {
    static let TabGroupCarouselTitleSize: CGFloat = 22
    static let TabGroupCarouselTitleSpacing: CGFloat = 16
    static let TabGroupCarouselTopPadding: CGFloat = 16
    static let TabGroupCarouselBottomPadding: CGFloat = 8
    static let TabGroupCarouselTabSpacing: CGFloat = 12
}

struct TabGridSectionHeaderView: View {
    let section: TabSection

    var body: some View {
        VStack {
            Color.secondarySystemFill
                .frame(height: 8)
                .padding(.horizontal, -CardGridUX.GridSpacing)

            HStack {
                Text(LocalizedStringKey(section.rawValue))
                    .withFont(.labelLarge)
                    .foregroundColor(.label)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Spacer()
            }
        }
    }
}

struct TabGridSectionView: View {
    @EnvironmentObject private var browserModel: BrowserModel

    let containerGeometry: GeometryProxy
    let section: TabSection
    let rows: [Row]

    var body: some View {
        ForEach(rows) { row in
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(Array(row.cells.enumerated()), id: \.0) { index, details in
                    switch details {
                    case .tabGroupInline(let groupDetails):
                        CollapsedCardGroupView(
                            groupDetails: groupDetails,
                            containerGeometry: containerGeometry,
                            row: row, cellIndex: index
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        .padding(.bottom, CardGridUX.GridSpacing)
                    case .tabGroupGridRow(let groupDetails, let range):
                        ExpandedCardGroupRowView(
                            groupDetails: groupDetails,
                            containerGeometry: containerGeometry,
                            range: range, row: row, cellIndex: index
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        .padding(
                            .bottom,
                            lastRowTabGroup(range, groupDetails)
                                ? CardGridUX.GridSpacing : 0)
                    case .tab(let tabDetails):
                        FittedCard(details: tabDetails)
                            .modifier(
                                CardTransitionModifier(
                                    details: tabDetails,
                                    containerGeometry: containerGeometry)
                            )
                            .padding(.top, 8)
                            .padding(.bottom, CardGridUX.GridSpacing)
                            .environment(\.selectionCompletion) {
                                ClientLogger.shared.logCounter(
                                    .SelectTab,
                                    attributes: getLogCounterAttributesForTabs(
                                        tab: tabDetails.tab))
                                browserModel.hideGridWithAnimation(
                                    tabToBeSelected: tabDetails.tab)
                            }
                    case .sectionHeader(let section):
                        TabGridSectionHeaderView(section: section)
                            .id(row.id)
                    }
                }
            }.zIndex(row.cells.contains(where: \.isSelected) ? 1 : 0)
        }
    }

    func lastRowTabGroup(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
    }

    init(
        tabModel: TabCardModel,
        containerGeometry: GeometryProxy,
        section: TabSection,
        incognito: Bool
    ) {
        self.containerGeometry = containerGeometry
        self.section = section
        self.rows = tabModel.getRows(for: section, incognito: incognito)
    }
}
