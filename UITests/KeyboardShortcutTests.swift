// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import Client

class KeyboardShortcutTests: UITestBase {
    var bvc: BrowserViewController!
    fileprivate var webRoot: String!

    override func setUp() {
        super.setUp()

        bvc = SceneDelegate.getBVC(for: nil)
        webRoot = SimplePageServer.start()
    }

    func openMultipleTabs(tester: KIFUITestActor) {
        for _ in 0...3 {
            openNewTab()
            tester.waitForWebViewElementWithAccessibilityLabel("Example Domain")
        }
    }

    func previousTab(tester: KIFUITestActor) {
        closeAllTabs()

        openNewTab(to: "\(webRoot!)/numberedPage.html?page=1")
        tester.waitForWebViewElementWithAccessibilityLabel("Page 1")

        openNewTab()
        tester.waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.previousTabKeyCommand()
    }

    // MARK: Find in Page
    func testFindInPageKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.findInPageKeyCommand()
        tester().waitForView(withAccessibilityLabel: "Done")
    }

    // MARK: UI
    func testSelectLocationBarKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()

        bvc.selectLocationBarKeyCommand()
        openURL()
    }

    func testShowTabTrayKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.showTabTrayKeyCommand()
        tester().waitForView(withAccessibilityLabel: "Normal Tabs")
    }

    // MARK: Tab Mangement
    func testNewTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        bvc.newTabKeyCommand()

        // Make sure Lazy Tab popped up
        tester().waitForView(withAccessibilityLabel: "Cancel")
    }

    func testNewIncognitoTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.newIncognitoTabKeyCommand()

        // Make sure Lazy Tab popped up
        tester().waitForView(withAccessibilityLabel: "Cancel")

        XCTAssert(bvc.incognitoModel.isIncognito == true)
    }

    func testNextTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        previousTab(tester: tester())
        bvc.nextTabKeyCommand()

        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.activeTabs[1])
    }

    func testPreviousTabCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        previousTab(tester: tester())

        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.activeTabs[0])
    }

    // MARK: - Close Tabs
    func testCloseTabCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        // Doesn't matter what this URL is, we don't need the page to load.
        openNewTab(to: "\(webRoot!)/numberedPage.html?page=1")
        tester().waitForAnimationsToFinish()

        bvc.closeTabKeyCommand()

        // Confirm the first tab opened is visible.
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")
    }

    func testCloseAllTabsCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openMultipleTabs(tester: tester())
        bvc.closeAllTabsCommand()

        tester().waitForView(withAccessibilityLabel: "Empty Card Grid")
    }

    func testRestoreTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openMultipleTabs(tester: tester())
        closeAllTabs()
        bvc.restoreTabKeyCommand()

        XCTAssert(bvc.tabManager.activeTabs.count > 1)
    }
}
