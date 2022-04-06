// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

private enum BrowserTopBarViewUX {
    static let ShowHeaderTapAreaHeight = 32.0
}

struct BrowserTopBarView: View {
    let bvc: BrowserViewController

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabContainerModel: TabContainerModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isShowingPreviewHome: Bool {
        tabContainerModel.currentContentUI == .previewHome
    }

    private var useTopToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    @ViewBuilder var switcherTopBar: some View {
        if useTopToolbar {
            SwitcherToolbarView(top: true)
        } else {
            GridPicker()
        }
    }

    @ViewBuilder var content: some View {
        if browserModel.showGrid {
            switcherTopBar
                .modifier(
                    SwipeToSwitchToSpacesGesture(fromPicker: true))
        } else {
            TopBarContent(
                browserModel: browserModel,
                suggestionModel: bvc.suggestionModel,
                model: bvc.locationModel,
                queryModel: bvc.searchQueryModel,
                gridModel: gridModel,
                trackingStatsViewModel: bvc.trackingStatsViewModel,
                chromeModel: bvc.chromeModel,
                readerModeModel: bvc.readerModeModel,
                web3Model: bvc.web3Model,
                newTab: {
                    bvc.openURLInNewTab(nil)
                },
                onCancel: {
                    if bvc.zeroQueryModel.isLazyTab {
                        bvc.closeLazyTab()
                    } else {
                        bvc.hideZeroQuery()
                    }
                }
            ).environment(
                \.openSettings,
                {
                    bvc.openSettings(openPage: .cookieCutter)
                }
            )
        }
    }

    var topBar: some View {
        GeometryReader { geom in
            content
                .transition(.opacity)
                .frame(height: chromeModel.topBarHeight)
        }
    }

    var body: some View {
        if !isShowingPreviewHome || browserModel.showGrid {
            VStack {
                if UIConstants.enableBottomURLBar {
                    Spacer()
                }

                if !UIConstants.enableBottomURLBar, chromeModel.inlineToolbar {
                    topBar
                        .background(
                            Group {
                                // invisible tap area to show the toolbars since modern iOS
                                // does not have a status bar in landscape.
                                Color.clear
                                    .ignoresSafeArea()
                                    .frame(
                                        height: BrowserTopBarViewUX
                                            .ShowHeaderTapAreaHeight
                                    )
                                    // without this, the area isn’t tappable because it’s invisible
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        browserModel.scrollingControlModel
                                            .showToolbars(
                                                animated: true)
                                    }
                            }, alignment: .top)
                } else {
                    topBar
                }

                if !UIConstants.enableBottomURLBar {
                    Spacer()
                }
            }
        }
    }
}
