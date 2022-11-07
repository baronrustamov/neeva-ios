/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

/* disabled since tab reordering is not implemented for the SwiftUI tab switcher
private let firstWebsite = (
    url: path(forTestPage: "test-mozilla-org.html"),
    tabName: "Internet for people, not profit — Mozilla"
)
private let secondWebsite = (
    url: path(forTestPage: "test-mozilla-book.html"), tabName: "The Book of Mozilla"
)
private let exampleWebsite = (
    url: path(forTestPage: "test-example.html"), tabName: "Example Domain"
)
private let homeTabName = "Home"
private let websiteWithSearchField = "https://developer.mozilla.org/en-US/"

private let exampleDomainTitle = "Example Domain"
private let twitterTitle = "Twitter"

extension BaseTestCase {
    fileprivate func dragAndDrop(dragElement: XCUIElement, dropOnElement: XCUIElement) {
        dragElement.press(forDuration: 1, thenDragTo: dropOnElement)
    }

    fileprivate func checkTabsOrder(dragAndDropTab: Bool, firstTab: String, secondTab: String) {
        let firstTabCell = app.collectionViews.cells.element(boundBy: 0).label
        let secondTabCell = app.collectionViews.cells.element(boundBy: 1).label

        if dragAndDropTab {
            sleep(1)
            XCTAssertEqual(firstTabCell, firstTab, "first tab after is not correct")
            XCTAssertEqual(secondTabCell, secondTab, "second tab after is not correct")
        } else {
            XCTAssertEqual(firstTabCell, firstTab, "first tab before is not correct")
            XCTAssertEqual(secondTabCell, secondTab, "second tab before is not correct")
        }
    }
}

class DragAndDropTestiPad: IpadOnlyTestCase {
    let testWithDB = [
        "testTryDragAndDropHistoryToURLBar", "testTryDragAndDropBookmarkToURLBar",
        "testDragAndDropBookmarkEntry", "testDragAndDropHistoryEntry",
    ]

    // This DDBB contains those 4 websites listed in the name
    let historyAndBookmarksDB = "browserYoutubeTwitterMozillaExample.db"

    override func setUp() {
        if testWithDB.contains(testName) {
            // for the current test name, add the db fixture used
            launchArguments = [
                LaunchArguments.SkipIntro,
                LaunchArguments.SkipETPCoverSheet,
                LaunchArguments.LoadDatabasePrefix + historyAndBookmarksDB,
            ]
        }
        super.setUp()
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        super.tearDown()
    }

    func testRearrangeTabs() {
        if skipPlatform { return }

        openTwoWebsites()
        app.buttons["Show Tabs"].tap()

        checkTabsOrder(
            dragAndDropTab: false, firstTab: firstWebsite.tabName, secondTab: secondWebsite.tabName)

        // Drag first tab on the second one
        dragAndDrop(
            dragElement: app.collectionViews.cells[firstWebsite.tabName],
            dropOnElement: app.collectionViews.cells[secondWebsite.tabName])
        checkTabsOrder(
            dragAndDropTab: true, firstTab: secondWebsite.tabName, secondTab: firstWebsite.tabName)
    }

    func testRearrangeTabsLandscape() {
        if skipPlatform { return }

        // Set the device in landscape mode
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        openTwoWebsites()
        app.buttons["Show Tabs"].tap()

        checkTabsOrder(
            dragAndDropTab: false, firstTab: firstWebsite.tabName, secondTab: secondWebsite.tabName)

        // Rearrange the tabs via drag home tab and drop it on twitter tab
        dragAndDrop(
            dragElement: app.collectionViews.cells[firstWebsite.tabName],
            dropOnElement: app.collectionViews.cells[secondWebsite.tabName])
        checkTabsOrder(
            dragAndDropTab: true, firstTab: secondWebsite.tabName, secondTab: firstWebsite.tabName)
    }

    func testDragAndDropHomeTab() {
        if skipPlatform { return }

        // Home tab is open and then a new website
        openTwoWebsites()
        app.buttons["Show Tabs"].tap()
        checkTabsOrder(
            dragAndDropTab: false, firstTab: firstWebsite.tabName, secondTab: secondWebsite.tabName)
        waitForExistence(app.collectionViews.cells.element(boundBy: 1))

        // Drag and drop home tab from the second position to the first one
        dragAndDrop(
            dragElement: app.collectionViews.cells[firstWebsite.tabName],
            dropOnElement: app.collectionViews.cells[secondWebsite.tabName])
        checkTabsOrder(
            dragAndDropTab: true, firstTab: secondWebsite.tabName, secondTab: firstWebsite.tabName)
    }

    func testRearrangeTabsPrivateMode() {
        if skipPlatform { return }

        toggleIncognito()
        openTwoWebsites()
        app.buttons["Show Tabs"].tap()

        checkTabsOrder(
            dragAndDropTab: false, firstTab: firstWebsite.tabName, secondTab: secondWebsite.tabName)
        // Drag first tab on the second one
        dragAndDrop(
            dragElement: app.collectionViews.cells[firstWebsite.tabName],
            dropOnElement: app.collectionViews.cells[secondWebsite.tabName])

        checkTabsOrder(
            dragAndDropTab: true, firstTab: secondWebsite.tabName, secondTab: firstWebsite.tabName)
    }
}
*/
