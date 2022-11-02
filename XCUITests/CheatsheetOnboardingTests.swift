// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import XCTest

final class CheatsheetOnboardingTests: BaseTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let idx = launchArguments.firstIndex(of: LaunchArguments.DisableCheatsheetBloomFilters) {
            launchArguments.remove(at: idx)
        }
        launchArguments.append(LaunchArguments.UseM1AppHost)
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)

        super.setUp()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func goToSRP() throws {
        enterSearchText("neeva")

        // Read the URL to confirm that we are using M1
        // This needs a special workaround because
        // 1. we can't "edit address" on SRP
        // 2. iOS 16 presents alert for copy pasting
        goToTabTray()
        // locate the tab for neeva
        waitForExistence(app.buttons["neeva - Neeva, Tab"])
        // press and hold to copy
        app.buttons["neeva - Neeva, Tab"]
            // the tap target is off. need to offset it
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 1)
        waitForExistence(app.buttons["Copy Link"])
        app.buttons["Copy Link"].tap()

        // go back to the tab
        app.buttons["neeva - Neeva, Tab"]
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .tap()

        // paste the URL back
        app.buttons["Address Bar"].tap()
        waitForExistence(app.textFields["address"])
        app.textFields["address"].tap()
        waitForExistence(app.menuItems["Paste"], timeout: 5)
        app.menuItems["Paste"].tap()

        // read the pasted value
        waitForExistence(app.textFields["address"])
        let urlField = app.textFields["address"]

        let urlString = try XCTUnwrap(urlField.value as? String)
        XCTAssert(urlString.contains("m1"))

        // now restore the UI as if we didn't perform the check
        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()
    }

    func testOnboardingHappyPath() throws {
        try goToSRP()

        // Tap neeva button
        app.buttons["Neeva"].tap()

        // Tap acknowledge button
        app.buttons["Got it!"].tap()

        // go to some link
        openURL("example.com")

        XCTAssertTrue(app.staticTexts["Try NeevaScope!"].exists)
    }
}
