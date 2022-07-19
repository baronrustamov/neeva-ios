// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SwitcherView: String, CaseIterable {
    case tabs = "Tabs"
    case spaces = "Spaces"
}

enum CardGridUX {
    static let PickerPadding: CGFloat = 20
    static let GridSpacing: CGFloat = 20
}

// Isolating dependency on CardTransitionModel to this sub-view for performance
// reasons.
struct CardGridBackground: View {
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var cardTransitionModel: CardTransitionModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel

    var color: some View {
        cardTransitionModel.state == .hidden
            ? Color.TrayBackground : Color.clear
    }

    var body: some View {
        color
            .accessibilityAction(.escape) {
                browserModel.hideGridWithAnimation()
            }
            .onAnimationCompleted(
                for: browserModel.showGrid,
                completion: browserModel.onCompletedCardTransition
            )
            .useEffect(deps: cardTransitionModel.state) { state in
                if state != .hidden {
                    let showGrid = (state == .visibleForTrayShow)
                    if browserModel.showGrid != showGrid {
                        withAnimation(CardTransitionUX.animation) {
                            browserModel.showGrid = showGrid
                        }
                    }
                }
            }
    }
}

struct CardGrid: View {
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var tabCardModel: TabCardModel
    @EnvironmentObject var toastViewManager: ToastViewManager
    @EnvironmentObject var walletDetailsModel: WalletDetailsModel

    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    @Environment(\.shareURL) var shareURL
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var detailDragOffset: CGFloat = 0
    @State private var cardSize: CGFloat = CardUX.DefaultCardSize

    var geom: GeometryProxy

    var topToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var columns: [GridItem] {
        return Array(
            repeating:
                GridItem(
                    .fixed(cardSize),
                    spacing: CardGridUX.GridSpacing, alignment: .leading),
            count: tabCardModel.columnCount)
    }

    var cardContainerBackground: some View {
        Color.background.ignoresSafeArea()
    }

    @ViewBuilder
    var detailedSpaceView: some View {
        if let detailedSpace = spaceModel.detailedSpace {
            SpaceContainerView(primitive: detailedSpace)
                .environment(\.onOpenURLForSpace, onOpenURLForSpace)
                .environment(\.shareURL, shareURL)
                .environment(\.columns, columns)
        }
    }

    @ViewBuilder
    var cardContainer: some View {
        VStack(spacing: 0) {
            CardsContainer(
                columns: columns
            )
            .environment(\.cardSize, cardSize)
            Spacer(minLength: 0)
        }
        .background(cardContainerBackground)
    }

    func updateCardSize(width: CGFloat, topToolbar: Bool) {
        guard gridModel.canResizeGrid else {
            return
        }

        var columnCount = tabCardModel.columnCount

        if width > 1000 {
            columnCount = 4
        } else {
            columnCount = topToolbar ? 3 : 2
        }

        if tabCardModel.columnCount != columnCount {
            tabCardModel.columnCount = columnCount
        }

        self.cardSize =
            (width - (tabCardModel.columnCount + 1) * CardGridUX.GridSpacing)
            / tabCardModel.columnCount
    }

    var body: some View {
        ZStack {
            cardContainer
                .offset(
                    x: (!walletDetailsModel.showingWalletDetails)
                        ? 0 : -(geom.size.width - detailDragOffset) / 5, y: 0
                )
                .background(CardGridBackground())
                .modifier(SwipeToSwitchToSpacesGesture())
            NavigationLink(
                destination: detailedSpaceView,
                isActive: $gridModel.showingDetailView
            ) {}.useEffect(deps: spaceModel.detailedSpace) { detailedSpace in
                gridModel.showingDetailView = detailedSpace != nil
            }
        }.useEffect(
            deps: geom.size.width, topToolbar, perform: updateCardSize
        ).useEffect(deps: gridModel.canResizeGrid) { _ in
            updateCardSize(width: geom.size.width, topToolbar: topToolbar)
        }.ignoresSafeArea(.keyboard)
    }
}
