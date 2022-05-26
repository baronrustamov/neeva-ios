// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct BrowserBottomBarView: View {
    let bvc: BrowserViewController

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var tabContainerModel: TabContainerModel

    @ViewBuilder var toolbar: some View {
        if !browserModel.showGrid && !chromeModel.inlineToolbar && !chromeModel.isEditingLocation
            && (Defaults[.didFirstNavigation] || NeevaConstants.currentTarget == .xyz)
        {
            TabToolbarContent(
                onNeevaButtonPressed: {
                    ClientLogger.shared.logCounter(
                        .OpenCheatsheet,
                        attributes: EnvironmentHelper.shared.getAttributes()
                    )
                    CheatsheetMenuViewModel.promoModel.openSheet(
                        on: chromeModel.topBarDelegate?.tabManager.selectedTab?.url
                    )
                    bvc.showCheatSheetOverlay()
                }
            )
        } else if browserModel.showGrid {
            SwitcherToolbarView(top: false)
        }
    }

    var body: some View {
        ZStack {
            if !chromeModel.inlineToolbar && !chromeModel.isEditingLocation
                && !chromeModel.keyboardShowing && !overlayManager.hideBottomBar
            {
                toolbar
                    .transition(.opacity)
                    .frame(
                        height: UIConstants.TopToolbarHeightWithToolbarButtonsShowing
                    )
                    .onHeightOfViewChanged { height in
                        self.chromeModel.bottomBarHeight = height
                    }
            }
        }.ignoresSafeArea(.keyboard)
    }
}
