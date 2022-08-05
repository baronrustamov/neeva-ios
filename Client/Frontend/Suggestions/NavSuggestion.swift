// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage

public struct NavSuggestion {
    let url: URL
    let title: String?
    // PR #4122; periphery:ignore
    let subtitle: String?
    let isMemorizedNav: Bool
    let isAutocomplete: Bool

    init?(suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion) {
        guard let url = suggestion.suggestedUrl.asURL else { return nil }
        self.url = url
        title = suggestion.title
        subtitle = suggestion.subtitle
        isMemorizedNav = true
        isAutocomplete = false
    }

    init(site: Site) {
        url = site.url
        title = site.title
        subtitle = nil
        isMemorizedNav = false
        isAutocomplete = false
    }

    init(url: URL, title: String?, isMemorizedNav: Bool = false, isAutocomplete: Bool = false) {
        self.url = url
        self.title = title
        subtitle = nil
        self.isMemorizedNav = isMemorizedNav
        self.isAutocomplete = isAutocomplete
    }
}

extension NavSuggestion: Equatable {
    public static func == (lhs: NavSuggestion, rhs: NavSuggestion) -> Bool {
        lhs.url.normalizedHostAndPathForDisplay == rhs.url.normalizedHostAndPathForDisplay
    }
}

extension NavSuggestion: Identifiable {
    public var id: String {
        return "nav-\(url)"
    }
}
