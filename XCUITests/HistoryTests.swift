/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let webpage = [
    "url": "www.mozilla.org", "label": "Internet for people, not profit — Mozilla",
    "value": "mozilla.org",
]
let oldHistoryEntries: [String] = [
    "Internet for people, not profit — Mozilla", "Twitter", "Home - YouTube",
]
// This is part of the info the user will see in recent closed tabs once the default visited website (https://www.mozilla.org/en-US/book/) is closed
let closedWebPageLabel = "localhost:\(serverPort)/test-fixture/test-mozilla-book.html"

class HistoryTests: BaseTestCase {
    // This DDBB contains those 4 websites listed in the name
    let historyDB = "browserYoutubeTwitterMozillaExample.db"
    let clearBrowsingDataOptions = [
        "Browsing History", "Archived Tabs", "Cache", "Cookies", "Cookie Cutter Exclusions",
    ]

    override func setUp() {
        launchArguments = [
            LaunchArguments.SkipIntro, LaunchArguments.SetSignInOnce,
            LaunchArguments.SetDidFirstNavigation, LaunchArguments.SkipWhatsNew,
            LaunchArguments.SkipETPCoverSheet, LaunchArguments.DeviceName,
            "\(LaunchArguments.ServerPort)\(serverPort)",
            "\(LaunchArguments.EnableNeevaFeatureBoolFlags)40640",
            LaunchArguments.DisableCheatsheetBloomFilters,
            LaunchArguments.LoadDatabasePrefix + historyDB, LaunchArguments.DontAddTabOnLaunch,
        ]

        super.setUp()
    }

    private func clearWebsiteData() {
        goToSettings()

        waitForExistence(app.cells["Clear Browsing Data"])
        app.cells["Clear Browsing Data"].tap()
        app.cells["Clear Selected Data on This Device"].tap()

        waitForExistence(app.buttons["Clear Data"])
        app.buttons["Clear Data"].tap()
        waitForNoExistence(app.buttons["Clear Data"])

        app.buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Done"].tap()
    }

    // MARK: - Clear Data
    func testClearHistoryFromSettings() {
        // Go to Clear Data
        clearWebsiteData()

        // Make sure history is empty.
        goToHistory()
        waitForExistence(app.staticTexts["History List Empty"])
    }

    func testClearPrivateDataButtonDisabled() {
        // Clear private data from settings and confirm
        clearPrivateData()

        // Wait for OK pop-up to disappear after confirming
        waitForNoExistence(app.alerts.buttons["Clear Data"], timeoutValue: 5)

        // Assert that the button has been replaced with a success message
        XCTAssertFalse(app.tables.cells["Clear Selected Data on This Device"].exists)
    }

    // MARK: - Clear History
    func testAllClearOptionsArePresent() {
        openURLInNewTab()
        goToHistory()

        waitForExistence(app.buttons["Clear Browsing Data"])
        app.buttons["Clear Browsing Data"].tap()

        for option in clearBrowsingDataOptions {
            XCTAssertTrue(
                app.cells.containing(NSPredicate(format: "label CONTAINS %@", option)).element
                    .exists)
        }
    }

    func testClearBrowsingDataNeevaMemoryNavigationInHistory() {
        openURLInNewTab()
        goToHistory()

        waitForExistence(app.buttons["Clear Browsing Data"])
        app.buttons["Clear Browsing Data"].tap()

        waitForExistence(app.buttons["Manage Neeva Memory"])
        app.buttons["Manage Neeva Memory"].tap()

        // Make sure we are back to main screen with overflow menu button
        waitForExistence(app.buttons["Tracking Protection"])
    }

    // MARK: - Delete
    func testDeleteItem() {
        goToHistory()

        waitForExistence(app.buttons["Twitter"])
        app.buttons["Twitter"].press(forDuration: 1)
        app.buttons["Delete"].tap()

        waitForNoExistence(app.buttons["Twitter"])
    }

    // MARK: - Open
    func testOpenItemOnTap() {
        goToHistory()
        waitForExistence(app.buttons["Twitter"])
        app.buttons["Twitter"].tap()

        XCTAssertEqual(getNumberOfTabs(), 1)
    }

    // MARK: - Open in New Tab
    func testOpenInNewTab() {
        goToHistory()

        waitForExistence(app.buttons["Twitter"])
        app.buttons["Twitter"].press(forDuration: 1)
        app.buttons["Open in new tab"].tap()

        waitForExistence(app.buttons["Switch"])
        app.buttons["Done"].firstMatch.tap(force: true)

        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }

    func testOpenInNewIncognitoTab() {
        goToHistory()

        waitForExistence(app.buttons["Twitter"])
        app.buttons["Twitter"].press(forDuration: 1)
        app.buttons["Open in new incognito tab"].tap()

        waitForExistence(app.buttons["Switch"])
        app.buttons["Done"].firstMatch.tap(force: true)

        setIncognitoMode(enabled: true, shouldOpenURL: false, closeTabTray: false)
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }

    // MARK: - Search
    func testSearchHistory() {
        goToHistory()

        // Make sure sites are visible before search.
        waitForExistence(app.staticTexts["Example Domain"])
        waitForExistence(app.buttons["Twitter"])

        // Select TextField.
        waitForHittable(app.textFields["History Search TextField"])
        app.textFields["History Search TextField"].tap(force: true)

        // Perform search and verify only the correct site is shown.
        app.textFields["History Search TextField"].typeText("example.com")
        waitForNoExistence(app.buttons["Twitter"])
        waitForExistence(app.staticTexts["Example Domain"])
    }
}
