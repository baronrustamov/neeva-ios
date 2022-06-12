// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class AddToSpaceSheetTests: BaseTestCase {
    override func setUp() {
        launchArguments = [
            // The argument below is needed to use the local server
            "\(LaunchArguments.ServerPort)\(serverPort)",
            LaunchArguments.SkipIntro,
            LaunchArguments.EnableMockSpaces,

            // Suppress sign-in prompts
            "\(LaunchArguments.SetLoginCookie)cookie",
            LaunchArguments.EnableMockUserInfo,
        ]

        super.setUp()

        // The actual page we use is irrelevant, we just want to
        // (1) enable the Add to Space button and (2) minimize latency
        // and server load (which is why we're using a local server)
        openURL(path(forTestPage: "test-mozilla-book.html"))
    }

    func testAddSpaceViaSheet() {
        openURL("example.com")
        app.buttons["Add To Space"].tap()

        // Bookmark icon is not filled
        waitForExistence(app.staticTexts[String(Nicon.bookmark.rawValue)])
        XCTAssertTrue(app.staticTexts[String(Nicon.bookmark.rawValue)].exists)

        // Add to Space
        app.staticTexts[SpaceServiceMock.mySpaceTitle].forceTapElement()

        // Confirmation view
        waitForExistence(app.staticTexts["Saved to \"\(SpaceServiceMock.mySpaceTitle)\""])
        XCTAssertTrue(app.staticTexts["Saved to \"\(SpaceServiceMock.mySpaceTitle)\""].exists)
    }

    func testBookmarkIconOpensSheet() {
        app.buttons["Add To Space"].tap()

        // Headline
        XCTAssertTrue(app.staticTexts["Save to Spaces"].exists)
        // Search text field
        XCTAssertTrue(app.textFields["Search Spaces"].exists)
    }

    func testCloseSheetOnTapOutside() throws {
        app.buttons["Add To Space"].tap()
        app.buttons["Address Bar"].tap()

        waitForNoExistence(app.buttons["View Spaces"])
    }

    func testCloseSheetOnTapX() throws {
        app.buttons["Add To Space"].tap()
        app.buttons["Close"].forceTapElement()

        waitForNoExistence(app.buttons["View Spaces"])
    }

    func testCreateSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        // We're not really adding a tab, we're adding a Space
        app.buttons["Add Tab"].tap()
        app.textFields["Space name"].typeText("Test Space")
        app.buttons["Save"].forceTapElement()

        // Confirm we are on the Space detail page
        XCTAssertTrue(app.buttons["Start Searching"].exists)

        app.buttons["Return to all Spaces view"].tap()

        // Confirm the Space is visible on the Space grid page
        XCTAssertTrue(app.buttons["Test Space"].exists)
    }

    func testDeleteItemFromExistingSpace() {
        // Add item to Space
        app.buttons["Add To Space"].tap()
        app.staticTexts[SpaceServiceMock.mySpaceTitle].forceTapElement()

        // Confirm the item was added
        waitForExistence(app.staticTexts["Saved to \"\(SpaceServiceMock.mySpaceTitle)\""])
        XCTAssertTrue(app.staticTexts["Saved to \"\(SpaceServiceMock.mySpaceTitle)\""].exists)

        app.buttons["Close"].forceTapElement()
        waitForNoExistence(app.staticTexts["Saved to \"\(SpaceServiceMock.mySpaceTitle)\""])

        // Remove item from Space
        app.buttons["Add To Space"].tap()
        app.staticTexts[SpaceServiceMock.mySpaceTitle].forceTapElement()

        // Confirm the item was removed
        waitForExistence(app.staticTexts["Deleted from \"\(SpaceServiceMock.mySpaceTitle)\""])
        XCTAssertTrue(app.staticTexts["Deleted from \"\(SpaceServiceMock.mySpaceTitle)\""].exists)
    }

    // If you are having trouble getting this test to pass locally,
    // make sure to disable the Simulator's hardware keyboard connection
    // I/O > Keyboard > Connect Hardware Keyboard
    // https://stackoverflow.com/a/34095158
    func testSearchForSpace() {
        app.buttons["Add To Space"].tap()
        app.textFields["Search Spaces"].forceTapElement()
        app.textFields["Search Spaces"].typeText("aa")

        XCTAssertFalse(app.staticTexts[SpaceServiceMock.mySpaceTitle].exists)

        // \u{8} is backspace
        app.textFields["Search Spaces"].typeText("\u{8}")

        XCTAssertTrue(app.staticTexts[SpaceServiceMock.mySpaceTitle].exists)
    }

    func testSpacesVisibleFromAddToSpaceSheet() {
        app.buttons["Add To Space"].tap()

        XCTAssertTrue(app.staticTexts[SpaceServiceMock.mySpaceTitle].exists)
    }

    func testViewSpacesButton() throws {
        app.buttons["Add To Space"].tap()
        XCTAssertTrue(app.buttons["View Spaces"].exists)

        app.buttons["View Spaces"].forceTapElement()

        XCTAssertTrue(app.buttons["Spaces"].isSelected)
    }
}
