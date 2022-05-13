/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI

extension BrowserViewController {
    func updateFindInPageVisibility(visible: Bool, tab: Tab? = nil, query: String? = nil) {
        if visible {
            findInPageModel = FindInPageModel(tab: tab ?? tabManager.selectedTab)

            overlayManager.show(
                overlay:
                    .find(
                        FindView(
                            content: .inPage(findInPageModel!),
                            onDismiss: {
                                self.updateFindInPageVisibility(visible: false, tab: tab)
                            })
                    ))

            findInPageModel!.searchValue = query ?? ""
        } else {
            if let currentOverlay = overlayManager.currentOverlay,
                case OverlayType.find = currentOverlay
            {
                overlayManager.hideCurrentOverlay(ofPriority: .modal, animate: false)
            }

            let tab = tab ?? tabManager.selectedTab
            guard let webView = tab?.webView else { return }
            webView.evaluateJavascriptInDefaultContentWorld("__firefox__.findDone()")

            findInPageModel = nil
        }
    }
}

extension BrowserViewController: FindInPageHelperDelegate {
    func findInPageHelper(
        _ findInPageHelper: FindInPageHelper, didUpdateCurrentResult currentResult: Int
    ) {
        findInPageModel?.currentIndex = currentResult
    }

    func findInPageHelper(
        _ findInPageHelper: FindInPageHelper, didUpdateTotalResults totalResults: Int
    ) {
        findInPageModel?.numberOfResults = totalResults
    }
}
