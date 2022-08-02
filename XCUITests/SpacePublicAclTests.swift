// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class SpacePublicAclTests: BaseTestCase {
    let privateSpaceName = "SpacePublicAclTests Space1"
    let publicSpaceName = "SpacePublicAclTests Space2"

    let strOnlyVisible = "Only visible to you and people you shared with"
    let strOwnerSpace = "You'll be shown as the owner of the Space"

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
    }

    func testAddPublicAcl() {
        app.buttons[privateSpaceName].tap(force: true)

        waitForExistence(app.staticTexts[strOnlyVisible])
        XCTAssertTrue(app.staticTexts[strOnlyVisible].exists)

        app.buttons["Share"].tap()

        XCTAssertTrue(app.switches.firstMatch.value as? String == "0")

        waitForExistence(app.switches.firstMatch)
        app.switches.firstMatch.tap()

        XCTAssertTrue(app.staticTexts[strOwnerSpace].exists)
        XCTAssertFalse(app.staticTexts[strOnlyVisible].exists)
        XCTAssertFalse(app.switches.firstMatch.value as? String == "0")
    }

    func testDeletePublicAcl() {
        app.buttons[publicSpaceName].tap(force: true)

        waitForNoExistence(app.staticTexts[strOnlyVisible])
        XCTAssertFalse(app.staticTexts[strOnlyVisible].exists)

        waitForExistence(app.buttons["Share"])
        app.buttons["Share"].tap()

        XCTAssertTrue(app.switches.firstMatch.value as? String == "1")

        app.switches.firstMatch.tap()
        // Anti-flake
        if app.switches.firstMatch.value as? String == "1" {
            app.switches.firstMatch.tap()
        }

        XCTAssertTrue(app.staticTexts[strOnlyVisible].exists)
        XCTAssertFalse(app.staticTexts[strOwnerSpace].exists)
        XCTAssertFalse(app.switches.firstMatch.value as? String == "1")
    }
}
