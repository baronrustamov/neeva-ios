// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct SpaceMarkdownSnippet: View {
    let showDescriptions: Bool
    let snippet: String
    var foregroundColor: Color = .secondaryLabel

    @ViewBuilder
    var content: some View {
        if #available(iOS 15.0, *),
            let attributedSnippet = try? AttributedString(
                markdown: snippet)
        {
            Text(attributedSnippet)
                .withFont(.bodyLarge)
        } else {
            Text(snippet)
                .withFont(.bodyLarge)
        }
    }

    var body: some View {
        content
            .lineLimit(showDescriptions ? nil : 3)
            .foregroundColor(foregroundColor)
            .fixedSize(horizontal: false, vertical: showDescriptions)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
