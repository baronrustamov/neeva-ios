// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class DuplicateTabTests: BaseTestCase {
    func testDuplicateTab() {
        openURL()
        goToTabTray()

        app.buttons["Example Domain, Tab"].press(forDuration: 1)
        waitForExistence(app.buttons["Duplicate Tab"])
        app.buttons["Duplicate Tab"].tap()

        app.buttons["Done"].tap()
        waitForExistence(app.links["More information..."])
    }

    func testOpenTabInIncognito() {
        openURL()
        goToTabTray()

        app.buttons["Example Domain, Tab"].press(forDuration: 1)
        waitForExistence(app.buttons["Open in Incognito"])
        app.buttons["Open in Incognito"].tap()
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)

        app.buttons["Done"].tap()
        waitForExistence(app.links["More information..."])
        waitForExistence(app.buttons["Tracking Protection, Incognito"])
    }
}
