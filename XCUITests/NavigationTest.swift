/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let website_2 = [
    "url": "www.example.com", "label": "Example", "value": "example", "link": "More information...",
    "moreLinkLongPressUrl": "https://www.iana.org/domains/example",
    "moreLinkLongPressUrlPrivate": "https://www.iana.org/domains/example",
    "moreLinkLongPressInfo": "iana",
]
let urlAddons = "addons.mozilla.org"
let urlGoogle = "www.google.com"
let popUpTestUrl = path(forTestPage: "test-popup-blocker.html")

let requestMobileSiteLabel = "Request Mobile Site"
let requestDesktopSiteLabel = "Request Desktop Site"

class NavigationTest: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.SkipAdBlockOnboarding)
        super.setUp()
    }

    func testNavigation() {
        func checkForwardButtonDisabled() {
            if app.buttons["Forward"].exists {
                XCTAssertFalse(app.buttons["Forward"].isEnabled)
            } else if iPad() {
                // This fails on CircleCI when using an iPhone.
                goToOverflowMenuButton(label: "Forward") { element in
                    XCTAssertFalse(element.isEnabled)
                    // Close the menu.
                    element.tap()
                }
            }
        }

        closeAllTabs()
        openURL()
        waitForValueContains(app.buttons["Address Bar"], value: "example.com")

        // Back button should be enabled since we opened a URL from search.
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        checkForwardButtonDisabled()

        waitForHittable(app.links["More information..."])
        app.links["More information..."].tap()

        // Once a second url is open, back button is enabled but not the forward one till we go back to url_1
        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: "www.iana.org")
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        checkForwardButtonDisabled()

        app.buttons["Back"].tap()

        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: "example.com")

        goForward()
        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: "www.iana.org")
    }

    // Smoketest
    func testLongPressLinkOptions() {
        openURL()
        waitForExistence(app.webViews.links[website_2["link"]!], timeout: 30)
        app.webViews.links[website_2["link"]!].press(forDuration: 1)
        waitForExistence(app.otherElements.collectionViews.element(boundBy: 0), timeout: 5)

        XCTAssertTrue(app.buttons["Open in New Tab"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Open in New Incognito Tab"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Copy Link"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Download Link"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Share Link"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Add to Space"].exists, "The option is not shown")
    }

    func testLongPressLinkOptionsIncognitoMode() {
        setIncognitoMode(enabled: true)

        openURL()
        waitForExistence(app.webViews.links[website_2["link"]!], timeout: 5)
        app.webViews.links[website_2["link"]!].press(forDuration: 1)
        waitForExistence(
            app.collectionViews.staticTexts[website_2["moreLinkLongPressUrl"]!], timeout: 3)
        XCTAssertFalse(app.buttons["Open in New Tab"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Open in New Incognito Tab"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Copy Link"].exists, "The option is not shown")
        XCTAssertTrue(app.buttons["Download Link"].exists, "The option is not shown")
    }

    func testCopyLink() {
        longPressLinkOptions(optionSelected: "Copy Link")
        XCTAssertEqual(UIPasteboard.general.url?.absoluteString, website_2["moreLinkLongPressUrl"]!)
    }

    func testCopyLinkIncognitoMode() {
        setIncognitoMode(enabled: true)
        longPressLinkOptions(optionSelected: "Copy Link")

        XCTAssertEqual(
            UIPasteboard.general.url?.absoluteString, website_2["moreLinkLongPressUrlPrivate"]!)
    }

    func testLongPressOnAddressBar() {
        openURL()
        editCurrentURL()

        app.textFields["address"].press(forDuration: 1)
        waitForExistence(app.menuItems["Select All"])

        //Tap on Select All option and make sure Copy, Cut, Paste, and Look Up are shown
        app.menuItems["Select All"].tap()
        waitForExistence(app.menuItems["Copy"])
        if iPad() {
            XCTAssertTrue(app.menuItems["Copy"].exists)
            XCTAssertTrue(app.menuItems["Cut"].exists)
            XCTAssertTrue(app.menuItems["Look Up"].exists)
            XCTAssertTrue(app.menuItems["Share…"].exists)
            XCTAssertTrue(app.menuItems["Paste"].exists)
            XCTAssertTrue(app.menuItems["Paste & Go"].exists)
        } else {
            XCTAssertTrue(app.menuItems["Copy"].exists)
            XCTAssertTrue(app.menuItems["Cut"].exists)
            XCTAssertTrue(app.menuItems["Look Up"].exists)
            XCTAssertTrue(app.menuItems["Paste"].exists)
        }

        app.textFields["address"].typeText("\n")
        waitUntilPageLoad()

        editCurrentURL()

        app.textFields["address"].press(forDuration: 1)
        waitForExistence(app.menuItems["Select All"])

        app.menuItems["Select All"].tap()
        waitForExistence(app.menuItems["Paste"])

        if iPad() {
            XCTAssertTrue(app.menuItems["Copy"].exists)
            XCTAssertTrue(app.menuItems["Cut"].exists)
            XCTAssertTrue(app.menuItems["Look Up"].exists)
            XCTAssertTrue(app.menuItems["Share…"].exists)
            XCTAssertTrue(app.menuItems["Paste & Go"].exists)
            XCTAssertTrue(app.menuItems["Paste"].exists)
        } else {
            XCTAssertTrue(app.menuItems["Copy"].exists)
            XCTAssertTrue(app.menuItems["Cut"].exists)
            XCTAssertTrue(app.menuItems["Look Up"].exists)
        }
    }

    private func longPressLinkOptions(optionSelected: String) {
        if !app.webViews.links[website_2["link"]!].exists {
            openURL()
            waitUntilPageLoad()
        }

        app.webViews.links[website_2["link"]!].press(forDuration: 2)
        waitForExistence(app.buttons[optionSelected])

        if !app.buttons[optionSelected].isHittable {
            app.swipeUp()
        }

        app.buttons[optionSelected].tap()
    }

    func testDownloadLink() throws {
        try skipTest(issue: 1241, "this test cannot be run twice in a row")
        longPressLinkOptions(optionSelected: "Download Link")
        waitForExistence(app.tables["Context Menu"])
        XCTAssertTrue(app.tables["Context Menu"].cells["download"].exists)
        app.tables["Context Menu"].cells["download"].tap()

        // TODO: update to check this another way
        waitForExistence(app.tables["DownloadsTable"])
        // There should be one item downloaded. It's name and size should be shown
        let downloadedList = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(
            downloadedList, 1, "The number of items in the downloads table is not correct")
        XCTAssertTrue(app.tables.cells.staticTexts["reserved.html"].exists)

        // Tap on the just downloaded link to check that the web page is loaded
        app.tables.cells.staticTexts["reserved.html"].tap()
        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: "reserved.html")

        // TODO: delete the downloaded file
    }

    func testShareLink() {
        longPressLinkOptions(optionSelected: "Share Link")
        waitForExistence(app.buttons["Copy"], timeout: 3)
        XCTAssertTrue(app.buttons["Copy"].exists, "The share menu is not shown")
    }

    func testShareLinkIncognitoMode() {
        waitForExistence(app.buttons["Show Tabs"], timeout: 30)
        setIncognitoMode(enabled: true)

        longPressLinkOptions(optionSelected: "Share Link")
        waitForExistence(app.buttons["Copy"], timeout: 3)
        XCTAssertTrue(app.buttons["Copy"].exists, "The share menu is not shown")
    }

    // Smoketest
    func testPopUpBlocker() throws {
        try skipTest(issue: 1241, "mechanism to read number of tabs does not work")
        // Check that it is enabled by default
        goToSettings()
        let switchBlockPopUps = app.tables.cells.switches["Block Pop-up Windows"]
        let switchValue = switchBlockPopUps.value!
        XCTAssertEqual(switchValue as? String, "1")

        // Check that there are no pop ups
        app.buttons["Done"].tap()
        openURL(popUpTestUrl)
        //waitForValueContains(app.buttons["Address Bar"], value: "blocker.html")
        waitUntilPageLoad()
        waitForExistence(app.webViews.staticTexts["Blocked Element"])

        let numTabs = app.buttons["Show Tabs"].value
        XCTAssertEqual("1", numTabs as? String, "There should be only on tab")

        // Now disable the Block PopUps option
        goToSettings()
        switchBlockPopUps.tap()
        let switchValueAfter = switchBlockPopUps.value!
        XCTAssertEqual(switchValueAfter as? String, "0")

        // Check that now pop ups are shown, two sites loaded
        app.buttons["Done"].tap()
        openURL(popUpTestUrl)
        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: "example.com")
        let numTabsAfter = app.buttons["Show Tabs"].value
        XCTAssertNotEqual("1", numTabsAfter as? String, "Several tabs are open")
    }

    // Smoketest
    func testSSL() {
        openURL("https://expired.badssl.com/")
        waitForExistence(app.buttons["Advanced"], timeout: 30)
        app.buttons["Advanced"].tap()

        waitForExistence(app.buttons["Visit site anyway"])
        app.buttons["Visit site anyway"].tap()
        waitForExistence(app.webViews.otherElements["expired.badssl.com"], timeout: 10)
        XCTAssertTrue(app.webViews.otherElements["expired.badssl.com"].exists)
    }

    // In this test, the parent window opens a child and in the child it creates a fake link 'link-created-by-parent'
    func testWriteToChildPopupTab() throws {
        try skipTest(issue: 1239, "toggling switches does not work")
        goToSettings()
        let switchBlockPopUps = app.tables.cells.switches["Block Pop-up Windows"]
        switchBlockPopUps.tap()
        let switchValueAfter = switchBlockPopUps.value!
        XCTAssertEqual(switchValueAfter as? String, "0")
        app.buttons["Done"].tap()
        waitUntilPageLoad()
        openURL(path(forTestPage: "test-window-opener.html"))
        waitForExistence(app.links["link-created-by-parent"], timeout: 10)
    }

    // Smoketest
    func testVerifyOverflowMenu() {
        let oniPad = UIDevice.current.userInterfaceIdiom == .pad
        if oniPad {
            app.buttons["TopBarOverflowButton"].tap(force: true)
        } else {
            app.buttons["TabOverflowButton"].tap(force: true)
        }
        waitForExistence(app.buttons["Support"])

        if !oniPad {
            XCTAssertTrue(app.buttons["OverflowMenu.Forward"].exists)
            XCTAssertTrue(app.buttons["OverflowMenu.Reload"].exists)
        }
        XCTAssertTrue(app.buttons["OverflowMenu.FindOnPage"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.TextSize"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.RequestDesktopSite"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.DownloadPage"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.Support"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.Settings"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.History"].exists)
        XCTAssertTrue(app.buttons["OverflowMenu.Downloads"].exists)
    }

    // Smoketest
    func testURLBar() throws {
        try skipTest(issue: 1241, "does not pass, need to investigate why")
        let urlBar = app.buttons["Address Bar"]
        waitForExistence(urlBar, timeout: 5)
        urlBar.tap()

        let addressBar = app.textFields["address"]
        XCTAssertTrue(addressBar.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
        XCTAssert(app.keyboards.count > 0, "The keyboard is not shown")
        app.typeText("example.com\n")

        waitUntilPageLoad()
        waitForValueContains(urlBar, value: "example.com/")
        XCTAssertFalse(app.keyboards.count > 0, "The keyboard is shown")
    }

    // Confirms that the share menu shows the right contents when navigating back
    // from a PDF. See https://github.com/neevaco/neeva-ios/issues/634,
    // in which the share menu was incorrectly reporting data about the PDF after
    // navigating back.
    func testShareMenuNavigatingBackFromPDF() {
        openURL(path(forTestPage: "test-pdf.html"))
        waitUntilPageLoad()

        waitForExistence(app.links["nineteen for me"])
        app.links["nineteen for me"].tap(force: true)
        waitUntilPageLoad()

        goToShareSheet()
        waitForExistence(
            app.navigationBars["UIActivityContentView"].otherElements["f1040, PDF Document"],
            timeout: 10)

        // Copy the text to dismiss the overlay sheet
        app.buttons["Copy"].tap()

        waitForExistence(app.buttons["Back"], timeout: 5)
        app.buttons["Back"].tap()
        waitUntilPageLoad()

        // Now confirm that we get a ShareMenu for the current page and not
        // the PDF again.
        goToShareSheet()
        waitForExistence(
            app.navigationBars["UIActivityContentView"].otherElements["localhost"], timeout: 10)
    }

    func testBackNavigationAfterOpeningFromParentTab() {
        openURL()
        waitUntilPageLoad()

        waitForExistence(app.links["More information..."])
        app.links["More information..."].press(forDuration: 1)

        waitForExistence(app.buttons["Open in New Tab"])
        app.buttons["Open in New Tab"].tap()

        waitForExistence(app.buttons["Switch"])
        app.buttons["Switch"].tap()
        waitUntilPageLoad()

        waitForExistence(app.links["IDN Evaluation"])
        app.links["IDN Evaluation"].tap()
        waitUntilPageLoad()

        // Make sure Tab return to the More information page.
        app.buttons["Back"].tap()
        waitForExistence(app.links["IDN Evaluation"])

        // Make sure Tab returns to the parent Tab.
        app.buttons["Back"].tap()
        waitForExistence(app.links["More information..."])

        // Current Tab, and default added Tab.
        XCTAssertEqual(getNumberOfTabs(), 2)
    }
}
