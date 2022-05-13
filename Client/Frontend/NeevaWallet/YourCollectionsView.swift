// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import SwiftUI
import WalletCore

struct YourCollectionsView: View {
    let bvc: BrowserViewController
    private let blockSpacing: CGFloat = 4
    private let blockSize: CGFloat = 64
    @ObservedObject var assetStore: AssetStore = AssetStore.shared
    @State private var selectedCollection: String?
    var dataSource: [Collection] {
        Array(assetStore.collections).sorted(by: {
            $0.stats?.marketCap ?? 0 > $1.stats?.marketCap ?? 0
        })
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            horizontalScrollContentView
        }
        .frame(height: blockSize + 20)
    }

    private var horizontalScrollContentView: some View {
        HStack {
            HStack(spacing: blockSpacing) {
                ForEach(dataSource, id: \.openSeaSlug) { collection in
                    NavigationLink(
                        tag: collection.openSeaSlug,
                        selection: $selectedCollection,
                        destination: {
                            YourCollectionDetailView(
                                matchingCollection: collection,
                                assetStore: assetStore,
                                onOpenUrl: {
                                    self.bvc.dismissCurrentOverlay()
                                    self.bvc.hideZeroQuery()
                                },
                                onBackButtonTap: {
                                    self.selectedCollection = nil
                                }
                            )
                        },
                        label: {
                            YourCollectionItemView(collection: collection, blockSize: blockSize)
                        }
                    )
                }
            }
            .frame(height: blockSize)
            .padding(.vertical, 10)
            .padding(.horizontal, ZeroQueryUX.Padding - 2)
        }
    }

}

struct YourCollectionItemView: View {
    let collection: Collection
    let blockSize: CGFloat

    var body: some View {
        WebImage(url: collection.imageURL)
            .resizable()
            .hexagonClip(with: blockSize)
    }
}
