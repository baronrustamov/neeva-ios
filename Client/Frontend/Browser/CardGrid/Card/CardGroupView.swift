// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// MARK: ThumbnailGroup

enum ThumbnailGroupViewUX {
    static let Spacing: CGFloat = 6
    static let ShadowRadius: CGFloat = 2
    static let ThumbnailCornerRadius: CGFloat = 7
    static let ThumbnailsContainerRadius: CGFloat = 16
}

struct ThumbnailGroupView<Model: ThumbnailModel>: View {
    @ObservedObject var model: Model
    @Environment(\.cardSize) private var size
    @Environment(\.aspectRatio) private var aspectRatio

    var numItems: Int {
        if let eligibleSpaceEntities = eligibleSpaceEntities {
            return eligibleSpaceEntities.count
        } else {
            return model.allDetails.count
        }
    }

    var contentSize: CGFloat {
        size
    }

    var itemSize: CGFloat {
        (contentSize - ThumbnailGroupViewUX.Spacing) / 2 - ThumbnailGroupViewUX.ShadowRadius
    }

    var eligibleSpaceEntities: [SpaceEntityThumbnail]? {
        return (model.allDetails as? [SpaceEntityThumbnail])?.filter { $0.data.url != nil }
    }

    @ViewBuilder func itemFor(_ index: Int) -> some View {
        if index >= numItems {
            Color.DefaultBackground.frame(width: itemSize, height: itemSize * aspectRatio)
                .cornerRadius(ThumbnailGroupViewUX.ThumbnailCornerRadius)
        } else if let eligibleSpaceEntities = eligibleSpaceEntities {
            let item = eligibleSpaceEntities[index]
            item.thumbnail.frame(width: itemSize, height: itemSize * aspectRatio)
                .cornerRadius(ThumbnailGroupViewUX.ThumbnailCornerRadius)
        } else {
            let item = model.allDetails[index]
            item.thumbnail.frame(width: itemSize, height: itemSize * aspectRatio)
                .cornerRadius(ThumbnailGroupViewUX.ThumbnailCornerRadius)
        }
    }

    var body: some View {
        let vSpacing = ThumbnailGroupViewUX.Spacing * aspectRatio
        VStack(spacing: ThumbnailGroupViewUX.Spacing) {
            HStack(spacing: vSpacing) {
                itemFor(0)
                itemFor(1)
            }
            HStack(spacing: vSpacing) {
                itemFor(2)
                if numItems <= 4 {
                    itemFor(3)
                } else if numItems > 4 {
                    Text("+\(numItems - 3)")
                        .foregroundColor(Color.secondaryLabel)
                        .withFont(.labelLarge)
                        .frame(width: itemSize, height: itemSize * aspectRatio)
                        .background(Color.DefaultBackground)
                        .cornerRadius(ThumbnailGroupViewUX.ThumbnailCornerRadius)
                }
            }
        }
        .cornerRadius(ThumbnailGroupViewUX.ThumbnailsContainerRadius)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .shadow(color: Color.black.opacity(0.25), radius: 1)
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
    }
}
