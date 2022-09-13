// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct HTTPAuthPromptOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let url: String
    let onSubmit: (String, String) -> Void

    var body: some View {
        HTTPAuthPromptOverlayView(
            url: url,
            onSubmit: { username, password in
                onSubmit(username, password)
                hideOverlay()
            }, onCancel: hideOverlay
        )
        .overlayIsFixedHeight(isFixedHeight: true)
        .accessibility(label: Text("HTTP Sign In"))
    }
}
