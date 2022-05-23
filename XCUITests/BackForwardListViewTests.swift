// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

class BackForwardListViewTests: BaseTestCase {
    func testListShowCorrectItems() {
        openURL()

        // Perform navigation
        waitForExistence(app.links["More information..."])
        app.links["More information..."].tap()
        waitUntilPageLoad()

        // Show BackForwardListView
        app.buttons["Back"].press(forDuration: 1)
        waitForExistence(app.alerts["Back/Forward List"])

        // Confirm navigation items exist
        waitForExistence(app.buttons["backForwardListItem-Example Domain"])
        waitForExistence(app.buttons["backForwardListItem-IANA-managed Reserved Domains"])
    }

    func testListShowCorrectItemsIncognito() {
        setIncognitoMode(enabled: true)
        testListShowCorrectItems()
    }
}
