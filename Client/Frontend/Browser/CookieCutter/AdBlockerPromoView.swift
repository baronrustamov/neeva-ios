// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import SwiftUI

public struct AdBlockerPromoView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Environment(\.hideOverlay) private var hideOverlay
    @Environment(\.openSettings) private var openSettings

    public var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HStack {
                    Spacer()
                    CloseButton(action: {
                        ClientLogger.shared.logCounter(.AdBlockPromoClose)
                        hideOverlay()
                    })
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Block Intrusive Ads")
                    .padding(.top, 50)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)

                Text(
                    "Browse with peace of mind. No more distracting video popups or clumsy clicks."
                )
                .withFont(.bodyLarge)
                .foregroundColor(.ui.gray30)
                .padding(.top, 20)
                .padding(.bottom, 30)

                Button {
                    ClientLogger.shared.logCounter(.AdBlockPromoSetup)
                    openSettings(.cookieCutter)
                    hideOverlay()
                } label: {
                    Text("Set up Ad Blocker")
                        .withFont(.labelLarge)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
                .padding(.horizontal, -16)
                .padding(.bottom, 10)
                .buttonStyle(.neeva(.primary))

                Button {
                    ClientLogger.shared.logCounter(.AdBlockPromoRemind)
                    hideOverlay()
                } label: {
                    Text("Skip")
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 26)
            .frame(maxWidth: 320, maxHeight: 390)
        }
    }
}

/// A `View` intended to be embedded within an `OverlayView`, used to
/// present the `AddToSpaceView` UI.
struct AdBlockerPromoOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    var body: some View {
        AdBlockerPromoView()
            .overlayIsFixedHeight(
                isFixedHeight: true
            )
    }
}
