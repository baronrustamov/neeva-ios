/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let webpage = ["url": "www.mozilla.org", "label": "Internet for people, not profit — Mozilla", "value": "mozilla.org"]
let oldHistoryEntries: [String] = ["Internet for people, not profit — Mozilla", "Twitter", "Home - YouTube"]
// This is part of the info the user will see in recent closed tabs once the default visited website (https://www.mozilla.org/en-US/book/) is closed
let closedWebPageLabel = "localhost:\(serverPort)/test-fixture/test-mozilla-book.html"

class HistoryTests: BaseTestCase {
    let testWithDB = ["testOpenHistoryFromBrowserContextMenuOptions", "testClearHistoryFromSettings", "testClearRecentHistory"]

    // This DDBB contains those 4 websites listed in the name
    let historyDB = "browserYoutubeTwitterMozillaExample.db"
    
    let clearRecentHistoryOptions = ["The Last Hour", "Today", "Today and Yesterday", "Everything"]

    override func setUp() {
        // Test name looks like: "[Class testFunc]", parse out the function name
        let parts = name.replacingOccurrences(of: "]", with: "").split(separator: " ")
        let key = String(parts[1])
        if testWithDB.contains(key) {
            // for the current test name, add the db fixture used
            launchArguments = [LaunchArguments.SkipIntro, LaunchArguments.SkipWhatsNew, LaunchArguments.SkipETPCoverSheet, LaunchArguments.LoadDatabasePrefix + historyDB]
        }
        super.setUp()
    }

    func testEmptyHistoryListFirstTime() {
        // Go to History List from Top Sites and check it is empty
        navigator.goto(HomePanelsScreen)
        navigator.goto(LibraryPanel_History)
        waitForExistence(app.tables.cells["HistoryPanel.recentlyClosedCell"])
        XCTAssertTrue(app.tables.cells["HistoryPanel.recentlyClosedCell"].exists)
    }

    func testClearHistoryFromSettings() {
        // Browse to have an item in history list
        navigator.goto(HomePanelsScreen)
        navigator.goto(LibraryPanel_History)
        waitForExistence(app.tables.cells["HistoryPanel.recentlyClosedCell"], timeout: 5)
        XCTAssertTrue(app.tables.cells.staticTexts[webpage["label"]!].exists)

        // Go to Clear Data
        navigator.performAction(Action.AcceptClearPrivateData)

        // Back on History panel view check that there is not any item
        navigator.goto(LibraryPanel_History)
        waitForExistence(app.tables.cells["HistoryPanel.recentlyClosedCell"])
        XCTAssertFalse(app.tables.cells.staticTexts[webpage["label"]!].exists)
    }

    func testClearPrivateDataButtonDisabled() {
        //Clear private data from settings and confirm
        navigator.goto(HomePanelsScreen)
        navigator.goto(ClearPrivateDataSettings)
        app.tables.cells["Clear Selected Data on This Device"].tap()
        app.sheets.buttons["Clear Data"].tap()
        
        //Wait for OK pop-up to disappear after confirming
        waitForNoExistence(app.alerts.buttons["Clear Data"], timeoutValue:5)
        
        //Assert that the button has been replaced with a success message
        XCTAssertFalse(app.tables.cells["Clear Selected Data on This Device"].exists)
    }

    func closeAllTabs() {
        app.buttons["Show Tabs"].press(forDuration: 3)

        let closeAllTabButton = app.buttons["Close All Tabs"]
        if closeAllTabButton.exists {
            closeAllTabButton.tap()

            waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
            app.buttons["Confirm Close All Tabs"].tap()
        } else {
            app.buttons["Close Tab"].tap()
        }
    }

    func showRecentlyClosedTabs() {
        navigator.nowAt(NewTabScreen)
        navigator.goto(TabTray)
        app.buttons["Add Tab"].press(forDuration: 4)
    }

    func testRecentlyClosedOptionAvailable() {
        // Now go back to default website close it and check whether the option is enabled
        navigator.openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        navigator.nowAt(NewTabScreen)
        navigator.goto(NeevaMenu)
        navigator.goto(HistoryRecentlyClosed)

        // The Closed Tabs list should contain the info of the website just closed
        waitForExistence(app.tables["Recently Closed Tabs List"], timeout: 3)
        XCTAssertTrue(app.tables.cells.staticTexts[closedWebPageLabel].exists)
        navigator.goto(HomePanelsScreen)

        // This option should be enabled on private mode too
        navigator.toggleOn(userState.isPrivate, withAction: Action.TogglePrivateMode)
        navigator.nowAt(NewTabScreen)
        navigator.goto(NeevaMenu)

        navigator.goto(HistoryRecentlyClosed)
        waitForExistence(app.tables["Recently Closed Tabs List"])
    }

    func testClearRecentlyClosedHistory() {
        // Open the default website
        navigator.openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        navigator.nowAt(NewTabScreen)
        navigator.goto(NeevaMenu)
        navigator.goto(HistoryRecentlyClosed)

        // Once the website is visited and closed it will appear in Recently Closed Tabs list
        waitForExistence(app.tables["Recently Closed Tabs List"])
        XCTAssertTrue(app.tables.cells.staticTexts[closedWebPageLabel].exists)
        navigator.goto(HomePanelsScreen)

        // Go to settings and clear private data
        navigator.performAction(Action.AcceptClearPrivateData)

        // Back on History panel view check that there is not any item
        navigator.goto(HistoryRecentlyClosed)
        waitForNoExistence(app.tables["Recently Closed Tabs List"])
    }

    func testRecentlyClosedMenuAvailable() {
        navigator.openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        XCTAssertTrue(app.buttons["The Book of Mozilla"].exists)
    }

    func testOpenInNewTabRecentlyClosedItemFromMenu() {
        // test the recently closed tab menu
        navigator.openURL("neeva.com")
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        app.buttons["Ad-free, private search - Neeva"].tap()

        let numTabsOpen = userState.numTabs
        XCTAssertEqual(numTabsOpen, 1)
    }

    func testOpenInNewTabRecentlyClosedItem() {
        // test the recently closed tab page
        navigator.openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        navigator.nowAt(NewTabScreen)
        navigator.goto(NeevaMenu)
        navigator.goto(HistoryRecentlyClosed)

        waitForExistence(app.tables["Recently Closed Tabs List"])
        app.tables.cells.staticTexts[closedWebPageLabel].tap()
    }

    func testOpenInNewPrivateTabRecentlyClosedItem() {
        // Open the default website
        navigator.openURL("neeva.com")
        waitUntilPageLoad()
        closeAllTabs()

        navigator.nowAt(NewTabScreen)
        navigator.goto(NeevaMenu)
        navigator.goto(HistoryRecentlyClosed)

        waitForExistence(app.tables["Recently Closed Tabs List"])
        app.tables.cells.staticTexts["https://neeva.com"].press(forDuration: 1)

        waitForExistence(app.tables["Context Menu"])
        app.tables.cells["incognito"].tap()

        navigator.toggleOn(userState.isPrivate, withAction: Action.TogglePrivateMode)

        navigator.goto(TabTray)
        let numTabsOpen = userState.numTabs
        XCTAssertEqual(numTabsOpen, 1)
    }

    func testPrivateClosedSiteDoesNotAppearOnRecentlyClosed() {
        waitForTabsButton()
        navigator.toggleOn(userState.isPrivate, withAction: Action.TogglePrivateMode)
        navigator.nowAt(NewTabScreen)
        // Open the default website
        userState.url = path(forTestPage: "test-mozilla-book.html")
        navigator.goto(BrowserTab)
        // It is necessary to open two sites so that when one is closed private mode is not closed
        navigator.openNewURL(urlString: path(forTestPage: "test-mozilla-org.html"))
        waitUntilPageLoad()
        waitForTabsButton()
        navigator.goto(TabTray)
        waitForExistence(app.cells.staticTexts[webpage["label"]!])
        // Close tab by tapping on its 'x' button
        app.collectionViews.cells.element(boundBy: 0).buttons["closeTabButtonTabTray"].tap()

        navigator.performAction(Action.OpenNewTabFromTabTray)
        navigator.goto(NewTabScreen)
        navigator.goto(LibraryPanel_History)
        XCTAssertFalse(app.cells.staticTexts["Recently Closed"].isSelected)
        waitForNoExistence(app.tables["Recently Closed Tabs List"])

        // Now verify that on regular mode the recently closed list is empty too
        navigator.toggleOff(userState.isPrivate, withAction: Action.TogglePrivateMode)
        navigator.goto(NewTabScreen)
        navigator.goto(LibraryPanel_History)
        XCTAssertFalse(app.cells.staticTexts["Recently Closed"].isSelected)
        waitForNoExistence(app.tables["Recently Closed Tabs List"])
    }
    
    // Private function created to select desired option from the "Clear Recent History" list
    // We used this aproch to avoid code duplication
    private func tapOnClearRecentHistoryOption(optionSelected: String) {
        app.sheets.buttons[optionSelected].tap()
    }
    
    private func navigateToExample() {
        navigator.openURL("example.com")
        navigator.goto(LibraryPanel_History)
        XCTAssertTrue(app.tables.cells.staticTexts["Example Domain"].exists)
    }
    
    func testClearRecentHistory() {
        navigator.goto(HomePanelsScreen)
        navigator.goto(LibraryPanel_History)
        navigator.performAction(Action.ClearRecentHistory)
        tapOnClearRecentHistoryOption(optionSelected: "The Last Hour")
        // No data will be removed after Action.ClearRecentHistory since there is no recent history created.
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        // Go to 'goolge.com' to create a recent history entry.
        navigateToExample()
        navigator.performAction(Action.ClearRecentHistory)
        // Recent data will be removed after calling tapOnClearRecentHistoryOption(optionSelected: "Today").
        // Older data will not be removed
        tapOnClearRecentHistoryOption(optionSelected: "Today")
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
        
        // Begin Test for Today and Yesterday
        // Go to 'goolge.com' to create a recent history entry.
        navigateToExample()
        navigator.performAction(Action.ClearRecentHistory)
        // Tapping "Today and Yesterday" will remove recent data (from yesterday and today).
        // Older data will not be removed
        tapOnClearRecentHistoryOption(optionSelected: "Today and Yesterday")
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
        
        // Begin Test for Everything
        // Go to 'goolge.com' to create a recent history entry.
        navigateToExample()
        navigator.performAction(Action.ClearRecentHistory)
        // Tapping everything removes both current data and older data.
        tapOnClearRecentHistoryOption(optionSelected: "Everything")
        for entry in oldHistoryEntries {
            waitForNoExistence(app.tables.cells.staticTexts[entry], timeoutValue: 10)

        XCTAssertFalse(app.tables.cells.staticTexts[entry].exists, "History not removed")
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
        
    }
    
    func testAllOptionsArePresent(){
        // Go to 'goolge.com' to create a recent history entry.
        navigateToExample()
        navigator.performAction(Action.ClearRecentHistory)
        for option in clearRecentHistoryOptions {
            XCTAssertTrue(app.sheets.buttons[option].exists)
        }
    }

    // Smoketest
    func testDeleteHistoryEntryBySwiping() {
        navigateToExample()
        navigator.goto(LibraryPanel_History)
        waitForExistence(app.cells.staticTexts["http://example.com/"], timeout: 10)
        app.cells.staticTexts["http://example.com/"].firstMatch.swipeLeft()
        waitForExistence(app.buttons["Delete"], timeout: 10)
        app.buttons["Delete"].tap()
        waitForNoExistence(app.staticTexts["http://example.com"])
    }
}
