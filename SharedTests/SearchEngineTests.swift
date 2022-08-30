// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import Shared

class SearchEngineTests: XCTestCase {
    func testSearchURLFrom() throws {
        let searchEngine = SearchEngine(
            id: "_neeva",
            label: "Neeva",
            icon: nil,
            suggestTemplate: nil,
            searchTemplate: "",
            isNeeva: true
        )

        // Simplest case
        XCTAssertEqual(
            searchEngine.searchURLFrom(searchQuery: "abc", queryItems: []),
            URL(string: "https://\(NeevaConstants.appHost)/search?q=abc&src=nvobar"))

        // Make sure plus signs in the query are encoded
        XCTAssertEqual(
            searchEngine.searchURLFrom(searchQuery: "c++", queryItems: []),
            URL(string: "https://\(NeevaConstants.appHost)/search?q=c%2B%2B&src=nvobar"))

        // Make sure query params are not duplicated
        XCTAssertEqual(
            searchEngine.searchURLFrom(
                searchQuery: "c++", queryItems: [URLQueryItem(name: "src", value: "nvobar")]),
            URL(string: "https://\(NeevaConstants.appHost)/search?q=c%2B%2B&src=nvobar"))

        // Make sure additional query params are added
        XCTAssertEqual(
            searchEngine.searchURLFrom(
                searchQuery: "c++", queryItems: [URLQueryItem(name: "abc", value: "def")]),
            URL(string: "https://\(NeevaConstants.appHost)/search?q=c%2B%2B&src=nvobar&abc=def"))
    }
}
