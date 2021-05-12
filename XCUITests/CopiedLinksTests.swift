/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class CopiedLinksTests: BaseTestCase {
    // This test is enable Offer to open copied links, when opening neeva
    func testCopiedLinks() {
        navigator.goto(SettingsScreen)

        //Check Offer to open copied links, when opening neeva is off
        let value = app.tables.cells.switches["Offer to Open Copied Links, When Opening Neeva"].value
        XCTAssertEqual(value as? String, "0")

        //Switch on, Offer to open copied links, when opening neeva
        app.tables.cells.switches["Offer to Open Copied Links, When Opening Neeva"].tap()

        //Check Offer to open copied links, when opening neeva is on
        let value2 = app.tables.cells.switches["Offer to Open Copied Links, When Opening Neeva"].value
        XCTAssertEqual(value2 as? String, "1")

        app.navigationBars["Settings"]/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".buttons[\"Done\"]",".buttons[\"AppSettingsTableViewController.navigationItem.leftBarButtonItem\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()

        app.buttons["TabToolbar.neevaMenuButton"].tap()
        let settingsmenuitemCell = app.buttons["NeevaMenu.Settings"]
        settingsmenuitemCell.tap()

        //Check Offer to open copied links, when opening neeva is on
        let value3 = app.tables.cells.switches["Offer to Open Copied Links, When Opening Neeva"].value
        XCTAssertEqual(value3 as? String, "1")
    }
}
