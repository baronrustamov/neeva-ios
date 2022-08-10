// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class PinnedTabTests: BaseTestCase {
    override func setUp() {
        launchArguments.append("\(LaunchArguments.EnableFeatureFlags)pinnedTabImprovments")
    }
    
    func testPlaceholderTabCreatedAndBackNavigation() {
        
    }
    
    func testMultipleChildTabs() {
        
    }
    
    func testComplicatedNavigationStack() {
        
    }
}
