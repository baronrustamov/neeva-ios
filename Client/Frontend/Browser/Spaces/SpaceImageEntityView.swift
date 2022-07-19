// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import SwiftUI

struct SpaceImageEntityView: View {

    var url: URL
    @ObservedObject var details: SpaceEntityThumbnail

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            //To-Do: Fix resize issue
            AnimatedImage(url: url)
                .resizable()
                .scaledToFit()
                .background(Color.groupedBackground)
                .cornerRadius(SpaceViewUX.ThumbnailCornerRadius)
                .padding(.bottom, 8)
            if let title = details.title {
                HStack(spacing: 0) {
                    Text(title)
                        .withFont(.bodyLarge)
                        .lineLimit(1)
                        .foregroundColor(Color.label)
                    Spacer()
                    if details.isPinned {
                        SpacePinView()
                    }
                }
            }
            if let domain = details.data.url?.baseDomain {
                Text(domain)
                    .withFont(.bodySmall)
                    .lineLimit(1)
                    .foregroundColor(Color.secondaryLabel)
            }
        }
    }
}
