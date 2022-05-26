// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class CookieCutterTests: BaseTestCase {
    private static let nonEssentialCookieSwitches = [
        "Marketing Cookies, Tracks your online activity for advertising purposes",
        "Analytics Cookies, Collects information about your visits and actions on a site",
        "Social Cookies, Personalization and social media features from third party providers",
    ]

    // MARK: - Logic
    func testCookieCutterGlobalDisable() {
        openURL()
        openURLInNewTab(path(forTestPage: "test-mozilla-book.html"))

        goToSettings()
        app.buttons["Cookie Cutter"].tap()

        waitForExistence(app.switches["Cookie Cutter"])
        app.switches["Cookie Cutter"].firstMatch.tap()

        app.buttons["Settings"].tap()
        app.buttons["Done"].tap()

        goToTrackingProtectionMenu()
        waitForNoExistence(app.staticTexts["Cookie Popups"])

        // Dismiss popover
        app.tap()

        // Switch tab
        goToTabTray()
        app.buttons["Example Domain, Tab"].tap()

        goToTrackingProtectionMenu()
        waitForNoExistence(app.staticTexts["Cookie Popups"])
    }

    func testCookieCutterPerSiteDisable() {
        openURL()
        openURLInNewTab(path(forTestPage: "test-mozilla-book.html"))

        goToTrackingProtectionMenu()
        app.switches["TrackingMenu.TrackingMenuProtectionRow"].tap()
        waitForNoExistence(app.staticTexts["Cookie Popups"])

        // Dismiss popover
        app.tap()

        // Switch tab, make sure Cookie Cutter is still enabled
        goToTabTray()
        app.buttons["Example Domain, Tab"].tap()

        goToTrackingProtectionMenu()
        waitForExistence(app.staticTexts["Cookie Popups"])

        // Dismiss popover
        app.tap()

        // Switch back, make sure Cookie Cutter is still disabled
        goToTabTray()
        app.buttons["The Book of Mozilla, Tab"].tap()

        goToTrackingProtectionMenu()
        waitForNoExistence(app.staticTexts["Cookie Popups"])
    }

    // MARK: - UI
    func testGoToSettingsFromTrackingMenu() {
        openURL()

        goToTrackingProtectionMenu()
        app.buttons["Cookie Cutter Settings"].tap()

        waitForExistence(app.tables["cookieCutterSettingsPage"])
    }

    func testCheckReloadToastShowsDisablingAllCookies() {
        goToSettings()
        app.buttons["Cookie Cutter"].tap()

        waitForExistence(app.staticTexts["Accept Non-essential Cookies"])
        app.staticTexts["Accept Non-essential Cookies"].tap()

        waitForExistence(app.switches[Self.nonEssentialCookieSwitches[0]])

        for i in 0...Self.nonEssentialCookieSwitches.count - 1 {
            app.switches[Self.nonEssentialCookieSwitches[i]].firstMatch.tap()
        }

        waitForExistence(app.buttons["Reload"])
        app.buttons["Reload"].firstMatch.tap(force: true)

        waitForExistence(app.switches["Cookie Popups"])
        XCTAssertTrue(app.switches["Cookie Popups"].firstMatch.value as! String == "1")
    }
}
