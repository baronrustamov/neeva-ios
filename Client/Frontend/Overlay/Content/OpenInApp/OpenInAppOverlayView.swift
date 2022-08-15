// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import UIKit

struct OpenInAppOverlayView: View {
    let url: URL
    let onOpen: () -> Void
    let onCancel: () -> Void

    @Environment(\.hideOverlay) private var hideOverlay

    var body: some View {
        GroupedStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Open link in external app?")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)

                Text(url.absoluteString)
                    .withFont(.labelMedium)
                    .truncationMode(.middle)
                    .foregroundColor(.secondaryLabel)
            }.padding(.bottom, 14)

            GroupedCellButton("Open", action: onOpen)
                .accessibilityIdentifier("ConfirmOpenInApp")

            GroupedCellButton("Cancel", style: .labelLarge, action: onCancel)
                .accessibilityIdentifier("CancelOpenInApp")
        }
    }
}

struct OpenInAppOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OpenInAppOverlayView(url: URL(string: "example.com")!, onOpen: {}, onCancel: {})
    }
}
