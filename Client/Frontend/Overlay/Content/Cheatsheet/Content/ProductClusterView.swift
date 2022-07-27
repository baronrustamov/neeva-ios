// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct ProductClusterItem: View {
    let product: NeevaScopeSearch.Product

    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: product.thumbnailURL))
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 100, alignment: .center)
                .clipped()
                .cornerRadius(11, corners: .top)
            Text(product.productName)
                .withFont(.headingMedium)
                .foregroundColor(Color.label)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
            Spacer()
            if let priceLow = product.priceLow {
                Text("$\(priceLow, specifier: "%.2f")")
                    .font(.system(size: 14))
                    .foregroundColor(Color.label)
                    .bold()
                    .foregroundColor(Color.brand.charcoal)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
            }
        }
        .frame(width: 160, height: 200)
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(Color(light: Color.ui.gray91, dark: Color(hex: 0x383b3f)), lineWidth: 1)
        )
    }
}

struct ProductClusterList: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let model: CheatsheetMenuViewModel
    let products: [NeevaScopeSearch.Product]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Top Reviewed Products")
                .withFont(.headingMedium)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(products, id: \.thumbnailURL) { product in
                        ProductClusterItem(product: product)
                            .onTapGesture {
                                guard let url = model.targetURLForProduct(product) else {
                                    return
                                }
                                onOpenURLForCheatsheet(
                                    url, String(describing: ProductClusterItem.self)
                                )
                            }
                    }
                }
                .padding(.horizontal, CheatsheetUX.horizontalPadding)
            }
            .padding(.horizontal, -1 * CheatsheetUX.horizontalPadding)
        }
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
        .padding(.bottom, 16)
    }
}
