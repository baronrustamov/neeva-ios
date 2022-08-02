/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import WebKit

protocol SessionRestoreHelperDelegate: AnyObject {
    func sessionRestoreHelper(didRestoreSessionForTab tab: Tab)
}

class SessionRestoreHelper: TabContentScript {
    weak var delegate: SessionRestoreHelperDelegate?
    fileprivate weak var tab: Tab?

    required init(tab: Tab) {
        self.tab = tab
    }

    func scriptMessageHandlerName() -> String? {
        return "sessionRestoreHelper"
    }

    func userContentController(didReceiveScriptMessage message: WKScriptMessage) {
        if let tab = tab, let params = message.body as? [String: AnyObject] {
            if params["name"] as! String == "didRestoreSession" {
                DispatchQueue.main.async {
                    self.delegate?.sessionRestoreHelper(didRestoreSessionForTab: tab)

                    if let navigationList = tab.webView?.backForwardList.all {
                        for (index, item) in navigationList.enumerated() {
                            guard let sessionData = tab.sessionData,
                                sessionData.typedQueries.indices.contains(index),
                                let query = sessionData.typedQueries[index]
                            else { break }

                            var suggestedQuery: String? = nil
                            var queryLocation: QueryForNavigation.Query.Location? = nil
                            if sessionData.suggestedQueries.indices.contains(index) {
                                suggestedQuery = sessionData.suggestedQueries[index]
                            }
                            if sessionData.queryLocations.indices.contains(index),
                                let rawValue = sessionData.queryLocations[index]
                            {
                                queryLocation = .init(rawValue: rawValue)
                            }
                            tab.queryForNavigation.queryForNavigations[item] = .init(
                                typed: query,
                                suggested: suggestedQuery,
                                location: queryLocation ?? .suggestion
                            )
                        }
                    }

                    tab.sessionData = nil
                }
            }
        }
    }

    class func name() -> String {
        return "SessionRestoreHelper"
    }
}
