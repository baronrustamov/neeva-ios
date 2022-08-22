// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct HoverEffectButton<Label: View>: View {
    @State private var useHoverEffect = FeatureFlag[.hoverEffects]

    let effect: HoverEffect
    let isTextButton: Bool
    let action: () -> Void
    let label: Label

    var button: some View {
        Button {
            action()

            /* Possible fix to https://developer.apple.com/forums/thread/712412?answerId=724148022#724148022,
             * but using a delay is not really a great solution.
            if UIDevice.current.userInterfaceIdiom == .pad, useHoverEffect {
                useHoverEffect = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    useHoverEffect = true
                    action()
                }
            } else {

            } */
        } label: {
            label
        }
    }

    public var body: some View {
        button
            .if(isTextButton) {
                $0.padding(6)  // a) padding for hoverEffect
            }
            .if(useHoverEffect) {
                $0.hoverEffect(effect)
            }
            .if(isTextButton) {
                $0.padding(-6)  // Remove extra padding added in `a`
            }
    }

    /// - Parameters:
    ///   - isTextButton: Applies special padding to a button with text.
    public init(
        effect: HoverEffect = .automatic,
        isTextButton: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.effect = effect
        self.isTextButton = isTextButton
        self.action = action
        self.label = label()
    }
}
