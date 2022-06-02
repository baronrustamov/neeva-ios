// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class SpaceTests: BaseTestCase {
    override func setUp() {
        launchArguments = [
            LaunchArguments.SkipIntro,
            LaunchArguments.EnableMockSpaces,

            // Suppress sign-in prompts
            "\(LaunchArguments.SetLoginCookie)cookie",
            LaunchArguments.EnableMockUserInfo,
        ]

        super.setUp()
    }

    func testAddSpaceViaSheet() {
        openURL("example.com")
        app.buttons["Add To Space"].tap()

        // Bookmark icon is not filled
        waitForExistence(app.staticTexts[String(Nicon.bookmark.rawValue)])
        XCTAssertTrue(app.staticTexts[String(Nicon.bookmark.rawValue)].exists)

        // Add to Space
        app.staticTexts["My Space"].forceTapElement()

        // Confirmation view
        waitForExistence(app.staticTexts["Saved to \"My Space\""])
        XCTAssertTrue(app.staticTexts["Saved to \"My Space\""].exists)
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

    func testSpacesVisibleFromAddToSpaceSheet() {
        openURL("example.com")
        app.buttons["Add To Space"].tap()
        XCTAssertTrue(app.staticTexts["My Space"].exists)
    }
}
