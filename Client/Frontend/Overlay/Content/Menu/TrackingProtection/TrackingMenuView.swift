// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import SFSafeSymbols
import Shared
import SwiftUI

private enum TrackingMenuUX {
    static let whosTrackingYouElementSpacing: CGFloat = 8
    static let whosTrackingYouRowSpacing: CGFloat = 60
    static let whosTrackingYouElementFaviconSize: CGFloat = 25
}

struct WhosTrackingYouDomain {
    let domain: TrackingEntity
    let count: Int
}

class TrackingStatsViewModel: ObservableObject {
    enum OnboardingBlockType {
        case adBlock
        case cookiePopup
    }

    // MARK: - Properties
    @Published private(set) var numDomains = 0
    @Published private(set) var numTrackers = 0
    @Published private(set) var numAdBlocked = 0
    @Published private(set) var whosTrackingYouDomains = [WhosTrackingYouDomain]()

    var didBlockCookiePopup = 0

    @Published var onboardingBlockType: OnboardingBlockType?

    @Published var preventTrackersForCurrentPage: Bool {
        didSet {
            var url = selectedTabURL
            // extract url query param for internal pages
            if let internalUrl = InternalURL(url),
                let extractedUrl = internalUrl.extractedUrlParam
            {
                url = extractedUrl
            }

            guard let domain = url?.host, Defaults[.cookieCutterEnabled] else {
                return
            }

            TrackingPreventionConfig.updateAllowList(
                with: domain, allowed: !preventTrackersForCurrentPage
            ) { requiresUpdate in
                guard requiresUpdate else {
                    return
                }

                ClientLogger.shared.logCounter(
                    .ToggleTrackingProtection,
                    attributes: [
                        ClientLogCounterAttribute(
                            key: LogConfig.CookieCutterAttribute.adBlockEnabled,
                            value: String(Defaults[.adBlockEnabled])),
                        ClientLogCounterAttribute(
                            key: LogConfig.CookieCutterAttribute.cookieCutterToggleState,
                            value: String(self.preventTrackersForCurrentPage)),
                        ClientLogCounterAttribute(
                            key: LogConfig.CookieCutterAttribute.trackingProtectionDomain,
                            value: domain),
                    ])

                self.selectedTab?.contentBlocker?.notifiedTabSetupRequired()
                self.selectedTab?.reload()
            }
        }
    }
    @Published var showTrackingStatsViewPopover = false

    private var selectedTab: Tab? {
        didSet {
            listenForStatUpdates()
        }
    }

    private var selectedTabURL: URL? {
        didSet {
            guard let selectedTabURL = selectedTabURL, selectedTabURL.isWebPage() else {
                return
            }

            if let domain = selectedTabURL.host {
                self.preventTrackersForCurrentPage = TrackingPreventionConfig.trackersPreventedFor(
                    domain, checkCookieCutterState: true)
            }
        }
    }

    private var subscriptions: Set<AnyCancellable> = []
    private var statsSubscription: AnyCancellable?

    /// FOR TESTING ONLY
    private(set) var trackers: [TrackingEntity] {
        didSet {
            onDataUpdated()
        }
    }

    // MARK: - Data Updates
    func listenForStatUpdates() {
        statsSubscription = nil

        guard let tab = selectedTab else {
            return
        }

        let trackingData = TrackingEntity.getTrackingDataForCurrentTab(
            stats: tab.contentBlocker?.stats)
        self.numDomains = trackingData.numDomains
        self.numTrackers = trackingData.numTrackers
        self.trackers = trackingData.trackingEntities
        self.numAdBlocked = trackingData.numAdBlocked
        self.didBlockCookiePopup = 0

        onDataUpdated()

        statsSubscription = selectedTab?.contentBlocker?.$stats
            .map { TrackingEntity.getTrackingDataForCurrentTab(stats: $0) }
            .sink { [weak self] data in
                guard let self = self else { return }
                self.numDomains = data.numDomains
                self.numTrackers = data.numTrackers
                self.trackers = data.trackingEntities
                self.numAdBlocked = data.numAdBlocked
                self.onDataUpdated()

                if self.numAdBlocked > 0 {
                    self.showOnboardingIfNecessary(onboardingBlockType: .adBlock)
                }
            }
    }

    func showOnboardingIfNecessary(onboardingBlockType: OnboardingBlockType) {
        if NeevaExperiment.arm(for: .adBlockOnboarding) == .adBlock
            && !Defaults[.cookieCutterOnboardingShowed]
            && self.onboardingBlockType == nil
            && ContentBlocker.shared.setupCompleted
        {
            self.onboardingBlockType = onboardingBlockType
            self.showTrackingStatsViewPopover = true

            switch onboardingBlockType {
            case .adBlock:
                ClientLogger.shared.logCounter(
                    LogConfig.Interaction.ShowNeevaShieldAdBlockOnboardingScreen)
            case .cookiePopup:
                ClientLogger.shared.logCounter(
                    LogConfig.Interaction.ShowNeevaShieldCookiePopupOnboardingScreen)
            }
        }
    }

    func onDataUpdated() {
        whosTrackingYouDomains =
            trackers
            .reduce(into: [:]) { dict, tracker in dict[tracker] = (dict[tracker] ?? 0) + 1 }
            .map { WhosTrackingYouDomain(domain: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
            .prefix(3)
            .toArray()
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.selectedTab = tabManager.selectedTab
        self.preventTrackersForCurrentPage = TrackingPreventionConfig.trackersPreventedFor(
            selectedTab?.currentURL()?.host ?? "", checkCookieCutterState: true)

        let trackingData = TrackingEntity.getTrackingDataForCurrentTab(
            stats: selectedTab?.contentBlocker?.stats)
        self.trackers = trackingData.trackingEntities

        tabManager.selectedTabPublisher.assign(to: \.selectedTab, on: self).store(
            in: &subscriptions)
        tabManager.selectedTabURLPublisher.assign(to: \.selectedTabURL, on: self).store(
            in: &subscriptions)

        onDataUpdated()
    }

    /// For usage with static data and testing only
    init(testingData: TrackingData) {
        self.preventTrackersForCurrentPage = true
        self.numDomains = testingData.numDomains
        self.numTrackers = testingData.numTrackers
        self.trackers = testingData.trackingEntities
        self.numAdBlocked = testingData.numAdBlocked

        onDataUpdated()
    }
}

struct TrackingMenuFirstRowElement: View {
    let label: LocalizedStringKey
    let num: Int

    var body: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(label).withFont(.headingMedium).foregroundColor(.secondaryLabel)
                Text("\(num)").withFont(.displayMedium)
            }
            .padding(.bottom, 4)
            .padding(.vertical, 10)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                Text(
                    "\(num) \(Text(label)) blocked",
                    comment:
                        "accessibility label for how many website trackers are blocked on this page"
                )
            )
            .accessibilityIdentifier("TrackingMenu.TrackingMenuFirstRowElement")
        }
    }
}

struct WhosTrackingYouElement: View {
    let whosTrackingYouDomain: WhosTrackingYouDomain

    var body: some View {
        HStack(spacing: TrackingMenuUX.whosTrackingYouElementSpacing) {
            Image(whosTrackingYouDomain.domain.rawValue).resizable().cornerRadius(5)
                .frame(
                    width: TrackingMenuUX.whosTrackingYouElementFaviconSize,
                    height: TrackingMenuUX.whosTrackingYouElementFaviconSize)
            Text("\(whosTrackingYouDomain.count)").withFont(.displayMedium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(whosTrackingYouDomain.count) trackers blocked from \(whosTrackingYouDomain.domain.rawValue)"
        )
        .accessibilityIdentifier("TrackingMenu.WhosTrackingYouElement")
    }
}

struct WhosTrackingYouView: View {
    let whosTrackingYouDomains: [WhosTrackingYouDomain]

    var body: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Who's Tracking You").withFont(.headingMedium).foregroundColor(.secondaryLabel)
                HStack(spacing: TrackingMenuUX.whosTrackingYouRowSpacing) {
                    ForEach(whosTrackingYouDomains, id: \.domain.rawValue) {
                        whosTrackingYouDomain in
                        WhosTrackingYouElement(whosTrackingYouDomain: whosTrackingYouDomain)
                    }
                }.padding(.bottom, 4)
            }.padding(.vertical, 14)
        }
    }
}

struct ShieldWithBadgeView: View {
    var foregroundSymbol: SFSymbol
    var foregroundColor: Color
    var backgroundSymbol: SFSymbol
    var backgroundColor: Color

    var body: some View {
        ZStack {
            Image("welcome-shield", bundle: .main)
                .frame(width: 32, height: 32)
            ZStack {
                Image(systemSymbol: foregroundSymbol).font(.system(size: 25))
                    .foregroundColor(foregroundColor)
                Image(systemSymbol: backgroundSymbol).font(.system(size: 25)).fixedSize()
                    .foregroundColor(backgroundColor)
            }.padding(.leading, 30)
        }
    }
}

struct TrackingMenuView: View {
    @EnvironmentObject var viewModel: TrackingStatsViewModel
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    @ViewBuilder
    func shieldWithBadge(
        foregroundSymbol: SFSymbol, foregroundColor: Color, backgroundSymbol: SFSymbol,
        backgroundColor: Color
    ) -> some View {
        ZStack {
            Image("welcome-shield", bundle: .main)
                .frame(width: 32, height: 32)
            ZStack {
                Image(systemSymbol: foregroundSymbol).font(.system(size: 25))
                    .foregroundColor(foregroundColor)
                Image(systemSymbol: backgroundSymbol).font(.system(size: 25)).fixedSize()
                    .foregroundColor(backgroundColor)
            }.padding(.leading, 30)
        }
    }

    var badgeView: some View {
        VStack {
            if viewModel.preventTrackersForCurrentPage {
                if viewModel.onboardingBlockType == .adBlock {
                    NotificationBadgeOverlay(
                        from: [NotificationBadgeLocation.right], count: viewModel.numTrackers,
                        value: viewModel.numTrackers == 1
                            ? "1 Tracker Blocked"
                            : "\(viewModel.numTrackers) Trackers Blocked", showBadgeOnZero: false,
                        contentSize: CGSize(width: 32, height: 32), fontSize: 15,
                        content:
                            Image("welcome-shield", bundle: .main)
                            .frame(width: 32, height: 32)
                    )
                    .padding(.top, 15)
                } else if viewModel.onboardingBlockType == .cookiePopup {
                    ShieldWithBadgeView(
                        foregroundSymbol: .checkmarkCircleFill, foregroundColor: .blue,
                        backgroundSymbol: .checkmarkCircle, backgroundColor: .white)
                }
            } else {
                ShieldWithBadgeView(
                    foregroundSymbol: .minusCircleFill, foregroundColor: .gray,
                    backgroundSymbol: .minusCircle, backgroundColor: .white)
            }
        }
    }

    @ViewBuilder
    func onboardingText(text: String) -> some View {
        Text(text)
            .multilineTextAlignment(
                .center
            ).foregroundColor(.primary).withFont(unkerned: .headingMedium).padding(
                .horizontal, 20
            )
            .frame(minHeight: 60)
            .padding(.top, 10)
    }

    var onboardingView: some View {
        GroupedStack {
            VStack(alignment: .center, spacing: 0) {
                badgeView
                    .frame(minHeight: 50)

                if !viewModel.preventTrackersForCurrentPage {
                    onboardingText(
                        text: "Want Neeva to block ads, trackers and cookie popups on this page?")
                } else if viewModel.onboardingBlockType == .adBlock {
                    onboardingText(text: "Neeva blocked ads and trackers on this page!")
                } else if viewModel.onboardingBlockType == .cookiePopup {
                    onboardingText(text: "Neeva blocked a cookie popup on this page!")
                }
                TrackingMenuProtectionOnboardingShieldButton(
                    preventTrackers: $viewModel.preventTrackersForCurrentPage
                )
                .padding(.vertical, 20)
                .frame(minHeight: 60)
                Button(
                    action: {
                        viewModel.showTrackingStatsViewPopover = false
                    },
                    label: {
                        Text("Cool. Thanks.")
                            .withFont(.labelMedium)
                            .foregroundColor(.brand.white)
                            .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(.neeva(.primary))
                .padding(.bottom, 20)
                .padding(.horizontal, 15)
            }.fixedSize(horizontal: false, vertical: true)
        }
    }

    var body: some View {
        if NeevaExperiment.arm(for: .adBlockOnboarding) == .adBlock
            && !Defaults[.cookieCutterOnboardingShowed] && viewModel.onboardingBlockType != nil
        {
            onboardingView
        } else {
            GroupedStack {
                if viewModel.preventTrackersForCurrentPage {
                    HStack(spacing: 8) {
                        TrackingMenuFirstRowElement(
                            label: "Ads & Trackers", num: viewModel.numTrackers)

                        TrackingMenuFirstRowElement(
                            label: "Cookie Popups", num: cookieCutterModel.cookiesBlocked)
                    }

                    if !viewModel.whosTrackingYouDomains.isEmpty {
                        WhosTrackingYouView(
                            whosTrackingYouDomains: viewModel.whosTrackingYouDomains)
                    }
                }

                TrackingMenuProtectionRowButton(
                    preventTrackers: $viewModel.preventTrackersForCurrentPage)
            }
        }
    }
}
