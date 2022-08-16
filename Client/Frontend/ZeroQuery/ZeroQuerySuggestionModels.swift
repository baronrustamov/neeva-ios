// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage

private var log = Logger.browser

class SuggestedSitesViewModel: ObservableObject {
    @Published var sites: [Site]

    init(sites: [Site]) {
        self.sites = sites
    }
}

struct SuggestedSearch {
    let id: UUID = UUID()
    let query: String
    let site: Site
    let isExample: Bool
}

let exampleQueries: [SuggestedSearch] = ["best headphones", "lemon bar recipe", "react hooks"].map {
    query in
    SuggestedSearch(
        query: query,
        site: .init(url: SearchEngine.current.searchURLForQuery(query)!),
        isExample: true)
}

class SuggestedSearchesModel: ObservableObject {
    @Published private(set) var suggestions: [SuggestedSearch] = []

    var searchUrlForQuery: String {
        SearchEngine.current.searchURLForQuery("blank")!.normalizedHostAndPath!
    }

    func reload(from profile: Profile, completion: (() -> Void)? = nil) {
        guard
            let deferredHistory = profile.history.getFrecentHistory().getSites(
                matchingSearchQuery: searchUrlForQuery, limit: 100) as? CancellableDeferred
        else {
            assertionFailure("FrecentHistory query should be cancellable")
            return
        }

        deferredHistory.uponQueue(.main) { result in
            guard !deferredHistory.cancelled else {
                return
            }

            var deferredHistorySites = result.successValue?.asArray().compactMap { $0 } ?? []
            let topFrecentHistorySite = deferredHistorySites[deferredHistorySites.indices]
                .popFirst()
            // TODO: https://github.com/neevaco/neeva-ios/issues/1027
            deferredHistorySites.sort { siteA, siteB in
                return siteA.latestVisit?.date ?? 0 > siteB.latestVisit?.date ?? 0
            }

            var queries = Set<String>()
            var topFrecentHistoryQuery: String? = nil
            if let topFrecentHistorySite = topFrecentHistorySite,
                let query = SearchEngine.current.queryForSearchURL(topFrecentHistorySite.url)
            {
                topFrecentHistoryQuery = query
                queries.insert(query)
            }

            var searches: [SuggestedSearch] = deferredHistorySites.compactMap { site in
                if let query = SearchEngine.current.queryForSearchURL(site.url),
                    !queries.contains(query)
                {
                    queries.insert(query)
                    return SuggestedSearch(query: query, site: site, isExample: false)
                } else {
                    return nil
                }
            }
            if let topFrecentHistorySite = topFrecentHistorySite,
                let topFrecentHistoryQuery = topFrecentHistoryQuery
            {
                searches.insert(
                    SuggestedSearch(
                        query: topFrecentHistoryQuery, site: topFrecentHistorySite, isExample: false
                    ), at: 0)
            }

            // Append any example queries not already present in the set.
            for example in exampleQueries {
                if !searches.contains(where: { $0.query == example.query }) {
                    searches.append(example)
                }
            }

            self.suggestions = searches

            log.info("updated suggestedQueries, count: \(self.suggestions.count)")

            completion?()
        }
    }
}
