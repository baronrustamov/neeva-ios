// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct ExpandedCardGroupRowView: View {
    @Environment(\.cardSize) private var size
    @Environment(\.columns) private var columns
    @EnvironmentObject var browserModel: BrowserModel
    @ObservedObject var groupDetails: TabGroupCardDetails

    let containerGeometry: GeometryProxy
    var range: Range<Int>
    let rowIndex: Int?
    let previousCell: TabCell?
    let nextCell: TabCell?
    var singleLined: Bool = false

    private let tabGroupPadding: CGFloat = 10
    private let tabPadding: CGFloat = 6

    var leadingPadding: CGFloat {
        guard let previousCell = previousCell else {
            return 0
        }

        return previousCell.isTabGroup ? tabGroupPadding : tabPadding
    }
    var trailingPadding: CGFloat {
        guard let nextCell = nextCell else {
            return 0
        }

        return nextCell.isTabGroup ? tabGroupPadding : tabPadding
    }

    var maxWidth: CGFloat {
        let numberOfCards = groupDetails.allDetails[range].count
        let widthForCards = size * numberOfCards
        let cardSpacing = CardGridUX.GridSpacing * (numberOfCards + 1)

        return widthForCards + cardSpacing + leadingPadding + trailingPadding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isFirstRow(range) {
                TabGroupHeader(
                    groupDetails: groupDetails, rowIndex: rowIndex
                ).if(previousCell != nil) {
                    $0.padding(.leading, tabPadding)
                }
            } else {
                HStack {
                    // Spacer to expand the width of the view
                    Spacer()
                }
            }

            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(Array(zip(range, groupDetails.allDetails[range])), id: \.1.id) {
                    index, childTabDetail in
                    FittedCard(details: childTabDetail)
                        .modifier(
                            CardTransitionModifier(
                                details: childTabDetail,
                                containerGeometry: containerGeometry)
                        )
                        .environment(\.selectionCompletion) {
                            ClientLogger.shared.logCounter(
                                .tabInTabGroupClicked,
                                attributes: getLogCounterAttributesForTabGroups(
                                    TabGroupRowIndex: rowIndex, selectedChildTabIndex: index + 1,
                                    expanded: true, numTabs: groupDetails.allDetails.count))
                            browserModel.hideGridWithAnimation(tabToBeSelected: childTabDetail.tab)
                        }
                }

                if isLastRowSingleTab(range, groupDetails) {
                    Spacer()
                }
            }
            .zIndex(groupDetails.allDetails[range].contains(where: \.isSelected) ? 1 : 0)
            .padding(
                .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
            )
            .padding(.leading, CardGridUX.GridSpacing)
            .padding(.top, CardUX.ShadowRadius)
        }
        .background(
            Color.secondarySystemFill
                .cornerRadius(
                    isFirstRow(range) ? 24 : 0,
                    corners: .top
                )
                .cornerRadius(
                    isLastRow(range, groupDetails) ? 24 : 0,
                    corners: .bottom
                )
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
        )
        .if(nextCell != nil || groupDetails.allDetails.count < columns.count) {
            $0.frame(maxWidth: maxWidth)
        }
        .animation(nil)
        .transition(.fade)
        .onDrop(of: ["public.url", "public.text"], delegate: groupDetails)
    }

    func isLastRow(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
    }

    func isLastRowSingleTab(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
            && groupDetails.allDetails.count % 2 == 1
    }

    func isFirstRow(_ rowInfo: Range<Int>) -> Bool {
        return rowInfo.first == 0
    }

    init(
        groupDetails: TabGroupCardDetails, containerGeometry: GeometryProxy, range: Range<Int>,
        rowIndex: Int?, previousCell: TabCell?, nextCell: TabCell?, singleLined: Bool = false
    ) {
        self.groupDetails = groupDetails
        self.containerGeometry = containerGeometry
        self.range = range
        self.rowIndex = rowIndex
        self.previousCell = previousCell
        self.nextCell = nextCell
        self.singleLined = singleLined
    }

    init(
        groupDetails: TabGroupCardDetails, containerGeometry: GeometryProxy, range: Range<Int>,
        row: Row, cellIndex: Int, singleLined: Bool = false
    ) {
        self.groupDetails = groupDetails
        self.containerGeometry = containerGeometry
        self.range = range
        self.rowIndex = row.index
        self.previousCell = row.cells.previousItem(before: cellIndex)
        self.nextCell = row.cells.nextItem(after: cellIndex)
        self.singleLined = singleLined
    }
}
