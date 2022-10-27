// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

private let subRedditNameMatcher = try! NSRegularExpression(
    pattern: #"/r/(?<subreddit>[a-zA-Z0-9_]{1,21})/"#,
    options: []
)

extension String {
    fileprivate func trimmingPrefix<T: StringProtocol>(_ prefix: T) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        return String(dropFirst(prefix.count))
    }
}

struct RedditDiscussion: Identifiable {
    struct RedditComment: Identifiable {
        static let filteredStrings: Set<String> = [
            "[removed]", "[deleted]",
        ]
        let body: String
        let url: URL?
        let upvotes: Int?

        let id = UUID()

        init?(from comment: CheatsheetQueryController.Backlink.Comment) {
            guard comment.body.isNotBlank,
                !Self.filteredStrings.contains(comment.body)
            else {
                return nil
            }

            self.body = comment.body.tryRemovingHTMLencoding(strict: true)
            self.url = comment.url
            self.upvotes = comment.score
        }
    }

    enum Content {
        case body(String)
        case comments([RedditComment])
    }

    static let filteredBodyStrings: Set<String> = [
        "[removed]", "[deleted]",
    ]

    // Required Properties
    let title: String
    let content: Content
    let url: URL
    let slash: String

    // Optionally Displayed Properties
    let upvotes: Int?
    let numComments: Int?
    let interval: String?

    // Identifiable by URL
    var id: URL { url }

    init?(from backlink: CheatsheetQueryController.Backlink) {
        guard let domain = backlink.domain?.trimmingPrefix("www."),
            domain == "reddit.com"
        else {
            return nil
        }

        // Extract displayed cotent
        // if have comments, show comments
        if let filteredComments = backlink.comments?.compactMap({ RedditComment(from: $0) }),
            !filteredComments.isEmpty
        {
            self.content = .comments(Array(filteredComments.prefix(10)))
        } else if let body = backlink.snippet?.tryRemovingHTMLencoding(strict: true),
            body.isNotBlank,
            !Self.filteredBodyStrings.contains(body)
        {
            // else, show body snippet
            self.content = .body(body)
        } else {
            return nil
        }

        // extract r/
        guard
            let match = subRedditNameMatcher.matches(
                in: backlink.url.path,
                range: NSRange(backlink.url.path.startIndex..., in: backlink.url.path)
            ).first,
            let extractedRange = Range(match.range(withName: "subreddit"), in: backlink.url.path)
        else {
            return nil
        }

        self.title = backlink.title.tryRemovingHTMLencoding(strict: true)
        self.url = backlink.url
        self.slash = #"r/"# + String(url.path[extractedRange])

        self.upvotes = backlink.score
        self.numComments = backlink.numComments

        self.interval = {
            guard let date = backlink.date else {
                return nil
            }

            return Self.localizedDateFormatter(date)
        }()
    }

    private static let shortDateFormatter: (Date) -> String? = {
        let dcFormatter = DateComponentsFormatter()
        dcFormatter.maximumUnitCount = 1
        dcFormatter.unitsStyle = .abbreviated
        return { date -> String? in
            let interval = abs(date.timeIntervalSinceNow)
            return dcFormatter.string(from: interval)
        }
    }()

    private static let localizedDateFormatter: (Date) -> String = {
        let rdtFormatter = RelativeDateTimeFormatter()
        rdtFormatter.dateTimeStyle = .named
        rdtFormatter.unitsStyle = .short
        // default local is autoupdatingCurrent
        return { date -> String in
            rdtFormatter.localizedString(fromTimeInterval: date.timeIntervalSinceNow)
        }
    }()
}

struct UGCDiscussion {
    var redditDiscussions: [RedditDiscussion] = []

    var isEmpty: Bool {
        redditDiscussions.isEmpty
    }

    init(backlinks: [CheatsheetQueryController.Backlink]?) {
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
        .padding(.bottom, 12)
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
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
    enum UXConst {
        static let postVSpacing: CGFloat = 4
        static let headerVSpacing: CGFloat = 4
        static let metadataHSpacing: CGFloat = 6
        static let metadataInnerHSpacing: CGFloat = 4
        static let commentSpacing: CGFloat = 16
        static let commentRowMinHeight: CGFloat = 102
    }
    let discussion: RedditDiscussion

    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    // Properties for expanding/collapsing body
    @State var expanded: Bool = false
    @State var truncated: Bool = false

    var showMoreCommentsButton: Bool {
        if let numComments = discussion.numComments,
            case .comments(let comments) = discussion.content,
            numComments > comments.count
        {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: UXConst.postVSpacing) {
            header

            switch discussion.content {
            case .body(let body):
                ZStack(alignment: .bottomTrailing) {
                    ReadMoreTextView(
                        body, limit: .lines(3), expanded: $expanded, truncated: $truncated
                    )
                    if truncated {
                        Button(expanded ? "Read Less" : "Read More") {
                            withAnimation {
                                expanded.toggle()
                            }
                        }
                        .withFont(unkerned: .bodyMedium)
                        .padding(.leading)
                        .background(Color.background)
                    }
                }
            case .comments(let comments):
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: UXConst.commentSpacing) {
                        HStack(alignment: .top, spacing: UXConst.commentSpacing) {
                            ForEach(comments) { comment in
                                RedditCommentView(comment: comment, fallbackURL: discussion.url)
                            }
                        }

                        if showMoreCommentsButton {
                            VStack {
                                Spacer()
                                MoreCommentsButton(url: discussion.url)
                                Spacer()
                            }
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.horizontal, CheatsheetUX.horizontalPadding)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, -1 * CheatsheetUX.horizontalPadding)
            }
        }
        .onTapGesture {
            onOpenURLForCheatsheet(discussion.url, String(describing: Self.self))
        }
    }

    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading, spacing: UXConst.headerVSpacing) {
            metadataHeader

            Text(discussion.title)
                .withFont(.headingMedium)
                .foregroundColor(.label)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var metadataHeader: some View {
        HStack(alignment: .center, spacing: UXConst.metadataHSpacing) {
            Image("reddit-logo")
                .resizable()
                .frame(width: 20, height: 20)
            Text(discussion.slash)
                .withFont(.labelMedium)
                .foregroundColor(.label)
            Group {
                if let upvotes = discussion.upvotes {
                    Text(" · ")
                    HStack(alignment: .center, spacing: UXConst.metadataInnerHSpacing) {
                        Image(systemSymbol: .arrowUp)
                        Text("\(upvotes)")
                    }
                }

                if let numComments = discussion.numComments {
                    Text(" · ")
                    HStack(alignment: .center, spacing: UXConst.metadataInnerHSpacing) {
                        Image(systemSymbol: .bubbleRight)
                        Text("\(numComments)")
                    }
                }

                if let interval = discussion.interval {
                    Text(" · ")
                    Text(interval)
                }
            }
            .withFont(unkerned: .bodySmall)
            .foregroundColor(.secondaryLabel)
        }
    }
}

private struct RedditCommentView: View {
    enum UXConst {
        static let leadingPadding: CGFloat = 12
        static let vSpacing: CGFloat = 0
        static let metadataHSpacing: CGFloat = 6
        static let metadataInnerHSpacing: CGFloat = 4
        static let totalWidth: CGFloat = 312
        static let totalHeight: CGFloat = 140
        static let bottomRowHeight: CGFloat = 30
        static let lineWidth: CGFloat = 2

        static var textCollapsedHeight: CGFloat {
            totalHeight - bottomRowHeight - UXConst.vSpacing
        }
    }

    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    @State var expanded: Bool = false
    @State var truncated: Bool = false

    let comment: RedditDiscussion.RedditComment
    let fallbackURL: URL

    var hasMetadata: Bool {
        // need to add replies in the future
        comment.upvotes != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: UXConst.vSpacing) {
            ReadMoreTextView(
                comment.body,
                limit: .height(UXConst.textCollapsedHeight),
                expanded: $expanded,
                truncated: $truncated
            )

            HStack {
                if hasMetadata {
                    metadataFooter
                }

                Spacer()

                if truncated {
                    Button(expanded ? "Read Less" : "Read More") {
                        withAnimation {
                            expanded.toggle()
                        }
                    }
                    .withFont(unkerned: .bodyMedium)
                }
            }
            .frame(height: UXConst.bottomRowHeight)
        }
        .padding(.leading, UXConst.leadingPadding)
        .frame(
            idealWidth: UXConst.totalWidth, minHeight: UXConst.totalHeight, alignment: .topLeading
        )
        .onTapGesture {
            onOpenURLForCheatsheet(comment.url ?? fallbackURL, String(describing: Self.self))
        }
        .overlay(
            Rectangle()
                .frame(width: UXConst.lineWidth, height: nil, alignment: .leading)
                .foregroundColor(.ui.adaptive.separator),
            alignment: .leading
        )
    }

    @ViewBuilder
    var metadataFooter: some View {
        HStack(alignment: .center, spacing: UXConst.metadataHSpacing) {
            if let upvotes = comment.upvotes {
                HStack(alignment: .center, spacing: UXConst.metadataInnerHSpacing) {
                    Image(systemSymbol: .arrowUp)
                    Text("\(upvotes)")
                }
            }
            // need to add replies in the future
        }
        .withFont(unkerned: .bodySmall)
        .foregroundColor(.secondaryLabel)
    }
}

private struct MoreCommentsButton: View {
    enum UXConst {
        static let hSpacing: CGFloat = 6
        static let leadingPadding: CGFloat = 11
        static let trailingPadding: CGFloat = 13
        static let vPadding: CGFloat = 8
    }
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let url: URL

    var body: some View {
        Button(
            action: {
                onOpenURLForCheatsheet(url, String(describing: Self.self))
            },
            label: {
                HStack(alignment: .center, spacing: UXConst.hSpacing) {
                    Group {
                        Text("More Comments")
                        Image(systemSymbol: .arrowUpRight)
                    }
                    .withFont(unkerned: .bodyMedium)
                    .foregroundColor(.label)
                }
                .padding(.leading, UXConst.leadingPadding)
                .padding(.trailing, UXConst.trailingPadding)
                .padding(.vertical, UXConst.vPadding)
                .background(
                    Capsule()
                        .stroke(Color.secondarySystemFill, lineWidth: 1)
                )
            })
    }
}

private struct ReadMoreTextView: View {
    enum Limit {
        case lines(Int)
        case height(CGFloat)
    }

    @State private var fullSize: CGFloat = 0
    @State private var limitedSize: CGFloat = 0

    @Binding var expanded: Bool
    @Binding var truncated: Bool

    let text: String
    let limit: Limit
    let font: FontStyle
    let textColor: Color

    init(
        _ text: String,
        limit: Limit,
        expanded: Binding<Bool>,
        truncated: Binding<Bool>,
        font: FontStyle = .bodyMedium,
        textColor: Color = .label
    ) {
        self.text = text
        self.limit = limit
        self._expanded = expanded
        self._truncated = truncated
        self.font = font
        self.textColor = textColor

        if case let .height(height) = limit {
            self._limitedSize = State(initialValue: height)
        }
    }

    var body: some View {
        limitedTextView
            .fixedSize(horizontal: false, vertical: true)
            .background(
                ZStack {
                    if case let .lines(lineLimit) = limit {
                        TextHeightReader(
                            height: $limitedSize,
                            content: Text(text),
                            font: font,
                            lineLimit: lineLimit
                        )
                    }

                    // read full size of text
                    TextHeightReader(
                        height: $fullSize, content: Text(text), font: font, lineLimit: nil
                    )
                }
                .hidden()
            )
            .onChange(of: fullSize) { _ in
                self.updatedTruncated()
            }
            .onChange(of: limitedSize) { _ in
                self.updatedTruncated()
            }
    }

    @ViewBuilder
    var limitedTextView: some View {
        Group {
            switch limit {
            case .lines(let lineLimit):
                textView
                    .lineLimit(expanded ? nil : lineLimit)
            case .height(let height):
                textView
                    .frame(height: expanded ? fullSize : height, alignment: .topLeading)
            }
        }
    }

    @ViewBuilder
    var textView: some View {
        Text(text)
            .withFont(font)
            .multilineTextAlignment(.leading)
            .foregroundColor(textColor)
            .animation(.default, value: expanded)
    }

    private func updatedTruncated() {
        truncated = limitedSize < fullSize
    }
}

private struct TextHeightReader: View {
    @Binding var height: CGFloat
    let content: Text
    let font: FontStyle
    let lineLimit: Int?

    var body: some View {
        content
            .withFont(font)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            self.height = proxy.size.height
                        }
                }
            )
    }
}
