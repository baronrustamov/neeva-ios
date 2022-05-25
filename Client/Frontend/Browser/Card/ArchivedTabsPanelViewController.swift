// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

class ArchivedTabsPanelViewController: UIHostingController<AnyView> {
    init(browserModel: BrowserModel) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            ArchivedTabsPanelView(
                model: ArchivedTabsPanelModel(tabManager: browserModel.tabManager)
            ) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }.environment(
                \.onOpenURL,
                {
                    browserModel.tabManager.createOrSwitchToTab(for: $0)
                    browserModel.hideGridWithNoAnimation()
                }
            ).environment(
                \.selectionCompletion, { browserModel.hideGridWithNoAnimation() }
            )
        )
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
