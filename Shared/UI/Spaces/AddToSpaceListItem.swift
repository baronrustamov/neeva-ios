// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import SwiftUI

/// An entry in the Add to Spaces sheet.
///
/// There are two modes, depending on the number of URLs to be added.
/// - For one URL, a bookmark icon is displayed indicating whether or not the URL is in the Space.
/// - For multiple URLs (i.e., a Tab Group), no bookmark icon is displayed.
struct AddToSpaceListItem: View {
    private let space: Space
    private let currentURL: URL?
    private let icon: Nicon
    private let iconColor: Color

    /// - Parameters:
    ///     - space: The space to render.
    ///     - currentURL: The current URL of the Tab if only one Tab is to be added. Otherwise `nil`, which indicates that a Tab Group is to be added.
    init(_ space: Space, currentURL: URL? = nil) {
        self.space = space
        self.currentURL = currentURL

        if let currentURL = currentURL,
            SpaceStore.shared.urlInSpace(currentURL, spaceId: space.id)
        {
            icon = .bookmarkFill
            iconColor = .ui.adaptive.blue
        } else {
            icon = .bookmark
            iconColor = .tertiaryLabel
        }
    }

    var body: some View {
        HStack {
            LargeSpaceIconView(space: space)
                .padding(.trailing, 8)
            Text(space.name)
                .withFont(.headingMedium)
                .foregroundColor(.label)
                .lineLimit(1)
                .accessibilityHint(
                    [space.isPublic ? "Public" : nil, space.isShared ? "Shared" : nil]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                )
                .accessibilityIdentifier("spaceListItemName")
            if !space.isPublic {
                Symbol(decorative: .lock, style: .labelMedium)
                    .foregroundColor(.secondaryLabel)
            }
            Spacer(minLength: 0)
            // If currentURL != nil, that means a single Tab is to be
            // added. In this case (and not the Tab Group case), show
            // the bookmark icon.
            if currentURL != nil {
                Symbol(decorative: icon, weight: .semibold, relativeTo: .title3)
                    .tapTargetFrame()
                    .foregroundColor(iconColor)
                    .hoverEffect()
            }
        }
        .padding(.vertical, 6)
        .padding(.leading, 16)
        .padding(.trailing, 5)
    }
}

public struct LoadingSpaceListItem: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.tertiarySystemFill)
                .frame(width: 36, height: 36)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.tertiarySystemFill)
                .frame(width: 150, height: 16)
            Spacer()
        }
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVStack(spacing: 14) {
            LoadingSpaceListItem()
                .padding(.vertical, 10)
                .padding(.leading, 16)
            AddToSpaceListItem(.empty(), currentURL: "https://neeva.com")
            AddToSpaceListItem(.savedForLaterEmpty, currentURL: "https://neeva.com")
            AddToSpaceListItem(.savedForLater, currentURL: "https://neeva.com")
            AddToSpaceListItem(.stackOverflow, currentURL: "https://neeva.com")
            AddToSpaceListItem(.shared, currentURL: "https://neeva.com")
            AddToSpaceListItem(.public, currentURL: "https://neeva.com")
            AddToSpaceListItem(.sharedAndPublic, currentURL: "https://neeva.com")
        }.padding(.vertical).previewLayout(.sizeThatFits)
    }
}
