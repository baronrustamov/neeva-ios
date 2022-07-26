// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

struct DefaultBrowserInterstitialBackdrop<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .foregroundColor(
                    Color.brand.variant.adaptive.polar
                )
                .padding(.horizontal, -32)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: UIConstants.hasHomeButton ? 10 : 50)

                VStack(alignment: .leading, spacing: 0) {
                    Image("welcome-shield", bundle: .main)
                        .frame(width: 32, height: 32)
                        .padding(.top, horizontalSizeClass == .regular ? 200 : 50)
                        .padding(.bottom, 15)
                        .padding(.horizontal, 45)
                    content
                }
                .background(Color(UIColor.systemBackground)).cornerRadius(20)
                .padding(.top, 10)
                .padding(.horizontal, -32)
            }
            .shadow(
                color: Color.brand.variant.adaptive.shadow,
                radius: 8,
                x: 0,
                y: -8
            )
        }
        Spacer()
    }
}

struct DefaultBrowserInterstitialView<Content: View>: View {
    @EnvironmentObject var interstitialModel: InterstitialViewModel

    var showSecondaryButton: Bool = true
    var showLogo: Bool = false
    var content: Content
    var primaryButton: LocalizedStringKey
    var secondaryButton: LocalizedStringKey?
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
            if showLogo {
                VStack(spacing: 0) {
                    Spacer()
                    Image("neevaMenuIcon")
                        .padding(.bottom, 40)
                        .frame(width: 32, height: 32)
                }
            }
        }
    }
}
