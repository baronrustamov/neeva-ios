// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

class SendFeedbackPanel: UIHostingController<AnyView> {
    init(
        requestId: String?, screenshot: UIImage?, url: URL?, query: String?,
        tabStats: TabManager.TabStats, onOpenURL: @escaping (URL) -> Void
    ) {
        super.init(rootView: AnyView(EmptyView()))

        var debugInfo: String = ""
        debugInfo += "\n\nActive Tabs (excluding zombies): \(tabStats.numberOfActiveNonZombieTabs)"
        debugInfo += "\nZombie Tabs: \(tabStats.numberOfActiveZombieTabs)"
        debugInfo += "\nArchived Tabs: \(tabStats.numberOfArchivedTabs)"

        rootView = AnyView(
            SendFeedbackView(
                screenshot: screenshot, url: url,
                onDismiss: { self.dismiss(animated: true, completion: nil) }, requestId: requestId,
                query: query,
                debugInfo: debugInfo
            ) { _ in
                // Wait for feedback UI to dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ToastDefaults().showToastForFeedback(
                        toastViewManager: SceneDelegate.getBVC(for: self.view)
                            .toastViewManager)
                }
            }
            .environment(\.onOpenURL, onOpenURL)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
