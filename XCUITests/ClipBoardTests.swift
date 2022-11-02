/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"

    // Check for test url in the browser
    func checkUrl() {
        let urlField = app.buttons["Address Bar"]
        waitForValueContains(urlField, value: "http://example.com/", timeout: 30)
    }

    // Check copied url is same as in browser
    func checkCopiedUrl() {
        let string: String? = {
            if #available(iOS 16.0, *) {
                return getTabURL()?.absoluteString
            } else {
                return UIPasteboard.general.string
            }
        }()

        if let myString = string {
            let value = app.buttons["Address Bar"].value as! String
            XCTAssertNotNil(myString)
            XCTAssertEqual(myString, value, "Url matches with the UIPasteboard")
        }
    }

    // This test is disabled in release, but can still run on master
    func testClipboard() throws {
        try skipTest(issue: 1749, "this test is flaky")

        openURL()
        checkUrl()
        copyUrl()
        checkCopiedUrl()

        waitForExistence(app.buttons["Edit current address"])
        app.buttons["Edit current address"].tap()
        app.textFields["address"].typeText("\n")

        waitForExistence(app.buttons["Address Bar"])
        app.buttons["Address Bar"].press(forDuration: 2)

        waitForExistence(app.menuItems["Paste & Go"], timeout: 30)
        app.menuItems["Paste & Go"].tap()

        checkUrl()
    }
}
