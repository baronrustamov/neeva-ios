// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import UIKit

struct OpenInAppOverlayView: View {
    var appName: String? = nil
    let url: URL
    let onOpen: () -> Void
    let onCancel: () -> Void

    @State var rememberMyChoice = false
    @Environment(\.hideOverlay) private var hideOverlay

    var title: String {
        if let appName = appName {
            return "Open link in \(appName)?"
        } else {
            return "Open link in external app?"
        }
    }

    public var body: some View {
        GroupedStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)

                Text(url.absoluteString)
                    .withFont(.labelMedium)
                    .truncationMode(.middle)
                    .foregroundColor(.secondaryLabel)
            }.padding(.bottom, 14)

            CheckboxView(checked: $rememberMyChoice) {
                Text("Remember my decision")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)
            }

            GroupedCellButton("Open") {
                onOpen()

                if rememberMyChoice {
                    rememberChoice(value: true)
                }
            }.accessibilityIdentifier("ConfirmOpenInApp")

            GroupedCellButton("Cancel", style: .labelLarge) {
                onCancel()

                if rememberMyChoice {
                    rememberChoice(value: false)
                }
            }.accessibilityIdentifier("CancelOpenInApp")
        }
    }

    private func rememberChoice(value: Bool) {
        if let host = url.host {
            OpenInAppModel.shared.savePreferences(for: host, shouldOpenInApp: value)
        }
    }
}

struct OpenInAppOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OpenInAppOverlayView(url: URL(string: "example.com")!, onOpen: {}, onCancel: {})
            OpenInAppOverlayView(
                appName: "Neeva", url: URL(string: "example.com")!, onOpen: {}, onCancel: {})
        }

    }
}
