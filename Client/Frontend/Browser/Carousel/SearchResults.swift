// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared

class SearchResultsController: QueryController<SearchResultsQuery, [URL]> {
    override class func processData(_ data: SearchResultsQuery.Data) -> [URL] {
        var results = [URL]()
        for group in data.search?.resultGroup ?? [] {
            for result in group?.result ?? [] {
                if let url = result?.actionUrl, !url.isEmpty {
                    results.append(URL(string: url)!)
                }
            }
        }
        return results
    }

    @discardableResult static func getSearchResults(
        for query: String,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) -> Cancellable {
        Self.perform(query: SearchResultsQuery(query: query), completion: completion)
    }
}
