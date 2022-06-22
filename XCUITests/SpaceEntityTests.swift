// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class SpaceEntityTests: BaseTestCase {
    let spaceName = "SpaceEntityTests Space"

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

    func testEntitySwipeMenu() {
        XCTAssertFalse(app.buttons["Edit"].exists)
        XCTAssertFalse(app.buttons["Add To"].exists)
        XCTAssertFalse(app.buttons["Delete"].exists)

        // Double-swipe to reduce flaking
        app.cells["Example"].swipeLeft()
        if !app.buttons["Edit"].exists {
            app.cells["Example"].swipeLeft()
        }

        XCTAssertTrue(app.buttons["Edit"].exists)
        XCTAssertTrue(app.buttons["Add To"].exists)
        XCTAssertTrue(app.buttons["Delete"].exists)
    }

    func testEditViaSwipe() {
        XCTAssertFalse(app.buttons["Example2"].exists)
        XCTAssertFalse(
            app.buttons["Example2"]
                .children(matching: .staticText)
                .matching(identifier: "This is a description")
                .element.exists)

        // Double-swipe to reduce flaking
        app.cells["Example"].swipeLeft()
        if !app.buttons["Edit"].exists {
            app.cells["Example"].swipeLeft()
        }
        app.buttons["Edit"].tap()

        XCTAssertTrue(app.staticTexts["Edit item"].exists)

        app.textFields["addOrUpdateSpaceTitle"].tap(force: true)
        app.textFields["addOrUpdateSpaceTitle"].typeText("2")  // Title is now Example2
        app.textViews["addOrUpdateSpaceDescription"].tap(force: true)
        app.textViews["addOrUpdateSpaceDescription"].typeText("This is a description")
        app.buttons["Save"].tap(force: true)

        XCTAssertTrue(app.buttons["Example2"].exists)
        XCTAssertTrue(
            app.buttons["Example2"]
                .children(matching: .staticText)
                .matching(identifier: "This is a description")
                .element.exists)
    }

    func testAddToViaSwipe() {
        // Double-swipe to reduce flaking
        app.cells["Example"].swipeLeft()
        if !app.buttons["Edit"].exists {
            app.cells["Example"].swipeLeft()
        }

        XCTAssertFalse(app.staticTexts["Save to Spaces"].exists)

        app.buttons["Add To"].tap()

        XCTAssertTrue(app.staticTexts["Save to Spaces"].exists)
    }

    func testDeleteViaSwipe() {
        XCTAssertTrue(app.buttons["Example"].exists)
        XCTAssertTrue(
            app.buttons["Example"]
                .children(matching: .staticText)
                .matching(identifier: "Click to add description")
                .element.exists)

        // Double-swipe to reduce flaking
        app.cells["Example"].swipeLeft()
        if !app.buttons["Edit"].exists {
            app.cells["Example"].swipeLeft()
        }

        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["Item removed from Space"].exists)
        XCTAssertFalse(app.buttons["Example"].exists)
        XCTAssertFalse(
            app.buttons["Example"]
                .children(matching: .staticText)
                .matching(identifier: "Click to add description")
                .element.exists)
    }
}
