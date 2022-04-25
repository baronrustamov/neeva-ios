// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct DismissBackgroundView: View {
    let opacity: Double
    var position: OverlaySheetPosition = .dismissed
    let onDismiss: () -> Void
    var waitForAnimation: Bool = true

    var body: some View {
        // The semi-transparent backdrop used to shade the content that lies below
        // the sheet.
        Button(action: onDismiss) {
            Color.black
                .opacity(opacity)
                .ignoresSafeArea()
                .modifier(
                    DismissalObserverModifier(
                        backdropOpacity: self.opacity,
                        position: position,
                        onDismiss: {
                            if waitForAnimation {
                                self.onDismiss()
                            }
                        }))
        }
        .buttonStyle(.highlightless)
        .accessibilityHint("Dismiss pop-up window")
        // make this the last option. This will bring the user’s focus first to the
        // useful content inside of the overlay sheet rather than the close button.
        .accessibilitySortPriority(-1)
    }
}

private struct DismissalObserverModifier: AnimatableModifier {
    var backdropOpacity: Double
    let position: OverlaySheetPosition
    let onDismiss: () -> Void

    var animatableData: Double {
        get { backdropOpacity }
        set {
            backdropOpacity = newValue
            if position == .dismissed && backdropOpacity == 0.0 {
                // Run after the call stack has unwound as |onDismiss| may tear down
                // the overlay sheet, which could cause issues for SwiftUI processing.
                // See issue #401.
                let onDismiss = self.onDismiss

                DispatchQueue.main.async {
                    onDismiss()
                }
            }
        }
    }

    func body(content: Content) -> some View {
        return content
    }
}
