// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletCore

struct YourCollectionDetailView: View {
    let matchingCollection: Collection
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @EnvironmentObject var web3Model: Web3Model
    @ObservedObject var assetStore: AssetStore
    var onOpenUrl: () -> Void
    var onBackButtonTap: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            contentView
            backButton
        }
        .navigationBarHidden(true)
        .onAppear {
            assetStore.fetch(collection: matchingCollection.openSeaSlug, onFetch: { _ in })
        }
    }

    private var contentView: some View {
        VStack(spacing: 36) {
            CollectionView(collection: matchingCollection)
                .background(WalletTheme.gradient.opacity(0.08))
                .cornerRadius(16)
                .frame(height: 300)
            HStack(spacing: 12) {
                Button(action: {
                    openUrl(matchingCollection.twitterURL)
                }) {
                    HStack(spacing: 4) {
                        Image("twitter-share", bundle: .main)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Twitter")
                    }
                }.buttonStyle(DashboardButtonStyle())
                Button(action: {
                    openUrl(matchingCollection.discordURL)
                }) {
                    HStack(spacing: 4) {
                        Image("discord")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Discord")
                    }
                }.buttonStyle(DashboardButtonStyle())
                Button(action: {
                    openUrl(matchingCollection.externalURL)
                }) {
                    HStack(spacing: 2) {
                        Symbol(decorative: .arrowUpRight, style: .bodyMedium)
                        Text("Website")
                    }
                }.buttonStyle(DashboardButtonStyle())
            }
            Spacer()
        }
    }

    private var backButton: some View {
        Button(
            action: {
                onBackButtonTap()
            },
            label: {
                Symbol(.arrowBackward, label: "Return to all Spaces view")
                    .foregroundColor(Color.label)
            }
        )
        .tapTargetFrame()
        .background(WalletTheme.gradient)
        .clipShape(Circle())
        .padding(.leading, 12)
        .padding(.top, 12)
    }

    private func openUrl(_ url: URL?) {
        guard let url = url else { return }
        web3Model.openURL(url)
        onOpenUrl()
    }
}
