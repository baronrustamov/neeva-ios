// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import Shared

class SearchEngineTests: XCTestCase {
    func testUpdateSearchQuery() throws {
        let searchEngine = SearchEngine(
            id: "_neeva",
            label: "Neeva",
            icon: nil,
            suggestTemplate: nil,
            searchTemplate: "",
            isNeeva: true
        )

        let originalQuery = searchEngine.searchURLForQuery("c++")!
        XCTAssertEqual(
            originalQuery.absoluteString,
            searchEngine.updateSearchQuery(originalQuery, newQuery: "c++").absoluteString)
    }
}
