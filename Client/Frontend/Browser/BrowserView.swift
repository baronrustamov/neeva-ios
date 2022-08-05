// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

// CardGrid is a parameter to this View so that we isolate it from updates
// to this View (specifically updates to BrowserModel.showContent).
struct BrowserContentView: View {
    let bvc: BrowserViewController
    let cardGrid: CardGrid
    var topBarHeight: CGFloat

    @EnvironmentObject private var contentVisibilityModel: ContentVisibilityModel

    private var tabContainerContent: some View {
        TabContainerContent(
            model: bvc.tabContainerModel,
            bvc: bvc,
            zeroQueryModel: bvc.zeroQueryModel,
            suggestionModel: bvc.suggestionModel,
            spaceContentSheetModel: FeatureFlag[.spaceComments]
                ? SpaceContentSheetModel(
                    tabManager: bvc.tabManager,
                    spaceModel: bvc.gridModel.spaceCardModel) : nil
        )
    }

    var body: some View {
        ZStack {
            cardGrid
                .environment(
                    \.onOpenURL,
                    { bvc.tabManager.createOrSwitchToTab(for: $0) }
                )
                .environment(
                    \.onOpenURLForSpace,
                    {
                        bvc.gridModel.tabCardModel.manager.createOrSwitchToTabForSpace(
                            for: $0, spaceID: $1)
                    }
                )
                .environment(
                    \.shareURL,
                    {
                        bvc.shareURL(url: $0, view: $1)
                    }
                )
                .opacity(contentVisibilityModel.showContent ? 0 : 1)
                .onAppear {
                    bvc.gridModel.scrollToSelectedTab()
                }
                .accessibilityHidden(contentVisibilityModel.showContent)
                .ignoresSafeArea(edges: [.bottom])

            tabContainerContent
                .opacity(contentVisibilityModel.showContent ? 1 : 0)
                .accessibilityHidden(!contentVisibilityModel.showContent)
        }.padding(.top, topBarHeight)
    }
}

struct BrowserView: View {
    // MARK: - Parameters
    // TODO: Eliminate this dependency
    let bvc: BrowserViewController

    // Explicitly not observed objects to avoid costly updates. WARNING: Do not
    // conditionalize SwiftUI View generation on these.
    let browserModel: BrowserModel
    let chromeModel: TabChromeModel
    let cheatsheetPromoModel: CheatsheetPromoModel

    @State var safeArea = EdgeInsets()
    @State var topBarHeight: CGFloat = .zero
    @State var bottomBarHeight: CGFloat = .zero

    // MARK: - Views
    var mainContent: some View {
        GeometryReader { geom in
            NavigationView {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        // Tab content or CardGrid
                        BrowserContentView(
                            bvc: bvc, cardGrid: CardGrid(geom: geom), topBarHeight: topBarHeight
                        )
                        .environment(\.shareURL, bvc.shareURL(url:view:))
                        .background(Color.background)

                        // Top Bar
                        BrowserTopBarView(bvc: bvc, geom: geom).onHeightOfViewChanged { height in
                            topBarHeight = height
                        }.fixedSize(horizontal: false, vertical: true)
                    }

                    // Bottom Bar
                    BrowserBottomBarView().onHeightOfViewChanged { height in
                        bottomBarHeight = height
                    }
                }.keyboardListener(
                    adapt: false,
                    keyboardVisibleStateChanged: { isVisible in
                        chromeModel.keyboardShowing = isVisible
                    }
                ).navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
            .useEffect(deps: geom.safeAreaInsets, topBarHeight, bottomBarHeight) {
                safeArea, topBarHeight, bottomBarHeight in
                self.safeArea = safeArea
                self.chromeModel.bottomBarHeight = bottomBarHeight

                // Add a 3px of extra height to footer to hide
                // a small bit of view that isn't hidden.
                browserModel.scrollingControlModel.setHeaderFooterHeight(
                    header: topBarHeight,
                    footer: bottomBarHeight + safeArea.bottom + 3
                )
            }
        }
    }

    var body: some View {
        ZStack {
            mainContent
            OverlayView()
        }
        .environment(\.safeArea, safeArea)
        .environment(
            \.openSettings,
            { page in
                bvc.openSettings(openPage: page)
            }
        )
        .environment(
            \.openArchivedTabsPanelView,
            {
                bvc.present(
                    ArchivedTabsPanelViewController(browserModel: browserModel), animated: true)
            }
        )
        .environmentObject(browserModel)
        .environmentObject(browserModel.cardStripModel)
        .environmentObject(browserModel.cardTransitionModel)
        .environmentObject(browserModel.contentVisibilityModel)
        .environmentObject(browserModel.cookieCutterModel)
        .environmentObject(browserModel.incognitoModel)
        .environmentObject(browserModel.scrollingControlModel)
        .environmentObject(browserModel.switcherToolbarModel)
        .environmentObject(browserModel.toastViewManager)
        .environmentObject(bvc.gridModel)
        .environmentObject(bvc.gridModel.spaceCardModel)
        .environmentObject(bvc.gridModel.tabCardModel)
        .environmentObject(bvc.overlayManager)
        .environmentObject(bvc.simulatedSwipeModel)
        .environmentObject(bvc.tabContainerModel)
        .environmentObject(bvc.web3Model)
        .environmentObject(bvc.web3Model.walletDetailsModel)
        .environmentObject(cheatsheetPromoModel)
        .environmentObject(chromeModel)
    }

    // MARK: - Init
    init(bvc: BrowserViewController) {
        self.bvc = bvc
        self.browserModel = bvc.browserModel
        self.chromeModel = bvc.chromeModel
        self.cheatsheetPromoModel = bvc.cheatsheetPromoModel
    }
}
