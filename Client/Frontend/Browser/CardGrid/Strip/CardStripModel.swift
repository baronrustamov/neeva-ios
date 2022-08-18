// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared

class CardStripModel: ObservableObject {
    let incognitoModel: IncognitoModel
    let tabCardModel: TabCardModel
    let tabChromeModel: TabChromeModel

    @Published var shouldEmbedInScrollView = false

    var rows: [Row] {
        incognitoModel.isIncognito
            ? tabCardModel.incognitoRows : tabCardModel.timeBasedNormalRows[.today] ?? []
    }

    private var detailCount: Int {
        incognitoModel.isIncognito
            ? tabCardModel.incognitoDetails.count
            : tabCardModel.allDetails.filter { $0.tab.isIncluded(in: [.pinned, .today]) }.count
    }

    var showCardStrip: Bool {
        return FeatureFlag[.cardStrip] && tabChromeModel.inlineToolbar
            && !tabChromeModel.isEditingLocation
            && detailCount > 1
    }

    init(incognitoModel: IncognitoModel, tabCardModel: TabCardModel, tabChromeModel: TabChromeModel)
    {
        self.incognitoModel = incognitoModel
        self.tabCardModel = tabCardModel
        self.tabChromeModel = tabChromeModel
    }
}
