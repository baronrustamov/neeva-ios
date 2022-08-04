// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct LongPressButton<Label: View>: View {
    let action: () -> Void
    let longPressAction: (() -> Void)?
    let label: () -> Label

    @State private var didLongPress = false

    public init(
        action: @escaping () -> Void,
        longPressAction: (() -> Void)? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.longPressAction = longPressAction
        self.label = label
    }

    public var body: some View {
        Button {
            if !didLongPress {
                action()
            }

            didLongPress = false
        } label: {
            label()
        }.simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3).onEnded { _ in
                if let longPressAction = longPressAction {
                    longPressAction()
                    Haptics.longPress()
                }

                didLongPress = true

                // Give a small buffer to allow the gesture to reset.
                // Set `didLongPress` to false so the user can perform
                // the regular tap action.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.didLongPress = false
                }
            }
        )
    }
}
