// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI

private enum BrowserTopBarViewUX {
    static let ShowHeaderTapAreaHeight = 32.0
}

struct BrowserTopBarView: View {
    let bvc: BrowserViewController
    var geom: GeometryProxy

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabContainerModel: TabContainerModel

    @ViewBuilder var switcherTopBar: some View {
        if chromeModel.inlineToolbar {
            SwitcherToolbarView(top: true)
        } else {
            GridPicker()
        }
    }

    @ViewBuilder var content: some View {
        if browserModel.showGrid {
            switcherTopBar
                .modifier(
                    SwipeToSwitchGridViewGesture(fromPicker: true))
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
                geom: geom,
                newTab: {
                    bvc.openURLInNewTab(nil)
                },
                onCancel: {
                    if bvc.zeroQueryModel.isLazyTab {
                        if !Defaults[.didFirstNavigation] {
                            chromeModel.setEditingLocation(to: false)
                        } else {
                            bvc.closeLazyTab()
                        }
                    } else {
                        bvc.dismissEditingAndHideZeroQuery(wasCancelled: true)
                    }
                }
            )
        }
    }

    var topBar: some View {
        content
            .transition(.opacity)
    }

    var body: some View {
        VStack {
            if chromeModel.inlineToolbar {
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
        }
    }
}
