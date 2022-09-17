// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

enum TriState: Int, Codable {
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
        default: .compact
    )
    fileprivate static let expandSearches = Defaults.Key<Bool>(
        "profile.home.searches.expanded", default: true)
    fileprivate static let expandSpaces = Defaults.Key<Bool>(
        "profile.home.spaces.expanded", default: true)
    fileprivate static let expandSuggestedSpace = Defaults.Key<TriState>(
        "profile.home.suggestedSpace.expanded", default: .compact)
}

struct ZeroQueryView: View {
    @EnvironmentObject var viewModel: ZeroQueryModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @ObservedObject var spaceStoreSuggested = SpaceStore.suggested

    @Default(.expandSuggestedSites) private var expandSuggestedSites
    @Default(.expandSearches) private var expandSearches
    @Default(.expandSpaces) private var expandSpaces
    @Default(.expandSuggestedSpace) private var expandSuggestedSpace

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
            store: spaceStoreSuggested,
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
                // only set for zero query first run
                .if(!Defaults[.didFirstNavigation]) { view in
                    view.frame(minHeight: geom.size.height)
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
        promoCardView(parentGeom)
        suggestedSitesView(parentGeom)
        searchesView
        // TODO: set up experiment
        //spacesView
        adBlockAnnouncement
        firstRunBranding
    }

    @ViewBuilder private var adBlockAnnouncement: some View {
        if !Defaults[.didFirstNavigation] {
            VStack(alignment: .leading, spacing: 30) {
                ShieldWithBadgeView(
                    foregroundSymbol: .checkmarkCircleFill, foregroundColor: .blue,
                    backgroundSymbol: .checkmarkCircle, backgroundColor: .white
                )
                .padding(.top, 15)
                .padding(.leading, -15)
                Text("Neeva Ad Blocker is activated").withFont(.headingLarge)
                Text(
                    "Browse faster without spammy, screen-filling ads. Experience the web without ads today."
                ).withFont(.bodyMedium)
                    .padding(.bottom, 15)
            }.padding(.horizontal, 32).padding(.vertical, 15).overlay(
                RoundedRectangle(cornerRadius: 20).stroke(Color.ui.adaptive.blue, lineWidth: 2)
            ).padding(15)
        }
    }

    @ViewBuilder private var firstRunBranding: some View {
        if !Defaults[.didFirstNavigation] {
            Spacer()
            Spacer()
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Spacer()
                    Image("splash")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 22)
                    Image("neeva-letter-only")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.secondary)
                        .frame(maxHeight: 18)
                    Spacer()
                }
                Text("The first ad-free, private search engine")
                    .foregroundColor(Color.secondary)
            }
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

        if Defaults[.didFirstNavigation] && viewModel.suggestedSitesViewModel.sites.count > 0 {
            ZeroQueryHeader(
                title: "Suggested sites",
                action: { expandSuggestedSites.advance() },
                label: "\(expandSuggestedSites.verb) this section",
                icon: expandSuggestedSites.icon,
                hideToggle: !Defaults[.didFirstNavigation]
            )

            if expandSuggestedSites != .hidden {
                SuggestedSitesView(
                    isExpanded: expandSuggestedSites == .expanded,
                    withHome: Defaults[.signedInOnce],
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
            title: "Searches",
            action: { expandSearches.toggle() },
            label: "\(expandSearches ? "hides" : "shows") this section",
            icon: expandSearches ? .chevronUp : .chevronDown,
            hideToggle: !Defaults[.didFirstNavigation]
        )

        if expandSearches {
            SuggestedSearchesView(profile: viewModel.profile)
        }
    }

    @ViewBuilder
    private var spacesView: some View {
        if !SpaceStore.shared.allSpaces.isEmpty {
            // show my spaces
            ZeroQueryHeader(
                title: "Spaces",
                action: { expandSpaces.toggle() },
                label: "\(expandSpaces ? "hides" : "shows") this section",
                icon: expandSpaces ? .chevronUp : .chevronDown,
                hideToggle: !Defaults[.didFirstNavigation]
            )
            if expandSpaces {
                SuggestedSpacesView()
            }
        } else {
            // show suggested spaces
            if !spaceStoreSuggested.allSpaces.isEmpty {
                suggestedSpace
            }
        }
    }
}
