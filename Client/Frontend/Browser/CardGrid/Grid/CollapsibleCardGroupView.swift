// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Shared
import SwiftUI

typealias Row = TabCardModel.Row
typealias TabCell = TabCardModel.Row.Cell

struct CollapsedCardGroupView: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    let containerGeometry: GeometryProxy
    let rowIndex: Int?
    let previousCell: TabCell?
    let nextCell: TabCell?

    @EnvironmentObject var browserModel: BrowserModel

    var gridScrollModel: GridScrollModel {
        browserModel.gridModel.scrollModel
    }

    @State private var isFirstVisible = true
    @State private var isLastVisible = false

    var cornersToRound: CornerSet {
        if groupDetails.allDetails.count <= 2 || groupDetails.isExpanded
            || (isFirstVisible && isLastVisible)
        {
            return .all
        }

        if isFirstVisible {
            return .leading
        }

        if isLastVisible {
            return .trailing
        }

        return .all
    }

    var body: some View {
        VStack(spacing: 0) {
            TabGroupHeader(groupDetails: groupDetails, rowIndex: rowIndex)
            scrollView
        }
        .animation(nil)
        .transition(.fade)
        .background(
            Color.secondarySystemFill
                .cornerRadius(24, corners: cornersToRound)
        ).onDrop(of: ["public.url", "public.text"], delegate: groupDetails)
    }

    @ViewBuilder
    private var scrollView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(
                    spacing: SingleLevelTabCardsViewUX.TabGroupCarouselTabSpacing
                ) {
                    ForEach(Array(groupDetails.allDetails.enumerated()), id: \.1.id) {
                        index, childTabDetail in

                        FittedCard(details: childTabDetail, dragToClose: false)
                            .modifier(
                                CardTransitionModifier(
                                    details: childTabDetail,
                                    containerGeometry: containerGeometry)
                            )
                            .id(childTabDetail.id)
                            .environment(\.selectionCompletion) {
                                ClientLogger.shared.logCounter(
                                    .tabInTabGroupClicked,
                                    attributes: getLogCounterAttributesForTabGroups(
                                        TabGroupRowIndex: rowIndex, selectedChildTabIndex: index,
                                        expanded: false, numTabs: groupDetails.allDetails.count))
                                browserModel.hideGridWithAnimation(
                                    tabToBeSelected: childTabDetail.tab)
                            }.visibleStateChanged { isVisible in
                                let isFirst = index == 0
                                let isLast = index == groupDetails.allDetails.count - 1

                                withAnimation {
                                    if isFirst {
                                        isFirstVisible = isVisible
                                    }

                                    if isLast {
                                        isLastVisible = isVisible
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, CardGridUX.GridSpacing)
                .padding(
                    .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                )
                // fix a bug where the shadow at the top of cards getting clipped
                .padding(.top, CardUX.ShadowRadius)
                // prevent ScrollViewReader from filling up the whole parent view when minHeight
                // in TabGridContainer is set to pin ArchivedTabsView at the bottom.
                .fixedSize()
            }
            // NOTE: Observing just this specific published var and not all of GridScrollModel
            // to avoid spurious updates.
            .useEffect(gridScrollModel.$needsScrollToSelectedTab) {
                scrollToSelectedCard(scrollProxy: scrollProxy)
            }
            .introspectScrollView { scrollView in
                // Hack: trigger SwiftUI to run this code each time an instance of this View type is
                // instantiated. This works by referencing an input parameter (groupDetails), which causes
                // SwiftUI to think that this ViewModifier needs to be evaluated again.
                _ = groupDetails

                // Fixes a bug where the Card would get clipped during opening/closing animation.
                scrollView.clipsToBounds = browserModel.cardTransitionModel.state == .hidden
            }
        }
    }

    init(
        groupDetails: TabGroupCardDetails, containerGeometry: GeometryProxy, row: Row,
        cellIndex: Int
    ) {
        self.groupDetails = groupDetails
        self.containerGeometry = containerGeometry
        self.rowIndex = row.index
        self.previousCell = row.cells.previousItem(before: cellIndex)
        self.nextCell = row.cells.nextItem(after: cellIndex)
    }

    func scrollToSelectedCard(scrollProxy: ScrollViewProxy) {
        if groupDetails.allDetails.contains(where: \.isSelected) {
            withAnimation(nil) {
                scrollProxy.scrollTo(
                    groupDetails.allDetails.first(where: \.isSelected)?.id)
            }
            DispatchQueue.main.async { gridScrollModel.didHorizontalScroll += 1 }
        }
    }
}

func getLogCounterAttributesForTabGroups(
    TabGroupRowIndex: Int?, selectedChildTabIndex: Int?, expanded: Bool?, numTabs: Int
) -> [ClientLogCounterAttribute] {
    var attributes = EnvironmentHelper.shared.getAttributes()

    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.TabGroupAttribute.TabGroupRowIndex, value: String(TabGroupRowIndex ?? -1)
        )
    )

    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.TabGroupAttribute.selectedChildTabIndex,
            value: String(selectedChildTabIndex ?? -1)

        )
    )

    if let expanded = expanded {
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.TabGroupAttribute.isExpanded, value: String(expanded))
        )
    }

    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.TabGroupAttribute.numTabsInTabGroup, value: String(numTabs))
    )

    return attributes
}
