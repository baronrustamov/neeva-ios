// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

@testable import Client

class SessionDataTests: XCTestCase {
    func testEncodeDecode() {
        let testUrls = [
            "https://neeva.com/",
            "https://news.ycombinator.com/",
            "https://www.wikipedia.org/",
        ].map({ URL(string: $0)! })

        let input = SessionData(
            currentPage: -1,
            navigationStackIndex: 0,
            urls: testUrls,
            queries: testUrls.map { _ in return nil },
            suggestedQueries: Array.init(repeating: nil, count: testUrls.count),
            queryLocations: Array(repeating: nil, count: testUrls.count),
            lastUsedTime: Date.nowMilliseconds())

        let data = try! NSKeyedArchiver.archivedData(
            withRootObject: input, requiringSecureCoding: false)

        let output = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! SessionData

        XCTAssertEqual(input.currentPage, output.currentPage)
        XCTAssertEqual(input.urls, output.urls)
        XCTAssertEqual(input.lastUsedTime, output.lastUsedTime)
    }
}
