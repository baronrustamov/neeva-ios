// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared

struct SuggestionsList: View {
    static let placeholderSite = Site(url: "https://neeva.com", title: "PlaceholderLongTitleOneWord")

    @EnvironmentObject private var historyModel: HistorySuggestionModel
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @Environment(\.isIncognito) private var isIncognito

    var body: some View {
        List {
            let suggestionList = NeevaSuggestionsList()

            if let lensOrBang = neevaModel.activeLensBang,
               let description = lensOrBang.description {
                Section(header: Group {
                    switch lensOrBang.type {
                    case .bang:
                        Text("Search on \(description)")
                    default:
                        Text(description)
                    }
                }.textCase(nil)) {
                    suggestionList
                }
            } else {
                if neevaModel.suggestions.isEmpty && neevaModel.shouldShowSuggestions {
                    PlaceholderSuggestions()
                } else {
                    suggestionList
                }
            }
            NavSuggestionsList()
        }
    }
}

struct SuggestionsList_Previews: PreviewProvider {
    static var previews: some View {
        let suggestions =  [Suggestion.query(.init(type: .standard, suggestedQuery: "hello world", boldSpan: [], source: .unknown))]
        let history = [
            Site(url: "https://neeva.com", title: "Neeva", id: 1),
            Site(url: "https://neeva.com", title: "", id: 2),
            Site(url: "https://google.com", title: "Google", id: 3)
        ]
        Group {
            SuggestionsList()
                .environmentObject(HistorySuggestionModel(previewSites: history))
                .environmentObject(NeevaSuggestionModel(previewLensBang: nil, suggestions: suggestions))
            SuggestionsList()
                .environmentObject(HistorySuggestionModel(previewSites: history))
                .environmentObject(NeevaSuggestionModel(previewLensBang: .previewBang, suggestions: suggestions))
            SuggestionsList()
                .environmentObject(HistorySuggestionModel(previewSites: history))
                .environmentObject(NeevaSuggestionModel(previewLensBang: .previewLens, suggestions: suggestions))
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
