// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct SpaceEntityDescriptionView: View {

    let canEdit: Bool
    let previewEntity: PreviewEntity
    let snippetToDisplay: String?
    let onEditSpaceItem: () -> Void
    @Default(.showDescriptions) var showDescriptions

    var body: some View {
        if showDescriptions,
            case .retailProduct(let product) = previewEntity,
            !product.description.isEmpty
        {
            ForEach(product.description, id: \.self) { description in
                Text(description)
                    .withFont(.bodyLarge)
                    .modifier(DescriptionTextModifier())
            }
        } else if showDescriptions,
            case .techDoc(let doc) = previewEntity,
            let body = doc.body
        {
            Text(AttributedString(body))
                .withFont(.bodyLarge)
                .modifier(DescriptionTextModifier())
        } else if let snippet = snippetToDisplay,
            showDescriptions, !snippet.isEmpty
        {
            SpaceMarkdownSnippet(
                showDescriptions: true,
                snippet: snippet
            )

        } else if canEdit,
            snippetToDisplay?.isEmpty != false
        {
            Text("Click to add description")
                .withFont(.bodyLarge)
                .foregroundColor(.tertiaryLabel)
                .highPriorityGesture(TapGesture().onEnded({ onEditSpaceItem() }))
        }
    }
}
