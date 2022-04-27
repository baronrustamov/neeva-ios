// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct ProductClusterItem: View {
    let product: NeevaScopeSearch.Product
    let currentURL: String

    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    var body: some View {
        Button(action: onClick) {
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

    func onClick() {
        guard let sellers = product.sellers else { return }
        if sellers.count > 0 {
            for s in sellers {
                if !s.url.isEmpty && s.url != currentURL {
                    onOpenURLForCheatsheet(URL(string: s.url)!, String(describing: Self.self))
                    return
                }
            }
        }

        guard let reviews = product.buyingGuideReviews else { return }
        if reviews.count > 0 {
            for r in reviews {
                if !r.reviewURL.isEmpty && r.reviewURL != currentURL {
                    onOpenURLForCheatsheet(URL(string: r.reviewURL)!, String(describing: Self.self))
                }
            }
        }
    }
}

struct ProductClusterList: View {
    let products: [NeevaScopeSearch.Product]
    let currentURL: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Top Reviewed Products").withFont(.headingMedium)
                .padding(.leading, 12)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(products, id: \.thumbnailURL) { product in
                        ProductClusterItem(product: product, currentURL: currentURL)
                    }
                }
                .padding([.leading, .bottom], 12)
            }
        }
        .padding(.bottom, 16)
    }
}
