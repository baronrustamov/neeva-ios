// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

extension BaseTestCase {
    /// Launches from tab page, or runs if already in tab tray
    func setIncognitoMode(
        enabled: Bool,
        urlToOpen: String = "example.com",
        shouldOpenURL: Bool = true,
        closeTabTray: Bool = true
    ) {
        if !app.buttons["Incognito Tabs"].exists {
            goToTabTray()
        }

        if enabled {
            app.buttons["Incognito Tabs"].tap()

            if shouldOpenURL {
                openURLInNewTab(urlToOpen)
            }
        } else {
            app.buttons["Normal Tabs"].tap()
        }

        if app.buttons["Done"].exists && app.buttons["Done"].isHittable && closeTabTray {
            app.buttons["Done"].tap()
        }
    }

    /// Reloads the page from the Overflow Menu
    func reloadPage() {
        if !iPad() {
            goToOverflowMenuButton(label: "Reload") { button in
                button.tap(force: true)
            }
        } else {
            app.buttons["Reload"].tap()
        }
    }

    /// Launches from tab page, switches to desktop site from Overflow Menu
    func requestDesktopSite() {
        goToOverflowMenuButton(label: "Request Desktop Site") { button in
            button.tap(force: true)
        }
    }

    /// Launches from tab page, switches to mobile site from Overflow Menu
    func requestMobileSite() {
        goToOverflowMenuButton(label: "Request Mobile Site") { button in
            button.tap(force: true)
        }
    }

    /// Launches from tab page, ends on tab page
    func clearPrivateData(fromTab: Bool = true) {
        if fromTab {
            goToClearData()
        }

        app.buttons["Clear Selected Data on This Device"].tap()

        waitForExistence(app.buttons["Clear Data"])
        app.buttons["Clear Data"].tap()
        waitForNoExistence(app.buttons["Clear Data"])

        // close settings
        app.buttons["Settings"].tap()

        let navBar = app.navigationBars["Settings"]
        waitForExistence(navBar.buttons["Done"])
        navBar.buttons["Done"].tap()
    }

    /// Launches from tab page, ends with the URL bar focused and the URL as the query
    func editCurrentURL() {
        waitForExistence(app.buttons["Address Bar"])
        app.buttons["Address Bar"].tap()

        waitForExistence(app.buttons["Edit current address"])
        app.buttons["Edit current address"].tap()
    }

    /// Go forward to next visited web site
    func goForward() {
        if !iPad() {
            goToOverflowMenuButton(label: "Forward") { element in
                element.tap(force: true)
            }
        } else {
            app.buttons["Forward"].tap()
        }
    }

    /// Types text into the address bar. Can work from a tab or if the address bar is already visible.
    func performSearch(text: String = "example") {
        if !app.textFields["address"].exists {
            goToAddressBar()
        }

        waitForExistence(app.textFields["address"])
        app.typeText(text)
        app.typeText("\r")

        waitForExistence(app.buttons["Back"])
    }
}
