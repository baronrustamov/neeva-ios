// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class PerfomanceTests: BaseTestCase {
    func testCardGridPerformance() {
        createFiveHundredTabs()

        // Open and close CardGrid
        measure(metrics: [XCTCPUMetric(application: app)]) {
            goToTabTray()
            app.buttons["Done"].tap()
        }
    }

    func testCloseAllTabsPerformance() {
        createFiveHundredTabs()
        goToTabTray()

        measure(metrics: [XCTCPUMetric()]) {
            startMeasuring()
            closeAllTabs(fromTabSwitcher: true, createNewTab: false)
            stopMeasuring()

            createFiveHundredTabs()
        }
    }
}
