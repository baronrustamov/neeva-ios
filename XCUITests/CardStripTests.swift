// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

class CardStripTests: IpadOnlyTestCase {
    func testSelectTab() throws {
        try skipIfNeeded()

        openURL()
        openURL(path(forTestPage: "test-mozilla-org.html"))

        // Select the other tab.
        waitForExistence(
            app.buttons["Internet for people, not profit — Mozilla, Card Strip Tab, Selected"]
        )
        app.buttons["Example Domain, Card Strip Tab"].tap()

        // Make sure it's selected.
        XCTAssertTrue(app.buttons["Example Domain, Card Strip Tab, Selected"].exists)
    }

    func testCloseTab() throws {
        try skipIfNeeded()

        closeAllTabs()
        openURL()
        openURL(path(forTestPage: "test-mozilla-org.html"))

        // Close the tab.
        waitForExistence(
            app.buttons["Close Card Strip Tab Internet for people, not profit — Mozilla"])
        app.buttons["Close Card Strip Tab Internet for people, not profit — Mozilla"].tap()

        // Confirm the CardStrip is hidden.
        waitForNoExistence(app.buttons["Example Domain, Card Strip Tab"])
        waitForExistence(app.staticTexts["Example Domain"])
    }

    func testSelectingTabGroup() throws {
        try skipIfNeeded()

        // Create tab group.
        openURL()
        waitForExistence(app.links["More information..."])
        app.links["More information..."].press(forDuration: 1)
        app.buttons["Open in New Tab"].tap()

        // Open regular tab and then confirm tab group is collapsed.
        openURL(path(forTestPage: "test-mozilla-org.html"))
        waitForExistence(app.buttons["Example Domain, Card Strip Tab Group Card"])

        // Tap the tab group and make sure it opens.
        app.buttons["Example Domain, Card Strip Tab Group Card"].tap()
        waitForExistence(app.buttons["Example Domain, Card Strip Tab, Selected"])
        waitForExistence(app.buttons["IANA-managed Reserved Domains, Card Strip Tab"])

        // And make sure the other tab is still opened.
        XCTAssertTrue(
            app.buttons["Internet for people, not profit — Mozilla, Card Strip Tab"].exists)
    }

    func testStripShowsHidesWhenNavigatingApp() throws {
        try skipIfNeeded()

        openURL()
        openURL(path(forTestPage: "test-mozilla-org.html"))
        waitForExistence(
            app.buttons["Internet for people, not profit — Mozilla, Card Strip Tab, Selected"])

        goToTabTray()
        waitForNoExistence(
            app.buttons["Internet for people, not profit — Mozilla, Card Strip Tab, Selected"])

        app.buttons["Done"].tap()
        waitForExistence(
            app.buttons["Internet for people, not profit — Mozilla, Card Strip Tab, Selected"])
    }

    func testPinnedTabsAppear() throws {
        try skipIfNeeded()

        openURL()
        openURL(path(forTestPage: "test-mozilla-org.html"))

        // Pin the tab.
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
        app.buttons["Example Domain, Tab"].press(forDuration: 1)
        app.buttons["Pin Tab"].tap()

        // Make sure pinned tab appears in the strip.
        waitForNoExistence(app.staticTexts["Tab Pinned"], timeoutValue: 30)
        app.buttons["Internet for people, not profit — Mozilla, Tab"].tap()
        waitForExistence(app.buttons["Example Domain, Card Strip Tab, Pinned"])

        // Tap the pinned tab.
        app.buttons["Example Domain, Card Strip Tab, Pinned"].tap()
        waitForExistence(app.buttons["Example Domain, Card Strip Tab, Pinned, Selected"])
    }
}
