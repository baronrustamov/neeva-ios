// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

struct SpaceCardsView: View {
    @ObservedObject var viewModel: SpaceCardViewModel
    @Environment(\.columns) private var columns

    init(spacesModel: SpaceCardModel) {
        self.viewModel = spacesModel.viewModel
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
            ForEach(viewModel.dataSource, id: \.id) { details in
                FittedCard(details: details)
                    .id(details.id)
            }
        }.animation(nil)

    }
}
