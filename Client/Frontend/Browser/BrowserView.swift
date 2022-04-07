// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

// CardGrid is a parameter to this View so that we isolate it from updates
// to this View (specifically updates to BrowserModel.showContent).
struct BrowserContentView: View {
    let bvc: BrowserViewController
    let cardGrid: CardGrid

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
                    { bvc.gridModel.tabCardModel.manager.createOrSwitchToTab(for: $0) }
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
        }
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

    @ObservedObject var tabContainerModel: TabContainerModel

    @State var safeArea = EdgeInsets()
    @State var topBarHeight: CGFloat = .zero

    private var isShowingPreviewHome: Bool {
        tabContainerModel.currentContentUI == .previewHome
    }

    // MARK: - Views
    var mainContent: some View {
        GeometryReader { geom in
            NavigationView {
                VStack(spacing: 0) {
                    ZStack {
                        // Tab content or CardGrid
                        BrowserContentView(bvc: bvc, cardGrid: CardGrid(geom: geom))
                            .environment(\.shareURL, bvc.shareURL(url:view:))
                            .if(!isShowingPreviewHome) {
                                $0.padding(
                                    UIConstants.enableBottomURLBar ? .bottom : .top,
                                    topBarHeight
                                )
                            }
                            .background(Color.background)

                        // Top Bar
                        BrowserTopBarView(bvc: bvc)
                    }

                    // Bottom Bar
                    BrowserBottomBarView(bvc: bvc)
                }.useEffect(deps: chromeModel.topBarHeight) { _ in
                    topBarHeight = chromeModel.topBarHeight
                    browserModel.scrollingControlModel.setHeaderFooterHeight(
                        header: chromeModel.topBarHeight,
                        footer: UIConstants.TopToolbarHeightWithToolbarButtonsShowing
                            + geom.safeAreaInsets.bottom)
                }.keyboardListener(adapt: false) { height in
                    DispatchQueue.main.async {
                        chromeModel.keyboardShowing = height > 0
                    }
                }.navigationBarHidden(true)
            }.navigationViewStyle(.stack)
        }
    }

    var body: some View {
        ZStack {
            mainContent
            OverlayView()
        }.safeAreaChanged { safeArea in
            self.safeArea = safeArea
        }
        .environment(\.safeArea, safeArea)
        .environmentObject(browserModel)
        .environmentObject(browserModel.incognitoModel)
        .environmentObject(browserModel.cardTransitionModel)
        .environmentObject(browserModel.contentVisibilityModel)
        .environmentObject(browserModel.scrollingControlModel)
        .environmentObject(browserModel.switcherToolbarModel)
        .environmentObject(browserModel.toastViewManager)
        .environmentObject(chromeModel)
        .environmentObject(bvc.gridModel)
        .environmentObject(bvc.gridModel.spaceCardModel)
        .environmentObject(bvc.gridModel.tabCardModel)
        .environmentObject(bvc.overlayManager)
        .environmentObject(bvc.simulatedSwipeModel)
        .environmentObject(bvc.tabContainerModel)
        .environmentObject(bvc.web3Model)
        .environmentObject(bvc.web3Model.walletDetailsModel)
    }

    // MARK: - Init
    init(bvc: BrowserViewController) {
        self.bvc = bvc
        self.browserModel = bvc.browserModel
        self.chromeModel = bvc.chromeModel
        self.tabContainerModel = bvc.tabContainerModel
    }
}
