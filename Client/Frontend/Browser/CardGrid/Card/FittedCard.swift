// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

/// A card that constrains itself to the default height and provided width.
struct FittedCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    var dragToClose: Bool = FeatureFlag[.swipeToCloseTabs]

    @Environment(\.cardSize) private var cardSize
    @Environment(\.aspectRatio) private var aspectRatio

    var body: some View {
        Card(details: details, dragToClose: dragToClose)
            .frame(width: cardSize, height: cardSize * aspectRatio + CardUX.HeaderSize)
    }
}
