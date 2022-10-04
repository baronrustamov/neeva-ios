// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import UIKit

struct SpacesCardsView: View {
    @ObservedObject var viewModel: SpaceCardViewModel
    @Environment(\.columns) private var columns

    let refreshControl: UIRefreshControl

    var body: some View {
        LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
            ForEach(viewModel.dataSource, id: \.id) { details in
                FittedCard(details: details)
                    .id(details.id)
            }.introspectScrollView { scrollView in
                scrollView.refreshControl = refreshControl
            }
        }.animation(nil)
    }

    init(spacesModel: SpaceCardModel) {
        self.viewModel = spacesModel.viewModel
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(
            viewModel, action: #selector(viewModel.refreshSpacesFromPullDown(_:)),
            for: .valueChanged)
    }
}
