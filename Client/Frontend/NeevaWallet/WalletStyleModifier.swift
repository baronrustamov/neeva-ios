// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct WalletListStyleModifier: ViewModifier {
    @EnvironmentObject var model: Web3Model

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.plain)
                .refreshable {
                    model.updateBalances()
                }
        }
    }
}
