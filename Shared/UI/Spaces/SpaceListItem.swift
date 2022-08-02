// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import SwiftUI

/// An entry in a space list
struct SpaceListItem: View {
    let space: Space
    let icon: Nicon
    let iconColor: Color

    /// - Parameter space: the space to render
    init(_ space: Space, currentURL: URL) {
        self.space = space
        if SpaceStore.shared.urlInSpace(currentURL, spaceId: space.id) {
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
            Symbol(decorative: icon, weight: .semibold, relativeTo: .title3)
                .tapTargetFrame()
                .foregroundColor(iconColor)
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
            SpaceListItem(.empty(), currentURL: "https://neeva.com")
            SpaceListItem(.savedForLaterEmpty, currentURL: "https://neeva.com")
            SpaceListItem(.savedForLater, currentURL: "https://neeva.com")
            SpaceListItem(.stackOverflow, currentURL: "https://neeva.com")
            SpaceListItem(.shared, currentURL: "https://neeva.com")
            SpaceListItem(.public, currentURL: "https://neeva.com")
            SpaceListItem(.sharedAndPublic, currentURL: "https://neeva.com")
        }.padding(.vertical).previewLayout(.sizeThatFits)
    }
}
