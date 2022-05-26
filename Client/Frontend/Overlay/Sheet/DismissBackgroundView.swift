// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct DismissBackgroundView: View {
    let opacity: Double
    let onDismiss: () -> Void

    var body: some View {
        // The semi-transparent backdrop used to shade the content that lies below
        // the sheet.
        Button(action: onDismiss) {
            Color.black
                .opacity(opacity)
                .ignoresSafeArea()
        }
        .buttonStyle(.highlightless)
        .accessibilityHint("Dismiss pop-up window")
        // make this the last option. This will bring the user’s focus first to the
        // useful content inside of the overlay sheet rather than the close button.
        .accessibilitySortPriority(-1)
    }
}
