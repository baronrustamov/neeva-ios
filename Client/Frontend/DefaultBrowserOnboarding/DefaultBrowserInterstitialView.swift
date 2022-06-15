// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import SwiftUI

struct DefaultBrowserInterstitialView<Content: View>: View {
    @EnvironmentObject var interstitialModel: InterstitialViewModel

    var showSecondaryButton: Bool = true
    var content: Content
    var primaryButton: String
    var secondaryButton: String?
    var primaryAction: () -> Void
    var secondaryAction: (() -> Void)?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            VStack(alignment: horizontalSizeClass == .regular ? .center : .leading) {
                content
                Spacer().frame(height: 150)
            }
            .padding(.horizontal, 32)
            VStack {
                Spacer()
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
                    .opacity(showSecondaryButton ? 1 : 0)
                    .padding(.top, 10)
                } else {
                    Spacer()
                        .frame(height: 65)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
    }
}
