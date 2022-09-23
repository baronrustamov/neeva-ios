// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class RelatedSpaceTests: BaseTestCase {
    let spaceName1 = "RelatedSpaceTests Space1"
    let spaceName2 = "RelatedSpaceTests Space2"

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

        goToTabTray()
        app.buttons["Spaces"].tap()

        // With iOS 16, the grid doesn't update unless we tap on a space and go back.
        waitForExistence(app.buttons["My Space"])
        app.buttons["My Space"].tap(force: true)

        waitForExistence(app.buttons["Return to all Spaces view"])
        app.buttons["Return to all Spaces view"].tap()

        waitForExistence(app.buttons[spaceName1])
        app.buttons[spaceName1].tap()
    }

    // Unfortunately, checking for the chevron symbol is flaky,
    // so we click the user's name and hope that the app navigates
    // to the Profile UI instead.
    func testGetRelatedSpaces() {
        waitForExistence(app.staticTexts[spaceName1])
        waitForExistence(app.buttons["Test User"])

        app.buttons["Test User"].tap()
        app.buttons[spaceName2].tap()

        XCTAssertTrue(app.staticTexts[spaceName2].exists)
        XCTAssertTrue(app.buttons["Test User"].exists)

        waitForNoExistence(app.staticTexts[spaceName1])

        XCTAssertFalse(app.staticTexts[spaceName1].exists)

        app.buttons["Return to all Spaces view"].tap()
        app.buttons["Return to Space"].tap()

        XCTAssertTrue(app.staticTexts[spaceName1].exists)
        XCTAssertTrue(app.buttons["Test User"].exists)
    }
}
