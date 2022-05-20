// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SpaceNoteEntityView: View {
    let details: SpaceEntityThumbnail
    var showDescriptions: Bool
    var isDigestSeeMore: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(details.title)
                .withFont(isDigestSeeMore ? .bodyLarge : .headingMedium)
                .foregroundColor(
                    isDigestSeeMore ? .ui.adaptive.blue : .label)

            if let snippet = details.data.snippet,
                !snippet.isEmptyOrWhitespace()
            {
                SpaceMarkdownSnippet(
                    showDescriptions: showDescriptions,
                    snippet: snippet
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .modifier(ListSeparatorModifier())
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isDigestSeeMore
                ? Color.DefaultBackground : Color.secondaryBackground
        )
        .onDrag {
            NSItemProvider(id: details.id)
        }
    }
}
