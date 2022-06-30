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
        guard let last = fullType.components(separatedBy: ".").last else { return nil }

        self.init(rawValue: last)
    }

    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
}

class QuickActions: NSObject {

    fileprivate let log = Logger.browser

    static let Version = "1.0"
    static let VersionKey = "dynamicQuickActionsVersion"

    static let TabURLKey = "url"
    static let TabTitleKey = "title"

    static var sharedInstance = QuickActions()

    var launchedShortcutItem: UIApplicationShortcutItem?

    // MARK: Administering Quick Actions
    func addDynamicApplicationShortcutItemOfType(
        _ type: ShortcutType, fromShareItem shareItem: ShareItem,
        toApplication application: UIApplication
    ) {
        var userData = [QuickActions.TabURLKey: shareItem.url]
        if let title = shareItem.title {
            userData[QuickActions.TabTitleKey] = title
        }
        QuickActions.sharedInstance.addDynamicApplicationShortcutItemOfType(
            type, withUserData: userData, toApplication: application)
    }

    @discardableResult func addDynamicApplicationShortcutItemOfType(
        _ type: ShortcutType, withUserData userData: [String: String] = [String: String](),
        toApplication application: UIApplication
    ) -> Bool {
        // add the quick actions version so that it is always in the user info
        var userData: [String: String] = userData
        userData[QuickActions.VersionKey] = QuickActions.Version

        let dynamicShortcutItems = application.shortcutItems ?? [UIApplicationShortcutItem]()
        application.shortcutItems = dynamicShortcutItems

        return true
    }

    func removeDynamicApplicationShortcutItemOfType(
        _ type: ShortcutType, fromApplication application: UIApplication
    ) {
        guard var dynamicShortcutItems = application.shortcutItems,
            let index = (dynamicShortcutItems.firstIndex { $0.type == type.type })
        else { return }

        dynamicShortcutItems.remove(at: index)
        application.shortcutItems = dynamicShortcutItems
    }

    // MARK: Handling Quick Actions
    @discardableResult func handleShortCutItem(
        _ shortcutItem: UIApplicationShortcutItem,
        withBrowserViewController bvc: BrowserViewController?
    ) -> Bool {
        guard let bvc = bvc else {
            return false
        }

        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard let shortCutType = ShortcutType(fullType: shortcutItem.type) else { return false }

        DispatchQueue.main.async {
            self.handleShortCutItemOfType(
                shortCutType, userData: shortcutItem.userInfo, browserViewController: bvc)
        }

        return true
    }

    fileprivate func handleShortCutItemOfType(
        _ type: ShortcutType, userData: [String: NSSecureCoding]?,
        browserViewController: BrowserViewController
    ) {
        switch type {
        case .newTab:
            handleOpenNewTab(withBrowserViewController: browserViewController, isIncognito: false)
        case .newIncognitoTab:
            handleOpenNewTab(withBrowserViewController: browserViewController, isIncognito: true)
        }
    }

    fileprivate func handleOpenNewTab(
        withBrowserViewController bvc: BrowserViewController, isIncognito: Bool
    ) {
        // Wait for animations that run when returning to foreground to finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let isEmpty =
                isIncognito
                ? bvc.tabManager.incognitoTabs.count == 0 : bvc.tabManager.normalTabs.count == 0
            bvc.openLazyTab(
                openedFrom: isEmpty ? .tabTray : .openTab(nil), switchToIncognitoMode: isIncognito
            )
        }
    }
}
