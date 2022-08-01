// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

enum CardControllerUX {
    static let Height: CGFloat = 75
}

struct CardStripContent: View {
    let tabCardModel: TabCardModel
    let spaceCardModel: SpaceCardModel
    let sitesCardModel: SiteCardModel
    let gridModel: GridModel
    @ObservedObject var cardStripModel: CardStripModel

    var width: CGFloat

    var body: some View {
        CardStripView()
            .environmentObject(tabCardModel)
            .environmentObject(spaceCardModel)
            .environmentObject(sitesCardModel)
            .environmentObject(cardStripModel)
            .environmentObject(gridModel)
            .offset(x: !cardStripModel.isVisible ? 0 : width - 50)
            .frame(height: CardControllerUX.Height)
    }

    init(bvc: BrowserViewController, width: CGFloat) {
        let tabManager = bvc.tabManager

        self.tabCardModel = TabCardModel(
            manager: tabManager)
        self.spaceCardModel = SpaceCardModel(
            manager: NeevaUserInfo.shared.isUserLoggedIn ? .shared : .suggested,
            scene: tabManager.scene)
        self.sitesCardModel = SiteCardModel(urls: [], tabManager: tabManager)
        self.cardStripModel = CardStripModel()
        self.gridModel = bvc.gridModel
        self.width = width
    }
}
