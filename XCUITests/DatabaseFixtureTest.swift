/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class DatabaseFixtureTest: BaseTestCase {
    let fixtures = [
        "testHistoryDatabaseFixture": "testHistoryDatabase4000-browser.db",
        "testHistoryDatabasePerformance": "testHistoryDatabase4000-browser.db",
        "testPerfHistory4000startUp": "testHistoryDatabase4000-browser.db",
        "testPerfHistory4000openMenu": "testHistoryDatabase4000-browser.db",
    ]

    override func setUp() {
        // for the current test name, add the db fixture used
        launchArguments = [
            LaunchArguments.SkipIntro, LaunchArguments.SkipWhatsNew,
            LaunchArguments.SkipETPCoverSheet,
            LaunchArguments.LoadDatabasePrefix + fixtures[testName]!,
        ]
        super.setUp()
    }

    func testPerfHistory4000startUp() {
        measure(metrics: [
            XCTMemoryMetric(),
            XCTClockMetric(),  // to measure timeClock Mon
            XCTCPUMetric(),  // to measure cpu cycles
            XCTStorageMetric(),  // to measure storage consuming
            XCTMemoryMetric(),
        ]) {
            // activity measurement here
            app.launch()
        }
    }

    func testPerfHistory4000openMenu() {
        measure(metrics: [
            XCTMemoryMetric(),
            XCTClockMetric(),  // to measure timeClock Mon
            XCTCPUMetric(),  // to measure cpu cycles
            XCTStorageMetric(),  // to measure storage consuming
            XCTMemoryMetric(),
        ]) {
        }
    }
}
