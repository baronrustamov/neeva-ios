// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class EditURLTests: BaseTestCase {
    func testEditURLShows() {
        openURL()
        goToAddressBar()
        assert(app.buttons["Edit current address"].exists == true)
    }

    func testTapEditURLShowsInAddressBar() {
        openURL()
        goToAddressBar()
        app.buttons["Edit current address"].tap()
        XCTAssertEqual(
            app.textFields["address"].value as! String, "http://example.com/")
    }

    func testTapEditURLShowsCorrectURLInAddressBar() {
        openURL()
        openURL("fakeurl.madeup")
        goToAddressBar()
        app.buttons["Edit current address"].tap()
        sleep(1)
        XCTAssertEqual(app.textFields["address"].value as! String, "http://fakeurl.madeup/")
    }

    // Prevents regression of:
    // Editing search for "c++" results in dropping the "++" part and just searching for "c" #4216
    func testEditQueryIsProperlyEncoded() {
        performSearch(text: "c++")

        waitForExistence(app.buttons["Address Bar"])
        app.buttons["Address Bar"].tap()
        waitForExistence(app.buttons["Edit current search"])
        app.buttons["Edit current search"].tap()

        // Resubmit the search
        app.typeText("\r")
        waitUntilPageLoad()

        // It would be better to directly check the URL, but there is no easy way to do that.
        XCTAssertEqual(app.staticTexts["locationLabelSiteSecure"].label, "c++")
    }
}
