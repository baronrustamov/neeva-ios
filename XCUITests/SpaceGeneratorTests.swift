// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class SpaceGeneratorTests: BaseTestCase {
    let spaceName = "SpaceGeneratorTests Space"

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

        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[spaceName].tap(force: true)
    }

    func testClaimGeneratedItem() {
        // Double-swipe to reduce flaking
        app.cells["First generated entity"].swipeLeft()
        if !app.buttons["Keep"].exists {
            app.cells["First generated entity"].swipeLeft()
        }
        app.buttons["Keep"].tap()

        // Double-swipe to reduce flaking
        app.cells["First generated entity"].swipeLeft()
        if !app.buttons["Edit"].exists {
            app.cells["First generated entity"].swipeLeft()
        }

        XCTAssertTrue(app.buttons["Edit"].exists)
    }

    func testDeleteGenerator() {
        XCTAssertTrue(app.staticTexts["News alerts"].exists)
        XCTAssertTrue(app.staticTexts["golden state"].exists)

        app.staticTexts["golden state"].tap()

        // At this point, the Keep/Delete menu should be replaced with Edit/Add To/Delete,
        // but this is not reliable enough to test right now.
        XCTAssertFalse(app.staticTexts["News alerts"].exists)
        XCTAssertFalse(app.staticTexts["golden state"].exists)
    }
}
