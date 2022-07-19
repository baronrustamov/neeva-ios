// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

enum CardTransitionState {
    case hidden
    case visibleForTrayShow
    case visibleForTrayHidden
}

class CardTransitionModel: ObservableObject {
    @Published private(set) var state = CardTransitionState.hidden

    func update(to state: CardTransitionState) {
        // Avoid spurious events.
        if self.state != state {
            self.state = state
        }
    }
}
