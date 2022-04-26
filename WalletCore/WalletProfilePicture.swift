// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

public struct WalletProfilePicture: View {

    private let size: CGSize
    @Default(.walletProfilePictureAssetId) var assetId

    public init(size: CGSize) {
        self.size = size
    }

    public var body: some View {
        if let assetId = assetId,
            let asset = AssetStore.shared.assets.first(where: { $0.id == assetId })
        {
            WebImage(
                url: asset.imageURL,
                context: [
                    .imageThumbnailPixelSize: CGSize(
                        width: 64,
                        height: 64)
                ]
            )
            .resizable()
            .frame(width: size.width, height: size.height)
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(WalletTheme.gradient)
                .frame(width: size.width, height: size.height)
        }
    }
}
