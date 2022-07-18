// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct OpenInAppOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let url: URL
    let toastViewManager: ToastViewManager

    var body: some View {
        OpenInAppOverlayView(
            url: url,
            onOpen: {
                hideOverlay()
                OpenInAppModel.shared.openInApp(url: url, toastViewManager: toastViewManager)
            },
            onCancel: hideOverlay
        )
        .padding(.bottom)
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}
