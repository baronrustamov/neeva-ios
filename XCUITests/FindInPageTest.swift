/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class FindInPageTests: BaseTestCase {
    private func openFindInPageFromMenu(
        _ url: String = "http://localhost:\(serverPort)/test-fixture/find-in-page-test.html"
    ) {
        openURL(url)
        goToFindOnPage()

        waitForExistence(app.buttons["FindInPage_Next"])
        waitForExistence(app.buttons["FindInPage_Previous"])
        XCTAssertTrue(app.textFields["FindInPage_TextField"].exists)
    }

    func testFindInLargeDoc() {
        openFindInPageFromMenu()

        // Enter some text to start finding
        app.textFields["FindInPage_TextField"].typeText("Book")

        waitForExistence(app.staticTexts["1 of 500+"])
    }

    // Smoketest
    func testFindFromMenu() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Enter some text to start finding
        app.textFields["FindInPage_TextField"].typeText("Book")

        // Once there are matches, test previous/next buttons
        waitForExistence(app.staticTexts["1 of 6"])
        XCTAssertTrue(app.staticTexts["1 of 6"].exists)

        let nextInPageResultButton = app.buttons["FindInPage_Next"]
        nextInPageResultButton.tap()

        waitForExistence(app.staticTexts["2 of 6"])
        XCTAssertTrue(app.staticTexts["2 of 6"].exists)

        nextInPageResultButton.tap()
        waitForExistence(app.staticTexts["3 of 6"])
        XCTAssertTrue(app.staticTexts["3 of 6"].exists)

        let previousInPageResultButton = app.buttons["FindInPage_Previous"]
        previousInPageResultButton.tap()

        waitForExistence(app.staticTexts["2 of 6"])
        XCTAssertTrue(app.staticTexts["2 of 6"].exists)

        previousInPageResultButton.tap()
        waitForExistence(app.staticTexts["1 of 6"])
        XCTAssertTrue(app.staticTexts["1 of 6"].exists)

        print(app.debugDescription)

        // Tapping on close dismisses the search bar
        app.buttons["FindInPage_Done"].tap()
        waitForNoExistence(app.textFields["Book"])
    }

    func testFindInPageTwoWordsSearch() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Enter some text to start finding
        app.textFields["FindInPage_TextField"].typeText("The Book of")

        // Once there are matches, test previous/next buttons
        waitForExistence(app.staticTexts["1 of 6"])
        XCTAssertTrue(app.staticTexts["1 of 6"].exists)
    }

    func testFindInPageTwoWordsSearchLargeDoc() {
        openFindInPageFromMenu()

        app.textFields["FindInPage_TextField"].typeText("The Book of")

        // Clear button will be shown if the count isn't visible
        // Shown because the text exceeds the width of the TextField
        if !app.buttons["Clear"].exists {
            XCTAssertTrue(app.staticTexts["1 of 500+"].exists)
        }
    }

    func testFindInPageResultsPageShowHideContent() {
        openFindInPageFromMenu("lorem2.com")

        // Enter some text to start finding
        app.textFields["FindInPage_TextField"].typeText("lorem")

        // There should be matches
        waitForExistence(app.staticTexts["1 of 5"])
    }

    func testQueryWithNoMatches() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Try to find text which does not match and check that there are not results
        app.textFields["FindInPage_TextField"].typeText("foo")

        waitForExistence(app.staticTexts["0 of 0"])
        XCTAssertTrue(app.staticTexts["0 of 0"].exists, "There should not be any matches")
    }

    func testFindFromSelection() throws {
        try skipTest(issue: 2440, "Menu does not show when running on CI")

        let textToFind = "cloud"
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitForExistence(app.webViews.staticTexts[textToFind].firstMatch)

        let stringToFind = app.webViews.staticTexts[textToFind].firstMatch
        stringToFind.press(forDuration: 2)

        waitForExistence(app.menuItems["Copy"], timeout: 30)

        // Find in page is correctly launched, bar with text pre-filled and
        // the buttons to find next and previous
        if app.menuItems["Find in Page"].exists {
            app.menuItems["Find in Page"].tap()
        } else {
            app.menuItems["show.next.items.menu.button"].tap()
            waitForExistence(app.menuItems["Find in Page"])
            app.menuItems["Find in Page"].tap()
        }

        waitForExistence(app.buttons["FindInPage_Previous"])
        waitForExistence(app.buttons["FindInPage_Next"])
    }
}
