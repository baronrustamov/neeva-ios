// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import Storage
import SwiftUI

protocol ZeroQueryPanelDelegate: AnyObject {
    func zeroQueryPanelDidRequestToOpenInNewTab(_ url: URL, isIncognito: Bool)
    func zeroQueryPanel(didSelectURL url: URL, visitType: VisitType)
    func zeroQueryPanel(didEnterQuery query: String)
    func zeroQueryPanelDidRequestToSaveToSpace(_ url: URL, title: String?, description: String?)
}

enum ZeroQueryOpenedLocation: Equatable {
    case backButton
    case createdTab
    case newTabButton
    case openTab(Tab?)
    case tabTray

    var openedTab: Tab? {
        switch self {
        case .openTab(let tab):
            return tab
        default:
            return nil
        }
    }
}

enum ZeroQueryTarget {
    /// Navigate the current tab.
    case currentTab

    /// Navigate to an existing tab matching the URL or create a new tab.
    case existingOrNewTab

    /// Navigate in a new tab.
    case newTab

    static var defaultValue: ZeroQueryTarget = .existingOrNewTab
}

class ZeroQueryModel: ObservableObject {
    @Published var isIncognito = false
    @Published private(set) var promoCardType: PromoCardViewType?
    @Published var showRatingsCard: Bool = false
    @Published var openedFrom: ZeroQueryOpenedLocation?

    var tabURL: URL? {
        if case .openTab(let tab) = openedFrom, let url = tab?.url {
            return url
        }

        return nil
    }

    var searchQuery: String? {
        if let url = tabURL, url.isNeevaURL() {
            return SearchEngine.current.queryForSearchURL(url)
        }

        return nil
    }

    let bvc: BrowserViewController

    @ObservedObject private(set) var suggestedSitesViewModel: SuggestedSitesViewModel =
        SuggestedSitesViewModel(
            sites: [])
    let profile: Profile
    let shareURLHandler: (URL, UIView) -> Void
    var delegate: ZeroQueryPanelDelegate?
    var isLazyTab = false
    var targetTab: ZeroQueryTarget = .defaultValue

    init(
        bvc: BrowserViewController, profile: Profile,
        shareURLHandler: @escaping (URL, UIView) -> Void
    ) {
        self.bvc = bvc
        self.profile = profile
        self.shareURLHandler = shareURLHandler
        updateState()
        profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
    }

    func logPromoCardImpression() {
        var attributes = EnvironmentHelper.shared.getAttributes()
        if let promoCardView = self.promoCardType {
            attributes.append(
                ClientLogCounterAttribute(key: "source", value: promoCardView.rawValue))
        }
        ClientLogger.shared.logCounter(.PromoCardAppear, attributes: attributes)
    }

    func logPromoCardInteraction(_ interaction: LogConfig.Interaction) {
        let attributes = EnvironmentHelper.shared.getAttributes()
        ClientLogger.shared.logCounter(interaction, attributes: attributes)
    }

    func dismissPromoCardView() {
        self.promoCardType = nil
    }

    func updatePromoCardView() {
        // no promos for premium members
        if NeevaUserInfo.shared.hasLoginCookie()
            && NeevaUserInfo.shared.entitledToPremiumFeatures()
        {
            promoCardType = nil
            return
        }

        let impressionCount = Defaults[.numOfZeroQueryImpressions]

        // impressions 0-3; no promos
        if impressionCount < 4 {
            promoCardType = nil
            return
        }

        // impressions 4-10; show premium promo
        if impressionCount < 10 {
            promoCardType = .premium
            return
        }

        // impressions 10+; every 5 impressions alternate between default browser and premium promos
        // impressions X0-X4; default browser
        // impressions X5-X9; premium
        if impressionCount % 10 < 5 {
            promoCardType = .defaultBrowser

            // if we think the user has set the default browser, show premium promo instead
            if Defaults[.didSetDefaultBrowser] {
                promoCardType = .premium
            }

            return
        } else {
            promoCardType = .premium
            return
        }
    }

    func updateState() {
        isIncognito = bvc.incognitoModel.isIncognito

        // TODO: remove once all users have upgraded
        if UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") {
            UserDefaults.standard.removeObject(forKey: "DidDismissDefaultBrowserCard")
            Defaults[.didDismissDefaultBrowserCard] = true
        }

        updatePromoCardView()

        // In case the ratings card server update was unsuccessful: each time we enter a ZeroQueryPage, check whether local change has been synced to server
        // The check is only performed once the local ratings card has been hidden
        if Defaults[.ratingsCardHidden] && UserFlagStore.shared.state == .ready
            && !UserFlagStore.shared.hasFlag(.dismissedRatingPromo)
        {
            UserFlagStore.shared.setFlag(.dismissedRatingPromo, action: {})
        }

        showRatingsCard =
            NeevaFeatureFlags[.appStoreRatingPromo]
            && promoCardType == nil
            && Defaults[.loginLastWeekTimeStamp].count
                == AppRatingPromoCardRule.numOfAppForegroundLastWeek
            && (!Defaults[.ratingsCardHidden]
                || (UserFlagStore.shared.state == .ready
                    && !UserFlagStore.shared.hasFlag(.dismissedRatingPromo)))

        if showRatingsCard {
            ClientLogger.shared.logCounter(.RatingsRateExperience)
        }
    }

    func updateSuggestedSites() {
        DispatchQueue.main.async {
            TopSitesHandler.getTopSites(
                profile: self.profile
            ).uponQueue(.main) { result in
                self.suggestedSitesViewModel.sites = Array(result.prefix(8))
            }
        }
    }

    func hideURLFromTopSites(_ site: Site) {
        guard let host = site.tileURL.normalizedHost else {
            return
        }

        let url = site.tileURL
        // If the default top sites contains the site URL, also wipe it from default suggested sites.
        if TopSitesHandler.defaultTopSites().filter({ $0.url == url }).isEmpty == false {
            Defaults[.deletedSuggestedSites].append(url.absoluteString)
        }

        profile.history.removeHostFromTopSites(host).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }

        self.suggestedSitesViewModel.sites.removeAll(where: { $0 == site })
    }

    func reset(
        bvc: BrowserViewController?, createdLazyTab: Bool = false, wasCancelled: Bool = false
    ) {
        if let bvc = bvc, bvc.incognitoModel.isIncognito, !(bvc.tabManager.incognitoTabs.count > 0),
            isLazyTab && !createdLazyTab
                && (openedFrom != .tabTray)
        {
            bvc.browserModel.switcherToolbarModel.onToggleIncognito()
        }

        // This can occur if a taps back and the Suggestion UI is shown.
        // If the user cancels out of that UI, we should navigate the tab back, like a complete undo.
        if let bvc = bvc, openedFrom == .backButton, wasCancelled {
            bvc.tabManager.selectedTab?.goBack(preferredTarget: nil)
        }

        isLazyTab = false
        openedFrom = nil
        targetTab = .defaultValue
    }
}
