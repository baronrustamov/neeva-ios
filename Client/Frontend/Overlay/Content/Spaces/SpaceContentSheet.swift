// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SpaceContentSheetUX {
    static let SpaceInfoThumbnailSize: CGFloat = 48
}

struct SpaceContentSheet: View {
    @ObservedObject var model: SpaceContentSheetModel
    var yOffset: CGFloat
    var footerHeight: CGFloat

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var useTopToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    private var isToolbarVisible: Bool {
        footerHeight - yOffset > 0
    }

    init(model: SpaceContentSheetModel, yOffset: CGFloat, footerHeight: CGFloat) {
        self.model = model
        self.yOffset = yOffset
        self.footerHeight = footerHeight
    }

    var body: some View {
        if let _ = model.currentSpaceEntityDetail {
            GeometryReader { geom in
                contentView
                    .offset(
                        x: 0,
                        y: calculateYPosition(with: geom)
                    )
            }
        }
    }

    private var contentView: some View {
        HStack(alignment: .center, spacing: 4) {
            SpacePageContent(model: model)
            closeButton
        }
        .padding(.leading, 16)
        .background(Color.DefaultBackground)
        .cornerRadius(16, corners: useTopToolbar ? .all : .top)
        .shadow(radius: 2)
    }

    private var closeButton: some View {
        Button(
            action: {
                model.didUserDismiss = true
            },
            label: {
                Image(systemName: "xmark")
                    .foregroundColor(.label)
                    .tapTargetFrame()
            })
    }

    private func calculateYPosition(with geometry: GeometryProxy) -> CGFloat {
        guard isToolbarVisible, !model.didUserDismiss else {
            return geometry.size.height + footerHeight
        }
        // there is a 1 px space between two views '+ 1' is fixing that
        return geometry.size.height - footerHeight + yOffset + 1
    }
}

struct SpacePageContent: View {
    @ObservedObject var model: SpaceContentSheetModel

    var body: some View {
        SpacePageSummary(
            details: model.currentSpaceEntityDetail,
            spaceDetails: model.currentSpaceDetail)
    }
}

struct SpacePageSummary: View {
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    let details: SpaceEntityThumbnail?
    let spaceDetails: SpaceCardDetails?

    var body: some View {
        if let details = details {
            VStack(spacing: 7) {
                if let spaceDetails = spaceDetails {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            ForEach(spaceDetails.allDetails, id: \.id) { entity in
                                if let url = entity.manager.get(for: entity.id)?
                                    .primitiveUrl
                                {
                                    Button(
                                        action: { onOpenURLForSpace(url, spaceDetails.id) },
                                        label: {
                                            entity.thumbnail.frame(
                                                width: SpaceContentSheetUX.SpaceInfoThumbnailSize
                                                    * (entity.id == details.id ? 1 : 0.8),
                                                height: SpaceContentSheetUX.SpaceInfoThumbnailSize
                                                    * (entity.id == details.id ? 1 : 0.8)
                                            ).cornerRadius(SpaceViewUX.ThumbnailCornerRadius)
                                        })
                                }
                            }
                        }
                    }
                } else {
                    details.thumbnail.frame(
                        width: SpaceContentSheetUX.SpaceInfoThumbnailSize,
                        height: SpaceContentSheetUX.SpaceInfoThumbnailSize
                    ).cornerRadius(SpaceViewUX.ThumbnailCornerRadius)

                }
            }
            .padding(.vertical, 20)
        }
    }

}
