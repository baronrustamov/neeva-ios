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
}
