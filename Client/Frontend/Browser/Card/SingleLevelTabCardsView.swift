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

enum TimeFilter: String, CaseIterable {
    case today = "Today"
    case lastWeek = "Last Week"
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
        timeLineCardsView(
            containerGeometry: containerGeometry, incognito: incognito)
    }

    func lastRowTabGroup(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
    }

    func isTopRow(_ rowIndex: Int?) -> Bool {
        if let rowIndex = rowIndex {
            return rowIndex == 1
        }
        return false
    }
}

struct timeLineCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject private var browserModel: BrowserModel
    @Environment(\.columns) private var columns
    @Environment(\.cardSize) private var cardSize
    @Environment(\.aspectRatio) private var aspectRatio

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    let containerGeometry: GeometryProxy
    let incognito: Bool
//    let time: String
    var body: some View {
        ForEach(
            tabModel.getRows(incognito: incognito)
        ) { row in
//            if let rowIndex = row.index, rowIndex == 1 {
//                VStack {
//                    Color.secondarySystemFill
//                        .frame(height: 8)
//                        .padding(.horizontal, -CardGridUX.GridSpacing)
//                    HStack {
//                        Text("Today")
//                            .withFont(.labelLarge)
//                            .foregroundColor(.label)
//                            .padding(.leading, 20)
//                            .padding(.top, 12)
//                            .padding(.bottom, 8)
//                        Spacer()
//                    }
//                }
//            }
                HStack(spacing: CardGridUX.GridSpacing) {
                    ForEach(row.cells) { details in
                        switch details {
                        case .tabGroupInline(let groupDetails):
                            CollapsedCardGroupView(
                                groupDetails: groupDetails, containerGeometry: containerGeometry,
                                rowIndex: row.index,
                                nextToCells: row.multipleCellTypes
                            )
                            .padding(.horizontal, -CardGridUX.GridSpacing)
                            .padding(.bottom, CardGridUX.GridSpacing)
                            .zIndex(groupDetails.allDetails.contains(where: \.isSelected) ? 1 : 0)
                        case .tabGroupGridRow(let groupDetails, let range):
                            ExpandedCardGroupRowView(
                                groupDetails: groupDetails, containerGeometry: containerGeometry,
                                range: range, rowIndex: row.index, nextToCells: false
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
                                .padding(.bottom, CardGridUX.GridSpacing)
                                .environment(\.selectionCompletion) {
                                    ClientLogger.shared.logCounter(
                                        .SelectTab,
                                        attributes: getLogCounterAttributesForTabs(
                                            selectedTabRow: row.index))
                                    browserModel.hideWithAnimation()
                                }
                        case .sectionHeader(let byTime):
                            VStack {
                                Color.secondarySystemFill
                                    .frame(height: 8)
                                    .padding(.horizontal, -CardGridUX.GridSpacing)
                                HStack {
                                    Text(byTime)
                                        .withFont(.labelLarge)
                                        .foregroundColor(.label)
                                        .padding(.leading, 20)
                                        .padding(.top, 12)
                                        .padding(.bottom, 8)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, CardGridUX.GridSpacing)
                .zIndex(row.cells.contains(where: \.isSelected) ? 1 : 0)
                .background(Color.background)
        }

    }

    func lastRowTabGroup(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
    }
    
    func isTopRow(_ rowIndex: Int?) -> Bool {
        if let rowIndex = rowIndex {
            return rowIndex == 1
        }
        return false
    }
}
