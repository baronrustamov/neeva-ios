// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class CreateOrSwitchToTabTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        super.setUp()
    }

    func testSwitchBackToTabFromURLBar() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))
        openURL(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 2)
    }

    // We need to use a remote server because GCDWebServer does not support https
    func testSwitchBackToTabFromURLBarNoScheme() {
        openURL("https://example.com")
        openURL(path(forTestPage: "test-mozilla-book.html"))
        // This should be equivalent to the first tab we opened,
        // resulting in a tab switch rather than a new tab
        openURL("example.com")

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 2)
    }

    func testSwitchBackToTabFromTabSwitcher() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))

        goToTabTray()
        openURL(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 2)
    }

    func testSwitchBackToTabFromTabSwitcherNoScheme() {
        openURL("https://example.com")
        openURL(path(forTestPage: "test-mozilla-book.html"))

        goToTabTray()
        openURL("example.com")

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 2)
    }

    func testCreatesNewTabFromLongPressMenu() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))

        openURLInNewTab(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 3)
    }

    func testCreatesNewTabFromLongPressMenuNoScheme() {
        openURL("https://example.com")
        openURL(path(forTestPage: "test-mozilla-book.html"))

        openURLInNewTab("example.com")

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 3)
    }
}
