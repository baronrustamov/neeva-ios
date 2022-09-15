// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct BrowserBottomBarView: View {
    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var gridVisibilityModel: GridVisibilityModel

    @ViewBuilder var toolbar: some View {
        if !gridVisibilityModel.showGrid && !chromeModel.inlineToolbar
            && !chromeModel.isEditingLocation
            && Defaults[.didFirstNavigation]
        {
            TabToolbarContent()
        } else if gridVisibilityModel.showGrid {
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
            }
        }.ignoresSafeArea(.keyboard)
    }
}
