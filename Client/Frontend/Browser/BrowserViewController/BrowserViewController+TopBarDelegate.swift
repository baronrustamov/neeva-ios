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
        if let percentEncodedQueryItems = searchQueryModel.components?.percentEncodedQueryItems,
            let url = SearchEngine.current.searchURLFrom(
                searchQuery: text, percentEncodedQueryItems: percentEncodedQueryItems)
        {
            finishEditingAndSubmit(url, visitType: VisitType.typed, forTab: currentTab)
            searchQueryModel.components = nil

            return
        }

        submitSearchText(text, forTab: currentTab, using: SearchEngine.current)
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
