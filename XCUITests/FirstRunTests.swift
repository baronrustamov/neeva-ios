// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class FirstRunTests: BaseTestCase {

    override func setUp() {
        // for the current test name, add the db fixture used
        launchArguments = [
            LaunchArguments.ReactivateIntro, LaunchArguments.SkipWhatsNew,
            LaunchArguments.ForceExperimentControlArm,
        ]

        super.setUp()
    }

    func openNeevaSettings() {
        waitForExistence(app.buttons["Get Started"])
        app.buttons["Get Started"].tap()

        waitForExistence(app.buttons["Open Neeva Settings"])

        // This will navigate the app away to system settings
        app.buttons["Open Neeva Settings"].tap()

        let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        waitForExistence(settingsApp.tables.cells.staticTexts["Default Browser App"])

        // foreground browser
        app.activate()
    }

    func testOpenNeevaSettingsAndClose() throws {
        openNeevaSettings()

        waitForExistence(app.buttons["close"])
        app.buttons["close"].tap()

        openURL(websiteExample["url"]!)
        waitUntilPageLoad()
    }

    func testOpenNeevaSettingsAndRemind() throws {
        openNeevaSettings()

        waitForExistence(app.buttons["Remind Me Later"])
        app.buttons["Remind Me Later"].tap()

        openURL(websiteExample["url"]!)
        waitUntilPageLoad()
    }

    func testRemindMeLater() throws {
        waitForExistence(app.buttons["Get Started"])
        app.buttons["Get Started"].tap()

        waitForExistence(app.buttons["Remind Me Later"])
        app.buttons["Remind Me Later"].tap()

        openURL(websiteExample["url"]!)
        waitUntilPageLoad()
    }

    func testDirectClose() throws {
        waitForExistence(app.buttons["Get Started"])
        app.buttons["Get Started"].tap()

        waitForExistence(app.buttons["close"])
        app.buttons["close"].tap()

        openURL(websiteExample["url"]!)
        waitUntilPageLoad()
    }

    func testTriggerSignInModalAndClose() throws {
        try skipTest(issue: 3696, "Disabled as this test is flaky")
        waitForExistence(app.buttons["Get Started"])
        app.buttons["Get Started"].tap()

        waitForExistence(app.buttons["close"])
        app.buttons["close"].tap()

        // We are on the new tab page, kind of. The sign-in button isn't visible yet
        XCTAssertTrue(app.staticTexts["Search or enter address"].isHittable)
        waitForExistence(app.buttons["Address Bar"])
        app.buttons["Address Bar"].tap()

        // Trigger the modal
        waitForExistence(app.buttons["Sign in or Join Neeva"])
        app.buttons["Sign in or Join Neeva"].tap()

        // Verify that the address bar isn't "hittable," i.e., the modal is on the screen
        XCTAssertFalse(app.staticTexts["Search or enter address"].isHittable)

        // Close the modal
        waitForExistence(app.buttons["Close"])
        app.buttons["Close"].tap()

        // Verify that the modal closed correctly
        XCTAssertTrue(app.staticTexts["Search or enter address"].isHittable)
    }
}
