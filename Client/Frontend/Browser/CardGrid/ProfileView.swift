// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct ACLView: View {
    @Binding var selectedACL: SpaceACLLevel

    var body: some View {
        Menu(
            content: {
                Button {
                    selectedACL = .edit
                } label: {
                    Text(SpaceACLLevel.edit.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
                Button {
                    selectedACL = .comment
                } label: {
                    Text(SpaceACLLevel.comment.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
                Button {
                    selectedACL = .view
                } label: {
                    Text(SpaceACLLevel.view.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
            },
            label: {
                HStack {
                    Text(selectedACL.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.ui.adaptive.blue)
                    Symbol(decorative: .chevronDown, style: .labelMedium)
                        .foregroundColor(Color.ui.adaptive.blue)
                }
            })
    }
}

struct ProfileView: View {
    let pictureURL: String
    let displayName: String
    let email: String

    var body: some View {
        ProfileImageView(pictureURL: pictureURL, displayName: displayName)
            .frame(width: 20, height: 20)
        VStack(alignment: .leading, spacing: 0) {
            Text(displayName)
                .withFont(.bodyMedium)
                .lineLimit(1)
                .foregroundColor(Color.label)
            if !email.isEmpty {
                Text(email)
                    .withFont(.bodySmall)
                    .lineLimit(1)
                    .foregroundColor(Color.secondaryLabel)
            }
        }
    }
}

struct ProfileImageView: View {
    let pictureURL: String
    let displayName: String

    var body: some View {
        Group {
            if let pictureUrl = URL(string: pictureURL) {
                WebImage(url: pictureUrl).resizable()
            } else {
                let name = (displayName).prefix(2).uppercased()
                Color.brand.blue
                    .overlay(
                        Text(name)
                            .accessibilityHidden(true)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    )
            }
        }
        .clipShape(Circle())
        .aspectRatio(contentMode: .fill)
    }
}
