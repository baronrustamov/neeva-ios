// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletCore

struct UnlockedThemesView: View {
    @Default(.currentTheme) var currentTheme
    @State var isExpanded: Bool = true
    let unlockedThemes: [Web3Theme]

    var body: some View {
        Section(
            content: {
                content
            },
            header: {
                header
            }
        )
        .modifier(WalletListSeparatorModifier())
    }

    private var content: some View {
        ForEach(
            unlockedThemes.sorted(by: { $0.rawValue > $1.rawValue }),
            id: \.rawValue
        ) { theme in
            if isExpanded {
                Button(
                    action: {
                        if let slug = theme.asset?.collection?.openSeaSlug {
                            Defaults[.currentTheme] = slug == currentTheme ? "" : slug
                            if !currentTheme.isEmpty {
                                ClientLogger.shared.logCounter(
                                    .ThemeSet,
                                    attributes: [
                                        ClientLogCounterAttribute(
                                            key: LogConfig.Web3Attribute.partnerCollection,
                                            value: slug),
                                        ClientLogCounterAttribute(
                                            key: LogConfig.Web3Attribute.walletAddress,
                                            value: Defaults[.cryptoPublicKey]),
                                    ])
                            }
                        }
                    },
                    label: {
                        createAssetCard(with: theme.asset)
                    }
                )
                .modifier(WalletListSeparatorModifier())
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        if !unlockedThemes.isEmpty {
            WalletHeader(
                title: "Unlocked Themes",
                isExpanded: $isExpanded
            )
        }
    }

    @ViewBuilder
    private func createAssetCard(with asset: Asset?) -> some View {
        HStack {
            WebImage(url: asset?.collection?.imageURL)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 0) {
                Text(asset?.collection?.name ?? "")
                    .withFont(.bodyMedium)
                    .lineLimit(1)
                    .foregroundColor(.label)
                Text(asset?.collection?.externalURL?.baseDomain ?? "")
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
            }
            Spacer()
            Symbol(
                decorative: currentTheme
                    == asset?.collection?.openSeaSlug
                    ? .checkmarkCircleFill : .circle,
                size: 24
            )
            .foregroundColor(.label)
        }
    }
}
