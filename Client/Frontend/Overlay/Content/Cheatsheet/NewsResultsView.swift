//
//  NewsResultsView.swift
//  Client
//
//  Created by Edward Luo on 2022-03-12.
//  Copyright © 2022 Neeva. All rights reserved.
//

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct NewsResultsView: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let newsResults: NeevaScopeSearch.NewsResults

    var newsQueryURL: URL? {
        let components = URLComponents(url: newsResults.actionURL, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.percentEncodedQueryItems,
            let query = queryItems.first(where: { $0.name == "q" })?.value
        else {
            return URL(string: "\(NeevaConstants.appSearchURL)?q=\(newsResults.title ?? "")")
        }
        return URL(string: "\(NeevaConstants.appSearchURL)?q=\(query)&c=News")
    }

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                if let newsQueryURL = newsQueryURL {
                    onOpenURLForCheatsheet(newsQueryURL, String(describing: Self.self))
                }
            }) {
                HStack(alignment: .center) {
                    Text("Related News")
                        .withFont(.headingXLarge)
                        .foregroundColor(.label)
                    Symbol(decorative: .arrowUpForward)
                        .foregroundColor(.label)
                        .frame(width: 18, height: 18, alignment: .center)
                }
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(newsResults.news, id: \.url) { news in
                        NewsResultItemView(newsItem: news)
                    }
                }
            }
        }
    }
}

struct NewsResultItemView: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let newsItem: NeevaScopeSearch.NewsResult

    let cornerRadius: CGFloat = 11
    let thumbnailSize = CGSize(width: 175, height: 100)
    let faviconSize = CGSize(width: 16, height: 16)
    let horizontalPadding: CGFloat = 12
    let size = CGSize(width: 175, height: 280)

    var body: some View {
        Button(action: openNews) {
            VStack(alignment: .leading) {
                WebImage(url: URL(string: newsItem.thumbnailURL))
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: thumbnailSize.width, height: thumbnailSize.height, alignment: .center
                    )
                    .clipped()
                    .cornerRadius(cornerRadius, corners: .top)

                VStack(alignment: .leading) {
                    Text(newsItem.title)
                        .withFont(.headingMedium)
                        .foregroundColor(Color.label)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(newsItem.snippet)
                        .withFont(unkerned: .bodyMedium)
                        .foregroundColor(Color.ui.gray30)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, horizontalPadding)

                Spacer()

                if let provider = newsItem.provider.name ?? newsItem.provider.site {
                    HStack(alignment: .center) {
                        Group {
                            if let faviconURLString = newsItem.faviconURL,
                                let faviconURL = URL(string: faviconURLString)
                            {
                                WebImage(url: faviconURL)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                FaviconView(forSiteUrl: newsItem.url)
                            }
                        }
                        .frame(
                            width: faviconSize.width, height: faviconSize.height, alignment: .center
                        )
                        .clipShape(Circle())

                        Text(provider)
                            .withFont(.bodySmall)
                            .lineLimit(1)
                            .foregroundColor(Color.label)
                    }
                    .padding(.horizontal, horizontalPadding)
                }
            }
            .padding(.bottom, 10)
            .frame(width: size.width, height: size.height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(light: Color.ui.gray91, dark: Color(hex: 0x383b3f)), lineWidth: 1)
            )
        }
    }

    func openNews() {
        onOpenURLForCheatsheet(newsItem.url, String(describing: Self.self))
    }
}
