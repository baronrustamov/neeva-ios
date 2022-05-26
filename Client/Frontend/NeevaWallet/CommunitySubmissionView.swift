// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI
import WalletCore

public struct CommunitySubmissionView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @EnvironmentObject var model: Web3Model

    let iconURL: URL
    let domain: String
    let url: URL
    @Binding var trust: Bool
    @State private var request: TrustSignalRequest? = nil

    public init(iconURL: URL, domain: String, url: URL, trust: Binding<Bool>) {
        self.iconURL = iconURL
        self.domain = domain
        self.url = url
        self._trust = trust
    }

    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                WalletSequenceSiteHeader(iconURL: iconURL, domain: domain, trusted: false)
                Text("We're building out community trust flags for sites like this one.")
                    .withFont(.bodyLarge)
                    .foregroundColor(Color(light: .brand.variant.blue, dark: .brand.blue))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(12)
            .background(Color.quaternarySystemFill)
            .cornerRadius(12)
            Text(
                "Do you have knowledge of this site? Help keep the community safe and contribute below."
            )
            .withFont(.bodyXLarge)
            .foregroundColor(.label)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 16) {
                NeevaWalletLongPressButton(
                    action: {
                        trust = true
                        if let balance = Double(model.balanceFor(.ether) ?? "0"), balance > 0 {
                            request = TrustSignalRequest(url: url, trusted: true)
                        }
                    },
                    label: {
                        Text("Hold to verify")
                            .frame(maxWidth: .infinity)

                    }
                )
                Button(
                    action: {
                        trust = false
                        hideOverlaySheet()
                        if let balance = Double(model.balanceFor(.ether) ?? "0"), balance > 0 {
                            request = TrustSignalRequest(url: url, trusted: false)
                        }
                    },
                    label: {
                        Text("Report as scam")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.secondary))
            }
        }
        .padding(12)
        .padding(.bottom, 24)
    }
}
