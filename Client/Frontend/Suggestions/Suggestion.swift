// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SFSafeSymbols
import Shared

/// A type that wraps both query and URL suggestions
public enum Suggestion {
    case query(SuggestionsQuery.Data.Suggest.QuerySuggestion)
    case url(SuggestionsQuery.Data.Suggest.UrlSuggestion)
    case bang(Bang)
    case lens(Lens)
    case navigation(NavSuggestion)
    case tabSuggestion(TabCardDetails)
    case editCurrentURL(TabCardDetails)
    case editCurrentQuery(String, URL)
    case findInPage(String)
    case xyzQuery(NFTSuggestion)

    public struct Bang {
        public let shortcut: String
        public let description: String
        public let domain: String?
    }

    public struct Lens {
        public let shortcut: String
        public let description: String
    }

    public init?(bang: SuggestionsQuery.Data.Suggest.BangSuggestion) {
        if let shortcut = bang.shortcut, let description = bang.description {
            self = .bang(Bang(shortcut: shortcut, description: description, domain: bang.domain))
        } else {
            return nil
        }
    }

    public init?(lens: SuggestionsQuery.Data.Suggest.LenseSuggestion) {
        if let shortcut = lens.shortcut, let description = lens.description {
            self = .lens(Lens(shortcut: shortcut, description: description))
        } else {
            return nil
        }
    }

    public static func placeholderQuery(_ query: String = "placeholderQuery")
        -> SuggestionsQuery.Data.Suggest.QuerySuggestion
    {
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: query,
            boldSpan: [],
            source: .bing
        )
    }
}

extension Suggestion: Identifiable, Equatable {
    public var id: String {
        switch self {
        case .query(let query):
            if let annotationType = query.annotation?.annotationType {
                return "query-\(query.suggestedQuery)-\(annotationType)"
            } else {
                return "query-\(query.suggestedQuery)"
            }
        case .url(let url):
            return "url-\(url.suggestedUrl)"
        case .bang(let bang):
            return "bang-\(bang.shortcut)"
        case .lens(let lens):
            return "lens-\(lens.shortcut)"
        case .navigation(let nav):
            return "nav-\(nav.url)"
        case .editCurrentURL(let tab):
            return "currentURL-\(tab.id)"
        case .tabSuggestion(let tab):
            return "tab-\(tab.id)"
        case .findInPage(let query):
            return "findInPage-\(query)"
        case .xyzQuery(let query):
            return "xyz-query-\(query)"
        case .editCurrentQuery(let query, _):
            return "editCurrentQuery-\(query)"
        }
    }

    public static func == (lhs: Suggestion, rhs: Suggestion) -> Bool {
        return lhs.id == rhs.id
    }
}

public typealias ActiveLensBangInfo = SuggestionsQuery.Data.Suggest.ActiveLensBangInfo
typealias SuggestionsQueryResult = (
    [Suggestion], [Suggestion], [Suggestion], ActiveLensBangInfo?,
    [String: String], [String: Int]
)
extension ActiveLensBangInfo: Equatable {
    public static func == (lhs: ActiveLensBangInfo, rhs: ActiveLensBangInfo) -> Bool {
        lhs.description == rhs.description && lhs.domain == rhs.domain
            && lhs.shortcut == rhs.shortcut && lhs.type == rhs.type
    }
}

extension ActiveLensBangType {
    var sigil: String {
        switch self {
        case .bang: return "!"
        case .lens: return "@"
        case .unknown, .__unknown(_): return ""
        }
    }
    // TODO: use Nicon? / customize to favicon
    var defaultSymbol: SFSymbol {
        switch self {
        case .bang: return .exclamationmarkCircle
        case .lens: return .at
        case .unknown, .__unknown(_): return .questionmarkDiamondFill
        }
    }
}

extension SuggestionsQuery.Data.Suggest.QuerySuggestion {
    public func suggestedCalculatorQuery() -> String? {
        if AnnotationType(annotation: self.annotation) == .calculator {
            return self.suggestedQuery + " ="
        } else {
            return nil
        }
    }
}

/// Fetches query and URL suggestions for a given query
class SuggestionsController: QueryController<SuggestionsQuery, SuggestionsQueryResult> {
    fileprivate static let querySuggestionsCap = 3

    override class func processData(_ data: SuggestionsQuery.Data) -> SuggestionsQueryResult {
        let querySuggestions = data.suggest?.querySuggestion ?? []
        // Split queries into standard queries that doesnt have annotations and everything else.
        let standardQuerySuggestions =
            querySuggestions.filter {
                $0.type == .standard
                    || $0.annotation?.dictionaryInfo != nil
            }
        let rowQuerySuggestions =
            querySuggestions.filter {
                $0.type != .standard
                    && $0.annotation?.dictionaryInfo == nil
            }

        var urlSuggestions = data.suggest?.urlSuggestion ?? []
        // Move all nav suggestions out of url suggestions.
        let navSuggestions = urlSuggestions.filter { !($0.subtitle?.isEmpty ?? true) }
        urlSuggestions.removeAll(where: { !($0.subtitle?.isEmpty ?? true) })

        var neevaSuggestions = [Suggestion]()

        var memorizedSuggestionMap = [String: String]()
        var querySuggestionIndexMap = [String: Int]()

        let navSuggestionMap = navSuggestions.reduce(
            into: [String: [SuggestionsQuery.Data.Suggest.UrlSuggestion]]()
        ) {
            if let sourceQueryIndex = $1.sourceQueryIndex,
                sourceQueryIndex < querySuggestions.count
            {
                let suggestedQuery = querySuggestions[sourceQueryIndex].suggestedQuery
                if let _ = $0[suggestedQuery] {
                    $0[suggestedQuery]?.append($1)
                } else {
                    $0[suggestedQuery] = [$1]
                }
            }
        }

        var numOfQuerySuggestions = 0
        var filteredStandardQuerySuggestions = [SuggestionsQuery.Data.Suggest.QuerySuggestion]()
        for suggestion in standardQuerySuggestions {
            if numOfQuerySuggestions == SuggestionsController.querySuggestionsCap {
                continue
            }
            filteredStandardQuerySuggestions.append(suggestion)
            numOfQuerySuggestions += 1
        }

        for (index, suggestion)
            in filteredStandardQuerySuggestions
            .enumerated()
        {
            neevaSuggestions.append(Suggestion.query(suggestion))
            if let urlSuggestions = navSuggestionMap[suggestion.suggestedQuery] {
                neevaSuggestions.append(contentsOf: urlSuggestions.map(Suggestion.url))
                urlSuggestions.forEach { urlSuggestion in
                    memorizedSuggestionMap[urlSuggestion.suggestedUrl] =
                        suggestion.suggestedQuery
                }
            }
            querySuggestionIndexMap[suggestion.suggestedQuery] = index
        }

        neevaSuggestions.append(contentsOf: rowQuerySuggestions.map(Suggestion.query))

        let bangSuggestions = data.suggest?.bangSuggestion ?? []
        let lensSuggestions = data.suggest?.lenseSuggestion ?? []

        return (
            neevaSuggestions
                + bangSuggestions.compactMap(Suggestion.init(bang:))
                + lensSuggestions.compactMap(Suggestion.init(lens:)),
            NeevaFeatureFlags[.personalSuggestion] ? urlSuggestions.map(Suggestion.url) : [],
            [],
            data.suggest?.activeLensBangInfo,
            memorizedSuggestionMap,
            querySuggestionIndexMap
        )
    }

    @discardableResult static func getSuggestions(
        for query: String,
        completion: @escaping (Result<SuggestionsQueryResult, Error>) -> Void
    ) -> Cancellable {
        Self.perform(query: SuggestionsQuery(query: query), completion: completion)
    }
}
