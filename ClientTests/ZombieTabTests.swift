// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

@testable import Client

class ZombieTabTests: XCTestCase {
    var manager: TabManager!

    override func setUp() {
        super.setUp()

        let profile = TabManagerMockProfile()
        manager = TabManager(profile: profile, imageStore: nil)
    }

    func testZombieTabRestoredProperly() {
        let url = URL(string: "https://example.com")!

        // Create a ZombieTab and close it.
        let tab = manager.addTabsForURLs([url])[0]
        manager.close(tab)

        // Restore the tab.
        let savedTab = manager.recentlyClosedTabsFlattened[0]
        manager.restoreSavedTabs([savedTab])

        // Check that the restored tab has the correct data.
        let restoredTab = manager.tabs[0]
        XCTAssertEqual(url, restoredTab.url)
    }
}
