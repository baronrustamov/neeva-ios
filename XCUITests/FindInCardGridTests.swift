// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class FindInCardGridTests: BaseTestCase {
    private func performSearch() {
        openURL()
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()

        goToTabTray()
        goToOverflowMenuButton(label: "Search Tabs", shouldDismissOverlay: false) { button in
            button.tap(force: true)
        }

        // Perform search and make sure only the correct tab is shown.
        app.textFields["FindInCardGrid_TextField"].typeText("example.com")
        waitForNoExistence(app.buttons["The Book of Mozilla, Tab"])
        waitForExistence(app.buttons["Example Domain, Tab"])
    }

    /// Makes sure everything reset properly.
    private func confirmResetWorked() {
        XCTAssertFalse(app.buttons["FindInCardGrid_Done"].exists)
        XCTAssertTrue(app.buttons["Example Domain, Tab"].exists)
        XCTAssertTrue(app.buttons["The Book of Mozilla, Tab"].exists)

        // Makes sure the `GridPicker` is enabled.
        setIncognitoMode(enabled: true)
    }

    func testSearchForTab() {
        performSearch()

        // Close the view and make sure everything resets properly.
        app.buttons["FindInCardGrid_Done"].tap()
        confirmResetWorked()
    }

    func testSelectTabFromSearch() {
        performSearch()

        // Tap a tab and make sure everything resets properly.
        app.buttons["Example Domain, Tab"].tap()
        waitForExistence(app.links["More information..."])

        goToTabTray()
        confirmResetWorked()
    }
}
