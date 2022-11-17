// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import AppClip

class AppClipTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveRetrieveData() throws {
        let testValue = "testing"

        AppClipHelper.saveTokenToDevice(testValue)
        XCTAssertEqual(AppClipHelper.retrieveAppClipData(), testValue)
    }
}
