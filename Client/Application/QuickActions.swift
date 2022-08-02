/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import XCGLogger

enum ShortcutType: String {
    case newTab = "NewTab"
    case newIncognitoTab = "NewIncognitoTab"

    init?(fullType: String) {
        // The full type looks like this: co.neeva.app.ios.browser[-dev].NewTab
        guard let last = fullType.components(separatedBy: ".").last else { return nil }

        self.init(rawValue: last)
    }
}

class QuickActions {
    static let sharedInstance = QuickActions()

    // MARK: Handling Quick Actions
    func handleShortcutItem(
        _ shortcutItem: UIApplicationShortcutItem,
        withBrowserViewController bvc: BrowserViewController?
    ) -> Bool {
        guard let bvc = bvc, let shortcutType = ShortcutType(fullType: shortcutItem.type) else {
            return false
        }

        DispatchQueue.main.async { [self] in
            handleOpenNewTab(
                withBrowserViewController: bvc, isIncognito: shortcutType == .newIncognitoTab)
        }

        return true
    }

    func handleOpenNewTab(
        withBrowserViewController bvc: BrowserViewController, isIncognito: Bool
    ) {
        bvc.openLazyTab(
            openedFrom: bvc.browserModel.showGrid ? .tabTray : .newTabButton,
            switchToIncognitoMode: isIncognito)
    }
}
