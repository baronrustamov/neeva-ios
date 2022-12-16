// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class ZeroQueryTests: BaseTestCase {
    func testPromoCardDisplayRules() {
        for impression in 1...10 {
            // setup
            goToAddressBar()
            waitForExistence(app.staticTexts["Searches"])

            // does not show promos until the 4th impression
            if impression < 4 {
                waitForNoExistence(app.staticTexts["promoCardContainer"])
            }
            if impression == 4 {
                waitForExistence(app.staticTexts["promoCardContainer"])
            }

            // shows premium promo until the 10th impression
            if impression >= 4 && impression < 10 {
                waitForExistence(app.buttons["Try it Free"])
            }
            if impression == 10 {
                waitForExistence(app.buttons["Set as Default Browser"])
            }

            // tear down
            app.buttons["Cancel"].tap()
            waitForNoExistence(app.buttons["Searches"])
        }
    }
}
