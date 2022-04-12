// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class FirstRunTests: BaseTestCase {

    override func setUp() {
        // for the current test name, add the db fixture used
        launchArguments = [
            LaunchArguments.ReactivateIntro, LaunchArguments.SkipWhatsNew,
        ]

        super.setUp()
    }

    func testOpenNeevaSettings() throws {
        waitForExistence(app.buttons["Get Started"])
        app.buttons["Get Started"].tap()

        waitForExistence(app.buttons["Open Neeva Settings"])

        // This will navigate the app away to system settings
        app.buttons["Open Neeva Settings"].tap()

        let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        waitForExistence(settingsApp.tables.cells.staticTexts["Default Browser App"])

        // foreground browser
        app.activate()

        openURL(websiteExample["url"]!)
        waitUntilPageLoad()
    }

    func testSkipForNow() throws {
        waitForExistence(app.buttons["Get Started"])
        app.buttons["Get Started"].tap()

        waitForExistence(app.buttons["Skip for Now"])
        app.buttons["Skip for Now"].tap()

        openURL(websiteExample["url"]!)
        waitUntilPageLoad()
    }
}
