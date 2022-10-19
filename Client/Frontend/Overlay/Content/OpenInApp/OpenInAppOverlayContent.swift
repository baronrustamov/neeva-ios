// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct OpenInAppOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    enum OpenInAppOverlayState {
        case canceled
        case didOpen
        case didNotOpen
    }

    let url: URL
    let completionHandler: ((OpenInAppOverlayState) -> Void)?

    var body: some View {
        OpenInAppOverlayView(
            url: url,
            onOpen: {
                hideOverlay()
                UIApplication.shared.open(url, options: [:]) { success in
                    completionHandler?(success ? .didOpen : .didNotOpen)
                }
            },
            onCancel: {
                hideOverlay()
                completionHandler?(.canceled)
            }
        )
        .padding(.bottom)
        .overlayIsFixedHeight(isFixedHeight: true)
    }

    init(url: URL, completionHandler: ((OpenInAppOverlayState) -> Void)? = nil) {
        self.url = url
        self.completionHandler = completionHandler
    }
}
