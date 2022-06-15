// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class SpaceGridTests: BaseTestCase {
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

    func testClickSliderOpensGrid() {
        app.buttons["Show Tabs"].tap()

        XCTAssertTrue(app.buttons["Normal Tabs"].isSelected)

        app.buttons["Spaces"].tap()

        XCTAssertTrue(app.buttons["Spaces"].isSelected)
        XCTAssertTrue(app.buttons["Space Filter"].exists)
    }

    func testSpaceFilter() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        XCTAssertTrue(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)

        app.buttons["Space Filter"].tap()
        app.buttons["Owned by me"].forceTapElement()

        waitForNoExistence(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle])
        XCTAssertFalse(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)

        app.buttons["All Spaces"].forceTapElement()

        XCTAssertTrue(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)
    }

    // This is tested in AddToSpaceSheetTests.swift, but the function
    // is left here just as a reminder that it is being covered.
    //    func testCreateSpace() {}

    func testDoneButton() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        XCTAssertTrue(app.buttons["Spaces"].isSelected)
        XCTAssertFalse(app.buttons["Address Bar"].exists)

        app.buttons["Done"].tap()

        XCTAssertTrue(app.buttons["Address Bar"].exists)
    }

    func testSpaceLockIcons() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        XCTAssertTrue(
            app.buttons[SpaceServiceMock.mySpaceTitle]
                .children(matching: XCUIElement.ElementType.image)
                .matching(identifier: "Lock")
                .element
                .exists
        )

        XCTAssertFalse(
            app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle]
                .children(matching: XCUIElement.ElementType.image)
                .matching(identifier: "Lock")
                .element
                .exists
        )
    }

    // Each Space starts with one static text child (the Space title)
    // and gets more static text children as Space items are added. These
    // additional children represent thumbnails.
    func testCorrectThumbnailCount() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        XCTAssertTrue(
            app.buttons[SpaceServiceMock.mySpaceTitle]
                .children(matching: XCUIElement.ElementType.staticText)
                .count == 1
        )

        XCTAssertTrue(
            app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle]
                .children(matching: XCUIElement.ElementType.staticText)
                .count == 2
        )
    }

    func testClickGridItem() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        XCTAssertFalse(app.buttons["Learn More About Spaces"].exists)

        app.buttons[SpaceServiceMock.mySpaceTitle].tap()

        XCTAssertTrue(app.buttons["Learn More About Spaces"].exists)
    }
}
