// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Defaults
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

    @Environment(\.columns) private var columns
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject private var gridModel: GridModel

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
        if groupDetails.allDetails.count <= columns.count {
            // Don't make it a scroll view if the tab group can't be expanded
            ExpandedCardGroupRowView(
                groupDetails: groupDetails, containerGeometry: containerGeometry,
                range: 0..<groupDetails.allDetails.count, rowIndex: rowIndex,
                previousCell: previousCell, nextCell: nextCell, singleLined: true
            )
        } else {
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
            .useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
                if groupDetails.allDetails.contains(where: \.isSelected) {
                    withAnimation(nil) {
                        scrollProxy.scrollTo(
                            groupDetails.allDetails.first(where: \.isSelected)?.id)
                    }
                    DispatchQueue.main.async { gridModel.didHorizontalScroll += 1 }
                }
            }
            .introspectScrollView { scrollView in
                // Hack: trigger SwiftUI to run this code each time an instance of this View type is
                // instantiated. This works by referencing an input parameter (groupDetails), which causes
                // SwiftUI to think that this ViewModifier needs to be evaluated again.
                let _ = groupDetails

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
}

struct ExpandedCardGroupRowView: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    let containerGeometry: GeometryProxy
    var range: Range<Int>
    let rowIndex: Int?
    let previousCell: TabCell?
    let nextCell: TabCell?
    var singleLined: Bool = false

    @Environment(\.cardSize) private var size
    @EnvironmentObject var browserModel: BrowserModel

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
        .animation(nil)
        .transition(.fade)
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
        ).if(previousCell != nil || nextCell != nil || singleLined) {
            $0.frame(maxWidth: maxWidth)
        }.onDrop(of: ["public.url", "public.text"], delegate: groupDetails)
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

struct TabGroupHeader: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    @Environment(\.columns) private var columns
    let rowIndex: Int?

    var body: some View {
        HStack {
            Menu {
                groupDetails.contextMenu()
            } label: {
                Label("ellipsis", systemImage: "ellipsis")
                    .foregroundColor(.label)
                    .labelStyle(.iconOnly)
                    .frame(height: 44)
            }

            Text(groupDetails.title)
                .withFont(.labelLarge)
                .foregroundColor(.label)
                .accessibility(identifier: "TabGroupTitle")
                .accessibility(value: Text(groupDetails.title))

            Spacer()

            if groupDetails.allDetails.count > columns.count {
                Button {
                    if groupDetails.isExpanded {
                        ClientLogger.shared.logCounter(
                            .tabGroupCollapsed,
                            attributes: getLogCounterAttributesForTabGroups(
                                TabGroupRowIndex: rowIndex, selectedChildTabIndex: nil,
                                expanded: nil, numTabs: groupDetails.allDetails.count))
                    } else {
                        ClientLogger.shared.logCounter(
                            .tabGroupExpanded,
                            attributes: getLogCounterAttributesForTabGroups(
                                TabGroupRowIndex: rowIndex, selectedChildTabIndex: nil,
                                expanded: nil, numTabs: groupDetails.allDetails.count))
                    }
                    groupDetails.isExpanded.toggle()
                } label: {
                    Label(
                        "arrows",
                        systemImage: groupDetails.isExpanded
                            ? "arrow.down.right.and.arrow.up.left"
                            : "arrow.up.left.and.arrow.down.right"
                    )
                    .foregroundColor(.label)
                    .labelStyle(.iconOnly)
                    .padding()
                }.accessibilityHidden(true)
            }
        }
        .padding(.leading, CardGridUX.GridSpacing)
        .frame(height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
        // the top and bottom paddings applied below are to make the tap target
        // of the context menu taller
        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
        .padding(.bottom, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tab Group, \(groupDetails.title)")
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityValue(groupDetails.isShowingDetails ? "Expanded" : "Collapsed")
        .accessibilityAction {
            groupDetails.isShowingDetails.toggle()
        }
        .contentShape(Rectangle())
        .contextMenu(menuItems: groupDetails.contextMenu)
        .textFieldAlert(
            isPresented: $groupDetails.renaming, title: "Rename “\(groupDetails.title)”",
            required: false
        ) { newName in
            if newName.isEmpty {
                groupDetails.customTitle = nil
            } else {
                groupDetails.customTitle = newName
            }
        } configureTextField: { tf in
            tf.clearButtonMode = .always
            tf.placeholder = groupDetails.defaultTitle ?? ""
            tf.text = groupDetails.customTitle
            tf.autocapitalizationType = .words
        }
        .actionSheet(isPresented: $groupDetails.deleting) {
            let buttons: [ActionSheet.Button] = [
                .destructive(Text("Close All")) {
                    groupDetails.onClose(showToast: false)
                },
                .cancel(),
            ]

            if let title = groupDetails.customTitle {
                return ActionSheet(
                    title: Text("Close all \(groupDetails.allDetails.count) tabs from “\(title)”?"),
                    buttons: buttons)
            } else {
                return ActionSheet(
                    title: Text("Close these \(groupDetails.allDetails.count) tabs?"),
                    buttons: buttons)
            }
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
