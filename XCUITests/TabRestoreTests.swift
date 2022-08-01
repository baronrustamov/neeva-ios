// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class TabRestoreTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        super.setUp()
    }

    func testRestoredTabCanBeClosed() {
        openURL()

        goToTabTray()
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)

        app.buttons["Close"].tap()
        waitForNoExistence(app.buttons["Close"])
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 0)

        app.buttons["Add Tab"].press(forDuration: 2)

        waitForExistence(app.collectionViews.firstMatch.buttons["Example Domain"])
        app.collectionViews.firstMatch.buttons["Example Domain"].tap()

        waitForExistence(app.buttons["Close"])
        app.buttons["Close"].tap()
        waitForNoExistence(app.buttons["Close"])
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 0)
    }

    func testRestoreTabGroup() {
        openURL()

        // Create the tab group.
        app.links["More information..."].press(forDuration: 1)
        waitForExistence(app.buttons["Open in New Tab"])
        app.buttons["Open in New Tab"].tap()
        waitForNoExistence(app.buttons["Switch"], timeoutValue: 30)

        // Close both the tabs.
        waitForExistence(app.buttons["Show Tabs"])
        app.buttons["Show Tabs"].press(forDuration: 1)
        waitForExistence(app.buttons["Close Tab"])
        app.buttons["Close Tab"].tap()

        waitForExistence(app.buttons["Show Tabs"])
        app.buttons["Show Tabs"].press(forDuration: 1)
        waitForExistence(app.buttons["Close Tab"])
        app.buttons["Close Tab"].tap()

        // Restore the first tab.
        app.buttons["Add Tab"].press(forDuration: 2)
        waitForExistence(app.buttons["Example Domain"])
        app.buttons["Example Domain"].tap()

        // Confirm the first tab doesn't show and restore the second.
        app.buttons["Add Tab"].press(forDuration: 2)
        waitForExistence(app.buttons["IANA-managed Reserved Domains"])
        waitForNoExistence(app.buttons["Example Domain"])
        app.buttons["IANA-managed Reserved Domains"].tap()

        // Make sure the restore tab menu can't be opened.
        // (Should open the ZeroQuery)
        app.buttons["Add Tab"].press(forDuration: 2)
        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 2)

        // Confirm tab group exists.
        XCTAssertTrue(app.staticTexts["TabGroupTitle"].exists)
    }
}
