// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct SpaceEntityThumbnailView: View {

    let details: SpaceEntityThumbnail

    var body: some View {
        if case .techDoc = details.data.previewEntity {
            EmptyView()
        } else {
            details.thumbnail.frame(
                width: SpaceViewUX.DetailThumbnailSize,
                height: SpaceViewUX.DetailThumbnailSize
            )
            .cornerRadius(SpaceViewUX.ThumbnailCornerRadius)
        }
    }
}
