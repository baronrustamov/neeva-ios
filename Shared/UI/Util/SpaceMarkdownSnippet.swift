// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct SpaceMarkdownSnippet: View {

    public init(
        showDescriptions: Bool, snippet: String, foregroundColor: Color = .secondaryLabel,
        lineLimit: Int = 3
    ) {
        self.showDescriptions = showDescriptions
        self.snippet = snippet
        self.foregroundColor = foregroundColor
        self.lineLimit = lineLimit
    }

    public let showDescriptions: Bool
    public let snippet: String
    public let foregroundColor: Color
    private let lineLimit: Int

    @ViewBuilder
    private var content: some View {
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

    public var body: some View {
        content
            .lineLimit(showDescriptions ? nil : lineLimit)
            .foregroundColor(foregroundColor)
            .fixedSize(horizontal: false, vertical: showDescriptions)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
