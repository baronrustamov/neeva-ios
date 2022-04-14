// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct WalletHeader: View {
    let title: String
    @Binding var isExpanded: Bool

    var body: some View {
        HStack {
            Text(title)
                .withFont(.headingMedium)
                .foregroundColor(.label)
            Spacer()
            Button(action: {
                isExpanded.toggle()
            }) {
                Symbol(
                    decorative: isExpanded ? .chevronUp : .chevronDown,
                    style: .headingMedium
                )
                .foregroundColor(.label)
            }
        }
        .padding(.bottom, 4)
    }
}
