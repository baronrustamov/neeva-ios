// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class EmptyTabTrayTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)

        super.setUp()
    }

    func openThreeTabs() {
        openURLInNewTab()
        openURLInNewTab()
        openURLInNewTab()
    }

    func testEmptyTabTrayShowsOnLaunch() {
        // Can assume no tabs are saved between tests
        waitForExistence(app.staticTexts["EmptyTabTray"], timeout: 30)
    }

    func testEmptyTabTrayShowsAfterClosingTab() {
        openURLInNewTab()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingTabFromTabTray() {
        openURLInNewTab()
        goToTabTray()

        app.buttons["Close"].tap(force: true)

        waitForExistence(app.staticTexts["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingAllTabs() {
        openThreeTabs()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])
        waitForExistence(app.buttons["Add Tab"])
    }

    func testEmptyTabTrayShowsAfterClosingAllTabsFromTabTray() {
        openThreeTabs()
        goToTabTray()
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])
        waitForExistence(app.buttons["Add Tab"])
    }

    /// Tests that when closing all incognito tabs, and no normal tabs exist that empty tab tray is shown
    func testEmptyTabTrayShowsAfterClosingAllIncognitoTabs() {
        setIncognitoMode(enabled: true)
        openThreeTabs()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTrayIncognito"])
        waitForExistence(app.buttons["Add Tab"])
    }

    func testEmptyTabTrayShowsAfterClosingAllIncognitoTabsFromTabTray() {
        setIncognitoMode(enabled: true)
        openThreeTabs()
        goToTabTray()
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTrayIncognito"])
        waitForExistence(app.buttons["Add Tab"])
    }

    func testTabTrayShowsTabs() {
        openURLInNewTab()
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
    }

    // https://github.com/neevaco/neeva-ios/issues/2595
    func testTabGroupWorksAfterClosingLastTab() {
        openURLInNewTab("https://example.com")

        waitForExistence(app.links["More information..."])
        app.links["More information..."].press(forDuration: 0.5)

        waitForExistence(app.buttons["Open in New Tab"])
        app.buttons["Open in New Tab"].tap()

        waitForNoExistence(app.buttons["Switch"], timeoutValue: 30)
        setIncognitoMode(enabled: true)
        openURLInNewTab("https://test.example/")
        goToTabTray()

        waitForExistence(app.buttons["Close"].firstMatch)
        app.buttons["Close"].firstMatch.tap(force: true)

        setIncognitoMode(enabled: false, closeTabTray: false)
        app.buttons["Tab Group, Example Domain"].tap()
        XCTAssert(app.buttons["Example Domain, Tab"].exists)
    }

    func testDoneButtonState() {
        // Test disabled on start
        XCTAssertEqual(app.buttons["Done"].value as! String, "Disabled")

        openURLInNewTab()

        // Make sure it's enabled
        goToTabTray()
        waitForValueContains(app.buttons["Done"], value: "Enabled")

        // Make sure it's disabled
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)
        waitForValueContains(app.buttons["Done"], value: "Disabled")
    }
}
