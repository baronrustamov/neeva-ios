// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class DeleteIncognitoTabTests: BaseTestCase {
    func testIncognitoTabsDeleted() {
        goToSettings()

        app.buttons["App Icon"].press(
            forDuration: 1, thenDragTo: app.buttons["Default Browser"])

        waitForHittable(app.switches["Close Incognito Tabs, When Leaving Incognito Mode"])
        app.switches["Close Incognito Tabs, When Leaving Incognito Mode"].tap()
        XCTAssertTrue(
            app.switches["Close Incognito Tabs, When Leaving Incognito Mode"].value as! String
                == "1")

        app.buttons["Done"].tap()

        setIncognitoMode(enabled: true)
        setIncognitoMode(enabled: false, shouldOpenURL: false, closeTabTray: false)

        // Check the incognito tab does not exists.
        setIncognitoMode(enabled: true, shouldOpenURL: false, closeTabTray: false)
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 0)
    }

    func testIncognitoTabsNotDeletingWhenSettingNotEnabled() {
        setIncognitoMode(enabled: true)
        setIncognitoMode(enabled: false)

        // Check the incognito tab still exists.
        setIncognitoMode(enabled: true, shouldOpenURL: false, closeTabTray: false)
        XCTAssertEqual(getNumberOfTabs(openTabTray: false), 1)
    }
}
