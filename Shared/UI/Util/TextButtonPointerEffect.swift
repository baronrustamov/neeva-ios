// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension View {
    public func textButtonPointerEffect() -> some View {
        return
            self
            .padding(6)  // a) padding for hoverEffect
            .hoverEffect()
            .padding(-6)  // Remove extra padding added in `a`
    }
}
