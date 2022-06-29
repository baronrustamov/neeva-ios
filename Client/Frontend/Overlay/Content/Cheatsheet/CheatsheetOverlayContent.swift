// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CheatsheetOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    private let menuAction: (OverflowMenuAction) -> Void
    private let model: CheatsheetMenuViewModel
    private let isIncognito: Bool
    private let tabManager: TabManager

    init(menuAction: @escaping (OverflowMenuAction) -> Void, tabManager: TabManager) {
        self.menuAction = menuAction
        self.model = tabManager.selectedTab?.cheatsheetModel ?? CheatsheetMenuViewModel(tab: nil)
        self.isIncognito = tabManager.incognitoModel.isIncognito
        self.tabManager = tabManager
    }

    var body: some View {
        CheatsheetMenuView { action in
            menuAction(action)
            hideOverlay()
        }
        .background(Color.DefaultBackground)
        .overlayIsFixedHeight(isFixedHeight: false)
        .environmentObject(model)
        .environment(\.onOpenURLForCheatsheet) { url, source in
            hideOverlay()
            ClientLogger.shared.logCounter(
                .OpenLinkFromCheatsheet,
                attributes:
                    EnvironmentHelper.shared.getAttributes()
                    + model.loggerAttributes
                    + [
                        ClientLogCounterAttribute(
                            key: LogConfig.CheatsheetAttribute.openLinkSource,
                            value: source
                        ),
                        ClientLogCounterAttribute(key: "url", value: url.absoluteString),
                    ]
            )
            self.tabManager.createOrSwitchToTab(for: url, from: self.tabManager.selectedTab)
        }
    }
}
