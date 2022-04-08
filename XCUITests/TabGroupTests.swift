// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class TabGroupTests: BaseTestCase {
    // MARK: - NYTimes Test Case
    // The NYTimes case is where a URL is opened from say nytimes.com,
    // and a sublink i.e. nytimes.com/article is opened.
    //
    // Then the user would open up a new tab to the orignal URL (nytimes.com,
    // which in that case we should create a tab group with the two tabs.

    /// Navigates to the test URL and if `andNavigateAway` is true, then it will tap a link
    /// to open the sublink (similar to nytimes.com/article).
    private func openTestURLInNewTab(andNavigateAway: Bool = true) {
        openURLInNewTab()
        waitForExistence(app.links["More information..."], timeout: 30)

        if andNavigateAway {
            app.links["More information..."].tap()
        }
    }

    private func confirmOneTabGroupExists() {
        // Confirms only one Tab Group exists,
        // will fail with multiple options error if more than one exists.
        XCTAssertTrue(app.staticTexts["TabGroupTitle"].exists)

        let titleValue = app.staticTexts["TabGroupTitle"].value as? String
        XCTAssertTrue(titleValue?.contains("example.com") ?? false)
    }

    /// Tests the NYTimes case in an instance where the child tab (nytimes.com/article)
    /// is not currently in a Tab Group.
    func testNYTimesCaseCreatesTabGroup() {
        openTestURLInNewTab()
        openTestURLInNewTab(andNavigateAway: true)

        goToTabTray()
        confirmOneTabGroupExists()
    }

    /// Tests the case above, with multiple tabs.
    func testNYTimesCaseCreatesTabGroupRepeated() {
        closeAllTabs(createNewTab: false)

        openTestURLInNewTab()
        openTestURLInNewTab()
        openTestURLInNewTab()
        openTestURLInNewTab(andNavigateAway: true)

        goToTabTray()
        confirmOneTabGroupExists()
    }

    func testNYTimesCaseCreatesTabGroupWithOtherTabs() {
        let url = "http://localhost:\(serverPort)/test-fixture/find-in-page-test.html"
        openURL(url)
        openTestURLInNewTab()
        openTestURLInNewTab(andNavigateAway: true)

        goToTabTray()

        // Confirm that the one tab is seperate from the Tab Group
        waitForExistence(app.staticTexts[url])

        // Confirm that that there is one Tab Group for the example URL
        confirmOneTabGroupExists()
    }

    func testNYTimesCaseIssue3088() {
        closeAllTabs(createNewTab: false)

        openTestURLInNewTab(andNavigateAway: true)
        openTestURLInNewTab(andNavigateAway: true)
        openTestURLInNewTab()

        goToTabTray()
        confirmOneTabGroupExists()
    }

    func testNYTimesCaseAfterTabRestore() {
        closeAllTabs(createNewTab: false)

        openTestURLInNewTab(andNavigateAway: true)
        openURL(path(forTestPage: "test-mozilla-book.html"))

        goToTabTray()

        app.buttons["Close"].firstMatch.tap()

        // Restore the closed tab.
        app.buttons["Add Tab"].press(forDuration: 2.0)
        waitForExistence(app.collectionViews.firstMatch)

        app.collectionViews.firstMatch.buttons.firstMatch.tap()

        // This should result in a Tab Group.
        openURL()

        goToTabTray()
        confirmOneTabGroupExists()
    }

    func testUniqueSearchQueriesAfterTabRestore() {
        closeAllTabs(createNewTab: false)

        openURL(path(forTestPage: "test-example.html?q=1"))  // Simulate a search query
        openURL(path(forTestPage: "test-mozilla-book.html"))

        goToTabTray()

        app.buttons["Close"].firstMatch.tap()

        // Restore the closed tab.
        app.buttons["Add Tab"].press(forDuration: 2.0)
        waitForExistence(app.collectionViews.firstMatch)

        app.collectionViews.firstMatch.buttons.firstMatch.tap()

        // This should not result in a tab group.
        openURL(path(forTestPage: "test-example.html?q=2"))  // Simulate a search query

        goToTabTray()
        XCTAssertFalse(app.buttons["Tab Group, Example Domain"].exists)
    }
}
