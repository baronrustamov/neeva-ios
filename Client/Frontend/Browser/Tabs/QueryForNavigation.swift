// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import WebKit

class QueryForNavigation {
    struct Query {
        /// Location from which a navigation was created for opening a result for this query
        enum Location: Int, Codable {
            /// Result was opened from the suggestion UI for this query
            case suggestion
            /// Result was opened from the SRP for this query
            case SRP
        }
        let typed: String
        let suggested: String?
        var location: Location
    }

    var queryForNavigations = [WKBackForwardListItem: Query]()
    var currentQuery: Query?

    func findQueryIndexFor(navigation: WKBackForwardListItem) -> Int? {
        return Array(queryForNavigations.keys).firstIndex { $0 == navigation }
    }

    func findQueryFor(navigation: WKBackForwardListItem) -> Query? {
        return queryForNavigations[navigation]
    }

    func findQueryForNavigation(with url: URL) -> Query? {
        return queryForNavigations.first { key, value in
            key.url == url
        }?.value
    }

    /// Recommended to call this only via `Tab.attachCurrentSearchQueryToCurrentNavigation`.
    func attachCurrentSearchQueryToCurrentNavigation(webView: WKWebView) {
        // attach current suggested query?
        guard let navigation = webView.backForwardList.currentItem else { return }

        // If opening in current tab from SRP
        if currentQuery == nil,
            let backItem = webView.backForwardList.backItem,
            NeevaConstants.isNeevaSearchResultPage(backItem.url),
            let query = self.findQueryFor(navigation: backItem)
        {
            currentQuery = query
            currentQuery?.location = .SRP
        }

        if let query = currentQuery, !query.typed.isEmpty {
            queryForNavigations[navigation] = query
            currentQuery = nil

            let backForwardList = webView.backForwardList.all
            queryForNavigations = queryForNavigations.filter {
                backForwardList.contains($0.key)
            }
        }
    }
}
