// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

enum OverlaySheetPosition: LocalizedStringKey {
    case top = "Full screen"
    case middle = "Half screen"
    case dismissed = ""
}

public class OverlaySheetModel: ObservableObject {
    @Published var topBarHeight: CGFloat = 0
    @Published var deltaHeight: CGFloat = 0
    @Published var position: OverlaySheetPosition = .dismissed
    @Published private(set) var backdropOpacity: Double = 0.0

    func show(defaultPosition: OverlaySheetPosition = .middle) {
        self.position = defaultPosition
        self.backdropOpacity = OverlaySheetUX.backdropMaxOpacity
    }

    func hide(animate: Bool = false) {
        if animate {
            withAnimation(.easeOut(duration: OverlaySheetUX.animationDuration)) {
                self.deltaHeight = 0
                self.position = .dismissed
                self.backdropOpacity = 0.0
            }
        } else {
            self.deltaHeight = 0
        }
    }
}
