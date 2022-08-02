// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class ToastTests: BaseTestCase {
    let testWithDB = [
        "testOpenHistoryFromBrowserContextMenuOptions", "testClearHistoryFromSettings",
        "testClearRecentHistory",
    ]

    // This DB contains those 4 websites listed in the name
    let historyDB = "browserYoutubeTwitterMozillaExample.db"

    let clearRecentHistoryOptions = ["The Last Hour", "Today", "Today and Yesterday", "Everything"]

    override func setUp() {
        if testWithDB.contains(testName) {
            // for the current test name, add the db fixture used
            launchArguments = [
                LaunchArguments.SkipIntro, LaunchArguments.SkipWhatsNew,
                LaunchArguments.SkipETPCoverSheet, LaunchArguments.LoadDatabasePrefix + historyDB,
            ]
        }
        super.setUp()
    }

    // MARK: Close Tab Toast
    private func showCloseTabToast() {
        // test the recently closed tab page
        goToTabTray()

        // close tab
        app.buttons["Close"].firstMatch.tap()
    }

    func testClosedTabToastDoesNotAppear() {
        // test the recently closed tab page
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs(createNewTab: false)

        waitForNoExistence(app.buttons["restore"])
    }

    func testClosedTabToastAppears() {
        showCloseTabToast()
        waitForExistence(app.buttons["restore"])
    }

    func testClosedTabToastDisappears() {
        showCloseTabToast()
        waitForExistence(app.buttons["restore"])
        waitForNoExistence(app.buttons["restore"], timeoutValue: 6)
    }

    func testClosedTabToastTabRestored() {
        showCloseTabToast()
        waitForExistence(app.buttons["restore"])
        app.buttons["restore"].tap(force: true)
    }
}
