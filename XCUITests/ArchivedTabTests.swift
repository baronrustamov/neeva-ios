// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import XCTest

class ArchivedTabTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.AddTestArchivedTabs)
        super.setUp()
    }

    func testDeleteSingleCard() {
        goToHistory()

        waitForHittable(app.buttons["Archive"])
        app.buttons["Archive"].tap()

        waitForExistence(app.buttons["ArchivedTabCardView"])
        app.buttons["ArchivedTabCardView"].press(forDuration: 1)

        waitForExistence(app.buttons["Delete"])
        app.buttons["Delete"].tap()

        waitForNoExistence(app.buttons["ArchivedTabCardView"])
    }
}
