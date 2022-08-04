// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private let firstWebsite = (
    url: path(forTestPage: "test-mozilla-org.html"),
    tabName: "Internet for people, not profit — Mozilla, Tab"
)
private let secondWebsite = (
    url: path(forTestPage: "test-mozilla-book.html"), tabName: "The Book of Mozilla, Tab"
)

class TabMenuTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        launchArguments.append("\(LaunchArguments.EnableFeatureFlags)tabGroupsPinning")
        super.setUp()
    }

    func testCloseNormalTabFromTab() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        XCTAssertEqual(getNumberOfTabs(), 1, "Expected number of tabs remaining is not correct")
    }

    func testCloseAllNormalTabsFromTab() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])

        // Check that the Toast does not appears
        waitForNoExistence(app.buttons["restore"])
    }

    func testCloseIncognitoTabFromTab() {
        setIncognitoMode(enabled: true)
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        XCTAssertEqual(getNumberOfTabs(), 1, "Expected number of tabs remaining is not correct")
    }

    func testCloseAllIncognitoTabsFromTab() {
        setIncognitoMode(enabled: true)
        openURLInNewTab(secondWebsite.url)

        closeAllTabs(createNewTab: false)

        waitForExistence(app.buttons["Incognito Tabs"])
        setIncognitoMode(enabled: false, shouldOpenURL: false, closeTabTray: false)

        XCTAssertEqual(
            getNumberOfTabs(openTabTray: false), 0,
            "Expected number of tabs remaining is not correct")

        // Check that the Toast does not appears
        waitForNoExistence(app.buttons["restore"])
    }

    func testCloseAllNormalTabsFromSwitcher() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
        goToTabTray()

        closeAllTabs(fromTabSwitcher: true, createNewTab: false)
        waitForExistence(app.staticTexts["EmptyTabTray"])

        // Check that the Toast does not appears
        waitForNoExistence(app.buttons["restore"])
    }

    func testCloseAllIncognitoTabsFromSwitcher() {
        setIncognitoMode(enabled: true)
        openURLInNewTab(secondWebsite.url)
        closeAllTabs(createNewTab: false)

        waitForExistence(app.buttons["Incognito Tabs"])
        setIncognitoMode(enabled: false, shouldOpenURL: false, closeTabTray: false)

        XCTAssertEqual(
            getNumberOfTabs(openTabTray: false), 0,
            "Expected number of tabs remaining is not correct")

        // Check that the Toast does not appears
        waitForNoExistence(app.buttons["restore"])
    }

    func testCloseAllTabsWithoutConfirmation() {
        goToSettings()
        app.switches["Require Confirmation, When Closing All Tabs"].firstMatch.tap()
        app.navigationBars["Settings"].buttons["Done"].tap()

        openURLInNewTab(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)
        app.buttons["Close All Tabs"].tap()

        // Check that the Toast appears
        waitForExistence(app.buttons["restore"])
    }

    func testPinTabFromSwitcher() {
        openURL(firstWebsite.url)
        goToTabTray()

        waitForExistence(app.buttons[firstWebsite.tabName], timeout: 30)
        app.buttons[firstWebsite.tabName].press(forDuration: 1)

        waitForExistence(app.buttons["Pin tab"], timeout: 30)
        app.buttons["Pin tab"].tap()

        app.buttons[firstWebsite.tabName].press(forDuration: 1)

        // Check that unpin option exists
        waitForExistence(app.buttons["Unpin tab"])
    }
}
