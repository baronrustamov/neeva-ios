// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class StringExtensionsTests: XCTestCase {
    func testIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue(" ".isBlank)
        XCTAssertTrue("\t".isBlank)
        XCTAssertTrue("\n".isBlank)

        XCTAssertFalse("a".isBlank)
    }

    func testIsNotBlank() {
        XCTAssertTrue("a".isNotBlank)

        XCTAssertFalse("".isNotBlank)
        XCTAssertFalse(" ".isNotBlank)
        XCTAssertFalse("\t".isNotBlank)
        XCTAssertFalse("\n".isNotBlank)
    }
}
