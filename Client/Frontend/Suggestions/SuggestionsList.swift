// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct SuggestionsList: View {
    static let placeholderNavSuggestion = NavSuggestion(
        url: "https://neeva.com", title: "PlaceholderLongTitleOneWord")

    @EnvironmentObject private var suggestionModel: SuggestionModel

    var searchSuggestionLabel: String {
        if NeevaConstants.currentTarget == .xyz {
            return "Web Search from \(SearchEngine.current.label)"
        } else {
            return SearchEngine.current.isNeeva
                ? "Neeva Search" : "\(SearchEngine.current.label) Suggestions"
        }
    }

    private var content: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            if let lensOrBang = suggestionModel.activeLensBang,
                let description = lensOrBang.description
            {
                Section(
                    header: Group {
                        switch lensOrBang.type {
                        case .bang:
                            Text("Search on \(description)")
                                .withFont(.bodyMedium)

                        default:
                            Text(description)
                                .withFont(.bodyMedium)
                        }
                    }.textCase(nil).padding(.vertical, 8)
                ) {
                    QuerySuggestionsList()
                }
            } else {
                TabSuggestionsList()

                if NeevaConstants.currentTarget != .xyz {
                    AutocompleteSuggestionView()
                }

                if !suggestionModel.xyzQuerySuggestions.isEmpty {
                    SuggestionsSection(header: "NFT Search from Neevaxyz") {
                        ForEach(Array(suggestionModel.xyzQuerySuggestions.enumerated()), id: \.0) {
                            index, suggestion in
                            SearchSuggestionView(suggestion)
                        }
                    }
                }

                if suggestionModel.shouldShowSearchSuggestions {
                    SuggestionsSection(
                        header: LocalizedStringKey(searchSuggestionLabel)
                    ) {
                        if suggestionModel.shouldShowPlaceholderSuggestions {
                            PlaceholderSuggestions()
                        } else {
                            QuerySuggestionsList()
                            UrlSuggestionsList()
                        }
                    }
                }
            }

            NavSuggestionsList()

            if let findInPageSuggestion = suggestionModel.findInPageSuggestion {
                SuggestionsSection(header: "Find on this page") {
                    SearchSuggestionView(findInPageSuggestion)
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geom in
            if #available(iOS 15.0, *) {
                ScrollView(.vertical, showsIndicators: false) {
                    content
                        .safeAreaInset(edge: .leading, spacing: 0) {
                            Color.clear.frame(width: geom.safeAreaInsets.leading)

                        }
                        .safeAreaInset(edge: .trailing, spacing: 0) {
                            Color.clear.frame(width: geom.safeAreaInsets.trailing)
                        }
                }
                .padding(.leading, -geom.safeAreaInsets.leading)
                .padding(.trailing, -geom.safeAreaInsets.trailing)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    content
                }
            }
        }
    }
}

struct SuggestionsList_Previews: PreviewProvider {
    static var previews: some View {
        let history = [
            Site(url: "https://neeva.com", title: "Neeva", id: 1),
            Site(url: "https://neeva.com", title: "", id: 2),
            Site(url: "https://google.com", title: "Google", id: 3),
        ]
        Group {
            SuggestionsList()
            SuggestionsList()
            SuggestionsList()
        }
        .environmentObject(
            SuggestionModel(
                bvc: SceneDelegate.getBVC(for: nil),
                previewSites: history)
        )
        .previewLayout(.fixed(width: 375, height: 250))
    }
}
