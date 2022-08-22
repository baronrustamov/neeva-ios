// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct LongPressButton<Label: View>: View {
    let action: () -> Void
    let longPressAction: (() -> Void)?
    let label: () -> Label

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
        HoverEffectButton {
            // Defer this to the TapGesture.
        } label: {
            label()
        }.simultaneousGesture(
            LongPressGesture().onEnded { _ in
                if let longPressAction = longPressAction {
                    longPressAction()
                    Haptics.longPress()
                }
            }
        ).simultaneousGesture(
            TapGesture().onEnded {
                action()
            }
        )
    }
}
