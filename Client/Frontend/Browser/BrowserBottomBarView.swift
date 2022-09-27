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
        if !gridVisibilityModel.showGrid && Defaults[.didFirstNavigation] {
            TabToolbarContent()
        } else if gridVisibilityModel.showGrid {
            SwitcherToolbarView(top: false)
        }
    }

    var body: some View {
        if !chromeModel.inlineToolbar && !overlayManager.hideBottomBar {
            toolbar
                .transition(.opacity.combined(with: .identity))
                .frame(
                    height: UIConstants.TopToolbarHeightWithToolbarButtonsShowing
                )
        }
    }
}
