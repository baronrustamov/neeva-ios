// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class RecentlyClosedTests: BaseTestCase {
    private func showRecentlyClosedTabs() {
        if !app.buttons["Add Tab"].exists {
            goToTabTray()
        }

        app.buttons["Add Tab"].press(forDuration: 1)
    }

    func testRecentlyClosedOptionAvailable() {
        openURL()
        closeAllTabs(createNewTab: false)

        goToRecentlyClosedPage()
        app.buttons["History"].tap()
        app.buttons["Done"].firstMatch.tap(force: true)

        // This option should be enabled on private mode too.
        setIncognitoMode(enabled: true, shouldOpenURL: false)
        goToRecentlyClosedPage()
    }

    func testRecentlyClosedMenuAvailable() {
        openURL()
        waitUntilPageLoad()
        closeAllTabs(createNewTab: false)

        showRecentlyClosedTabs()
        XCTAssertTrue(app.buttons["Example Domain"].exists)
    }

    // MARK: - Open in New Tab
    func testOpenInNewTabRecentlyClosedItemFromMenu() {
        openURL()
        waitUntilPageLoad()
        closeAllTabs(createNewTab: false)

        showRecentlyClosedTabs()
        app.buttons["Example Domain"].tap()

        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }

    func testOpenInNewTabRecentlyClosedItem() {
        // Test the recently closed tab page
        openURL()
        closeAllTabs(createNewTab: false)
        goToRecentlyClosedPage()

        app.buttons["Example Domain"].press(forDuration: 1)
        app.buttons["Open in new tab"].tap()
        app.buttons["History"].tap()
        app.buttons["Done"].firstMatch.tap(force: true)

        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }

    func testOpenInNewIncognitoTabRecentlyClosedItem() {
        // Open the default website
        openURL()
        closeAllTabs(createNewTab: false)
        goToRecentlyClosedPage()

        app.buttons["Example Domain"].press(forDuration: 1)
        app.buttons["Open in new incognito tab"].tap()
        app.buttons["History"].tap()
        app.buttons["Done"].firstMatch.tap(force: true)

        setIncognitoMode(enabled: true, shouldOpenURL: false, closeTabTray: false)

        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }

    func testIncognitoClosedSiteDoesNotAppearOnRecentlyClosedMenu() {
        setIncognitoMode(enabled: true)
        closeAllTabs()
        showRecentlyClosedTabs()
        XCTAssertFalse(app.buttons["Example Domain"].exists)
    }
}
