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
    let testWithDB = [
        "testOpenHistoryFromBrowserContextMenuOptions", "testClearHistoryFromSettings",
        "testClearRecentHistory", "testSearchHistory",
    ]

    // This DDBB contains those 4 websites listed in the name
    let historyDB = "browserYoutubeTwitterMozillaExample.db"

    let clearBrowsingDataOptions = [
        "Browsing History", "Archived Tabs", "Cache", "Cookies", "Cookie Cutter Exclusions",
    ]

    func clearWebsiteData() {
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

    override func setUp() {
        if testWithDB.contains(testName) {
            // for the current test name, add the db fixture used
            launchArguments = [
                LaunchArguments.SkipIntro, LaunchArguments.SkipWhatsNew,
                LaunchArguments.SkipETPCoverSheet, LaunchArguments.LoadDatabasePrefix + historyDB,
            ]
        }
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        super.setUp()
    }

    func testEmptyHistoryListFirstTime() {
        // Go to History List from Top Sites and check it is empty
        goToHistory()

        waitForExistence(app.staticTexts["History List Empty"])
    }

    func testClearHistoryFromSettings() {
        // Go to Clear Data
        clearWebsiteData()

        // Back on History panel view check that there is not any item
        goToHistory()
        XCTAssertFalse(app.tables.cells.staticTexts[webpage["label"]!].exists)
    }

    func testClearPrivateDataButtonDisabled() {
        //Clear private data from settings and confirm
        clearPrivateData()

        //Wait for OK pop-up to disappear after confirming
        waitForNoExistence(app.alerts.buttons["Clear Data"], timeoutValue: 5)

        //Assert that the button has been replaced with a success message
        XCTAssertFalse(app.tables.cells["Clear Selected Data on This Device"].exists)
    }

    private func showRecentlyClosedTabs() {
        goToTabTray()
        app.buttons["Add Tab"].press(forDuration: 1)
    }

    func testRecentlyClosedOptionAvailable() {
        // Now go back to default website close it and check whether the option is enabled
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        // The Closed Tabs list should contain the info of the website just closed
        waitForExistence(app.scrollViews["recentlyClosedPanel"])
        waitForExistence(app.buttons["The Book of Mozilla"])
        app.buttons["History"].tap()
        app.buttons["Done"].tap()

        // This option should be enabled on private mode too
        setIncognitoMode(enabled: true)

        goToRecentlyClosedPage()
        waitForExistence(app.scrollViews["recentlyClosedPanel"])
    }

    func testClearRecentlyClosedHistory() {
        // Open the default website
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        // Once the website is visited and closed it will appear in Recently Closed Tabs list
        waitForExistence(app.scrollViews["recentlyClosedPanel"])
        waitForExistence(app.buttons["The Book of Mozilla"])
        app.buttons["History"].tap()
        app.buttons["Done"].tap()

        clearPrivateData()
        goToHistory()

        // Check history/recently closed items are cleared
        waitForExistence(app.staticTexts["History List Empty"])
    }

    func testRecentlyClosedMenuAvailable() {
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        XCTAssertTrue(app.buttons["The Book of Mozilla"].exists)
    }

    func testOpenInNewTabRecentlyClosedItemFromMenu() {
        // test the recently closed tab menu
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        app.buttons["The Book of Mozilla"].tap()

        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 2)
    }

    func testOpenInNewTabRecentlyClosedItem() {
        // Test the recently closed tab page
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        waitForExistence(app.scrollViews["recentlyClosedPanel"])
        app.buttons["The Book of Mozilla"].press(forDuration: 1)
        app.buttons["Open in new tab"].tap()
        app.buttons["History"].tap()
        app.buttons["Done"].tap()

        XCTAssertEqual(getNumberOfTabs(), 2)
    }

    func testOpenInNewIncognitoTabRecentlyClosedItem() {
        // Open the default website
        openURLInNewTab(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        waitForExistence(app.scrollViews["recentlyClosedPanel"])
        app.buttons["The Book of Mozilla"].press(forDuration: 1)
        app.buttons["Open in new incognito tab"].tap()
        app.buttons["History"].tap()
        app.buttons["Done"].tap()

        goToTabTray()
        setIncognitoMode(enabled: true, shouldOpenURL: false, closeTabTray: false)

        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }

    func testIncognitoClosedSiteDoesNotAppearOnRecentlyClosedMenu() {
        setIncognitoMode(enabled: true)

        // Open the default website
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        XCTAssertFalse(app.buttons["The Book of Mozilla"].exists)
    }

    func testIncognitoClosedSiteDoesNotAppearOnRecentlyClosed() {
        setIncognitoMode(enabled: true)

        // Open the default website
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToHistory()

        waitForExistence(app.staticTexts["History List Empty"])
    }

    // Private function created to select desired option from the "Clear Recent History" list
    // We used this aproch to avoid code duplication
    private func tapOnClearRecentHistoryOption(optionSelected: String) {
        app.sheets.buttons[optionSelected].tap()
    }

    private func navigateToExample() {
        openURL("example.com")
        waitUntilPageLoad()
    }

    func testClearRecentHistory() throws {
        try skipTest(issue: 981, "disabled because it fails with the new URL bar")
        goToHistory()
        waitForExistence(
            app.tables["History List"].cells.element(
                matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(
            matching: .cell, identifier: "HistoryPanel.clearHistory"
        ).tap()
        tapOnClearRecentHistoryOption(optionSelected: "The Last Hour")
        // No data will be removed after Action.ClearRecentHistory since there is no recent history created.
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }

        app.buttons["Done"].tap()
        navigateToExample()

        goToHistory()
        waitForExistence(
            app.tables["History List"].cells.element(
                matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(
            matching: .cell, identifier: "HistoryPanel.clearHistory"
        ).tap()
        // Recent data will be removed after calling tapOnClearRecentHistoryOption(optionSelected: "Today").
        // Older data will not be removed
        tapOnClearRecentHistoryOption(optionSelected: "Today")
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)

        // Begin Test for Today and Yesterday
        app.buttons["Done"].tap()
        navigateToExample()

        goToHistory()
        waitForExistence(
            app.tables["History List"].cells.element(
                matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(
            matching: .cell, identifier: "HistoryPanel.clearHistory"
        ).tap()
        // Tapping "Today and Yesterday" will remove recent data (from yesterday and today).
        // Older data will not be removed
        tapOnClearRecentHistoryOption(optionSelected: "Today and Yesterday")
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)

        // Begin Test for Everything
        app.buttons["Done"].tap()
        navigateToExample()

        goToHistory()
        waitForExistence(
            app.tables["History List"].cells.element(
                matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(
            matching: .cell, identifier: "HistoryPanel.clearHistory"
        ).tap()
        // Tapping everything removes both current data and older data.
        tapOnClearRecentHistoryOption(optionSelected: "Everything")
        for entry in oldHistoryEntries {
            waitForNoExistence(app.tables.cells.staticTexts[entry], timeoutValue: 10)
            XCTAssertFalse(app.tables.cells.staticTexts[entry].exists, "History not removed")
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
    }

    func testAllOptionsArePresent() {
        navigateToExample()

        goToHistory()

        waitForExistence(app.buttons["Clear Browsing Data"])
        app.buttons["Clear Browsing Data"].tap()

        for option in clearBrowsingDataOptions {
            XCTAssertTrue(
                app.cells.containing(NSPredicate(format: "label CONTAINS %@", option)).element
                    .exists)
        }
    }

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
