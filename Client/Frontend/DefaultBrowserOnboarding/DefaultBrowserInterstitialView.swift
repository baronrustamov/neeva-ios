// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import SwiftUI

struct DefaultBrowserInterstitialView<Detail: View, Header: View>: View {
    var detail: Detail
    var header: Header
    var primaryButton: String
    var secondaryButton: String?
    var primaryAction: () -> Void
    var secondaryAction: (() -> Void)?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(alignment: horizontalSizeClass == .regular ? .center : .leading) {
            Spacer()
            VStack(alignment: .leading) {
                header
            }
            Spacer()
            detail
            Spacer()
            if let _ = secondaryButton {
                Spacer()
            }
            Button(
                action: {
                    primaryAction()
                },
                label: {
                    Text(primaryButton)
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.neeva(.primary))
            .padding(.top, secondaryButton != nil ? 0 : 10)

            if let secondaryButton = secondaryButton {
                Button(
                    action: {
                        if let secondaryAction = secondaryAction {
                            secondaryAction()
                        }
                    },
                    label: {
                        Text(secondaryButton)
                            .withFont(.labelLarge)
                            .foregroundColor(.ui.adaptive.blue)
                            .padding(13)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                    }
                )
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
