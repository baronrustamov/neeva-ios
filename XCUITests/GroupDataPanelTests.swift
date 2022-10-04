// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

/// Tests the functionality of the ArchivedTabs & History panel view.
class GroupDataPanelTests: BaseTestCase {
    func testOpenFromArchivedTabs() {
        goToTabTray()
        waitForExistence(app.buttons["Archived Tabs"])

        app.buttons["Archived Tabs"].tap()

        // Confirm the archived tab view opened.
        waitForExistence(app.buttons["Clear All Archived Tabs"])
        XCTAssertFalse(app.buttons["Clear Browsing Data"].exists)
    }

    func testOpenFromHistory() {
        goToHistory()

        // Confirm the history view opened.
        waitForExistence(app.buttons["Clear Browsing Data"])
        XCTAssertFalse(app.buttons["Clear All Archived Tabs"].exists)
    }

    func testToggleViews() {
        goToHistory()
        XCTAssertTrue(app.buttons["Clock"].isSelected)

        // Switch to archived tabs...
        app.buttons["Archive"].tap()
        XCTAssertTrue(app.buttons["Archive"].isSelected)
        waitForExistence(app.buttons["Clear All Archived Tabs"])

        // ... and back to history.
        app.buttons["Clock"].tap()
        XCTAssertTrue(app.buttons["Clock"].isSelected)
        waitForExistence(app.buttons["Clear Browsing Data"])
    }
}
