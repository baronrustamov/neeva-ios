/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

/// PR: https://github.com/mozilla-mobile/firefox-ios/pull/4387
/// Commit: https://github.com/mozilla-mobile/firefox-ios/commit/8b1450fbeb87f1f559a2f8e42971c715dc96bcaf
/// InternalURL helps  encapsulate all internal scheme logic for urls rather than using URL extension. Extensions to built-in classes should be more minimal that what was being done previously.
/// This migration was required mainly for above PR which is related to a PI request that reduces security risk. Also, this particular method helps in cleaning up / migrating old localhost:6571 URLs to internal: SessionData urls
private func migrate(urls: [URL]) -> [URL] {
    return urls.map { url in
        var url = url
        let port = AppInfo.webserverPort
        [
            (
                "http://localhost:\(port)/errors/error.html?url=",
                "\(InternalURL.baseUrl)/\(SessionRestoreHandler.path)?url="
            )
            // TODO: handle reader pages ("http://localhost:6571/reader-mode/page?url=", "\(InternalScheme.url)/\(ReaderModeHandler.path)?url=")
        ].forEach {
            oldItem, newItem in
            if url.absoluteString.hasPrefix(oldItem) {
                var urlStr = url.absoluteString.replacingOccurrences(of: oldItem, with: newItem)
                let comp = urlStr.components(separatedBy: newItem)
                if comp.count > 2 {
                    // get the last instance of incorrectly nested urls
                    urlStr = newItem + (comp.last ?? "")
                    assertionFailure(
                        "SessionData urls have nested internal links, investigate: [\(url.absoluteString)]"
                    )
                }
                url = URL(string: urlStr) ?? url
            }
        }

        if let internalUrl = InternalURL(url), internalUrl.isAuthorized,
            let stripped = internalUrl.stripAuthorization
        {
            return stripped
        }

        return url
    }
}

class SessionData: NSObject, NSCoding {
    let currentPage: Int
    let urls: [URL]

    /// For each URL there is a corresponding query or nil.
    /// If a query is nil, there is not a query for that specific navigation.
    let typedQueries: [String?]
    let suggestedQueries: [String?]
    let queryLocations: [QueryForNavigation.Query.Location.RawValue?]
    let lastUsedTime: Timestamp

    var currentUrl: URL? {
        // TODO: We should probably unwrap this if it is a session restore internal URL.
        let index = urls.count - 1 + currentPage
        return 0..<urls.count ~= index ? urls[index] : nil
    }

    var initialUrl: URL? {
        let url = urls.first
        if let nestedUrl = InternalURL.unwrapSessionRestore(url: url) {
            return nestedUrl
        }
        return url
    }

    /// Creates a new SessionData object representing a serialized tab.
    ///
    /// - Parameters:
    ///   - currentPage: The active page index. Must be in the range of (-N, 0],
    ///                  where 1-N is the first page in history, and 0 is the last.
    ///   - urls: The sequence of URLs in this tab's session history.
    ///   - lastUsedTime: The last time this tab was modified.
    init(
        currentPage: Int, urls: [URL],
        queries: [String?], suggestedQueries: [String?],
        queryLocations: [QueryForNavigation.Query.Location?],
        lastUsedTime: Timestamp
    ) {
        self.currentPage = currentPage
        self.urls = migrate(urls: urls)
        self.typedQueries = queries
        self.suggestedQueries = suggestedQueries
        self.queryLocations = queryLocations.map { $0?.rawValue }
        self.lastUsedTime = lastUsedTime

        assert(urls.count > 0, "Session has at least one entry")
        assert(currentPage > -urls.count && currentPage <= 0, "Session index is valid")
        assert(urls.count == queries.count, "The number of queries should match the number of URLs")
    }

    required init?(coder: NSCoder) {
        self.currentPage = coder.decodeInteger(forKey: "currentPage")
        self.urls = migrate(urls: coder.decodeObject(forKey: "urls") as? [URL] ?? [URL]())
        let queries = coder.decodeObject(forKey: "queries") as? [String?] ?? [String]()
        self.typedQueries = queries
        self.suggestedQueries =
            coder.decodeObject(forKey: "suggestedQueries") as? [String?]
            ?? Array(repeating: nil, count: queries.count)
        self.queryLocations =
            coder.decodeObject(forKey: "queryLocations")
            as? [QueryForNavigation.Query.Location.RawValue]
            ?? Array(repeating: nil, count: queries.count)
        self.lastUsedTime = Timestamp(coder.decodeInt64(forKey: "lastUsedTime"))
    }

    func encode(with coder: NSCoder) {
        coder.encode(currentPage, forKey: "currentPage")
        coder.encode(migrate(urls: urls), forKey: "urls")
        coder.encode(typedQueries, forKey: "queries")
        coder.encode(suggestedQueries, forKey: "suggestedQueries")
        coder.encode(queryLocations, forKey: "queryLocations")
        coder.encode(Int64(lastUsedTime), forKey: "lastUsedTime")
    }
}
