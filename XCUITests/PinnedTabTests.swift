// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class PinnedTabTests: BaseTestCase {
    override func setUp() {
        launchArguments.append("\(LaunchArguments.EnableFeatureFlags)pinnedTabImprovments")
        super.setUp()
    }

    private func createPinnedTab(addChild: Bool) {
        // Open URL and pin it.
        openURL()
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
        app.buttons["Example Domain, Tab"].press(forDuration: 1)

        waitForExistence(app.buttons["Pin Tab"])
        app.buttons["Pin Tab"].tap()
        waitForNoExistence(app.buttons["Pin Tab"])

        app.buttons["Example Domain, Tab"].tap()

        if addChild {
            // Create the placeholder tab.
            waitForExistence(app.links["More information..."])
            app.links["More information..."].tap()

        }
    }

    private func confirmOnlyPinnedTabExists() {
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
        XCTAssertFalse(app.buttons["IANA-managed Reserved Domains, Tab"].exists)
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 2)
    }

    func testPlaceholderTabCreatedAndBackNavigation() {
        createPinnedTab(addChild: true)

        // Confirm child tab.
        goToTabTray()
        waitForExistence(app.buttons["IANA-managed Reserved Domains, Tab"])
        XCTAssertTrue(app.buttons["Example Domain, Tab"].exists)

        // Go back to the pinned tab.
        app.buttons["IANA-managed Reserved Domains, Tab"].tap()
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()
        waitForExistence(app.links["More information..."])

        confirmOnlyPinnedTabExists()

    }

    func testMultipleChildTabs() {
        createPinnedTab(addChild: true)

        // Open another child tab.
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
        app.buttons["Example Domain, Tab"].tap()
        waitForExistence(app.links["More information..."])
        app.links["More information..."].tap()

        // Go back from first child.
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
        app.buttons["IANA-managed Reserved Domains, Tab"].firstMatch.tap()
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()
        waitForExistence(app.links["More information..."])

        // Go back from second child.
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
        app.buttons["IANA-managed Reserved Domains, Tab"].tap()
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()
        waitForExistence(app.links["More information..."])

        confirmOnlyPinnedTabExists()
    }

    func testComplicatedNavigationStack() {
        // Open tab and navigate somewhere.
        openURL()
        waitForExistence(app.links["More information..."])
        app.links["More information..."].tap()

        // Pin the tab.
        goToTabTray()
        waitForExistence(app.buttons["IANA-managed Reserved Domains, Tab"])
        app.buttons["IANA-managed Reserved Domains, Tab"].press(forDuration: 1)

        waitForExistence(app.buttons["Pin Tab"])
        app.buttons["Pin Tab"].tap()
        waitForNoExistence(app.buttons["Pin Tab"])

        app.buttons["IANA-managed Reserved Domains, Tab"].tap(force: true)

        // Create child tab.
        waitForExistence(app.links["RFC 2606"])
        app.links["RFC 2606"].tap()

        // Go to pinned tab and navigate back.
        goToTabTray()
        waitForExistence(app.buttons["IANA-managed Reserved Domains, Tab"])
        app.buttons["IANA-managed Reserved Domains, Tab"].tap()
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()

        // Return to child and navigate back.
        // Make sure the child tab is still open.
        goToTabTray()
        waitForExistence(app.buttons["RFC 2606: Reserved Top Level DNS Names, Tab"])
        app.buttons["RFC 2606: Reserved Top Level DNS Names, Tab"].tap()
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()
        XCTAssertEqual(getNumberOfTabs(), 3)

        // Open child and navigate back again.
        // Tab should close and return to the pinned tab.
        waitForExistence(app.buttons["IANA-managed Reserved Domains, Tab"])
        app.buttons["IANA-managed Reserved Domains, Tab"].tap()
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()

        confirmOnlyPinnedTabExists()
    }

    func testBackNavigationDoesntCreateNewTab() {
        // Open tab and navigate somewhere.
        openURL()
        waitForExistence(app.links["More information..."])
        app.links["More information..."].tap()

        // Pin the tab.
        goToTabTray()
        waitForExistence(app.buttons["IANA-managed Reserved Domains, Tab"])
        app.buttons["IANA-managed Reserved Domains, Tab"].press(forDuration: 1)

        waitForExistence(app.buttons["Pin Tab"])
        app.buttons["Pin Tab"].tap()
        waitForNoExistence(app.buttons["Pin Tab"])

        // Second tab is placeholder.
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 2)

        // Go back.
        app.buttons["IANA-managed Reserved Domains, Tab"].tap(force: true)
        waitForExistence(app.buttons["Back"])
        app.buttons["Back"].tap()
        waitForExistence(app.links["More information..."])

        // Verify only one tab still exists (+ placeholder).
        XCTAssertEqual(getNumberOfTabs(), 2)
    }
}
