// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKitTest

class WelcomeFlowTests: BaseTestCase {
    func testShowPlansWhenProductsExist() {
        _ = try! SKTestSession(configurationFileNamed: "StoreKitLocalTesting")

        launchArguments = []
        setUp()

        waitForExistence(app.buttons["Let's Go"])
        app.buttons["Let's Go"].tap()

        waitForExistence(app.buttons["Try it Free"])
    }

    func testShowDefaultBrowserWhenProductsAreAbsent() {
        _ = try! SKTestSession(configurationFileNamed: "StoreKitEmpty")

        launchArguments = []
        setUp()

        waitForExistence(app.buttons["Let's Go"])
        app.buttons["Let's Go"].tap()

        waitForExistence(app.buttons["Open Neeva settings"])
    }

    func testGetFreePathThroughPlans() {
        _ = try! SKTestSession(configurationFileNamed: "StoreKitLocalTesting")

        launchArguments = []
        setUp()

        waitForExistence(app.buttons["Let's Go"])
        app.buttons["Let's Go"].tap()

        waitForExistence(app.staticTexts["planFree"])
        app.staticTexts["planFree"].tap()

        waitForExistence(app.buttons["Get FREE"])
        app.buttons["Get FREE"].tap()

        waitForExistence(app.buttons["Remind me later"])
        app.buttons["Remind me later"].tap()
    }
}
