// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

@testable import Shared

class MRUCacheTests: XCTestCase {
    func testEviction() {
        let cache = MRUCache<String, Int>(maxEntries: 3)

        cache["a"] = 1
        cache["b"] = 2
        cache["c"] = 3
        cache["d"] = 4

        XCTAssertEqual(cache.count, 3)
        XCTAssertNil(cache["a"])
        XCTAssertEqual(cache["b"], 2)
        XCTAssertEqual(cache["c"], 3)
        XCTAssertEqual(cache["d"], 4)
    }

    func testPromotion() {
        let cache = MRUCache<String, Int>(maxEntries: 3)

        cache["a"] = 1
        cache["b"] = 2
        cache["c"] = 3

        // Fetch "a" to promote it, and we should observe that it does not get evicted.
        let _ = cache["a"]

        cache["d"] = 4

        XCTAssertEqual(cache.count, 3)
        XCTAssertNil(cache["b"])
        XCTAssertEqual(cache["a"], 1)
        XCTAssertEqual(cache["c"], 3)
        XCTAssertEqual(cache["d"], 4)
    }

    func testCacheOfOne() {
        let cache = MRUCache<String, Int>(maxEntries: 1)

        cache["a"] = 1
        cache["b"] = 2
        cache["c"] = 3

        XCTAssertEqual(cache.count, 1)
        XCTAssertNil(cache["a"])
        XCTAssertNil(cache["b"])
        XCTAssertEqual(cache["c"], 3)
    }

    func testReplaceAll() {
        let cache = MRUCache<String, Int>(maxEntries: 3)

        cache["a"] = 1
        cache["b"] = 2
        cache["c"] = 3
        cache["d"] = 4
        cache["e"] = 5
        cache["f"] = 6

        XCTAssertEqual(cache.count, 3)
        XCTAssertNil(cache["a"])
        XCTAssertNil(cache["b"])
        XCTAssertNil(cache["c"])
        XCTAssertEqual(cache["d"], 4)
        XCTAssertEqual(cache["e"], 5)
        XCTAssertEqual(cache["f"], 6)
    }

    func testRemoval() {
        let cache = MRUCache<String, Int>(maxEntries: 3)

        cache["a"] = 1

        XCTAssertEqual(cache.count, 1)
        XCTAssertEqual(cache["a"], 1)

        cache["a"] = nil

        XCTAssertEqual(cache.count, 0)
        XCTAssertNil(cache["a"])
    }

    func testRemovalThenEviction() {
        let cache = MRUCache<String, Int>(maxEntries: 3)

        cache["a"] = 1
        cache["a"] = nil

        cache["b"] = 2
        cache["c"] = 3
        cache["d"] = 4
        cache["e"] = 5

        XCTAssertEqual(cache.count, 3)
        XCTAssertNil(cache["a"])
        XCTAssertNil(cache["b"])
        XCTAssertEqual(cache["c"], 3)
        XCTAssertEqual(cache["d"], 4)
        XCTAssertEqual(cache["e"], 5)
    }
}
