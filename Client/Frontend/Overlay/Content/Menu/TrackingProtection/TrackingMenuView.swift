// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import SFSafeSymbols
import Shared
import Storage
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
    // MARK: - Properties
    @Published private(set) var numDomains = 0
    @Published private(set) var numTrackers = 0
    @Published private(set) var whosTrackingYouDomains = [WhosTrackingYouDomain]()
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

    private var selectedTab: Tab? = nil {
        didSet {
            listenForStatUpdates()
        }
    }

    private var selectedTabURL: URL? = nil {
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
    private var statsSubscription: AnyCancellable? = nil

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
        onDataUpdated()

        statsSubscription = selectedTab?.contentBlocker?.$stats
            .map { TrackingEntity.getTrackingDataForCurrentTab(stats: $0) }
            .sink { [weak self] data in
                guard let self = self else { return }
                self.numDomains = data.numDomains
                self.numTrackers = data.numTrackers
                self.trackers = data.trackingEntities
                self.onDataUpdated()
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

struct TrackingMenuView: View {
    @EnvironmentObject var viewModel: TrackingStatsViewModel
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    @State private var isShowingPopup = false

    var body: some View {
        GroupedStack {
            if viewModel.preventTrackersForCurrentPage {
                HStack(spacing: 8) {
                    TrackingMenuFirstRowElement(label: "Trackers", num: viewModel.numTrackers)

                    TrackingMenuFirstRowElement(
                        label: "Cookie Popups", num: cookieCutterModel.cookiesBlocked)
                }

                if !viewModel.whosTrackingYouDomains.isEmpty {
                    WhosTrackingYouView(whosTrackingYouDomains: viewModel.whosTrackingYouDomains)
                }
            }

            TrackingMenuProtectionRowButton(
                preventTrackers: $viewModel.preventTrackersForCurrentPage)
        }
    }
}
