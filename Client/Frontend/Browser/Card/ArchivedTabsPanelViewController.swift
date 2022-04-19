// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// UIKit wrapper for `HistoryPanelView`.
class ArchivedTabsPanelViewController: UIHostingController<AnyView> {
    init(bvc: BrowserViewController) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            ArchivedTabsPanelView(model: ArchivedTabsPanelModel(tabManager: bvc.tabManager)) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }.environment(
                \.onOpenURL,
                { bvc.tabManager.createOrSwitchToTab(for: $0) }
            )
            .environmentObject(bvc.browserModel)
            .environmentObject(bvc.browserModel.scrollingControlModel)
            .environmentObject(bvc.chromeModel)
            .environmentObject(bvc.overlayManager)
        )
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
