/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import GCDWebServers
import Shared
import WebKit
import XCTest

@testable import Client

class TabEventHandlerTests: XCTestCase {

    func testEventDelivery() {
        let tab = Tab(
            bvc: SceneDelegate.getBVC(for: nil), configuration: WKWebViewConfiguration())
        let handler = DummyHandler()

        XCTAssertNil(handler.isFocused)

        TabEvent.post(.didGainFocus, for: tab)
        XCTAssertTrue(handler.isFocused!)

        TabEvent.post(.didLoseFocus, for: tab)
        XCTAssertFalse(handler.isFocused!)
    }

    func testBlankPopupURL() {
        // Hide intro so it is easier to see the test running and debug it
        Defaults[.introSeen] = true

        let webServer = GCDWebServer()
        webServer.addHandler(
            forMethod: "GET", path: "/blankpopup", request: GCDWebServerRequest.self
        ) { (request) -> GCDWebServerResponse in
            let page = """
                    <html>
                    <body onload="window.open('')">open about:blank popup</body>
                    </html>
                """
            return GCDWebServerDataResponse(html: page)!
        }

        if !webServer.start(withPort: 0, bonjourName: nil) {
            XCTFail("Can't start the GCDWebServer")
        }
        let webServerBase = "http://localhost:\(webServer.port)"

        let tabManager = SceneDelegate.getTabManagerOrNil()!

        Defaults[.blockPopups] = false
        tabManager.addTab(
            URLRequest(url: URL(string: "\(webServerBase)/blankpopup")!))

        let exists = NSPredicate { obj, _ in
            let tabManager = obj as! TabManager
            return tabManager.activeTabs.count > 2
        }

        expectation(for: exists, evaluatedWith: tabManager) {
            let url = SceneDelegate.getTabManagerOrNil()!.activeTabs[2].url
            XCTAssertTrue(url?.absoluteString == "about:blank")
            return true
        }

        waitForExpectations(timeout: 20, handler: nil)
    }
}

class DummyHandler: TabEventHandler {
    // This is not how this should be written in production — the handler shouldn't be keeping track
    // of individual tab state.
    var isFocused: Bool? = nil

    init() {
        register(self, forTabEvents: .didGainFocus, .didLoseFocus)
    }

    func tabDidGainFocus(_ tab: Tab) {
        isFocused = true
    }

    func tabDidLoseFocus(_ tab: Tab) {
        isFocused = false
    }
}
