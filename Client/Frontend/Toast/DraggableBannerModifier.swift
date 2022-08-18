// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

protocol BannerViewDelegate: AnyObject {
    func dismiss()
    func draggingUpdated()
    func draggingEnded(dismissing: Bool)
}

struct DraggableBannerModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    private var opacity: CGFloat {
        let delta = abs(offset) - ToastViewUX.threshold
        return delta > 0 ? 1 - delta / (ToastViewUX.threshold * 3) : 1
    }

    var bannerViewDelegate: BannerViewDelegate?

    private var drag: some Gesture {
        DragGesture()
            .onChanged {
                self.offset = $0.translation.height
                bannerViewDelegate?.draggingUpdated()
            }
            .onEnded {
                var dismissing = false
                if abs($0.predictedEndTranslation.height) > ToastViewUX.height * 1.5 {
                    self.offset = $0.predictedEndTranslation.height
                    dismissing = true
                } else if abs($0.translation.height) > ToastViewUX.height {
                    dismissing = true
                } else {
                    self.offset = 0
                }

                bannerViewDelegate?.draggingEnded(dismissing: dismissing)
            }
    }

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .gesture(drag)
            .opacity(Double(opacity))
            .animation(.interactiveSpring(), value: offset)
    }
}
