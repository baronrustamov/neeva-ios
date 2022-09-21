// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

extension EnvironmentValues {
    private struct ColumnsKey: EnvironmentKey {
        static var defaultValue: [GridItem] = Array(
            repeating:
                GridItem(
                    .fixed(CardUX.DefaultCardSize),
                    spacing: CardGridUX.GridSpacing),
            count: 2)
    }

    public var columns: [GridItem] {
        get { self[ColumnsKey.self] }
        set { self[ColumnsKey.self] = newValue }
    }

}

struct ScrollToFirstSpaceModifier: ViewModifier {
    let scrollProxy: ScrollViewProxy

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridVisibilityModel: GridVisibilityModel

    func body(content: Content) -> some View {
        content.useEffect(deps: gridVisibilityModel.showGrid) { _ in
            if let details = browserModel.gridModel.spaceCardModel.viewModel.dataSource.first {
                scrollProxy.scrollTo(details.id)
            }
        }
    }
}

struct TabGridContainer: View {
    let isIncognito: Bool
    let geom: GeometryProxy
    let scrollProxy: ScrollViewProxy

    @EnvironmentObject private var browserModel: BrowserModel
    @EnvironmentObject private var tabModel: TabCardModel
    @Environment(\.safeArea) private var safeArea

    @State var rows: [Row] = []

    var gridScrollModel: GridScrollModel {
        browserModel.gridModel.scrollModel
    }

    var selectedRowId: TabCardModel.Row.ID? {
        var previous: Row!
        for row in rows {
            if row.cells.contains(where: \.isSelected) {
                // If we are selecting the first row of cards in the tab section, then
                // select the header instead (i.e., the previous row). This way the header
                // will be visible too. Do this only if there is a section header, which
                // may not always be the case (e.g., incognito mode).
                if row.index == 1 && previous.isSectionHeader {
                    return previous.id
                }
                return row.id
            }
            previous = row
        }
        return nil
    }

    var body: some View {
        let _ = debugCount("TabGridContainer.body")
        LazyVStack(alignment: .leading, spacing: 0) {
            TabGridRowsView(
                containerGeometry: geom,
                rows: rows
            )
        }
        .padding(.horizontal, CardGridUX.GridSpacing)
        .background(Color.background)
        .onDrop(of: ["public.url", "public.text"], delegate: tabModel)
        .frame(
            minHeight:
                geom.size.height - UIConstants.ArchivedTabsViewHeight - CardGridUX.GridSpacing,
            maxHeight: .infinity,
            alignment: .top
        )
        .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
        // NOTE: Observing just this specific published var and not all of GridScrollModel
        // to avoid spurious updates.
        .useEffect(gridScrollModel.$needsScrollToSelectedTab) {
            scrollToSelectedRowId()
        }
        .useEffect(deps: tabModel.rowsUpdated) { _ in
            self.rows = tabModel.getRowSectionsNeeded(incognito: isIncognito).flatMap {
                tabModel.getRows(for: $0, incognito: isIncognito)
            }
        }
        .if(tabModel.isSearchingForTabs) {
            $0.padding(.bottom, safeArea.bottom + FindInPageViewUX.height)
        }
    }

    func scrollToSelectedRowId() {
        if let selectedRowId = selectedRowId {
            withAnimation(nil) {
                scrollProxy.scrollTo(selectedRowId)
            }
            DispatchQueue.main.async { gridScrollModel.didVerticalScroll += 1 }
        }
    }
}

struct CardScrollContainer<Content: View>: View {
    let columns: [GridItem]
    @ViewBuilder var content: (ScrollViewProxy) -> Content

    @EnvironmentObject var gridSwitcherModel: GridSwitcherModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var browserModel: BrowserModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader(content: content)
        }
        // Fixes two animation bugs:
        // 1. scrollView would stutter at the edge without making the animation nil
        // 2. scrollView wouldn't push down when the bottom tab is closed if the
        // animation is nil
        .animation(
            (gridSwitcherModel.gridCanAnimate || tabModel.tabsDidChange
                ? .interactiveSpring() : nil)
        )
        .accessibilityIdentifier("CardGrid")
        .environment(\.columns, columns)
        .introspectScrollView { scrollView in
            // This is to make sure the overlay card bleeds outside the horizontal and bottom
            // area in landscape mode. Clipping should be kept in portrait mode because
            // bottom tool bar needs to be shown.
            if landscapeMode {
                scrollView.clipsToBounds = false
            }
            // Disable bounce on iOS 14 due to stuttering bug with ScrollView
            guard #available(iOS 15, *) else {
                scrollView.bounces = false
                return
            }

            scrollView.isScrollEnabled =
                (browserModel.cardTransitionModel.state != .visibleForTrayHidden)
        }
    }
}

// This modifier exists to isolate the dependency on `switchWithAnimation`.
struct CardsContainerOffsetAnimationModifier: ViewModifier {
    @EnvironmentObject var gridSwitcherAnimationModel: GridSwitcherAnimationModel

    func body(content: Content) -> some View {
        content
            .animation(
                gridSwitcherAnimationModel.switchWithAnimation ? .interactiveSpring() : nil
            )
    }
}

struct CardsContainer: View {
    @Default(.seenSpacesIntro) var seenSpacesIntro: Bool

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridSwitcherModel: GridSwitcherModel
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var tabModel: TabCardModel

    // Used to rebuild the scene when switching between portrait and landscape.
    @State var orientation: UIDeviceOrientation = .unknown
    @State var generationId: Int = 0

    let columns: [GridItem]

    var body: some View {
        let _ = debugCount("CardsContainer.body")
        GeometryReader { geom in
            let _ = debugCount("CardsContainer geom \(geom.size) \(geom.safeAreaInsets)")
            ZStack {
                // Spaces
                CardScrollContainer(columns: columns) { scrollProxy in
                    VStack(alignment: .leading) {
                        SpaceCardsView(spacesModel: browserModel.gridModel.spaceCardModel)
                            .environment(\.columns, columns)
                        if !NeevaUserInfo.shared.isUserLoggedIn {
                            SpacesIntroOverlayContent()
                        }
                    }
                    .padding(.vertical, CardGridUX.GridSpacing)
                    .modifier(ScrollToFirstSpaceModifier(scrollProxy: scrollProxy))
                }
                .offset(x: (gridSwitcherModel.state == .spaces ? 0 : geom.widthIncludingSafeArea))
                .modifier(CardsContainerOffsetAnimationModifier())
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Spaces")
                .accessibilityHidden(gridSwitcherModel.state != .spaces)

                // Normal Tabs
                ZStack {
                    if !tabModel.isSearchingForTabs {
                        EmptyCardGrid(
                            isIncognito: false,
                            showArchivedTabsView:
                                tabModel.manager.activeNormalTabs.isEmpty
                        ).opacity(tabModel.normalDetails.isEmpty ? 1 : 0)
                    }

                    if !tabModel.manager.activeNormalTabs.isEmpty {
                        CardScrollContainer(columns: columns) { scrollProxy in
                            TabGridContainer(
                                isIncognito: false,
                                geom: geom,
                                scrollProxy: scrollProxy
                            )
                            .zIndex(1)
                            .accessibilityHidden(
                                gridSwitcherModel.state != .tabs || incognitoModel.isIncognito)

                            OpenArchivedTabsPanelButton(containerGeometry: geom.size)
                        }.onAppear {
                            browserModel.gridModel.scrollModel.scrollToSelectedTab()
                        }
                    }
                }.offset(
                    x: (gridSwitcherModel.state == .tabs
                        ? (incognitoModel.isIncognito ? geom.widthIncludingSafeArea : 0)
                        : -geom.widthIncludingSafeArea)
                )
                .modifier(CardsContainerOffsetAnimationModifier())
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Tabs")
                .accessibilityValue(Text("\(tabModel.manager.activeNormalTabs.count) tabs"))

                // Incognito Tabs
                ZStack {
                    if !tabModel.isSearchingForTabs {
                        EmptyCardGrid(
                            isIncognito: true,
                            showArchivedTabsView: false
                        ).opacity(tabModel.incognitoDetails.isEmpty ? 1 : 0)
                    }

                    CardScrollContainer(columns: columns) { scrollProxy in
                        TabGridContainer(isIncognito: true, geom: geom, scrollProxy: scrollProxy)
                            .accessibilityHidden(
                                gridSwitcherModel.state != .tabs || !incognitoModel.isIncognito)
                    }.onAppear {
                        browserModel.gridModel.scrollModel.scrollToSelectedTab()
                    }
                }
                .offset(
                    x: (gridSwitcherModel.state == .tabs
                        ? (incognitoModel.isIncognito ? 0 : -geom.widthIncludingSafeArea)
                        : -geom.widthIncludingSafeArea)
                )
                .modifier(CardsContainerOffsetAnimationModifier())
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Incognito Tabs")
                .accessibilityValue(Text("\(tabModel.manager.incognitoTabs.count) tabs"))
            }
        }
        .id(generationId)
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        ) { _ in
            if self.orientation.isLandscape != UIDevice.current.orientation.isLandscape {
                generationId += 1
            }
            self.orientation = UIDevice.current.orientation
        }
    }
}

func getLogCounterAttributesForTabs(tab: Tab) -> [ClientLogCounterAttribute] {
    var lastExecutedTime = ""

    for time in TabSection.allCases {
        if tab.isIncluded(in: time) {
            lastExecutedTime = time.rawValue
            break
        }
    }

    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.TabsAttribute.selectedTabSection,
            value: lastExecutedTime))
    return attributes
}
