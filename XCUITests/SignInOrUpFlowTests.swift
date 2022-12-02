// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKitTest

class SignInOrUpFlowTests: BaseTestCase {
    func testSignInOrUpFlowDisplays() {
        _ = try! SKTestSession(configurationFileNamed: "StoreKitLocalTesting")

        goToSettings()

        waitForExistence(app.buttons["Sign in or Join Neeva"])
        app.buttons["Sign in or Join Neeva"].tap()

        waitForExistence(app.buttons["Try it Free"])
    }
}
