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
        if let row = rows.first(where: { row in
            row.cells.contains(where: \.isSelected)
        }) {
            if row.index == 1 {
                return rows[0].id
            }

            return row.id
        }

        return nil
    }

    var body: some View {
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

struct CardsContainer: View {
    @Default(.seenSpacesIntro) var seenSpacesIntro: Bool

    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridSwitcherModel: GridSwitcherModel
    @EnvironmentObject var gridVisibilityModel: GridVisibilityModel
    @EnvironmentObject var incognitoModel: IncognitoModel

    // Used to rebuild the scene when switching between portrait and landscape.
    @State var orientation: UIDeviceOrientation = .unknown
    @State var generationId: Int = 0
    @State var containerGeom: CGSize = CGSize.zero

    let columns: [GridItem]

    var body: some View {
        GeometryReader { geom in
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
                    .useEffect(deps: gridVisibilityModel.showGrid) { _ in
                        scrollProxy.scrollTo(
                            browserModel.gridModel.spaceCardModel.allDetails.first?.id ?? ""
                        )
                    }
                }
                .offset(x: (gridSwitcherModel.state == .spaces ? 0 : geom.widthIncludingSafeArea))
                .animation(
                    gridSwitcherModel.switchModeWithoutAnimation ? nil : .interactiveSpring()
                )
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
                .animation(
                    gridSwitcherModel.switchModeWithoutAnimation ? nil : .interactiveSpring()
                )
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
                .animation(
                    gridSwitcherModel.switchModeWithoutAnimation ? nil : .interactiveSpring()
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Incognito Tabs")
                .accessibilityValue(Text("\(tabModel.manager.incognitoTabs.count) tabs"))
            }
            .useEffect(deps: geom.size) { newValue in
                containerGeom = newValue
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
