// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

enum OverflowMenuLocation {
    case tab
    case cardGrid
}

struct OverflowMenuOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let menuAction: (OverflowMenuAction) -> Void
    let changedUserAgent: Bool?
    let chromeModel: TabChromeModel
    let locationModel: LocationViewModel
    let location: OverflowMenuLocation

    @ViewBuilder
    var content: some View {
        if location == .tab {
            OverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
                hideOverlay()
                menuAction(action)
            }
        } else {
            CardGridOverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
                hideOverlay()
                menuAction(action)
            }
        }
    }

    var body: some View {
        content
            .environmentObject(chromeModel)
            .environmentObject(locationModel)
    }
}
