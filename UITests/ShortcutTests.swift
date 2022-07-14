// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import Client

class ShortcutTests: UITestBase {
    fileprivate var bvc: BrowserViewController!
    fileprivate var webRoot: String!

    override func setUp() {
        super.setUp()

        bvc = SceneDelegate.getBVCOrNil()
        webRoot = SimplePageServer.start()
    }

    // Runs the code path that a shortcut from the homescreen would call.
    private func simulateShortcutCase(incognito: Bool, openURL: Bool) {
        QuickActions.sharedInstance.handleOpenNewTab(
            withBrowserViewController: bvc, isIncognito: incognito)
        tester().waitForView(withAccessibilityLabel: "Cancel")

        if openURL {
            self.openURL(forceSkipAddressBar: true)

            // Make sure WebView is visible and Address Bar is closed.
            tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")
            XCTAssertFalse(tester().viewExistsWithLabel("Cancel"))
        } else {
            tester().tapView(withAccessibilityLabel: "Cancel")
            tester().waitForAnimationsToFinish()
        }
    }

    // MARK: - Opened Tab
    func testNewTabShortcut() {
        simulateShortcutCase(incognito: false, openURL: true)
        simulateShortcutCase(incognito: false, openURL: false)

        // Make sure WebView is visible and Address Bar is closed.
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")
        XCTAssertFalse(tester().viewExistsWithLabel("Cancel"))
    }

    func testNewTabIncognitoShortcut() {
        simulateShortcutCase(incognito: true, openURL: true)
        XCTAssertTrue(isSelectedTabIncognito())

        simulateShortcutCase(incognito: true, openURL: false)

        // Make sure WebView is visible and Address Bar is closed.
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")
        XCTAssertFalse(tester().viewExistsWithLabel("Cancel"))
    }

    // MARK: - CardGrid
    func testNewTabShortcutCardGrid() {
        goToCardGrid()
        simulateShortcutCase(incognito: false, openURL: false)

        // Make sure user is returned to CardGrid on cancel.
        tester().waitForView(withAccessibilityLabel: "Done")
    }

    func testNewTabIncognitoShortcutCardGrid() {
        goToCardGrid()
        simulateShortcutCase(incognito: true, openURL: false)

        // Make sure user is returned to CardGrid on cancel.
        tester().waitForView(withAccessibilityLabel: "Done")
        simulateShortcutCase(incognito: true, openURL: true)
        XCTAssertTrue(isSelectedTabIncognito())
    }
}
