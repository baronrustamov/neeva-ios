// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SwitcherViews: String, CaseIterable {
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
                browserModel.hideWithAnimation()
            }
            .onAnimationCompleted(
                for: browserModel.showGrid,
                completion: browserModel.onCompletedCardTransition
            )
            .useEffect(deps: cardTransitionModel.state) { _ in
                // Ensure that the `Card` for the selected tab is visible. This way its
                // `CardTransitionModifier` will be visible and run the animation.
                if cardTransitionModel.state != .hidden {
                    if !tabModel.allDetails.isEmpty {
                        gridModel.scrollToSelectedTab()
                    }
                    // Allow some time for the `Card` to get created if it was previously
                    // not visible.
                    DispatchQueue.main.async {
                        if cardTransitionModel.state != .hidden {
                            withAnimation(CardTransitionUX.animation) {
                                let showGrid =
                                    (cardTransitionModel.state == .visibleForTrayShow)
                                if browserModel.showGrid != showGrid {
                                    browserModel.showGrid = showGrid
                                }
                            }
                        }
                    }
                }
            }
    }
}

struct CardGrid: View {
    @EnvironmentObject var tabCardModel: TabCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel
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

    @ViewBuilder
    var loadingIndicator: some View {
        ZStack {
            Color.TrayBackground
                .opacity(0.5)

            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(UIColor.DefaultBackground))
                .shadow(color: .black.opacity(0.1), radius: 12)
                .frame(width: 50, height: 50)

            ProgressView()
        }
    }

    func updateCardSize(width: CGFloat, topToolbar: Bool) {
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

            if gridModel.isLoading {
                loadingIndicator
                    .ignoresSafeArea()
            }

            NavigationLink(
                destination: detailedSpaceView,
                isActive: $gridModel.showingDetailView
            ) {}.useEffect(deps: spaceModel.detailedSpace) { detailedSpace in
                gridModel.showingDetailView = detailedSpace != nil
            }
        }.useEffect(
            deps: geom.size.width, topToolbar, perform: updateCardSize
        ).ignoresSafeArea(.keyboard)
    }
}

struct GridPicker: View {
    var isInToolbar = false

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel
    @EnvironmentObject var browserModel: BrowserModel

    @State var selectedIndex: Int = 1

    var segments: [Segment] {
        var segments = [
            Segment(
                symbol: Symbol(.incognito, weight: .medium, label: "Incognito Tabs"),
                selectedIconColor: .background,
                selectedColor: .label,
                selectedAction: { gridModel.switchToTabs(incognito: true) }),
            Segment(
                symbol: Symbol(.squareOnSquare, weight: .medium, label: "Normal Tabs"),
                selectedIconColor: .white,
                selectedColor: Color.ui.adaptive.blue,
                selectedAction: { gridModel.switchToTabs(incognito: false) }),
        ]
        if NeevaConstants.currentTarget != .xyz {
            segments.append(
                Segment(
                    symbol: Symbol(.bookmarkOnBookmark, label: "Spaces"),
                    selectedIconColor: .white, selectedColor: Color.ui.adaptive.blue,
                    selectedAction: gridModel.switchToSpaces
                ))
        }
        return segments
    }

    @ViewBuilder
    var picker: some View {
        HStack {
            Spacer()

            SegmentedPicker(
                segments: segments,
                selectedSegmentIndex: $selectedIndex, dragOffset: switcherToolbarModel.dragOffset
            )
            .useEffect(deps: gridModel.switcherState) { _ in
                switch gridModel.switcherState {
                case .tabs:
                    if switcherToolbarModel.dragOffset == nil {
                        selectedIndex = 1
                    }
                case .spaces:
                    if switcherToolbarModel.dragOffset == nil {
                        selectedIndex = 2
                    }

                    if incognitoModel.isIncognito {
                        gridModel.tabCardModel.manager.toggleIncognitoMode(
                            fromTabTray: true, openLazyTab: false)
                    }
                }
            }
            .useEffect(deps: incognitoModel.isIncognito) { isIncognito in
                if gridModel.switcherState == .tabs && switcherToolbarModel.dragOffset == nil {
                    selectedIndex = isIncognito ? 0 : 1
                }
            }

            Spacer()
        }
    }

    var body: some View {
        picker
            .frame(height: gridModel.pickerHeight)
            .background(
                (!isInToolbar
                    ? Color.background : Color.clear)
                    .ignoresSafeArea()
            )
            .opacity(browserModel.showGrid ? 1 : 0)
            .animation(.easeOut)
    }
}

struct SwipeToSwitchToSpacesGesture: ViewModifier {
    var fromPicker: Bool = false

    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel

    private var gesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                let horizontalAmount = value.translation.width as CGFloat

                // Divide by 2.5 to follow drag more accurately
                horizontalOffsetChanged(
                    fromPicker ? horizontalAmount : (-horizontalAmount / 2.5))
            })
            .onEnded { value in
                horizontalOffsetChanged(nil)
            }
    }

    private func horizontalOffsetChanged(_ offset: CGFloat?) {
        switcherToolbarModel.dragOffset = offset
    }

    func body(content: Content) -> some View {
        if fromPicker {
            content.simultaneousGesture(gesture)
        } else {
            content.gesture(gesture)
        }
    }
}
