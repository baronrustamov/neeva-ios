/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

protocol FindInPageHelperDelegate: AnyObject {
    func findInPageHelper(didUpdateCurrentResult currentResult: Int)
    func findInPageHelper(didUpdateTotalResults totalResults: Int)
}

class FindInPageHelper: TabContentScript {
    weak var delegate: FindInPageHelperDelegate?
    fileprivate weak var tab: Tab?

    class func name() -> String {
        return "FindInPage"
    }

    required init(tab: Tab) {
        self.tab = tab
    }

    func scriptMessageHandlerName() -> String? {
        return "findInPageHandler"
    }

    func userContentController(didReceiveScriptMessage message: WKScriptMessage) {
        let data = message.body as! [String: Int]

        if let currentResult = data["currentResult"] {
            delegate?.findInPageHelper(didUpdateCurrentResult: currentResult)
        }

        if let totalResults = data["totalResults"] {
            delegate?.findInPageHelper(didUpdateTotalResults: totalResults)
        }
    }

    func connectedTabChanged(_ tab: Tab) {
        self.tab = tab
    }
}
