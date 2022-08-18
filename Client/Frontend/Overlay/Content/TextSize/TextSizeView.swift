// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct TextSizeView: View {
    @ObservedObject var model: TextSizeModel
    let onDismiss: () -> Void

    var body: some View {
        GroupedStack {
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    // all the content in here is decorative since the accessibility element is explicitly provided below.
                    TextSizeStepper(model: model)

                    Color.groupedBackground.frame(height: 1)

                    GroupedCellButton("Reset", action: model.resetZoom)
                        .accentColor(.red)

                    Color.groupedBackground.frame(height: 1)

                    GroupedCellButton("Done", style: .labelLarge, action: onDismiss)
                }.accentColor(.label)
            }
        }.overlayIsFixedHeight(isFixedHeight: true)
    }
}
