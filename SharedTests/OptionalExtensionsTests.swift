// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class OptionalExtensionsTests: XCTestCase {
    func testIsBlank() {
        XCTAssertTrue(Optional.none.isBlank)
        XCTAssertTrue(Optional.some("").isBlank)
        XCTAssertTrue(Optional.some(" ").isBlank)
        XCTAssertTrue(Optional.some("\t").isBlank)
        XCTAssertTrue(Optional.some("\n").isBlank)

        XCTAssertFalse(Optional.some("a").isBlank)
    }

    func testIsNotBlank() {
        XCTAssertTrue(Optional.some("a").isNotBlank)

        XCTAssertFalse(Optional.none.isNotBlank)
        XCTAssertFalse(Optional.some("").isNotBlank)
        XCTAssertFalse(Optional.some(" ").isNotBlank)
        XCTAssertFalse(Optional.some("\t").isNotBlank)
        XCTAssertFalse(Optional.some("\n").isNotBlank)
    }
}
