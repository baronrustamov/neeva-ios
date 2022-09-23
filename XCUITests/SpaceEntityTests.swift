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

        swipeToRevealEdit("Example")

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

        swipeToRevealEdit("Example")
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
        swipeToRevealEdit("Example")

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

        swipeToRevealEdit("Example")

        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["Item removed from Space"].exists)
        XCTAssertFalse(app.buttons["Example"].exists)
        XCTAssertFalse(
            app.buttons["Example"]
                .children(matching: .staticText)
                .matching(identifier: "Click to add description")
                .element.exists)
    }

    func testEntityReordering() {
        // Prevents the XCUIElementQuery from breaking
        waitForExistence(app.buttons["Example"])

        var buttons = app.descendants(matching: .button).allElementsBoundByIndex.map { $0.label }

        XCTAssertTrue(buttons.firstIndex(of: "Example")! < buttons.firstIndex(of: "Yahoo")!)

        waitForExistence(app.buttons["Example"])
        let dragToTarget: XCUIElement = {
            if #available(iOS 16, *) {
                // Dragging to the static text does not trigger reordering on iOS 16
                return app.buttons["Example"]
            } else {
                return app.staticTexts["Only visible to you and people you shared with"]
            }
        }()
        app.buttons["Yahoo"]
            .press(
                forDuration: 0.5,
                thenDragTo: dragToTarget
            )
        waitForExistence(app.buttons["Example"])

        buttons = app.descendants(matching: .button).allElementsBoundByIndex.map { $0.label }

        XCTAssertTrue(buttons.firstIndex(of: "Yahoo")! < buttons.firstIndex(of: "Example")!)
    }

    func testNewEntityThenReorder() throws {
        // The iPad UI is a bit different, and testing for that platform
        // offers us little benefit.
        specificForPlatform = .phone
        try skipIfNeeded()

        waitForExistence(app.buttons["Example"])

        // Delete one of the entities so the reordering doesn't break --
        // otherwise the driver will swipe too low and go to the home screen.
        swipeToRevealEdit("Cnn")
        app.buttons["Delete"].tap()

        // Add an entity
        app.buttons["Add"].firstMatch.tap()

        app.textFields["addOrUpdateSpaceTitle"].tap(force: true)
        app.textFields["addOrUpdateSpaceTitle"].tap(force: true)
        app.typeText("AAA")

        app.textFields["addOrUpdateSpaceUrl"].tap()
        app.textFields["addOrUpdateSpaceUrl"].tap()
        app.typeText("aaa.com")

        app.buttons["Save"].tap(force: true)

        // Move the new entity to the top of the Space
        waitForExistence(app.buttons["AAA"])
        let dragToTarget: XCUIElement = {
            if #available(iOS 16, *) {
                // Dragging to the static text does not trigger reordering on iOS 16
                return app.buttons["Example"]
            } else {
                return app.staticTexts["Only visible to you and people you shared with"]
            }
        }()
        app.buttons["AAA"]
            .press(
                forDuration: 0.5,
                thenDragTo: dragToTarget
            )
        waitForExistence(app.buttons["Example"])

        // Go back to the Space grid
        app.buttons["Return to all Spaces view"].tap()

        // Go to the Space detail page again
        waitForExistence(app.buttons["\(spaceName), Space"])
        app.buttons["\(spaceName), Space"].tap()
        waitForExistence(app.buttons["Example"])

        // Verify that the new entity is at the top of the Space again
        let buttons = app.descendants(matching: .button).allElementsBoundByIndex.map { $0.label }
        XCTAssertTrue(buttons.firstIndex(of: "AAA")! < buttons.firstIndex(of: "Example")!)
    }
}

extension SpaceEntityTests {
    func swipeToRevealEdit(_ identifier: String) {
        // Double-swipe to reduce flakiness
        if #available(iOS 16.0, *) {
            // iOS 16, these are buttons not cells
            app.buttons[identifier].swipeLeft()
            if !app.buttons["Edit"].exists {
                app.buttons[identifier].swipeLeft()
            }
        } else {
            app.cells[identifier].swipeLeft()
            if !app.buttons["Edit"].exists {
                app.cells[identifier].swipeLeft()
            }
        }
    }
}
