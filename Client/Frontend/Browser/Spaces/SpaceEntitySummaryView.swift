// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct SpaceEntitySummaryView: View {

    let title: String
    let snippetToDisplay: String?
    let previewEntity: PreviewEntity
    let url: URL?
    let socialURL: URL?
    @ObservedObject var details: SpaceEntityThumbnail
    @Default(.showDescriptions) var showDescriptions

    var body: some View {
        VStack(alignment: .leading, spacing: SpaceViewUX.Padding) {
            HStack(spacing: 6) {
                if let socialURL = socialURL {
                    FaviconView(forSiteUrl: socialURL)
                        .frame(width: 12, height: 12)
                        .cornerRadius(4)
                }
                HStack(spacing: 0) {
                    Text(title)
                        .withFont(.headingMedium)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    if details.isPinned {
                        SpacePinView()
                    }
                }
            }
            if let url = url {
                EntityInfoView(
                    url: url,
                    entity: previewEntity
                )
            }

            if !showDescriptions,
                let snippet = snippetToDisplay
            {
                SpaceMarkdownSnippet(
                    showDescriptions: false,
                    snippet: snippet
                )
            }
        }
    }
}
