// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct SpacePinView: View {

    var body: some View {
        Image(systemSymbol: .pinFill)
            .resizable()
            .foregroundColor(.primary)
            .padding(6)
            .frame(width: CardUX.CloseButtonSize, height: CardUX.CloseButtonSize)
    }
}
