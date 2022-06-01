// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

private let subRedditNameMatcher = try! NSRegularExpression(
    pattern: #"/r/(?<subreddit>[a-zA-Z0-9_]{1,21})/"#,
    options: []
)

struct RedditDiscussion: Identifiable {
    let title: String
    let snippet: String
    let url: URL
    let slash: String

    // Identifiable by URL
    var id: URL { url }

    init?(from backlink: CheatsheetInfoQuery.Data.GetCheatsheetInfo.BacklinkUrl) {
        guard backlink.domain == "www.reddit.com",
            let urlString = backlink.url,
            let url = URL(string: urlString),
            let title = backlink.title,
            let snippet = backlink.snippet
        else {
            return nil
        }

        // extract r/
        guard
            let match = subRedditNameMatcher.matches(
                in: url.path,
                range: NSRange(url.path.startIndex..., in: url.path)
            ).first,
            let extractedRange = Range(match.range(withName: "subreddit"), in: url.path)
        else {
            return nil
        }

        self.title = title
        self.snippet = snippet
        self.url = url
        self.slash = #"r/"# + String(url.path[extractedRange])
    }
}

struct UGCDiscussion {
    var redditDiscussions: [RedditDiscussion] = []

    var isEmpty: Bool {
        redditDiscussions.isEmpty
    }

    init(backlinks: [CheatsheetInfoQuery.Data.GetCheatsheetInfo.BacklinkUrl]?) {
        guard let backlinks = backlinks else {
            return
        }
        redditDiscussions = backlinks.compactMap { RedditDiscussion(from: $0) }
    }
}

struct UGCDiscussionView: View {
    enum UX {
        static let numCollapsed: Int = 2
        static let buttonHeight: CGFloat = 48
        static let chevronSize: CGFloat = 16
    }

    @State var showAllReddit: Bool

    let discussions: UGCDiscussion

    var redditNumDisplayed: Int {
        showAllReddit ? discussions.redditDiscussions.count : UX.numCollapsed
    }

    init(_ discussions: UGCDiscussion) {
        self.discussions = discussions
        // if contains no more than number of elements in collapsed state, default to showing all
        _showAllReddit = State(initialValue: discussions.redditDiscussions.count <= UX.numCollapsed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discussions").withFont(.headingXLarge)

            redditDiscussions

            if !showAllReddit {
                toggleShowAllButton
            }
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    var redditDiscussions: some View {
        ForEach(discussions.redditDiscussions.prefix(redditNumDisplayed)) { discussion in
            RedditDiscussionView(discussion: discussion)
        }
    }

    @ViewBuilder
    var toggleShowAllButton: some View {
        Button(
            action: {
                showAllReddit.toggle()
            },
            label: {
                HStack(alignment: .center) {
                    Text("Show More Discussions")
                    Image(systemSymbol: .chevronDown)
                        .renderingMode(.template)
                        .font(.system(size: UX.chevronSize))
                }
                .withFont(unkerned: .bodyLarge)
                .frame(maxWidth: .infinity, minHeight: UX.buttonHeight)
                .foregroundColor(Color.label)
                .background(Capsule().fill(Color.ui.quarternary))
            })
    }
}

private struct RedditDiscussionView: View {
    let discussion: RedditDiscussion

    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 6) {
                Image("reddit-logo")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(discussion.slash)
                    .withFont(.labelMedium)
                    .foregroundColor(.label)
            }
            Text(discussion.title)
                .withFont(.headingMedium)
                .foregroundColor(.label)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            ReadMoreTextView(text: discussion.snippet, lineLimit: 3)
        }
        .foregroundColor(.label)
        .onTapGesture {
            onOpenURLForCheatsheet(discussion.url, String(describing: Self.self))
        }
    }
}

private struct ReadMoreTextView: View {
    @State private var expanded = false
    @State private var fullSize: CGFloat = 0
    @State private var limitedSize: CGFloat = 0
    private var truncated: Bool { limitedSize < fullSize }

    var text: String
    var lineLimit: Int
    var font: FontStyle = .bodyMedium
    var textColor: Color = .label

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(text)
                .withFont(font)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(expanded ? nil : lineLimit)
                .foregroundColor(textColor)
                .animation(.default, value: expanded)
            if truncated, !expanded {
                Button("Read More") {
                    expanded = true
                }
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
}
