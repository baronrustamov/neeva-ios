// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

enum SuggestionViewUX {
    static let ThumbnailSize: CGFloat = 36
    static let CornerRadius: CGFloat = 4
    static let Padding: CGFloat = 12
    static let DictionaryIconTopPadding: CGFloat = 5
    static let DictionaryLabelPadding: CGFloat = 5
    static let RowHeight: CGFloat = 58
    static let FaviconSize: CGFloat = 18
    static let IconSize: CGFloat = 20
    static let positiveStockColor = Color(hex: 0x028961)
    static let negativeStockColor = Color(hex: 0xD12E19)
}

enum SuggestionState {
    case normal
    case focused

    var color: Color {
        switch self {
        case .normal:
            return .clear
        case .focused:
            return .selectedCell
        }
    }
}

/// Renders a provided suggestion
public struct SearchSuggestionView: View {
    let suggestion: Suggestion

    public init(_ suggestion: Suggestion) {
        self.suggestion = suggestion
    }

    @ViewBuilder public var body: some View {
        switch suggestion {
        case .query(let suggestion):
            QuerySuggestionView(suggestion: suggestion)
        case .url(let suggestion):
            URLSuggestionView(suggestion: suggestion)
        case .bang(let suggestion):
            BangSuggestionView(suggestion: suggestion)
        case .lens(let suggestion):
            LensSuggestionView(suggestion: suggestion)
        case .navigation(let nav):
            NavSuggestionView(suggestion: nav)
        case .editCurrentURL(let tab):
            EditCurrentURLSuggestionView(suggestion: tab)
        case .tabSuggestion(let tab):
            TabSuggestionView(suggestion: tab)
        case .findInPage(let query):
            FindInPageSuggestionView(query: query)
        case .xyzQuery(let query):
            XYZQueryView(query: query)
        case .editCurrentQuery(let query, let url):
            EditCurrentQuerySuggestionView(suggestion: (query, url))
        }
    }
}

public enum SuggestionConfig {
    case row
    case dictionary
}

struct SuggestionSpec: ViewModifier {
    let config: SuggestionConfig
    var suggestionState: SuggestionState

    func body(content: Content) -> some View {
        switch config {
        case .row:
            content
                .frame(minHeight: SuggestionViewUX.RowHeight)
                .padding(.horizontal, SuggestionViewUX.Padding)
                .background(suggestionState.color)
                .hoverEffect()
        case .dictionary:
            content.padding(.horizontal, SuggestionViewUX.Padding)
                .padding(.top, SuggestionViewUX.Padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(suggestionState.color)
                .hoverEffect()
        }
    }
}

struct ClipShape: ViewModifier {
    let config: SuggestionConfig

    func body(content: Content) -> some View {
        switch config {
        case .row:
            content.clipped()
        case .dictionary:
            content.clipped()
        }
    }
}

extension View {
    fileprivate func apply(config: SuggestionConfig, suggestionState: SuggestionState) -> some View
    {
        self.modifier(SuggestionSpec(config: config, suggestionState: suggestionState))
    }
}

struct URLDisplayView: View {
    let url: URL

    @ViewBuilder public var body: some View {
        HStack(spacing: 0) {
            if let baseDomain = url.baseDomain {
                Text(baseDomain)
                    .withFont(.bodySmall)
                    .foregroundColor(.label)
                    .lineLimit(1)
                    .fixedSize()
            }
            if let pathDisplay = url.pathDisplay {
                Text(pathDisplay)
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
                    .lineLimit(1)
            }
        }
    }
}

struct SuggestionView<Icon: View, Label: View, SecondaryLabel: View, Detail: View>: View {
    let action: (() -> Void)?
    let icon: Icon
    let label: Label
    let secondaryLabel: SecondaryLabel
    let detail: Detail
    let suggestion: Suggestion?

    @State var suggestionState: SuggestionState = .normal
    @EnvironmentObject public var suggestionModel: SuggestionModel
    @Environment(\.suggestionConfig) private var config

    var body: some View {
        Button {
            if let suggestion = suggestion {
                suggestionModel.handleSuggestionSelected(suggestion)
            }

            action?()
        } label: {
            HStack(alignment: config == .dictionary ? .top : .center, spacing: 0) {
                icon.foregroundColor(.tertiaryLabel)
                    .frame(
                        width: SuggestionViewUX.IconSize,
                        height: SuggestionViewUX.IconSize
                    )
                    .unredacted()
                VStack(alignment: .leading, spacing: 0) {
                    label
                    secondaryLabel
                }.padding(
                    .leading,
                    SuggestionViewUX.Padding)
                if case .row = config {
                    Spacer(minLength: 0)
                    detail
                        .foregroundColor(.secondaryLabel)
                        .font(.callout)
                }
            }.apply(config: config, suggestionState: suggestionState)
        }
        .buttonStyle(.tableCell)
        .modifier(ClipShape(config: config))
        .accentColor(.primary)
        .useEffect(deps: suggestionModel.keyboardFocusedSuggestion) { _ in
            if let suggestion = suggestion, suggestionModel.isFocused(suggestion) {
                suggestionState = .focused
            } else {
                suggestionState = .normal
            }
        }
    }
}

/// Renders a query suggestion
struct QuerySuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.QuerySuggestion
    var isStockUp: Bool {
        suggestion.annotation?.isChangeInStockPricePositive() ?? false
    }

    @EnvironmentObject public var model: SuggestionModel
    @Environment(\.setSearchInput) private var setInput

    @ViewBuilder
    var dictionaryLabelView: some View {
        if let annotation = suggestion.annotation,
            let dictionaryInfo = suggestion.annotation?.dictionaryInfo
        {
            HStack(spacing: 0) {
                Text(dictionaryInfo.word ?? "")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)
                    .lineLimit(1)
                    .fixedSize()
                Text(
                    annotation.dictionarySupplementText()
                )
                .withFont(.bodySmall)
                .padding(.leading, SuggestionViewUX.DictionaryLabelPadding)
                .foregroundColor(.secondaryLabel)
                .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    var stockLabelView: some View {
        if let stockInfo = suggestion.annotation?.stockInfo {
            HStack {
                Text(String(stockInfo.currentPrice ?? 0.0))
                    .withFont(.bodyLarge)
                if let changeFromPreviousClose =
                    stockInfo.changeFromPreviousClose,
                    let percentChangeFromPreviousClose =
                        stockInfo.percentChangeFromPreviousClose
                {
                    Text(
                        (isStockUp ? "+" : "")
                            + String(changeFromPreviousClose)
                            + " (\(String(percentChangeFromPreviousClose))%)"
                    )
                    .withFont(.bodyMedium)
                    .accentColor(
                        isStockUp
                            ? SuggestionViewUX.positiveStockColor
                            : SuggestionViewUX.negativeStockColor
                    )
                }
                Spacer()
                Text(stockInfo.fetchedAtTime ?? "")
                    .withFont(.bodySmall)
                    .accentColor(.gray)
            }
            .lineLimit(1)
        }
    }

    var suggestedQuery: String {
        if let lensOrBang = model.activeLensBang,
            let shortcut = lensOrBang.shortcut,
            let sigil = lensOrBang.type?.sigil
        {
            return sigil + shortcut + " " + suggestion.suggestedQuery
        } else {
            return suggestion.suggestedQuery
        }
    }

    @ViewBuilder
    var icon: some View {
        if AnnotationType(annotation: suggestion.annotation) == .stock
            && suggestion.annotation?.stockInfo != nil
        {
            Symbol(decorative: isStockUp ? .arrowtriangleUpFill : .arrowtriangleDownFill)
                .foregroundColor(
                    isStockUp
                        ? SuggestionViewUX.positiveStockColor
                        : SuggestionViewUX.negativeStockColor
                )
                .padding(.bottom, 18)
        } else if AnnotationType(annotation: suggestion.annotation) == .calculator {
            Image("calculator")
        } else if let activeType = model.activeLensBang?.type {
            Symbol(decorative: activeType.defaultSymbol)
        } else if let annotation = suggestion.annotation, let imageUrl = annotation.imageUrl,
            AnnotationType(annotation: suggestion.annotation) == .wikipedia
        {
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .placeholder {
                    Color.tertiarySystemFill
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(SuggestionViewUX.CornerRadius)
                .frame(
                    width: SuggestionViewUX.ThumbnailSize,
                    height: SuggestionViewUX.ThumbnailSize
                )
        } else if AnnotationType(annotation: suggestion.annotation) == .dictionary
            && suggestion.annotation?.dictionaryInfo != nil
        {
            Image("icon-dictionary")
                .padding(.top, SuggestionViewUX.DictionaryIconTopPadding)
        } else {
            switch suggestion.type {
            case .searchHistory:
                Symbol(decorative: .clock)
            case .space:  // unused?
                SpaceIconView()
            case .standard:
                Symbol(decorative: .magnifyingglass)
            case .operator, .unknown, .__unknown(_):  // seemingly unused
                Symbol(decorative: .questionmarkCircle).foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    var label: some View {
        if AnnotationType(annotation: suggestion.annotation) == .stock
            && suggestion.annotation?.stockInfo != nil
        {
            stockLabelView
        } else if AnnotationType(annotation: suggestion.annotation) == .calculator {
            Text(suggestion.annotation?.description ?? "")
                .withFont(.bodyLarge)
                .lineLimit(1)
        } else if AnnotationType(annotation: suggestion.annotation) == .wikipedia {
            Text(suggestion.suggestedQuery.capitalized)
                .withFont(.bodyLarge)
                .lineLimit(1)
        } else if AnnotationType(annotation: suggestion.annotation) == .dictionary
            && suggestion.annotation?.dictionaryInfo != nil
        {
            dictionaryLabelView
        } else {
            Text(suggestion.suggestedQuery)
                .withFont(.bodyLarge)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        if AnnotationType(annotation: suggestion.annotation) == .stock
            && suggestion.annotation?.stockInfo != nil
        {
            HStack {
                Text("\(String(suggestion.annotation?.stockInfo?.companyName ?? ""))")
                    .withFont(.bodySmall)
                    .lineLimit(1)
                Text("\(String(suggestion.annotation?.stockInfo?.ticker ?? ""))")
                    .withFont(.bodySmall)
                    .lineLimit(1)
                    .accentColor(.gray)
            }
        } else if let suggestedCalculatorQuery = suggestion.suggestedCalculatorQuery(),
            AnnotationType(annotation: suggestion.annotation) == .calculator
        {
            Text(suggestedCalculatorQuery).withFont(.bodySmall)
                .foregroundColor(.secondaryLabel).lineLimit(1)
        } else if let annotation = suggestion.annotation, let description = annotation.description,
            AnnotationType(annotation: suggestion.annotation) == .wikipedia
        {
            Text(description).withFont(.bodySmall)
                .foregroundColor(.secondaryLabel).lineLimit(1)
        } else if AnnotationType(annotation: suggestion.annotation) == .dictionary
            && suggestion.annotation?.dictionaryInfo != nil
        {
            Text(suggestion.annotation?.dictionaryInfo?.shortDefinition ?? "").withFont(.bodySmall)
                .foregroundColor(.secondaryLabel).lineLimit(3)
        } else {
            EmptyView()
        }

    }

    @ViewBuilder
    var detail: some View {
        if suggestion.type != .space
            && AnnotationType(annotation: suggestion.annotation) != .calculator
            && suggestion.annotation?.stockInfo == nil
        {
            Button(action: { setInput(suggestedQuery) }) {
                Symbol(decorative: .arrowUpLeft)
                    .foregroundColor(.tertiaryLabel)
            }.buttonStyle(.borderless)
        } else if AnnotationType(annotation: suggestion.annotation) == .calculator {
            Button {
                copySuggestion(
                    value: suggestion.annotation?.description ?? "",
                    scene: model.bvc.tabManager.scene)
            } label: {
                Symbol(decorative: .docOnDoc)
            }
        }
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: detail,
            suggestion: Suggestion.query(suggestion)
        )
        .environmentObject(model)
    }
}

/// Renders a URL suggestion (and its associated icon)
struct URLSuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion

    @EnvironmentObject public var model: SuggestionModel

    @ViewBuilder
    var icon: some View {
        if let labels = suggestion.icon.labels,
            let image = Image(icons: labels)
        {
            image
        } else if let subtitle = suggestion.subtitle, !subtitle.isEmpty,
            let url = URL(string: suggestion.suggestedUrl)
        {
            FaviconView(forSiteUrl: url)
                .frame(width: SuggestionViewUX.FaviconSize, height: SuggestionViewUX.FaviconSize)
                .roundedOuterBorder(
                    cornerRadius: SuggestionViewUX.CornerRadius, color: .quaternarySystemFill)
        } else {
            Symbol(decorative: .questionmarkDiamondFill)
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    var label: some View {
        if let subtitle = suggestion.subtitle, !subtitle.isEmpty {
            Text(subtitle).withFont(.bodyLarge).foregroundColor(.primary).lineLimit(1)
        } else if let title = suggestion.title {
            Text(title).withFont(.bodyLarge).lineLimit(1)
        } else {
            Text(suggestion.suggestedUrl).withFont(.bodyLarge).lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        if !(suggestion.subtitle?.isEmpty ?? true) {
            if let url = URL(string: suggestion.suggestedUrl) {
                URLDisplayView(url: url)
            } else if let title = suggestion.title {
                Text(title)
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel).lineLimit(1)
            }
        }
    }

    @ViewBuilder
    var detail: some View {
        if let formatted = format(suggestion.timestamp, as: .full) {
            Text(formatted)
        }
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: detail,
            suggestion: Suggestion.url(suggestion)
        )
        .environmentObject(model)
    }
}

private struct BangSuggestionView: View {
    let suggestion: Suggestion.Bang

    @EnvironmentObject public var model: SuggestionModel

    var body: some View {
        SuggestionView(
            action: nil,
            icon: Symbol(decorative: ActiveLensBangType.bang.defaultSymbol),
            label: Text("!\(suggestion.shortcut)"),
            secondaryLabel: EmptyView(),
            detail: Text(suggestion.description),
            suggestion: Suggestion.bang(suggestion)
        )
        .environmentObject(model)
    }
}

private struct LensSuggestionView: View {
    let suggestion: Suggestion.Lens

    @EnvironmentObject public var model: SuggestionModel

    var body: some View {
        SuggestionView(
            action: nil,
            icon: Symbol(decorative: ActiveLensBangType.lens.defaultSymbol),
            label: Text("@\(suggestion.shortcut)"),
            secondaryLabel: EmptyView(),
            detail: Text(suggestion.description),
            suggestion: Suggestion.lens(suggestion)
        )
        .environmentObject(model)
    }
}

private struct TabSuggestionView: View {
    let suggestion: TabCardDetails

    @EnvironmentObject public var model: SuggestionModel

    @ViewBuilder
    var icon: some View {
        if !suggestion.isSelected {
            Symbol(decorative: .squareOnSquare)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        Text(
            suggestion.isSelected
                ? suggestion.url?.absoluteString ?? ""
                : suggestion.title
        )
        .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: Text(
                suggestion.isSelected ? suggestion.title : "Switch to Tab"),
            secondaryLabel: secondaryLabel,
            detail: EmptyView(),
            suggestion: Suggestion.tabSuggestion(suggestion)
        )
        .environmentObject(model)
    }
}

private struct EditCurrentURLSuggestionView: View {
    let suggestion: TabCardDetails

    func copy() {
        copySuggestion(value: suggestion.url?.absoluteString, scene: suggestion.manager.scene)
    }

    var url: URL? {
        let url = suggestion.url

        if let originalURL = url?.decodeReaderModeURL {
            return originalURL
        }

        return InternalURL.isValid(url: url)
            ? InternalURL(url)?.originalURLFromErrorPage : suggestion.url
    }

    @EnvironmentObject public var model: SuggestionModel

    var icon: some View {
        suggestion.favicon
            .frame(
                width: SuggestionViewUX.FaviconSize,
                height: SuggestionViewUX.FaviconSize
            )
            .roundedOuterBorder(
                cornerRadius: SuggestionViewUX.CornerRadius, color: .quaternarySystemFill)
    }

    var label: some View {
        Text("Edit current address")
            .withFont(.bodyLarge).foregroundColor(.label).lineLimit(1)
    }

    var secondaryLabel: some View {
        Text(url?.absoluteString ?? "")
            .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
    }

    var copyBotton: some View {
        Button {
            copy()
        } label: {
            Symbol(decorative: .docOnDoc)
        }
    }

    var menuItems: some View {
        Group {
            Button {
                copy()
            } label: {
                Label("Copy Address", systemSymbol: .link)
            }

            Button {
                let tabManager = suggestion.manager
                let bvc = SceneDelegate.getBVC(with: tabManager.scene)

                guard
                    let tab = tabManager.selectedTab,
                    let url = suggestion.url
                else { return }

                if url.isFileURL {
                    bvc.share(
                        fileURL: url, buttonView: UIHostingController(rootView: self).view,
                        presentableVC: bvc)
                } else {
                    bvc.share(
                        tab: tab, from: UIHostingController(rootView: self).view, presentableVC: bvc
                    )
                }
            } label: {
                Label("Share", systemSymbol: .squareAndArrowUp)
            }
        }
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: copyBotton,
            suggestion: Suggestion.editCurrentURL(suggestion)
        )
        .environmentObject(model)
        .contextMenu { menuItems }
        .accessibility(label: Text("Edit current address"))
    }
}

private struct EditCurrentQuerySuggestionView: View {
    let suggestion: (String, URL)

    @EnvironmentObject public var model: SuggestionModel

    var favicon: some View {
        Image("neevaMenuIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: SuggestionViewUX.IconSize, height: SuggestionViewUX.IconSize)
    }

    var label: some View {
        Text("Edit current search")
            .withFont(.bodyLarge).foregroundColor(.label).lineLimit(1)
    }

    var secondaryLabel: some View {
        Text(suggestion.0)
            .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: favicon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: Symbol(decorative: .arrowUpLeft),
            suggestion: Suggestion.editCurrentQuery(suggestion.0, suggestion.1)
        )
        .environmentObject(model)
        .accessibility(label: Text("Edit current search"))
    }
}

private struct FindInPageSuggestionView: View {
    let query: String

    @State var focused: Bool = false
    @EnvironmentObject public var model: SuggestionModel

    var label: some View {
        Text("Find on Page")
            .withFont(.bodyLarge)
            .lineLimit(1)
    }

    var secondaryLabel: some View {
        Text(query)
            .withFont(.bodySmall)
            .foregroundColor(.secondaryLabel)
            .lineLimit(1)
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: Symbol(decorative: .docTextMagnifyingglass),
            label: label,
            secondaryLabel: secondaryLabel,
            detail: EmptyView(),
            suggestion: Suggestion.findInPage(query)
        )
        .environmentObject(model)
    }
}

private struct XYZQueryView: View {
    let query: String

    @State var focused: Bool = false
    @EnvironmentObject public var model: SuggestionModel

    var label: some View {
        Text(query)
            .withFont(.bodyLarge)
            .lineLimit(1)
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: Symbol(decorative: .magnifyingglass),
            label: label,
            secondaryLabel: EmptyView(),
            detail: EmptyView(),
            suggestion: Suggestion.xyzQuery(query)
        )
        .environmentObject(model)
    }
}

func copySuggestion(value: String?, scene: UIScene) {
    UIPasteboard.general.string = value

    let toastManager = SceneDelegate.getBVC(with: scene).toastViewManager
    toastManager.makeToast(text: "Copied to clipboard").enqueue(manager: toastManager)
}

struct SuggestionView_Previews: PreviewProvider {
    static let query =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: "neeva",
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .bing
        )
    static let historyQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .searchHistory,
            suggestedQuery: "swift set sysroot",
            boldSpan: [
                .init(startInclusive: 6, endExclusive: 9),
                .init(startInclusive: 12, endExclusive: 15),
            ],
            source: .elastic
        )
    static let spaceQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .space,
            suggestedQuery: "SavedForLater",
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .elastic
        )

    static let url =
        SuggestionsQuery.Data.Suggest.UrlSuggestion(
            icon: .init(labels: ["google-email", "email"]),
            suggestedUrl: "https://mail.google.com/mail/u/jed@neeva.co/#inbox/1766c8357ae540a5",
            title: "How was your Neeva onboarding?",
            author: "feedback@neeva.co",
            timestamp: "2020-12-16T17:05:12Z",
            boldSpan: [.init(startInclusive: 13, endExclusive: 29)]
        )

    static let bang = Suggestion.Bang(
        shortcut: "w",
        description: "Wikipedia",
        domain: "wikipedia.org"
    )

    static let logoBang = Suggestion.Bang(
        shortcut: "imdb",
        description: "IMDb",
        domain: "imdb.com"
    )

    static let noDomainBang = Suggestion.Bang(
        shortcut: "zillow",
        description: "Zillow",
        domain: nil
    )

    static let lens = Suggestion.Lens(
        shortcut: "my",
        description: "Search my personal data"
    )

    static var previews: some View {
        let bvc = SceneDelegate.getBVC(for: nil)

        List {
            Section(header: Text("Query").textCase(nil)) {
                QuerySuggestionView(suggestion: spaceQuery)
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(SuggestionModel(bvc: bvc))

            Section(header: Text("Query — Bang active").textCase(nil)) {
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(
                SuggestionModel(
                    bvc: bvc,
                    previewLensBang: .init(
                        domain: nil, shortcut: "w", description: "Wikipedia", type: .bang)))

            Section(header: Text("Query — Lens active").textCase(nil)) {
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(
                SuggestionModel(
                    bvc: bvc,
                    previewLensBang: .init(
                        domain: nil, shortcut: "w", description: "Wikipedia", type: .lens)))

            Section(header: Text("URL, Bang, and Lens").textCase(nil)) {
                URLSuggestionView(suggestion: url)
                BangSuggestionView(suggestion: bang)
                BangSuggestionView(suggestion: noDomainBang)
                LensSuggestionView(suggestion: lens)
            }
        }
        .environment(\.setSearchInput) { _ in }
    }
}
