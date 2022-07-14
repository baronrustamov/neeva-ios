// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel

    var body: some View {
        ForEach(spacesModel.detailsMatchingFilter, id: \.id) { details in
            FittedCard(details: details)
                .id(details.id)
        }.accessibilityHidden(spacesModel.detailedSpace != nil)
    }
}
