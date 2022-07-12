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

        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[spaceName1].tap()
    }

    // Unfortunately, checking for the chevron symbol is flaky,
    // so we click the user's name and hope that the app navigates
    // to the Profile UI instead.
    func testGetRelatedSpaces() {
        XCTAssertTrue(app.staticTexts[spaceName1].exists)
        XCTAssertTrue(app.buttons["Test User"].exists)

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
