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

    func testSpacesVisibleFromAddToSpaceSheet() {
        openURL("example.com")
        app.buttons["Add To Space"].tap()
        XCTAssertTrue(app.staticTexts["My Space"].exists)
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
}
