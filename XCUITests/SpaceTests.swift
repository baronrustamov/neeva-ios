// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class SpaceTests: BaseTestCase {
    override func setUp() {
        launchArguments = [
            LaunchArguments.SkipIntro,
            LaunchArguments.EnableMockSpaces,
        ]

        super.setUp()
    }

    func testSpacesVisibleFromAddToSpaceSheet() {
        openURL("example.com")
        app.buttons["Add To Space"].tap()
        XCTAssertTrue(app.staticTexts["My Space"].exists)
    }
}
