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
        app.buttons["Owned by me"].tap(force: true)

        waitForNoExistence(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle])
        XCTAssertFalse(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)

        app.buttons["All Spaces"].tap(force: true)

        XCTAssertTrue(app.buttons[SpaceServiceMock.spaceNotOwnedByMeTitle].exists)
    }

    func testSpaceSort() throws {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()
        app.buttons["Space Filter"].tap()

        // Assert that the arrow is up
        XCTAssertTrue(
            app.buttons["Last Updated"]
                .children(matching: .staticText)
                .matching(identifier: String(Nicon.arrowUp.rawValue)).element.exists
        )

        // Change the sort order
        app.buttons["Last Updated"].tap(force: true)

        // Assert that the AAA Space is now first
        XCTAssertTrue(
            app.scrollViews["CardGrid"]
                .descendants(matching: .button)
                .firstMatch.label.starts(with: "AAA Space"))

        app.buttons["Name"].tap(force: true)

        XCTAssertTrue(
            app.buttons["Name"]
                .children(matching: .staticText)
                .matching(identifier: String(Nicon.arrowDown.rawValue)).element.exists
        )

        app.buttons["Name"].tap(force: true)

        // Assert that the ZZZ Space is now first
        XCTAssertTrue(
            app.scrollViews["CardGrid"]
                .descendants(matching: .button)
                .firstMatch.label.starts(with: "ZZZ Space"))

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

        app.buttons[SpaceServiceMock.mySpaceTitle].tap(force: true)

        XCTAssertTrue(app.buttons["Learn More About Spaces"].exists)
    }

    func testPinSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        // On XCode 14.1, we need to interact the screen somehow in order to select a space in test
        app.swipeDown()

        app.buttons[SpaceServiceMock.mySpaceTitle].press(forDuration: 1)

        XCTAssertTrue(app.buttons["Pin"].exists)

        app.buttons["Pin"].tap()

        waitForExistence(app.scrollViews["CardGrid"])
        // Assert that the Space named `mySpaceTitle` comes first
        XCTAssertTrue(
            app.scrollViews["CardGrid"]
                .descendants(matching: .button)
                .firstMatch.label
                .contains(SpaceServiceMock.mySpaceTitle)
        )
        // This is a bit of a hack -- unfortunately, the pin
        // button neighbors the Space in the element tree, so
        // we just check if the Space is first and the pin badge exists.
        XCTAssertTrue(app.buttons["pin"].exists)
    }

    func testUnpinSpace() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        // On XCode 14.1, we need to interact the screen somehow in order to select a space in test
        app.swipeDown()

        XCTAssertFalse(app.buttons["pin"].exists)

        app.buttons[SpaceServiceMock.mySpaceTitle].press(forDuration: 1)
        app.buttons["Pin"].tap()

        waitForExistence(app.scrollViews["CardGrid"])
        XCTAssertTrue(app.buttons["pin"].exists)

        app.buttons[SpaceServiceMock.mySpaceTitle].press(forDuration: 1)
        app.buttons["Unpin"].tap()

        waitForExistence(app.scrollViews["CardGrid"])
        XCTAssertFalse(app.buttons["pin"].exists)
    }

    func testPinnedSpaceIsFirstInAddToSpaceSheet() {
        app.buttons["Show Tabs"].tap()
        app.buttons["Spaces"].tap()

        // On XCode 14.1, we need to interact the screen somehow in order to select a space in test
        app.swipeDown()

        app.buttons[SpaceServiceMock.mySpaceTitle].press(forDuration: 1)
        app.buttons["Pin"].tap()

        waitForExistence(app.scrollViews["CardGrid"])

        app.buttons["Normal Tabs"].tap()
        openURL(path(forTestPage: "test-mozilla-book.html"))
        app.buttons["Add To Space"].tap()

        // Assert that the pinned Space comes first
        XCTAssertTrue(
            app.staticTexts["spaceListItemName"]
                .firstMatch.label == SpaceServiceMock.mySpaceTitle
        )
    }
}
