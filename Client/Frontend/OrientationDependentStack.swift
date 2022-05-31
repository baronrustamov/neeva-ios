// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct OrientationDependentStack<Content: View>: View {
    let orientation: UIDeviceOrientation
    var VStackAlignment: HorizontalAlignment = .center
    var spacing: CGFloat = 0

    @ViewBuilder var content: Content

    @ViewBuilder
    var body: some View {
        if orientation.isLandscape {
            HStack(spacing: spacing) {
                content
            }
        } else {
            VStack(alignment: VStackAlignment, spacing: spacing) {
                content
            }
        }
    }
}
