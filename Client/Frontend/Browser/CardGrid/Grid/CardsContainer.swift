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

    @EnvironmentObject private var tabModel: TabCardModel
    @EnvironmentObject private var gridModel: GridModel
    @Environment(\.safeArea) private var safeArea

    @State var cardStackGeom: CGSize = CGSize.zero

    var selectedRowId: TabCardModel.Row.ID? {
        let rows = tabModel.getRows(for: .all, incognito: isIncognito)
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
        Group {
            LazyVStack(alignment: .leading, spacing: 0) {
                // When there aren't enough tabs to make the scroll view scrollable, we build a VStack
                // with spacer to pin ArchivedTabsView at the bottom of the scrollView.
                TabGridCardView(containerGeometry: geom)
            }.background(
                GeometryReader { proxy in
                    Color.clear
                        .useEffect(deps: proxy.size) { newValue in
                            cardStackGeom = newValue
                        }
                }
            )
        }
        .frame(
            minHeight:
                geom.size.height - UIConstants.ArchivedTabsViewHeight - CardGridUX.GridSpacing,
            maxHeight: .infinity,
            alignment: .top
        )
        .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
        .useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
            if let selectedRowId = selectedRowId {
                withAnimation(nil) {
                    scrollProxy.scrollTo(selectedRowId)
                }
                DispatchQueue.main.async { gridModel.didVerticalScroll += 1 }
            }
        }.if(tabModel.isSearchingForTabs) {
            $0.padding(.bottom, safeArea.bottom + FindInPageViewUX.height)
        }.animation(nil)
    }
}

struct CardScrollContainer<Content: View>: View {
    let columns: [GridItem]
    @ViewBuilder var content: (ScrollViewProxy) -> Content

    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel
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
            (gridModel.gridCanAnimate
                ? .interactiveSpring() : tabModel.tabsDidChange ? .default : nil)
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
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var chromeModel: TabChromeModel

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
                        SpaceCardsView(spacesModel: spacesModel)
                            .environment(\.columns, columns)
                        if !NeevaUserInfo.shared.isUserLoggedIn {
                            SpacesIntroOverlayContent()
                        }
                    }
                    .padding(.vertical, CardGridUX.GridSpacing)
                    .useEffect(deps: browserModel.showGrid) { _ in
                        scrollProxy.scrollTo(
                            spacesModel.allDetails.first?.id ?? ""
                        )
                    }
                }
                .offset(x: (gridModel.switcherState == .spaces ? 0 : geom.widthIncludingSafeArea))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Spaces")
                .accessibilityHidden(gridModel.switcherState != .spaces)

                // Normal Tabs
                ZStack {
                    if !tabModel.isSearchingForTabs {
                        EmptyCardGrid(
                            isIncognito: false,
                            isTopBar: chromeModel.inlineToolbar,
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
                                gridModel.switcherState != .tabs || incognitoModel.isIncognito)

                            OpenArchivedTabsPanelButton(containerGeometry: geom.size)
                        }.onAppear {
                            gridModel.scrollToSelectedTab()
                        }
                    }
                }.offset(
                    x: (gridModel.switcherState == .tabs
                        ? (incognitoModel.isIncognito ? geom.widthIncludingSafeArea : 0)
                        : -geom.widthIncludingSafeArea)
                )
                .animation(gridModel.switchModeWithoutAnimation ? nil : .interactiveSpring())
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Tabs")
                .accessibilityValue(Text("\(tabModel.manager.activeNormalTabs.count) tabs"))

                // Incognito Tabs
                ZStack {
                    if !tabModel.isSearchingForTabs {
                        EmptyCardGrid(
                            isIncognito: true,
                            isTopBar: chromeModel.inlineToolbar,
                            showArchivedTabsView: false
                        ).opacity(tabModel.incognitoDetails.isEmpty ? 1 : 0)
                    }

                    CardScrollContainer(columns: columns) { scrollProxy in
                        TabGridContainer(isIncognito: true, geom: geom, scrollProxy: scrollProxy)
                            .accessibilityHidden(
                                gridModel.switcherState != .tabs || !incognitoModel.isIncognito)
                    }.onAppear {
                        gridModel.scrollToSelectedTab()
                    }
                }
                .offset(
                    x: (gridModel.switcherState == .tabs
                        ? (incognitoModel.isIncognito ? 0 : -geom.widthIncludingSafeArea)
                        : -geom.widthIncludingSafeArea)
                )
                .animation(gridModel.switchModeWithoutAnimation ? nil : .interactiveSpring())
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
