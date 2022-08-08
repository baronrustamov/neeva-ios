// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

class ReaderModeTests: BaseTestCase {
    func goToReaderModeSite() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        waitUntilPageLoad()
        waitForExistence(app.buttons["Reader Mode"])
    }

    func enableReaderMode() {
        goToReaderModeSite()
        app.buttons["Reader Mode"].tap()
        waitUntilPageLoad()
    }

    func testReaderModeOptionDoesntExist() {
        openURL()
        waitUntilPageLoad()
        waitForNoExistence(app.buttons["Reader Mode"])
    }

    func testEnableDisableReaderMode() {
        enableReaderMode()
        waitForExistence(app.buttons["Reading Mode Settings"])
        app.buttons["Reading Mode Settings"].tap()

        waitForExistence(app.buttons["Close Reading Mode"])
        app.buttons["Close Reading Mode"].tap()
        waitUntilPageLoad()

        copyUrl()

        if let myString = UIPasteboard.general.string, let url = URL(string: myString) {
            XCTAssertEqual("/test-fixture/test-mozilla-org.html", url.path)
        }
    }

    func testSecureSiteIconShowsCorrectState() {
        openURL("badssl.com")
        waitForExistence(app.staticTexts["locationLabelSiteSecure"])

        goToReaderModeSite()
        app.buttons["Reader Mode"].tap()
        waitUntilPageLoad()

        // Make sure the site still shows as secure.
        goToTabTray()
        app.buttons["badssl.com, Tab"].tap()
        waitForExistence(app.staticTexts["locationLabelSiteSecure"])

        // Try an unsecure site.
        app.links["expired"].firstMatch.tap()
        waitForExistence(app.staticTexts["locationLabelSiteNotSecure"])

        goToReaderModeSite()
        app.buttons["Reader Mode"].tap()
        waitUntilPageLoad()

        // Make sure the site still shows as not secure.
        goToTabTray()
        app.buttons["This connection is not trusted, Tab"].tap()
        waitForExistence(app.staticTexts["locationLabelSiteNotSecure"])
    }
}
