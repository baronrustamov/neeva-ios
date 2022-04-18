// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletCore

extension Asset: SelectableThumbnail {
    var thumbnail: some View {
        WebImage(
            url: imageURL,
            context: [
                .imageThumbnailPixelSize: CGSize(
                    width: 800,
                    height: 800)
            ]
        )
        .resizable()
        .aspectRatio(contentMode: .fill)
    }

    func onSelect() {}
}

struct AssetView: View {
    @EnvironmentObject var web3Model: Web3Model
    @EnvironmentObject var walletDetailsModel: WalletDetailsModel
    @EnvironmentObject var browserModel: BrowserModel
    let asset: Asset
    let cardSize: CGFloat = 100

    var contractAddress: String {
        guard let address = asset.contract?.address else {
            return ""
        }
        return address
    }

    var body: some View {
        VStack {
            titleView
            HStack {
                thumbnailView
                VStack {
                    neevaButton
                    openSeaButton
                }.padding(.trailing, 12)
            }
        }
        .padding(4)
        .backgroundColorOrGradient()
        .frame(maxWidth: 200)
        .cornerRadius(CardUX.CornerRadius)
    }

    private var titleView: some View {
        Text(asset.name ?? "")
            .withFont(.headingSmall)
            .padding(.horizontal, 8)
    }

    private var thumbnailView: some View {
        asset.thumbnail
            .frame(width: cardSize, height: cardSize)
            .cornerRadius(CardUX.CornerRadius)
            .padding(12)
    }

    private var neevaButton: some View {
        createCircularButton(
            with:
                "https://neeva.xyz/search?q=\(contractAddress)&contractAddress=\(contractAddress)&tokenID=\(asset.tokenID ?? "")",
            assetUrl: SearchEngine.nft.icon)
    }

    private var openSeaButton: some View {
        createCircularButton(
            with: "https://opensea.io/assets/\(contractAddress)/\(asset.tokenID ?? "")",
            assetUrl: URL(string: "https://opensea.io/static/images/favicon/180x180.png"))
    }

    private func createCircularButton(with urlString: String, assetUrl: URL?) -> some View {
        Button {
            guard let url = URL(string: urlString) else {
                return
            }

            DispatchQueue.main.async {
                web3Model.openURL(url)
            }
        } label: {
            WebImage(url: assetUrl)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .padding(12)
                .background(Color.tertiarySystemFill)
                .clipShape(Capsule())
        }
    }

}

public class AssetGroup: ThumbnailModel, Identifiable {
    public var id: String = UUID().uuidString
    var allDetails: [Asset] = []
    var assetStoreSubscription: AnyCancellable? = nil
    var collections: [String] = []
    var allDetailsWithExclusionList: [Asset] {
        return allDetails
    }

    init(collectionSlug: String) {
        allDetails = AssetStore.shared.assets.filter {
            $0.collection?.openSeaSlug == collectionSlug
        }
        collections = [collectionSlug]

        assetStoreSubscription = AssetStore.shared.$state.sink { state in
            guard case .ready = state else { return }
            self.allDetails = AssetStore.shared.assets.filter {
                $0.collection?.openSeaSlug == self.collections[0]
            }
        }
    }

    init() {
        allDetails = AssetStore.shared.assets
        collections = AssetStore.shared.collections.map { $0.openSeaSlug }

        assetStoreSubscription = AssetStore.shared.$state.sink { state in
            guard case .ready = state else { return }
            self.allDetails = AssetStore.shared.assets
            self.collections = AssetStore.shared.collections.map { $0.openSeaSlug }
        }
    }
}

struct AssetGroupView: View {
    @EnvironmentObject var walletDetailsModel: WalletDetailsModel

    let assetGroup: AssetGroup
    @State var isPressed = false

    func collectionBadge(collection: String) -> some View {
        WebImage(
            url: AssetStore.shared.collections.first(where: { $0.openSeaSlug == collection })?
                .imageURL
        )
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)
        .clipShape(Circle())
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(
                action: {
                    walletDetailsModel.showingWalletDetails = true
                },
                label: {
                    ThumbnailGroupView(model: assetGroup)
                }
            )
            .buttonStyle(.reportsPresses(to: $isPressed))
            .scaleEffect(isPressed ? 0.95 : 1)
            HStack(alignment: .center) {
                Spacer(minLength: 12)
                ForEach(assetGroup.collections.prefix(4), id: \.self) { collection in
                    self.collectionBadge(collection: collection)
                }
                if assetGroup.collections.count > 5 {
                    Text("\(assetGroup.collections.count - 4)")
                        .withFont(.labelSmall)
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .frame(width: 18, height: 18)
                        .background(Color.ui.adaptive.blue)
                        .clipShape(Circle())
                } else if assetGroup.collections.count == 5 {
                    collectionBadge(collection: assetGroup.collections[4])
                }
                Spacer(minLength: 12)
            }.frame(height: CardUX.HeaderSize)
        }
        .shadow(radius: 0)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                AssetStore.shared.fetchCollections()
            }
        }
    }
}
