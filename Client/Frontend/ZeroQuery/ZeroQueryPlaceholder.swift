// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ZeroQueryPlaceholder: View {
    let label: LocalizedStringKey

    var body: some View {
        HStack {
            Spacer()
            Text(label)
                .withFont(.bodyMedium)
                .multilineTextAlignment(.center)
                .foregroundColor(.label)
            Spacer()
        }.padding(.vertical, 12)
    }
}
