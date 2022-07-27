// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class SuggestionBackButtonTests: BaseTestCase {
    override func setUp() {
        if testName == "testSuggestionBackButtonEnabledFromCardGrid" {
            launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        }

        super.setUp()
    }

    private func performSearch() {
        performSearch(text: "example.com")
    }

    private func testAddressBarContains(value: String) {
        waitForExistence(app.textFields["address"])
        XCTAssertEqual(value, app.textFields["address"].value as? String)
    }

    /// Make sure back button can be tapped after searching from Card Grid.
    /// Also tests if tapping the back button works and shows the Suggest UI.
    func testSuggestionBackButtonEnabledFromCardGrid() {
        // Create new tab, and perform a search
        newTab()
        performSearch()

        // Go back to Suggest UI
        app.buttons["Back"].tap()
        testAddressBarContains(value: "example.com")
    }

    func testSuggestionBackButtonEnabledFromURLBar() {
        goToAddressBar()
        performSearch()

        XCTAssertTrue(app.buttons["Back"].isEnabled)
    }

    func testMultipleQueryPaths() {
        goToAddressBar()
        performSearch()

        waitForHittable(app.buttons["Back"])
        app.buttons["Back"].tap()

        performSearch(text: "/fake")

        app.buttons["Back"].tap()
        testAddressBarContains(value: "example.com/fake")

        app.buttons["Cancel"].tap()
        waitForExistence(app.buttons["Back"])

        app.buttons["Back"].tap()
        testAddressBarContains(value: "example.com")
    }

    func testReturningToParentTabFromURLBar() {
        // Open parent tab.
        goToAddressBar()
        performSearch()

        // Open tab from parent.
        goToAddressBar()
        performSearch(text: path(forTestPage: "test-mozilla-book.html"))

        // Go back to example.com.
        app.buttons["Back"].tap()
        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // Confirm returned to parent tab.
        waitForExistence(app.staticTexts["Example Domain"])
    }
}
