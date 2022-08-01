// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreGraphics
import Shared
import SwiftUI

struct DragToCloseInteraction: ViewModifier {
    let action: () -> Void
    @State private var hasExceededThreshold = false

    @Environment(\.cardSize) private var cardSize
    @Environment(\.layoutDirection) private var layoutDirection

    @State private var offset = CGFloat.zero

    private var dragToCloseThreshold: CGFloat {
        // Using `cardSize` here helps this scale properly with different card sizes,
        // across portrait and landscape modes.
        cardSize * 0.6
    }

    private var progress: CGFloat {
        abs(offset) / (dragToCloseThreshold * 1.5)
    }
    private var angle: Angle {
        .radians(Double(progress * (.pi / 10)).withSign(offset.sign) * layoutDirection.xSign)
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(1 - (progress / 5))
            .rotation3DEffect(angle, axis: (x: 0.0, y: 1.0, z: 0.0))
            .translate(x: offset)
            .opacity(Double(1 - progress))
            .highPriorityGesture(
                DragGesture()
                    .onChanged { value in
                        // Workaround for SwiftUI gestures and UIScrollView not playing well
                        // together. See issue #1378 for details. Only apply an offset if the
                        // translation is mostly in the horizontal direction to avoid translating
                        // the card when the UIScrollView is scrolling.
                        if offset != 0
                            || abs(value.translation.width) > abs(value.translation.height)
                        {
                            offset = value.translation.width
                            if abs(offset) > dragToCloseThreshold {
                                if !hasExceededThreshold {
                                    hasExceededThreshold = true
                                    Haptics.swipeGesture()
                                }
                            } else {
                                hasExceededThreshold = false
                            }
                        }
                    }
                    .onEnded { value in
                        let finalOffset = value.translation.width
                        withAnimation(.interactiveSpring()) {
                            if abs(finalOffset) > dragToCloseThreshold {
                                offset = finalOffset
                                action()

                                // work around reopening tabs causing the state to not be reset
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + .milliseconds(500)
                                ) {
                                    offset = 0
                                }
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
    }
}
