// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SpaceHeaderView: View {
    @EnvironmentObject var spaceModel: SpaceCardModel
    let space: Space
    // This fixes iPad auto pop problem
    var onShowProfileUI: () -> Void

    var owner: Space.Acl? {
        space.acls.first(where: { $0.acl == .owner })
    }

    var displayTitle: String {
        if space.isDigest {
            // This removes the count from the end of title.
            return "Daily Digest"
        } else {
            return space.displayTitle
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleView
            aclView
            descriptionView
            if !space.isDigest {
                if space.isPublic {
                    if let followers = space.followers {
                        HStack(spacing: 0) {
                            Symbol(decorative: .person2Fill, style: .bodyLarge)
                                .foregroundColor(.label)
                            Text(" \(followers) Followers")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                            Spacer()
                            if space.ACL == .owner, let views = space.views {
                                Symbol(decorative: .eye, style: .bodyLarge)
                                    .foregroundColor(.label)
                                Text(" \(views)")
                                    .withFont(.bodyLarge)
                                    .foregroundColor(.label)
                            }
                        }
                    }
                } else {
                    HStack(spacing: 0) {
                        Symbol(decorative: .lock, style: .bodySmall)
                            .foregroundColor(.secondaryLabel)
                        Text("Only visible to you and people you shared with")
                            .withFont(.bodySmall)
                            .foregroundColor(.secondaryLabel)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.DefaultBackground)

    }

    private var titleView: some View {
        Text(displayTitle)
            .withFont(.displayMedium)
            .foregroundColor(.label)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
    }

    private var aclView: some View {
        ZStack(alignment: .leading) {
            Button(
                action: {
                    self.onShowProfileUI()
                },
                label: {
                    SpaceACLView(isPublic: space.isPublic, acls: space.acls, owner: space.owner)
                })
        }
    }

    @ViewBuilder var descriptionView: some View {
        if let description = space.description, !description.isEmpty {
            SpaceMarkdownSnippet(
                showDescriptions: true,
                snippet: description,
                foregroundColor: .label
            )
        }
    }
}

struct SpaceACLView: View {
    let isPublic: Bool
    let acls: [Space.Acl]

    var owner: SpacesMetadata.Owner?

    var secondACL: Space.Acl? {
        return acls.first(where: { $0.acl != .owner })
    }

    var countToShow: Int {
        var count = acls.count
        if let _ = owner {
            count -= 1
        }
        if let _ = secondACL {
            count -= 1
        }
        return count
    }

    var body: some View {
        if let owner = owner {
            if isPublic {
                HStack(spacing: 12) {
                    ProfileImageView(pictureURL: owner.pictureUrl, displayName: owner.displayName)
                        .frame(width: 32, height: 32)
                    Text(owner.displayName)
                        .withFont(.bodyLarge)
                        .foregroundColor(.label)
                }
            } else {
                HStack(spacing: 12) {
                    HStack(spacing: -6) {
                        ProfileImageView(
                            pictureURL: owner.pictureUrl, displayName: owner.displayName
                        )
                        .frame(width: 32, height: 32)
                        if let secondACL = secondACL?.profile {
                            ProfileImageView(
                                pictureURL: secondACL.pictureUrl,
                                displayName: secondACL.displayName
                            )
                            .frame(width: 32, height: 32)
                        }
                        if countToShow > 0 {
                            Text("\(countToShow)")
                                .withFont(.labelMedium)
                                .foregroundColor(.label)
                                .frame(width: 32, height: 32)
                                .background(Color.brand.polar)
                                .clipShape(Circle())
                        }
                    }
                    Text(acls.map { $0.profile.displayName }.joined(separator: ", "))
                        .withFont(.bodyLarge)
                        .foregroundColor(.label)
                        .lineLimit(1)
                }
            }
        }
    }

}
