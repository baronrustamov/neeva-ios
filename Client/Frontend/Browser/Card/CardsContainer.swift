// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    @Environment(\.columns) private var columns

    var selectedRowId: TabCardModel.Row.ID? {
        isIncognito
            ? tabModel.incognitoRows.first { $0.cells.contains(where: \.isSelected) }?.id
            : tabModel.normalRows.first { $0.cells.contains(where: \.isSelected) }?.id
    }

    var selectedCardID: String? {
        if let details = tabModel.allDetailsWithExclusionList.first(where: \.isSelected) {
            return details.id
        }
        if let details = tabModel.allTabGroupDetails.first(where: \.isSelected) {
            return details.id
        }
        return nil
    }

    var body: some View {
        Group {
            LazyVStack(alignment: .leading, spacing: 0) {
                SingleLevelTabCardsView(containerGeometry: geom, incognito: isIncognito)
            }
        }
        .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
        .padding(.vertical, landscapeMode ? 8 : 16)
        .useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
            if let selectedRowId = selectedRowId {
                withAnimation(nil) {
                    scrollProxy.scrollTo(selectedRowId)
                }
            }
        }
        .animation(nil)
    }
}

struct CardScrollContainer<Content: View>: View {
    let columns: [GridItem]
    @ViewBuilder var content: (ScrollViewProxy) -> Content

    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader(content: content)
        }
        .accessibilityIdentifier("CardGrid")
        .environment(\.columns, columns)
        .introspectScrollView { scrollView in
            // This is to make sure the overlay card bleeds outside the horizontal and bottom
            // area in landscape mode. Clipping should be kept in portrait mode because
            // bottom tool bar needs to be shown.
            if landscapeMode {
                scrollView.clipsToBounds = false
            }
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

    // Used to rebuild the scene when switching between portrait and landscape.
    @State var orientation: UIDeviceOrientation = .unknown
    @State var generationId: Int = 0
    @State var switchingState = false

    var geom: GeometryProxy
    var columns: [GridItem]

    var body: some View {
        ZStack {
            // Spaces
            CardScrollContainer(columns: columns) { scrollProxy in
                VStack(alignment: .leading) {
                    LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                        SpaceCardsView()
                            .environment(\.columns, columns)
                    }.animation(nil)
                }
                .padding(.vertical, CardGridUX.GridSpacing)
                .useEffect(deps: browserModel.showGrid) { _ in
                    scrollProxy.scrollTo(
                        spacesModel.allDetails.first?.id ?? ""
                    )
                }
            }
            .offset(x: (gridModel.switcherState == .spaces ? 0 : geom.size.width))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Spaces")
            .accessibilityHidden(gridModel.switcherState != .spaces)

            // Normal Tabs
            ZStack {
                EmptyCardGrid(isIncognito: false)
                    .opacity(tabModel.normalDetails.isEmpty ? 1 : 0)

                CardScrollContainer(columns: columns) { scrollProxy in
                    TabGridContainer(isIncognito: false, geom: geom, scrollProxy: scrollProxy)
                }.onAppear {
                    gridModel.scrollToSelectedTab()
                }
            }
            .offset(
                x: (gridModel.switcherState == .tabs
                    ? (incognitoModel.isIncognito ? geom.size.width : 0) : -geom.size.width)
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Tabs")
            .accessibilityValue(Text("\(tabModel.manager.normalTabs.count) tabs"))
            .accessibilityHidden(gridModel.switcherState != .tabs || incognitoModel.isIncognito)

            // Incognito Tabs
            ZStack {
                EmptyCardGrid(isIncognito: true)
                    .opacity(tabModel.incognitoDetails.isEmpty ? 1 : 0)

                CardScrollContainer(columns: columns) { scrollProxy in
                    TabGridContainer(isIncognito: true, geom: geom, scrollProxy: scrollProxy)
                }.onAppear {
                    gridModel.scrollToSelectedTab()
                }
            }
            .offset(
                x: (gridModel.switcherState == .tabs
                    ? (incognitoModel.isIncognito ? 0 : -geom.size.width) : -geom.size.width)
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Incognito Tabs")
            .accessibilityValue(Text("\(tabModel.manager.incognitoTabs.count) tabs"))
            .accessibilityHidden(
                gridModel.switcherState != .tabs || !incognitoModel.isIncognito)
        }
        .id(generationId)
        .animation(
            .interactiveSpring(), value: "\(gridModel.switcherState) \(incognitoModel.isIncognito)"
        )
        .onChange(of: gridModel.switcherState) { value in
            guard case .spaces = value, !seenSpacesIntro, !gridModel.isLoading else {
                return
            }

            SceneDelegate.getBVC(with: tabModel.manager.scene).showModal(
                style: .withTitle,
                content: {
                    SpacesIntroOverlayContent()
                },
                onDismiss: {
                    browserModel.showSpaces()
                })
            seenSpacesIntro = true
        }
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

func getLogCounterAttributesForTabs(selectedTabRow: Int?) -> [ClientLogCounterAttribute] {
    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.TabsAttribute.selectedTabRow,
            value: String(selectedTabRow ?? 0)))
    return attributes
}
