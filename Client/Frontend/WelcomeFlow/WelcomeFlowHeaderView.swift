// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct WelcomeFlowHeaderView: View {
    var text: LocalizedStringKey
    var alignment: TextAlignment = .center

    var body: some View {
        Text(text)
            .font(
                .system(
                    size: UIDevice.current.useTabletInterface || UIConstants.hasHomeButton
                        ? 24 : 36, weight: .bold)
            )
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(alignment)
    }
}
