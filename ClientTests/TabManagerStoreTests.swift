/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import GCDWebServers
import Shared
import Storage
import UIKit
import WebKit
import XCTest

@testable import Client

class TabManagerStoreTests: XCTestCase {
    let profile = TabManagerMockProfile()
    var manager: TabManager!
    let configuration = WKWebViewConfiguration()
    let webServer: GCDWebServer = GCDWebServer()
    var webServerBase: String!

    override func setUp() {
        super.setUp()
        setupWebServer()

        manager = TabManager(profile: profile, imageStore: nil)
        configuration.processPool = WKProcessPool()

        if UIDevice.current.useTabletInterface {
            // BVC.viewWillAppear() calls restoreTabs() which interferes with these tests. (On iPhone, ClientTests never dismiss the intro screen, on iPad the intro is a popover on the BVC).
            // Wait for this to happen (UIView.window only gets assigned after viewWillAppear()), then begin testing.
            let predicate = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "view.window != nil"),
                object: SceneDelegate.getBVC(for: nil))
            wait(for: [predicate], timeout: 20)
        }

        manager.testClearArchive()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Setup a basic web server that binds to a random port and that has one default handler on /hello
    fileprivate func setupWebServer() {
        webServer.addHandler(forMethod: "GET", path: "/hello", request: GCDWebServerRequest.self) {
            (request) -> GCDWebServerResponse in
            return GCDWebServerDataResponse(html: "<html><body><p>Hello World</p></body></html>")!
        }
        if webServer.start(withPort: 0, bonjourName: nil) == false {
            XCTFail("Can't start the GCDWebServer")
        }
        webServerBase = "http://localhost:\(webServer.port)"
    }

    // Without session data, a Tab can't become a SavedTab and get archived
    @discardableResult
    func addTabWithSessionData(isIncognito: Bool = false) -> Tab {
        return addTabWithSessionData(isIncognito: isIncognito) { tab in
            manager.configureTab(
                tab,
                request: URLRequest(url: tab.url!),
                flushToDisk: false,
                zombie: false,
                notify: true
            )
        }
    }

    @discardableResult
    func addTabWithSessionData(
        isIncognito: Bool = false,
        configureTab: (Tab) -> Void
    ) -> Tab {
        let tab = Tab(
            bvc: SceneDelegate.getBVC(for: nil), configuration: configuration,
            isIncognito: isIncognito)
        tab.setURL(URL(string: "\(webServerBase!)/hello"))
        configureTab(tab)
        tab.sessionData = SessionData(
            currentPage: 0, urls: [tab.url!],
            queries: [nil], suggestedQueries: [nil], queryLocations: [nil],
            lastUsedTime: Date.nowMilliseconds()
        )
        return tab
    }

    func testNoData() {
        manager.testClearArchive()
        XCTAssertEqual(manager.testTabCountOnDisk(), 0, "Expected 0 tabs on disk")
        XCTAssertEqual(manager.testCountRestoredTabs(), 0)
    }

    func testIncognitoTabsAreArchived() {
        for _ in 0..<2 {
            addTabWithSessionData(isIncognito: true)
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 2
        }
    }

    func testAddedTabsAreStored() {
        // Add 2 tabs
        for _ in 0..<2 {
            addTabWithSessionData()
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 2
        }

        // Add 2 more
        for _ in 0..<2 {
            addTabWithSessionData()
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 4
        }

        // Remove all tabs, and add just 1 tab
        manager.removeAllTabs()
        addTabWithSessionData()
        waitForCondition {
            self.manager.testTabCountOnDisk() == 1
        }
    }

    func testParentRefsAreRestored() throws {
        // create and save two tabs
        let tab1 = addTabWithSessionData()
        let tab2 = addTabWithSessionData {
            manager.configureTab(
                $0, request: URLRequest(url: $0.url!),
                afterTab: tab1,
                flushToDisk: false, zombie: false, notify: true
            )
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 2
        }

        // verify parent tab relationship
        XCTAssertEqual(tab1, tab2.parent)

        let newManager = TabManager(profile: profile, imageStore: nil)
        XCTAssertEqual(newManager.activeTabs.count, 0)

        // restore tabs
        newManager.testRestoreTabs()
        XCTAssertEqual(newManager.activeTabs.count, 2)

        // verify parent is restored
        let childTab = try XCTUnwrap(newManager.activeTabs.first { $0.parent != nil })
        let parentTab = try XCTUnwrap(childTab.parent)
        XCTAssertTrue(newManager.activeTabs.contains(parentTab))
    }
}
