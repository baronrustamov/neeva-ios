/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

@testable import Client

class TPStatsBlocklistsTests: XCTestCase {
    var blocklists: TPStatsBlocklists!

    override func setUp() {
        super.setUp()

        blocklists = TPStatsBlocklists()
    }

    override func tearDown() {
        super.tearDown()
        blocklists = nil
    }

    func testLoadPerformance() {
        self.measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
            blocklists.load()
            self.stopMeasuring()
        }
    }

    func testURLInListPerformance() {
        blocklists.load()

        let safelistedRegexs = ["*google.com"].compactMap { (domain) -> String? in
            return wildcardContentBlockerDomainToRegex(domain: domain)
        }

        self.measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
            for _ in 0..<100 {
                _ = blocklists.findBlockedRuleInList(
                    URL(string: "https://www.neeva.com")!,
                    mainDocumentURL: URL(string: "http://foo.com")!,
                    safelistedDomains: safelistedRegexs)
            }
            self.stopMeasuring()
        }
    }

    func testURLInList() {
        blocklists.load()

        ContentBlocker.shared.setupCompleted = true

        func blocklist(
            _ urlString: String, _ mainDoc: String = "https://foo.com",
            _ safelistedDomains: [String] = []
        ) -> Bool {
            let safelistedRegexs = safelistedDomains.compactMap { (domain) -> String? in
                return wildcardContentBlockerDomainToRegex(domain: domain)
            }
            let mainDoc = URL(string: mainDoc)!
            return blocklists.findBlockedRuleInList(
                URL(string: urlString)!, mainDocumentURL: mainDoc,
                safelistedDomains: safelistedRegexs) != nil
        }
        XCTAssertEqual(blocklist("https://www.facebook.com", "https://atlassolutions.com"), false)
        XCTAssertEqual(blocklist("https://www.neeva.com"), false)
        XCTAssertEqual(blocklist("https://cadreon.com/track"), true)
        XCTAssertEqual(blocklist("https://cadreon.com.au"), false)
        XCTAssertEqual(blocklist("https://datafeedfile.com/popup"), true)
        XCTAssertEqual(blocklist("https://datafront.co/track"), true)
        XCTAssertEqual(blocklist("https://data.front.com/track"), false)
        XCTAssertEqual(
            blocklist("https://aol.com.aolanswers.com", "https://foo.com", ["ers.com"]), false)
        XCTAssertEqual(blocklist("https://sub.xiti.com/track"), true)
    }
}
