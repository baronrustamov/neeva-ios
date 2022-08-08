// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

/// Renders a nav suggestion
struct NavSuggestionView: View {
    let suggestion: NavSuggestion

    @EnvironmentObject var model: SuggestionModel

    @ViewBuilder
    var icon: some View {
        FaviconView(forSiteUrl: suggestion.url)
            .frame(width: SuggestionViewUX.FaviconSize, height: SuggestionViewUX.FaviconSize)
            .roundedOuterBorder(
                cornerRadius: SuggestionViewUX.CornerRadius, color: .quaternarySystemFill)
    }

    @ViewBuilder
    var label: some View {
        if let title = suggestion.title {
            Text(title).withFont(.bodyLarge).lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        URLDisplayView(url: suggestion.url)
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: EmptyView(),
            suggestion: Suggestion.navigation(suggestion)
        )
        .environmentObject(model)
    }
}

struct NavSuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NavSuggestionView(suggestion: NavSuggestion(url: "https://neeva.com", title: "Neeva"))
            NavSuggestionView(suggestion: NavSuggestion(url: "https://neeva.com", title: ""))
            NavSuggestionView(suggestion: NavSuggestion(url: "https://google.com", title: "Google"))
        }
        .previewLayout(.fixed(width: 375, height: 200))
    }
}
