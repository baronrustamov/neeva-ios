// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

class SimulatedSwipeModel: ObservableObject {
    @Published var hidden = true
    @Published var overlayOffset: CGFloat = 0 {
        didSet {
            contentOffset = overlayOffset
        }
    }
    @Published var contentOffset: CGFloat = 0

    let tabManager: TabManager
    let chromeModel: TabChromeModel
    let swipeDirection: SwipeDirection
    var forwardUrlMap = [String: [URL]?]()
    var progressModel = CarouselProgressModel(urls: [], index: 0)

    func canGoBack() -> Bool {
        return swipeDirection == .back && !hidden
    }

    func canGoForward() -> Bool {
        return swipeDirection == .forward && !hidden
    }

    @discardableResult func goBack() -> Bool {
        guard canGoBack(),
            swipeDirection == .back,
            let tab = tabManager.selectedTab
        else {
            return false
        }

        if let _ = tab.parent {
            tabManager.removeTab(tab, showToast: false)
            return true
        } else if let id = tab.parentSpaceID {
            SceneDelegate.getBVC(with: tabManager.scene).browserModel.openSpace(spaceID: id)
            return true
        }

        return false
    }

    @discardableResult func goForward() -> Bool {
        guard canGoForward(), swipeDirection == .forward, let tab = tabManager.selectedTab,
            let urls = forwardUrlMap[tab.tabUUID]!
        else {
            return false
        }

        let index = urls.firstIndex(of: tab.currentURL()!) ?? -1
        tab.loadRequest(URLRequest(url: urls[index + 1]))
        return true
    }

    init(tabManager: TabManager, chromeModel: TabChromeModel, swipeDirection: SwipeDirection) {
        self.tabManager = tabManager
        self.chromeModel = chromeModel
        self.swipeDirection = swipeDirection
    }
}
