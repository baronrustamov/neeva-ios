// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

// TODO(jon):
// 1. Share button
// 2. Expand/collapse descriptions
// 3. Add to another Space
// 4. Open all Space links
class SpaceDetailPageTopBarTests: BaseTestCase {
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
    }

    func testaddItemToSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[SpaceServiceMock.mySpaceTitle].tap(force: true)

        waitForExistence(app.buttons["Learn More About Spaces"])
        XCTAssertTrue(app.buttons["Learn More About Spaces"].exists)

        app.buttons["Add"].tap()

        // Title field -- for some reason, if we don't
        // force tap this, it hits the description field.
        //
        // Also, `typeText` works pretty poorly, so
        // double force tapping reduces flakiness.
        app.textFields["addToSpaceTitle"].tap(force: true)
        app.textFields["addToSpaceTitle"].tap(force: true)
        app.typeText("The Book of Mozilla")

        // URL field
        waitForExistence(app.textFields["addToSpaceUrl"])
        app.textFields["addToSpaceUrl"].tap()
        app.textFields["addToSpaceUrl"].tap()
        app.typeText(path(forTestPage: "test-mozilla-book.html"))

        app.buttons["Save"].tap(force: true)

        XCTAssertFalse(app.buttons["Learn More About Spaces"].exists)
        XCTAssertTrue(app.staticTexts["The Book of Mozilla"].exists)
        XCTAssertTrue(app.staticTexts["Click to add description"].exists)
    }

    // Right now, we're not testing editing of the description
    // because the description is not visible when the Space is empty.
    func testEditSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[SpaceServiceMock.mySpaceTitle].tap()
        app.buttons["Compose"].tap(force: true)

        waitForExistence(app.textFields["addToSpaceTitle"])
        app.textFields["addToSpaceTitle"].tap(force: true)
        app.textFields["addToSpaceTitle"].tap(force: true)
        app.typeText("2")

        app.buttons["Save"].tap(force: true)

        waitForExistence(app.buttons["Return to all Spaces view"])
        app.buttons["Return to all Spaces view"].tap(force: true)

        XCTAssertTrue(app.staticTexts["\(SpaceServiceMock.mySpaceTitle)2"].exists)
    }

    func testShareSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[SpaceServiceMock.mySpaceTitle].tap()

        XCTAssertFalse(app.switches["Enable shareable link, Anyone with the link can view"].exists)

        app.buttons["Share"].tap()

        XCTAssertTrue(app.switches["Enable shareable link, Anyone with the link can view"].exists)
    }

    func testOverflowMenu() {
        // A Space I own
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[SpaceServiceMock.mySpaceTitle].tap()

        XCTAssertFalse(app.buttons["Delete Space"].exists)
        XCTAssertFalse(app.buttons["Add to another Space"].exists)
        XCTAssertFalse(app.buttons["Open all Space links"].exists)

        app.buttons["Overflow Menu"].tap()

        XCTAssertTrue(app.buttons["Delete Space"].exists)
        XCTAssertTrue(app.buttons["Add to another Space"].exists)
        XCTAssertTrue(app.buttons["Open all Space links"].exists)

        app.buttons["Return to all Spaces view"].tap(force: true)

        // A Space I don't own
        app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].tap()

        XCTAssertFalse(app.buttons["Unfollow"].exists)
        XCTAssertFalse(app.buttons["Add to another Space"].exists)
        XCTAssertFalse(app.buttons["Open all Space links"].exists)

        app.buttons["Overflow Menu"].tap()

        XCTAssertTrue(app.buttons["Unfollow"].exists)
        XCTAssertTrue(app.buttons["Add to another Space"].exists)
        XCTAssertTrue(app.buttons["Open all Space links"].exists)
    }

    func testDeleteSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[SpaceServiceMock.mySpaceTitle].tap()
        app.buttons["Overflow Menu"].tap(force: true)
        waitForExistence(app.buttons["Delete Space"])
        app.buttons["Delete Space"].tap()

        // Action sheet
        waitForExistence(app.buttons["Delete Space"])
        app.buttons["Delete Space"].tap()

        waitForExistence(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle])
        XCTAssertTrue(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)
        XCTAssertFalse(app.buttons[SpaceServiceMock.mySpaceTitle].exists)
    }

    func testUnfollowSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].tap()
        app.buttons["Overflow Menu"].tap()
        waitForExistence(app.buttons["Unfollow"])
        app.buttons["Unfollow"].tap()

        // Action sheet
        waitForExistence(app.buttons["Unfollow Space"])
        app.buttons["Unfollow Space"].tap()

        waitForExistence(app.buttons[SpaceServiceMock.mySpaceTitle])
        XCTAssertTrue(app.buttons[SpaceServiceMock.mySpaceTitle].exists)
        XCTAssertFalse(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)
    }
}
