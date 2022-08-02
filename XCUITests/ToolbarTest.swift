/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let website1: [String: String] = [
    "url": path(forTestPage: "test-mozilla-org.html"),
    "label": "Internet for people, not profit — Mozilla", "value": "localhost",
    "longValue": "localhost:\(serverPort)/test-fixture/test-mozilla-org.html",
]
let website2 = path(forTestPage: "test-example.html")

let PDFWebsite = ["url": "http://www.pdf995.com/samples/pdf.pdf"]

class ToolbarTests: BaseTestCase {
    override func setUp() {
        super.setUp()

        if testName.contains("Landscape") {
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        }
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        super.tearDown()
    }

    /// Tests landscape page navigation enablement with the URL bar with tab switching.
    func testLandscapeNavigationWithTabSwitch() throws {
        try skipTest(issue: 1823, "this test if flaky")

        XCTAssert(app.buttons["Address Bar"].exists)

        // Check that the back and forward buttons are disabled
        XCTAssertFalse(app.buttons["Back"].isEnabled)
        goToOverflowMenuButton(label: "Forward") { element in
            XCTAssertFalse(element.isEnabled)
        }

        // Navigate to two pages and press back once so that all buttons are enabled in landscape mode.
        openURL(website1["url"]!)
        waitUntilPageLoad()
        waitForExistence(app.webViews.links["Mozilla"], timeout: 10)
        let valueMozilla = app.buttons["Address Bar"].value as! String
        XCTAssertEqual(valueMozilla, website1["url"])
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        XCTAssertTrue(app.buttons["Reload"].isEnabled)
        goToOverflowMenuButton(label: "Forward") { element in
            XCTAssertFalse(element.isEnabled)
        }

        openURL(website2)
        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: website2)
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        goToOverflowMenuButton(label: "Forward") { element in
            XCTAssertFalse(element.isEnabled)
        }

        app.buttons["Back"].tap()
        XCTAssertEqual(valueMozilla, website1["url"])

        waitUntilPageLoad()
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        goToOverflowMenuButton(label: "Forward") { element in
            XCTAssertTrue(element.isEnabled)
        }

        // Open new tab and then go back to previous tab to test navigation buttons.
        waitForExistence(app.buttons["Show Tabs"], timeout: 15)
        goToTabTray()
        waitForExistence(app.buttons["\(website1["label"]!), Tab"])
        XCTAssertEqual(valueMozilla, website1["url"])

        app.buttons["\(website1["label"]!), Tab"].tap()

        // Test to see if all the buttons are enabled then close tab.
        waitUntilPageLoad()
        waitForExistence(app.buttons["Back"])
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        goToOverflowMenuButton(label: "Forward") { element in
            XCTAssertTrue(element.isEnabled)
        }

        closeAllTabs(fromTabSwitcher: app.buttons["Done"].exists)

        waitForExistence(app.buttons["Back"])

        // Go Back to other tab to see if all buttons are disabled.
        XCTAssertFalse(app.buttons["Back"].isEnabled)
        goToOverflowMenuButton(label: "Forward") { element in
            XCTAssertFalse(element.isEnabled)
        }
    }

    func testClearURLTextUsingBackspace() {
        openURL(path(forTestPage: "test-mozilla-book.html"))

        let valueMozilla = app.buttons["Address Bar"].value as! String
        XCTAssertEqual(valueMozilla, path(forTestPage: "test-mozilla-book.html"))

        // Simulate pressing on backspace key should remove the text
        app.buttons["Address Bar"].tap()
        app.textFields["address"].typeText("\u{8}")

        let value = app.textFields["address"].value
        XCTAssertEqual(value as? String, "", "The url has not been removed correctly")
    }

    func testToolbarsHideOnScroll() {
        openURL(website1["url"]!)

        // Confirm toolbars are visible.
        XCTAssert(app.buttons["Address Bar"].isHittable)
        XCTAssert(app.buttons["Back"].isHittable)

        // Different elemets that are used for dragging.
        let iOS = app.webViews.links["iOS"].firstMatch
        let firefox = app.webViews.links["Firefox"].firstMatch
        let requirments = app.webViews.links["requirements"].firstMatch
        let firefoxPrivacyNotice = app.webViews.links["Firefox Privacy Notice"].firstMatch

        // Scroll down to hide toolbars.
        iOS.press(forDuration: 0.1, thenDragTo: firefox)

        // Confirm toolbars are hidden.
        XCTAssertFalse(app.buttons["Address Bar"].isHittable)
        XCTAssertFalse(app.buttons["Back"].isHittable)

        // Scroll back up to show toolbars.
        requirments.press(forDuration: 0.1, thenDragTo: firefoxPrivacyNotice)
        iOS.press(forDuration: 0.1, thenDragTo: requirments)

        // Confirm toolbars are visible.
        XCTAssert(app.buttons["Address Bar"].isHittable)
        XCTAssert(app.buttons["Back"].isHittable)
    }

    func testRevealToolbarWhenTappingOnStatusbar() {
        openURL(website1["url"]!)

        // Confirm toolbars are visible.
        XCTAssert(app.buttons["Address Bar"].isHittable)
        XCTAssert(app.buttons["Back"].isHittable)

        // Different elemets that are used for dragging.
        let iOS = app.webViews.links["iOS"].firstMatch
        let firefox = app.webViews.links["Firefox"].firstMatch

        // Scroll down to hide toolbars.
        iOS.press(forDuration: 0.1, thenDragTo: firefox)

        // Confirm toolbars are hidden.
        XCTAssertFalse(app.buttons["Address Bar"].isHittable)
        XCTAssertFalse(app.buttons["Back"].isHittable)

        // Tap status bar to show toolbars.
        let statusbarElement: XCUIElement = {
            return XCUIApplication(bundleIdentifier: "com.apple.springboard").statusBars.firstMatch
        }()
        sleep(1)
        statusbarElement.tap(force: true)

        // Confirm toolbars are visible.
        XCTAssert(app.buttons["Address Bar"].isHittable)
        XCTAssert(app.buttons["Back"].isHittable)
    }
}
