// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

private enum KnowledgeCardUX {
    static let thumbnailSize: CGFloat = 68
    static let thumbnailRadius: CGFloat = 12
    static let socialIconSize: CGFloat = 14
    static let buttonHPadding: CGFloat = 16
    static let buttonVPadding: CGFloat = 8
}

extension EntitySocialNetworkProfileIcon {
    fileprivate var assetName: String? {
        switch self {
        case .wikipedia:
            return "wikiepedia-w"
        case .facebook:
            return "facebook-share"
        case .twitter:
            return "twitter"
        case .instagram:
            return "instagram"
        case .linkedin:
            return "linkedin-share"
        case .imdb:
            return "imdb-square"
        case .pinterest:
            return "pinterest"
        case .youtube:
            return "youtube"
        case .rottentomatoes:
            return "rottentomatoes"
        case .crunchbase:
            return "crunchbase"
        default:
            return nil
        }
    }

    @ViewBuilder
    fileprivate func makeImage() -> some View {
        if let assetName = assetName {
            Image(assetName)
                .resizable()
        } else {
            Image(systemSymbol: .globe)
                .resizable()
        }
    }
}

private struct SocialButton: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let social: NeevaScopeSearch.RichEntityResult.SocialNetwork

    var body: some View {
        Button(
            action: {
                onOpenURLForCheatsheet(social.url, String(describing: Self.self))
            },
            label: {
                HStack {
                    social.icon.makeImage()
                        .scaledToFit()
                        .frame(
                            width: KnowledgeCardUX.socialIconSize,
                            height: KnowledgeCardUX.socialIconSize
                        )

                    Text(social.text)
                        .withFont(.bodyMedium)
                        .foregroundColor(.label)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, KnowledgeCardUX.buttonHPadding)
                .padding(.vertical, KnowledgeCardUX.buttonVPadding)
                .background(
                    Capsule()
                        .fill(Color.quaternarySystemFill)
                )
            }
        )

    }
}

private struct ReadMoreDescriptionView: View {
    @State private var expanded = false
    @State private var fullSize: CGFloat = 0
    @State private var limitedSize: CGFloat = 0
    private var truncated: Bool { limitedSize < fullSize }

    var text: String
    var lineLimit: Int
    var font: FontStyle = .bodyMedium
    var textColor: Color = .label

    var body: some View {
        VStack {
            Text(text)
                .withFont(font)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(expanded ? nil : lineLimit)
                .foregroundColor(textColor)
                .animation(.default, value: expanded)
            if truncated, !expanded {
                button
            }
        }
        .background(
            ZStack {
                // Read size of text when linelimit is applied
                Text(text)
                    .withFont(font)
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    self.limitedSize = proxy.size.height
                                }
                        }
                    )

                // read full size of text
                Text(text)
                    .withFont(font)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    self.fullSize = proxy.size.height
                                }
                        }
                    )
            }
            .hidden()
        )
    }

    @ViewBuilder
    var button: some View {
        Button(
            action: {
                expanded = true
            },
            label: {
                HStack {
                    Spacer()
                    Text("Read More")
                    Image(systemSymbol: .chevronDown)
                        .scaledToFit()
                    Spacer()
                }
                .foregroundColor(.label)
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.quaternarySystemFill)
                )
            }
        )
        .background(
            Rectangle()
                .fill(Color.DefaultBackground)
                .blur(radius: 20, opaque: false)
                .frame(height: 90)
        )
    }
}

struct KnowledgeCardView: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let richEntity: NeevaScopeSearch.RichEntityResult

    var socialMedia: [NeevaScopeSearch.RichEntityResult.SocialNetwork] {
        richEntity.socials + richEntity.secondarySocials
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading) {
                    Text(richEntity.title)
                        .withFont(.headingLarge)
                        .foregroundColor(.label)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle = richEntity.subtitle {
                        Text(subtitle)
                            .withFont(.bodyMedium)
                            .foregroundColor(.secondaryLabel)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
                if let imageURL = richEntity.imageURL {
                    WebImage(url: imageURL)
                        .placeholder {
                            Color.clear
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: KnowledgeCardUX.thumbnailSize,
                            height: KnowledgeCardUX.thumbnailSize,
                            alignment: .center
                        )
                        .cornerRadius(KnowledgeCardUX.thumbnailRadius)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(socialMedia, id: \.text) { social in
                        SocialButton(social: social)
                    }
                }
                .padding(.horizontal, CheatsheetUX.horizontalPadding)
            }
            .padding(.horizontal, -1 * CheatsheetUX.horizontalPadding)

            ReadMoreDescriptionView(text: richEntity.description, lineLimit: 4)

            Divider()
        }
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
    }
}
