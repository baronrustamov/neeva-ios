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

struct SingleLevelTabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject private var browserModel: BrowserModel
    @Environment(\.columns) private var columns

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    let containerGeometry: GeometryProxy
    let incognito: Bool

    var body: some View {
        ForEach(
            tabModel.getRows(incognito: incognito)
        ) { row in
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(Array(row.cells.enumerated()), id: \.0) { index, details in
                    switch details {
                    case .tabGroupInline(let groupDetails):
                        CollapsedCardGroupView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry,
                            row: row, cellIndex: index
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        .padding(.bottom, CardGridUX.GridSpacing)
                        .zIndex(groupDetails.allDetails.contains(where: \.isSelected) ? 1 : 0)
                    case .tabGroupGridRow(let groupDetails, let range):
                        ExpandedCardGroupRowView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry,
                            range: range, row: row, cellIndex: index
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        .padding(
                            .bottom,
                            lastRowTabGroup(range, groupDetails) ? CardGridUX.GridSpacing : 0)
                    case .tab(let tabDetails):
                        FittedCard(details: tabDetails)
                            .modifier(
                                CardTransitionModifier(
                                    details: tabDetails, containerGeometry: containerGeometry)
                            )
                            .padding(.top, 8)
                            .padding(.bottom, CardGridUX.GridSpacing)
                            .environment(\.selectionCompletion) {
                                ClientLogger.shared.logCounter(
                                    .SelectTab,
                                    attributes: getLogCounterAttributesForTabs(
                                        tab: tabDetails.tab))
                                browserModel.hideGridWithAnimation(tabToBeSelected: tabDetails.tab)
                            }
                    case .sectionHeader(let byTime):
                        VStack {
                            Color.secondarySystemFill
                                .frame(height: 8)
                                .padding(.horizontal, -CardGridUX.GridSpacing)

                            HStack {
                                Text(byTime.rawValue)
                                    .withFont(.labelLarge)
                                    .foregroundColor(.label)
                                    .padding(.top, 12)
                                    .padding(.bottom, 8)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, CardGridUX.GridSpacing)
            .background(Color.background)
            .zIndex(row.cells.contains(where: \.isSelected) ? 1 : 0)
            .onDrop(of: ["public.url", "public.text"], delegate: tabModel)
        }
    }

    func lastRowTabGroup(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
    }
}
