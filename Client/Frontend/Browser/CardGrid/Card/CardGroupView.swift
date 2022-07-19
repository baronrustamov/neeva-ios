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

struct RoundedCorners: Shape {
    var corners: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(corners[1], h / 2), w / 2)
        let tl = min(min(corners[0], h / 2), w / 2)
        let bl = min(min(corners[2], h / 2), w / 2)
        let br = min(min(corners[3], h / 2), w / 2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(
            center: CGPoint(x: w - tr, y: tr), radius: tr,
            startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(
            center: CGPoint(x: w - br, y: h - br), radius: br,
            startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(
            center: CGPoint(x: bl, y: h - bl), radius: bl,
            startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(
            center: CGPoint(x: tl, y: tl), radius: tl,
            startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
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

    var columns: [GridItem] {
        Array(
            repeating: GridItem(
                .fixed(itemSize),
                spacing: ThumbnailGroupViewUX.Spacing,
                alignment: .top),
            count: 2)
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
        .drawingGroup()
        .shadow(color: Color.black.opacity(0.25), radius: 1)
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
    }
}

// MARK: ColorThumbnail for Preview

private class PreviewThumbnailModel: ThumbnailModel {

    fileprivate struct ColorThumbnail: SelectableThumbnail {
        let color: Color
        var thumbnail: some View { color }

        func onSelect() {}
    }

    let color: Color
    var num: Int

    init(color: Color, num: Int) {
        self.color = color
        self.num = num
    }

    var allDetailsWithExclusionList: [ColorThumbnail] {
        allDetails
    }

    var allDetails: [ColorThumbnail] {
        set(newDetails) {
            num = newDetails.count
        }

        get {
            Array(repeating: ColorThumbnail(color: color), count: num)
        }
    }
}

struct CardGroupView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .red, num: 1))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .blue, num: 3))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .black, num: 4))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .green, num: 5))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .purple, num: 8))
        }
    }
}
