// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class SignedOutAddToSpacesSheetTests: BaseTestCase {
    override func setUp() {
        launchArguments = [
            // The argument below is needed to use the local server
            "\(LaunchArguments.ServerPort)\(serverPort)",
            LaunchArguments.ClearProfile,
            LaunchArguments.SkipWhatsNew,
            LaunchArguments.SkipIntro,
        ]

        super.setUp()

        // The actual page we use is irrelevant, we just want to
        // (1) enable the Add to Space button and (2) minimize latency
        // and server load (which is why we're using a local server)
        openURL(path(forTestPage: "test-mozilla-book.html"))
        app.buttons["Add To Space"].tap()
    }

    func testViewSpacesButton() throws {
        XCTAssertTrue(app.buttons["View Spaces"].exists)

        app.buttons["View Spaces"].forceTapElement()

        XCTAssertTrue(app.buttons["Spaces"].isSelected)
    }

    func testCloseOnTapOutside() throws {
        app.buttons["Address Bar"].tap()

        waitForNoExistence(app.buttons["View Spaces"])
    }

    func testCloseOnTapX() throws {
        app.buttons["Close"].forceTapElement()

        waitForNoExistence(app.buttons["View Spaces"])
    }

    func testCopyExists() throws {
        waitForExistence(app.staticTexts["Save to Spaces"])
        XCTAssertTrue(app.staticTexts["Oops, this page is a little shy"].exists)
        XCTAssertTrue(app.buttons["Sign in or Join Neeva"].exists)
    }

    func testSignInButton() throws {
        try skipTest(
            issue: 3410,
            "Flaky -- need to figure out why the second popover sometimes does not appear")

        app.buttons["Sign in or Join Neeva"].forceTapElement()

        waitForExistence(app.staticTexts["Create your free Neeva account"])
    }
}
