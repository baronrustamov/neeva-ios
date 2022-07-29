// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct CardDragAndDropModifier: ViewModifier {
    @EnvironmentObject var tabModel: TabCardModel
    var tabCardDetail: TabCardDetails

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .onDrag {
                CardDropDelegate.draggingDetail = tabCardDetail
                return NSItemProvider(object: tabCardDetail.id as NSString)
            }
    }
}
