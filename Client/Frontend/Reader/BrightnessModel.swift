// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SFSafeSymbols
import Shared

class BrightnessModel: ObservableObject {
    private let levels: [CGFloat] = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

    var brightness: CGFloat {
        UIScreen.main.brightness
    }

    @Published private(set) var canDecrease: Bool = false
    @Published private(set) var canIncrease: Bool = false

    func setBrightness(to: CGFloat) {
        UIScreen.main.brightness = to
        canDecrease = to > 0
        canIncrease = to < 1
    }

    func increase() {
        if brightness < levels.first! {
            setBrightness(to: levels.first!)
        } else if let currentIndex = levels.firstIndex(where: { abs($0 - brightness) < 0.05 }),
            levels.indices.contains(currentIndex + 1)
        {
            setBrightness(to: levels[currentIndex + 1])
        }
    }

    func decrease() {
        if brightness > levels.last! {
            setBrightness(to: levels.first!)
        } else if let currentIndex = levels.firstIndex(where: { abs($0 - brightness) < 0.05 }),
            levels.indices.contains(currentIndex - 1)
        {
            setBrightness(to: levels[currentIndex - 1])
        }
    }

    var symbol: Symbol {
        if brightness < 0.5 {
            return Symbol(decorative: .sunMin, style: .headingLarge)
        } else {
            return Symbol(decorative: .sunMax, style: .headingLarge)
        }
    }

    init() {
        self.canDecrease = brightness > levels.first!
        self.canIncrease = brightness < levels.last!
    }
}
