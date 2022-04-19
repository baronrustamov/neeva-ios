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
                ForEach(dataSource, id: \.self) { collection in
                    YourCollectionItemView(collection: collection, blockSize: blockSize)
                        .onTapGesture {
                            showCollection(with: collection)
                        }
                }
            }
            .frame(height: blockSize)
            .padding(.vertical, 10)
            .padding(.horizontal, ZeroQueryUX.Padding - 2)
        }
    }

    private func showCollection(with collection: Collection) {
        assetStore.fetch(collection: collection.openSeaSlug, onFetch: { _ in })
        bvc.showModal(
            style: .spaces,
            headerButton: nil,
            content: {
                YourCollectionDetailView(
                    matchingCollection: collection,
                    assetStore: assetStore,
                    onOpenUrl: {
                        self.bvc.dismissCurrentOverlay()
                        self.bvc.hideZeroQuery()
                    }
                )
                .overlayIsFixedHeight(isFixedHeight: true)
            }, onDismiss: {})
    }
}

struct YourCollectionItemView: View {
    let collection: Collection
    let blockSize: CGFloat

    var body: some View {
        WebImage(url: collection.imageURL)
            .resizable()
            .frame(width: blockSize, height: blockSize)
            .hexagonClip()
    }
}
