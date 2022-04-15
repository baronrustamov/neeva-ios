// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum SpaceViewUX {
    static let Padding: CGFloat = 4
    static let ThumbnailCornerRadius: CGFloat = 6
    static let ThumbnailSize: CGFloat = 54
    static let DetailThumbnailSize: CGFloat = 72
    static let ItemPadding: CGFloat = 14
    static let EditingRowInset: CGFloat = 8
}

struct SpaceContainerView: View {
    @State private var headerVisible = true
    @ObservedObject var primitive: SpaceCardDetails

    var space: Space? {
        primitive.space
    }

    var body: some View {
        VStack(spacing: 0) {
            SpaceTopView(primitive: primitive, headerVisible: $headerVisible)
            if primitive.space == nil && primitive.allDetails.isEmpty && !(space?.isDigest ?? false)
            {
                EmptySpaceView()
            } else {
                SpaceDetailList(primitive: primitive, headerVisible: $headerVisible)
            }
        }
        .navigationBarHidden(true)
    }

}

// Allows the NavigationView to keep the swipe back interaction,
// while also hiding the navigation bar.

//To-Do: Figurate a better way to do
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
