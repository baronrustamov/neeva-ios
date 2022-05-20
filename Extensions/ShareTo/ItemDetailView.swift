// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

struct ItemDetailView: View {
    @Binding var item: ShareItem

    var body: some View {
        HStack(alignment: .top, spacing: ShareToUX.padding) {
            WebImage(url: item.favicon?.url)
                .resizable()
                .background(Color.tertiarySystemFill)
                .frame(width: ShareToUX.thumbnailSize, height: ShareToUX.thumbnailSize)
                .cornerRadius(ShareToUX.spacing)
            VStack(alignment: .leading, spacing: ShareToUX.spacing) {
                if let title = item.title {
                    Text(title)
                        .withFont(.headingMedium)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let url = URL(string: item.url) {
                    URLDisplayView(url: url)
                }
                if let snippet = item.description {
                    SpaceMarkdownSnippet(
                        showDescriptions: false,
                        snippet: snippet,
                        lineLimit: 2
                    )
                }
            }
        }.padding(ShareToUX.padding)
    }

}
