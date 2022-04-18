// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import WalletCore

struct YourNFTsView: View {
    @State var isExpanded: Bool = true
    @ObservedObject var assetStore: AssetStore

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

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            ScrollView(
                .horizontal, showsIndicators: false,
                content: {
                    LazyHStack {
                        ForEach(
                            assetStore.assets, id: \.id,
                            content: { asset in
                                AssetView(asset: asset)
                            })
                    }
                })
        }
    }

    @ViewBuilder
    private var header: some View {
        if !assetStore.assets.isEmpty {
            WalletHeader(
                title: "Your NFTs",
                isExpanded: $isExpanded
            )
        }
    }

}
