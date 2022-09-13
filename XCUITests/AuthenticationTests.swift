// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class AuthenticationTests: IpadOnlyTestCase {
    private let url = "https://jigsaw.w3.org/HTTP/Basic"

    func testIncorrectCredentials() throws {
        try skipIfNeeded()
        openURL(url, waitForPageLoad: false)

        // Make sure that 3 invalid credentials result in authentication failure.
        enterCredentials(username: "foo", password: "bar")
        enterCredentials(username: "foo2", password: "bar2")
        enterCredentials(username: "foo3", password: "bar3")
        waitForExistence(app.staticTexts["Unauthorized access"])
    }

    func testCorrectCredentials() throws {
        try skipIfNeeded()
        openURL(url, waitForPageLoad: false)

        enterCredentials(username: "guest", password: "guest")
        waitForExistence(app.staticTexts["Your browser made it!"])
    }

    private func enterCredentials(username: String, password: String) {
        enter(text: username, in: "Auth_Username_Field")
        enter(text: password, in: "Auth_Password_Field", isSecure: true)

        waitForExistence(app.buttons["Auth_Submit"])
        app.buttons["Auth_Submit"].tap(force: true)
        waitForExistence(app.buttons["Show Tabs"])
    }

    private func enter(text: String, in field: String, isSecure: Bool = false) {
        waitForExistence(app.textFields["Auth_Username_Field"])

        app.textFields[field].tap(force: true)
        app.textFields[field].typeText(text + "\n")
    }
}
