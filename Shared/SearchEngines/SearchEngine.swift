// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

private let replacements = [
    "google:baseURL": "https://www.google.com/",
    "google:baseSuggestURL": "https://www.google.com/complete/",
    "google:suggestClient": "firefox",
    "inputEncoding": "UTF-8",
]

private let replacementsToStrip = [
    "google:pathWildcard", "mailru:referralID", "outputEncoding", "yandex:searchPath",
    "google:cursorPosition", "yandex:referralID", "google:RLZ", "google:originalQueryForSuggestion",
    "google:assistedQueryStats", "google:searchFieldtrialParameter", "google:iOSSearchLanguage",
    "google:prefetchSource", "google:searchClient", "google:sourceId",
    "google:contextualSearchVersion",
    "google:suggestRid", "google:inputType", "google:omniboxFocusType", "google:currentPageUrl",
    "google:pageClassification", "google:clientCacheTimeToLive", "google:searchVersion",
    "google:sessionToken",
    "google:prefetchQuery", "google:suggestAPIKeyParameter",
]

public class SearchEngine: Identifiable, Hashable {
    // MARK: Statics
    public static var nft: SearchEngine {
        return neevaxyz
    }

    // MARK: Public properties & conformances
    public let id: String
    public let label: String
    public let icon: URL?
    public let isNeeva: Bool

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SearchEngine, rhs: SearchEngine) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Public Accessors
    public static func all(for countryCode: String) -> [SearchEngine] {
        let resolved = byCountry.countryMapping[countryCode] ?? "default"
        let engineList =
            byCountry.engineLists.first { $0.code == resolved } ?? byCountry.defaultEngineList
        return engineList.searchEngines
    }

    public static let countryMapping = byCountry.countryMapping

    // MARK: Public methods

    /// Returns the search URL for the given query.
    public func searchURLForQuery(_ query: String) -> URL? {
        interpolate(query: query, into: searchTemplate)
    }

    /// Returns the search URL for the given query.
    public func suggestURLForQuery(_ query: String) -> URL? {
        suggestTemplate.flatMap { interpolate(query: query, into: $0) }
    }

    /// Returns the query that was used to construct a given search URL
    public func queryForSearchURL(_ url: URL?) -> String? {
        guard isSearchURLForEngine(url), let key = searchQueryComponentKey else { return nil }

        if let value = url?.getQuery()[key] {
            return value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        } else {
            // If search term could not found in query, it may be exist inside fragment
            var components = URLComponents()
            components.query = url?.fragment?.removingPercentEncoding

            guard let value = components.url?.getQuery()[key] else { return nil }
            return value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        }
    }

    public func queryForLocationBar(from url: URL?) -> String? {
        if let query = queryForSearchURL(url),
            !isNeeva || !NeevaConstants.isNeevaPageWithSearchBox(url: url)
        {
            return query
        }
        return nil
    }

    public func searchURLFrom(searchQuery: String, queryItems: [URLQueryItem]) -> URL? {
        guard let url = searchURLForQuery(searchQuery) else { return nil }

        return url.withQueryParams(queryItems.filter { $0.name != searchQueryComponentKey })
    }

    // MARK: - Internal properties & initializers
    private let suggestTemplate: String?
    private let customSearchTemplate: String
    private var searchTemplate: String {
        isNeeva
            ? "https://\(NeevaConstants.appHost)/search?q={searchTerms}&src=nvobar"
            : customSearchTemplate
    }

    private init(
        id: String, label: String, icon: URL?, suggestTemplate: String?, searchTemplate: String,
        isNeeva: Bool = false
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.suggestTemplate =
            id == "google"
            ? "{google:baseSuggestURL}search?{google:searchFieldtrialParameter}client={google:suggestClient}&q={searchTerms}"
            : suggestTemplate
        self.customSearchTemplate = searchTemplate
        self.isNeeva = isNeeva
    }

    public static var neeva: SearchEngine {
        SearchEngine(
            id: "_neeva",
            label: "Neeva",
            icon: nil,
            suggestTemplate: nil,
            searchTemplate: "",
            isNeeva: true
        )
    }

    private static var neevaxyz: SearchEngine {
        SearchEngine(
            id: "_neevaxyz",
            label: "Neevaxyz",
            icon: URL(string: "https://neeva.xyz/apple-touch-icon.png"),
            suggestTemplate: "https://neeva.xyz/_suggest?q={searchTerms}",
            searchTemplate: "https://neeva.xyz?q={searchTerms}"
        )
    }

    public static var google: SearchEngine {
        SearchEngine(
            id: "google",
            label: "Google",
            icon: URL(
                "https://google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png"
            ),
            suggestTemplate: "",
            searchTemplate: "https://google.com/search?q={searchTerms}")
    }

    // MARK: Private helpers
    // we have to inject a search query in order to produce a valid URL, otherwise
    // we cannot do the conversion to URLComponents and have to do flaky pattern matching instead.
    private let placeholder = "PLACEHOLDER"
    private lazy var searchQueryURL: URL = searchURLForQuery(placeholder)!
    /// Return the arg that we use for searching for this engine
    private lazy var searchQueryComponentKey: String? = {
        let components = URLComponents(url: searchQueryURL, resolvingAgainstBaseURL: false)

        if let retVal = extractQueryArg(in: components?.queryItems, for: placeholder) {
            return retVal
        } else {
            // Query arg may be exist inside fragment
            var fragmentToQuery = URLComponents()
            fragmentToQuery.query = components?.fragment
            return extractQueryArg(in: fragmentToQuery.queryItems, for: placeholder)
        }
    }()

    private func extractQueryArg(in queryItems: [URLQueryItem]?, for placeholder: String) -> String?
    {
        return queryItems?.filter({ $0.value == placeholder }).first?.name
    }

    /// check that the URL host contains the name of the search engine somewhere inside it
    fileprivate func isSearchURLForEngine(_ url: URL?) -> Bool {
        guard let url = url, url.path == searchQueryURL.path else { return false }

        return url.shortDisplayString == searchQueryURL.shortDisplayString
    }

    private func interpolate(query: String, into template: String) -> URL? {
        guard
            let escapedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .SearchTermsAllowed)
        else { return nil }

        // Escape the search template as well in case it contains not-safe characters like symbols
        // Allow brackets since we use them in our template as our insertion point
        let templateAllowedSet = CharacterSet(charactersIn: "{}").union(.URLAllowed)

        guard
            let encodedTemplate = template.addingPercentEncoding(
                withAllowedCharacters: templateAllowedSet)
        else { return nil }

        var urlString =
            encodedTemplate
            .replacingOccurrences(of: "{searchTerms}", with: escapedQuery, options: .literal)
            .replacingOccurrences(
                of: "{language}",
                with: Locale.current.identifier.replacingOccurrences(of: "_", with: "-"),
                options: .literal)

        for (key, value) in replacements {
            urlString = urlString.replacingOccurrences(of: "{\(key)}", with: value)
        }
        for key in replacementsToStrip {
            urlString = urlString.replacingOccurrences(of: "{\(key)}", with: "")
        }

        return URL(string: urlString)
    }
}

// MARK: - Data Loading

extension SearchEngine {
    fileprivate static var byCountry = try! JSONDecoder().decode(
        ByCountry.self,
        from: Data(
            contentsOf: NeevaConstants.sharedBundle.url(
                forResource: "engines_by_country", withExtension: "json")!))

    public static let all: [String: SearchEngine] = Dictionary(
        uniqueKeysWithValues:
            try! JSONDecoder().decode(
                PrepopulatedEngines.self,
                from: Data(
                    contentsOf: NeevaConstants.sharedBundle.url(
                        forResource: "prepopulated_engines", withExtension: "json")!
                )
            ).elements.map { (id, engine) in
                (
                    id,
                    SearchEngine(
                        id: id, label: engine.name, icon: URL(string: engine.favicon_url),
                        suggestTemplate: engine.suggest_url, searchTemplate: engine.search_url)
                )
            })
}

private struct ByCountry: Codable {
    let countryMapping: [String: String]
    let engineLists: [EngineList]

    fileprivate var defaultEngineList: EngineList {
        engineLists.first { $0.code == "default" }!
    }
}

private struct EngineList: Codable {
    let code: String
    private let engines: [String]

    var searchEngines: [SearchEngine] {
        engines.compactMap { SearchEngine.all[$0] }
    }
}

private struct PrepopulatedEngines: Codable {
    let int_variables: [String: Int]
    let generate_array: [String: String]
    let elements: [String: SearchEngineValue]
}

private struct SearchEngineValue: Codable {
    let name: String
    let keyword: String
    let favicon_url: String
    let search_url: String
    let suggest_url: String?
    let type: String
    let id: Int
}
