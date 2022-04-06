// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import Storage
import SwiftUI

private enum TriState: Int, Codable {
    case hidden
    case compact
    case expanded

    var verb: String {
        switch self {
        case .hidden: return "shows"
        case .compact: return "expands"
        case .expanded: return "hides"
        }
    }

    var icon: Nicon {
        switch self {
        case .hidden: return .chevronDown
        case .compact: return .doubleChevronDown
        case .expanded: return .chevronUp
        }
    }

    var next: TriState {
        switch self {
        case .hidden: return .compact
        case .compact: return .expanded
        case .expanded: return .hidden
        }
    }

    mutating func advance() {
        self = self.next
    }
}

extension EnvironmentValues {
    private struct ZeroQueryWidthKey: EnvironmentKey {
        static let defaultValue: CGFloat = 0
    }
    /// The width of the zero query view, in points.
    var zeroQueryWidth: CGFloat {
        get { self[ZeroQueryWidthKey.self] }
        set { self[ZeroQueryWidthKey.self] = newValue }
    }
}

extension Defaults.Keys {
    fileprivate static let expandSuggestedSites = Defaults.Key<TriState>(
        "profile.home.suggestedSites.expanded",
        default: NeevaConstants.currentTarget == .xyz ? .expanded : .compact
    )
    fileprivate static let expandSearches = Defaults.Key<Bool>(
        "profile.home.searches.expanded", default: true)
    fileprivate static let expandSpaces = Defaults.Key<Bool>(
        "profile.home.spaces.expanded", default: true)
    fileprivate static let expandSuggestedSpace = Defaults.Key<Bool>(
        "profile.home.suggestedSpace.expanded", default: true)
}

struct ZeroQueryView: View {
    @EnvironmentObject var viewModel: ZeroQueryModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Default(.expandSuggestedSites) private var expandSuggestedSites
    @Default(.expandSearches) private var expandSearches
    @Default(.expandSpaces) private var expandSpaces
    @Default(.expandSuggestedSpace) private var expandSuggestedSpace
    @Default(.cryptoPublicKey) private var cryptoPublicKey: String

    @State var url: URL?
    @State var tab: Tab?

    func ratingsCard(_ viewWidth: CGFloat) -> some View {
        RatingsCard(
            onClose: {
                viewModel.showRatingsCard = false
                Defaults[.ratingsCardHidden] = true
                UserFlagStore.shared.setFlag(
                    .dismissedRatingPromo,
                    action: {})
            },
            onFeedback: {
                showFeedbackPanel(bvc: viewModel.bvc, shareURL: false)
            },
            viewWidth: viewWidth
        )
        .modifier(
            ImpressionLoggerModifier(
                path: .PromoCardAppear,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + [
                        ClientLogCounterAttribute(
                            key: LogConfig.PromoCardAttribute
                                .promoCardType,
                            value: "RatingCard"
                        )
                    ]
            )
        )
    }

    func isLandScape() -> Bool {
        return horizontalSizeClass == .regular
            || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }

    var suggestedSpace: some View {
        RecommendedSpacesView(
            store: SpaceStore.suggested,
            viewModel: viewModel,
            expandSuggestedSpace: $expandSuggestedSpace
        )
    }

    var body: some View {
        GeometryReader { geom in
            ScrollView {
                VStack(spacing: 0) {
                    queryView
                    if viewModel.isIncognito {
                        IncognitoDescriptionView().clipShape(RoundedRectangle(cornerRadius: 12.0))
                            .padding(ZeroQueryUX.Padding)
                    } else {
                        contentView(geom)
                    }
                    Spacer()
                }
            }
            .environment(\.zeroQueryWidth, geom.size.width)
            .animation(nil)
            .onAppear {
                url = viewModel.tabURL
                tab = viewModel.openedFrom?.openedTab
            }
        }
    }

    @ViewBuilder
    private func contentView(_ parentGeom: GeometryProxy) -> some View {
        if NeevaConstants.currentTarget == .xyz {
            promoCardView(parentGeom)
            suggestedSitesView(parentGeom)
            browseNFTsView
            searchesView
        } else {
            promoCardView(parentGeom)
            suggestedSitesView(parentGeom)
            searchesView
            spacesView
        }
    }

    @ViewBuilder
    private var queryView: some View {
        if let searchQuery = viewModel.searchQuery, let url = url {
            SearchSuggestionView(
                Suggestion.editCurrentQuery(searchQuery, url)
            )
            .environmentObject(viewModel.bvc.suggestionModel)

            SuggestionsDivider(height: 8)
        } else if let openTab = tab {
            SearchSuggestionView(
                Suggestion.editCurrentURL(
                    TabCardDetails(
                        tab: openTab,
                        manager: viewModel.bvc.tabManager)
                )
            )
            .environmentObject(viewModel.bvc.suggestionModel)

            SuggestionsDivider(height: 8)
        }
    }

    @ViewBuilder
    private func promoCardView(_ parentGeom: GeometryProxy) -> some View {
        if let promoCardType = viewModel.promoCard {
            PromoCard(type: promoCardType, viewWidth: parentGeom.size.width)
                .modifier(
                    ImpressionLoggerModifier(
                        path: .PromoCardAppear,
                        attributes: EnvironmentHelper.shared.getAttributes()
                            + [
                                ClientLogCounterAttribute(
                                    key: LogConfig.PromoCardAttribute
                                        .promoCardType,
                                    value: viewModel.promoCard?.name ?? "None"
                                )
                            ]
                    )
                )
        }
    }

    @ViewBuilder
    private func suggestedSitesView(_ parentGeom: GeometryProxy) -> some View {
        if isLandScape() && viewModel.showRatingsCard {
            ratingsCard(parentGeom.size.width)
        }

        if !SpaceStore.suggested.allSpaces.isEmpty,
            expandSuggestedSpace
        {
            suggestedSpace
        }

        if Defaults[.signedInOnce] || NeevaConstants.currentTarget == .xyz {
            ZeroQueryHeader(
                title: NeevaConstants.currentTarget == .xyz ? "Web3 Tools" : "Suggested sites",
                action: { expandSuggestedSites.advance() },
                label: "\(expandSuggestedSites.verb) this section",
                icon: expandSuggestedSites.icon
            )

            if expandSuggestedSites != .hidden {
                SuggestedSitesView(
                    isExpanded: expandSuggestedSites == .expanded,
                    viewModel: viewModel.suggestedSitesViewModel)
            }

            if !isLandScape() && viewModel.showRatingsCard {
                ratingsCard(parentGeom.size.width)
            }
        }
    }

    @ViewBuilder
    private var searchesView: some View {
        ZeroQueryHeader(
            title: NeevaConstants.currentTarget == .xyz
                ? "Search on Ethereum (or the web)" : "Searches",
            action: { expandSearches.toggle() },
            label: "\(expandSearches ? "hides" : "shows") this section",
            icon: expandSearches ? .chevronUp : .chevronDown
        )

        if expandSearches {
            if !Defaults[.signedInOnce] {
                if NeevaConstants.currentTarget == .xyz {
                    SuggestedXYZSearchesView()
                        .onChange(of: cryptoPublicKey) { _ in
                            viewModel.updateState()
                        }
                } else {
                    SuggestedPreviewSearchesView()
                }
            } else {
                SuggestedSearchesView()
            }
        }
    }

    @ViewBuilder
    private var spacesView: some View {
        if NeevaUserInfo.shared.isUserLoggedIn && Defaults[.signedInOnce] {
            ZeroQueryHeader(
                title: "Spaces",
                action: { expandSpaces.toggle() },
                label: "\(expandSpaces ? "hides" : "shows") this section",
                icon: expandSpaces ? .chevronUp : .chevronDown
            )
            if expandSpaces {
                SuggestedSpacesView()
            }
        }

        if !SpaceStore.suggested.allSpaces.isEmpty,
            !expandSuggestedSpace
        {
            suggestedSpace
        }
    }

    @ViewBuilder
    private var browseNFTsView: some View {
        ZeroQueryHeader(
            title: "Browse NFTs"
        )
        SuggestedSitesView(
            isExpanded: false,
            withHome: false,
            viewModel: Web3SuggestedSitesViewModel())
    }
}

#if DEBUG
    struct ZeroQueryView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ZeroQueryView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(
                ZeroQueryModel(
                    bvc: SceneDelegate.getBVC(for: nil),
                    profile: BrowserProfile(localName: "profile"), shareURLHandler: { _, _ in })
            )
            .environmentObject(SuggestedSitesViewModel.preview)
            .environmentObject(
                SuggestedSearchesModel(
                    suggestedQueries: [
                        ("lebron james", .init(url: "https://neeva.com", title: "", guid: "1")),
                        ("neeva", .init(url: "https://neeva.com", title: "", guid: "2")),
                        ("knives out", .init(url: "https://neeva.com", title: "", guid: "3")),
                    ]
                )
            )
        }
    }
#endif
