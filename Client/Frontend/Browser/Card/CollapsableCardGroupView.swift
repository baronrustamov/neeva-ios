// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CollapsedCardGroupView: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    let containerGeometry: GeometryProxy

    @Environment(\.aspectRatio) private var aspectRatio
    @Environment(\.cardSize) private var size
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel
    @EnvironmentObject private var gridModel: GridModel

    @State private var frame = CGRect.zero

    var body: some View {
        VStack(spacing: 0) {
            TabGroupHeader(groupDetails: groupDetails)
            scrollView
        }
        .animation(nil)
        .transition(.fade)
        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
        .background(
            Color.secondarySystemFill
                .cornerRadius(
                    24,
                    corners: groupDetails.allDetails.count <= 2 || groupDetails.isExpanded
                        ? .all : .leading
                )
        )
    }

    @ViewBuilder
    private var scrollView: some View {
        // ScrollView clips child views by default, so here ScrollView is resized
        // to make CardTransitionModifier visible. TopSpace and BottomSpace are
        // paddings needed to make ScrollView look in place when it's resized.
        let topSpace =
            browserModel.cardTransition == .hidden
            ? 0 : self.frame.minY - containerGeometry.frame(in: .global).minY
        let bottomSpace =
            browserModel.cardTransition == .hidden
            ? 0 : containerGeometry.frame(in: .global).maxY - self.frame.maxY

        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(
                    spacing: SingleLevelTabCardsViewUX.TabGroupCarouselTabSpacing
                ) {
                    ForEach(groupDetails.allDetails) { childTabDetail in
                        FittedCard(details: childTabDetail, dragToClose: false)
                            .modifier(
                                CardTransitionModifier(
                                    details: childTabDetail,
                                    containerGeometry: containerGeometry)
                            )
                            .id(childTabDetail.id)
                    }
                }
                .padding(.leading, CardGridUX.GridSpacing)
                .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
                .padding(
                    .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                )
                .background(
                    GeometryReader { geom in
                        Color.clear.useEffect(deps: geom.frame(in: .global)) { frame in
                            self.frame = frame
                        }
                    }
                )
                .padding(.top, topSpace)
                .padding(.bottom, bottomSpace)

            }
            .padding(.top, -topSpace)
            .padding(.bottom, -bottomSpace)
            .useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
                if groupDetails.allDetails.contains(where: \.isSelected) {
                    withAnimation(nil) {
                        scrollProxy.scrollTo(groupDetails.allDetails.first(where: \.isSelected)?.id)
                    }
                }
            }
        }
    }
}

struct ExpandedCardGroupRowView: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    let containerGeometry: GeometryProxy
    var range: Range<Int>

    @Environment(\.aspectRatio) private var aspectRatio
    @Environment(\.cardSize) private var size
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel

    var body: some View {
        VStack(spacing: 0) {
            if isFirstRow(range) {
                TabGroupHeader(groupDetails: groupDetails)
            } else {
                HStack {
                    // Spacer to expand the width of the view
                    Spacer()
                }
            }
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(groupDetails.allDetails[range]) { childTabDetail in
                    FittedCard(details: childTabDetail, dragToClose: false)
                        .modifier(
                            CardTransitionModifier(
                                details: childTabDetail,
                                containerGeometry: containerGeometry)
                        )
                }
                .padding(
                    .leading, isLastRowSingleTab(range, groupDetails) ? CardGridUX.GridSpacing : 0)
                if isLastRowSingleTab(range, groupDetails) {
                    Spacer()
                }
            }
            .zIndex(groupDetails.allDetails[range].contains(where: \.isSelected) ? 1 : 0)
            .padding(
                .top,
                isFirstRow(range) ? SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing : 0
            )
            .padding(
                .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
            )
        }
        .animation(nil)
        .transition(.fade)
        .padding(.top, isFirstRow(range) ? SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding : 0)
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
        )
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
}

struct TabGroupHeader: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel

    var groupFromSpace: Bool {
        return groupDetails.id
            == tabGroupCardModel.manager.get(for: groupDetails.id)?.children.first?.parentSpaceID
    }

    var body: some View {
        HStack {
            Symbol(decorative: groupFromSpace ? .bookmarkFill : .squareGrid2x2Fill)
                .foregroundColor(.label)
            Text(groupDetails.title)
                .withFont(.labelLarge)
                .foregroundColor(.label)
            Spacer()
            Button {
                groupDetails.isExpanded.toggle()
            } label: {
                Label("caret", systemImage: "chevron.up")
                    .foregroundColor(.label)
                    .labelStyle(.iconOnly)
                    .rotationEffect(
                        .degrees(groupDetails.isExpanded ? -180 : 0)
                    )
                    .padding()
            }.accessibilityHidden(true)
        }
        .padding(.leading, CardGridUX.GridSpacing)
        .frame(height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tab Group, \(groupDetails.title)")
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityValue(groupDetails.isShowingDetails ? "Expanded" : "Collapsed")
        .accessibilityAction {
            groupDetails.isShowingDetails.toggle()
        }
    }

}
