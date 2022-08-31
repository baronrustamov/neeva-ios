// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import Storage

extension BrowserViewController: TopBarDelegate {
    func perform(menuAction: OverflowMenuAction) {
        self.perform(overflowMenuAction: menuAction, targetButtonView: nil)
    }

    func urlBarDidPressReload() {
        // log tap reload
        ClientLogger.shared.logCounter(
            .TapReload, attributes: EnvironmentHelper.shared.getAttributes())

        tabManager.selectedTab?.reload()
    }

    func urlBarDidPressStop() {
        tabManager.selectedTab?.stop()
    }

    func urlBar(didSubmitText text: String, isSearchQuerySuggestion: Bool = false) {
        // When user enter text in the url bar, assume user figured out
        // how to search from url bar, so auto dismiss the search input tour prompt
        Defaults[.searchInputPromptDismissed] = true

        let currentTab = tabManager.selectedTab

        if let fixupURL = URLFixup.getURL(text), !isSearchQuerySuggestion {
            // The user entered a URL, so use it.
            finishEditingAndSubmit(fixupURL, visitType: VisitType.typed, forTab: currentTab)
            return
        }

        // User is editing the current query, should preserve the parameters from their original query
        if let queryItems = searchQueryModel.queryItems, let url = currentTab?.url {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

            if let queryKey = SearchEngine.current.searchQueryComponentKey,
                let encodedOldQuery = queryItems.first(where: { $0.name == "q" })?
                    .value?
                    .addingPercentEncoding(withAllowedCharacters: .SearchTermsAllowed),
                let encodedNewQuery = text.addingPercentEncoding(
                    withAllowedCharacters: .SearchTermsAllowed)
            {
                components.percentEncodedQuery = components.percentEncodedQuery?
                    .replacingOccurrences(
                        of: "\(queryKey)=\(encodedOldQuery)", with: "\(queryKey)=\(encodedNewQuery)"
                    )
            }

            finishEditingAndSubmit(components.url!, visitType: VisitType.typed, forTab: currentTab)
            searchQueryModel.queryItems = nil
            return
        }

        let searchEngine =
            NeevaConstants.currentTarget == .xyz && FeatureFlag[.newWeb3Features]
                && !isSearchQuerySuggestion ? SearchEngine.nft : SearchEngine.current
        // We couldn't build a URL, so check for a matching search keyword.
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        guard trimmedText.firstIndex(of: " ") != nil else {
            submitSearchText(text, forTab: currentTab, using: searchEngine)
            return
        }

        self.submitSearchText(text, forTab: currentTab, using: searchEngine)
    }

    fileprivate func submitSearchText(
        _ text: String, forTab tab: Tab?, using searchEngine: SearchEngine = SearchEngine.current
    ) {
        if let searchURL = searchEngine.searchURLForQuery(text) {
            // we don't associate the query string so that the action will open a new search
            IntentHelper.suggestSearchIntent()
            IntentHelper.donateSearchIntent()

            // We couldn't find a matching search keyword, so do a search query.
            finishEditingAndSubmit(searchURL, visitType: VisitType.typed, forTab: tab)
        } else {
            // We still don't have a valid URL, so something is broken. Give up.
            print("Error handling URL entry: \"\(text)\".")
            assertionFailure("Couldn't generate search URL: \(text)")
        }
    }
}
