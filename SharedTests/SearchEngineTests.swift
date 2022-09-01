// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import Shared

class SearchEngineTests: XCTestCase {
    func testUpdateSearchQuery() throws {
        let originalQuery = SearchEngine.neeva.searchURLForQuery("c++")!
        XCTAssertEqual(
            originalQuery.absoluteString,
            SearchEngine.neeva.updateSearchQuery(originalQuery, newQuery: "c++").absoluteString)
    }
}
