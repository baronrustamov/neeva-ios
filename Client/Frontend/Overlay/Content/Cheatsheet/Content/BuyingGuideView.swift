// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct BuyingGuideListItem: View {
    let guide: NeevaScopeSearch.BuyingGuide
    let index: Int
    let total: Int
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    var body: some View {
        Button(action: onClick) {
            HStack {
                WebImage(url: URL(string: guide.thumbnailURL))
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120, alignment: .center)
                    .clipped()
                    .cornerRadius(11)

                VStack(alignment: .leading) {
                    if let reviewType = guide.reviewType {
                        Text(reviewType)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .textCase(.uppercase)
                            .font(.system(size: 11).bold())
                            .foregroundColor(
                                Color(light: .brand.variant.blue, dark: Color(hex: 0x7cabe4)))
                        Spacer()
                    }
                    if let productName = guide.productName {
                        Text(productName)
                            .lineLimit(1)
                            .font(.system(size: 12))
                        Spacer()
                    }
                    if let reviewSummary = guide.reviewSummary {
                        Text(reviewSummary)
                            .lineLimit(2)
                            .font(.system(size: 10).italic())
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    HStack {
                        if let price = guide.price {
                            Text(price)
                                .font(.system(size: 14))
                        }
                        Spacer()
                        Text("\(index + 1) OF \(total)")
                            .font(.system(size: 11))
                    }
                }
                .foregroundColor(.label)
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
            }
            .frame(width: 270, height: 125, alignment: .leading)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(Color(light: Color.ui.gray91, dark: Color(hex: 0x383b3f)), lineWidth: 1)
            )
        }
    }

    func onClick() {
        onOpenURLForCheatsheet(guide.actionURL, String(describing: Self.self))
    }
}

struct BuyingGuideListView: View {
    let buyingGuides: [NeevaScopeSearch.BuyingGuide]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(buyingGuides.enumerated()), id: \.0) { index, item in
                    BuyingGuideListItem(guide: item, index: index, total: buyingGuides.count)
                }
            }
            .padding(.horizontal, CheatsheetUX.horizontalPadding)
        }
        .padding(.horizontal, -1 * CheatsheetUX.horizontalPadding)
    }
}

struct ReviewURLButton: View {
    let url: URL
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    var body: some View {
        Button(action: {
            onOpenURLForCheatsheet(url, String(describing: Self.self))
        }) {
            getHostName()
        }
    }

    @ViewBuilder
    func getHostName() -> some View {
        let host = url.baseDomain?.replacingOccurrences(of: ".com", with: "")
        let lastPath = url.lastPathComponent
            .replacingOccurrences(of: ".html", with: "")
            .replacingOccurrences(of: "-", with: " ")
        if host != nil {
            HStack {
                Text(host!).bold()
                if !lastPath.isEmpty {
                    Text("(")
                        + Text(lastPath)
                        + Text(")")
                }
            }
            .withFont(unkerned: .bodyMedium)
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1).padding(-6)
            )
            .padding(6)
            .foregroundColor(.secondaryLabel)
        }
    }
}

struct BuyingGuideView: View {
    let reviewURLs: [URL]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Buying Guide").withFont(.headingMedium)
            ForEach(reviewURLs, id: \.self) { url in
                ReviewURLButton(url: url)
            }
        }
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
    }
}
