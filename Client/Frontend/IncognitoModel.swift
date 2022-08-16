// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

class IncognitoModel: ObservableObject {
    @Published private(set) var isIncognito: Bool

    init(isIncognito: Bool) {
        self.isIncognito = isIncognito
    }

    func update(isIncognito: Bool) {
        // Avoid spurious events.
        if self.isIncognito != isIncognito {
            self.isIncognito = isIncognito
        }
    }

    func toggle() {
        self.isIncognito.toggle()
    }
}
