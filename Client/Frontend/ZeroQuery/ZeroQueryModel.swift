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

enum PromoCardTrigger {
    case shouldTriggerArmDefaultPromo
    case shouldTriggerWalletOrSignupPromo
    case shouldTriggerReferralPromo
    case shouldTriggerSignInPromo
}

class ZeroQueryModel: ObservableObject {
    @Published var isIncognito = false
    @Published private(set) var promoCard: PromoCardType?
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

    let promoCardPriority: [PromoCardTrigger] = [
        .shouldTriggerArmDefaultPromo,
        .shouldTriggerWalletOrSignupPromo,
        .shouldTriggerReferralPromo,
        .shouldTriggerSignInPromo,
    ]

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

    func signIn() {
        self.bvc.presentIntroViewController(
            true,
            completion: {
                self.bvc.dismissEditingAndHideZeroQuery()
            })
    }

    func handlePromoCard(interaction: LogConfig.Interaction) {
        var attributes = EnvironmentHelper.shared.getAttributes()
        if interaction == .OpenReferralPromo || interaction == .CloseReferralPromo {
            attributes.append(ClientLogCounterAttribute(key: "source", value: "zero query"))
        }
        ClientLogger.shared.logCounter(interaction, attributes: attributes)
    }

    func shouldDisplayPromoCard(_ promocard: PromoCardTrigger) -> Bool {
        switch promocard {
        case .shouldTriggerArmDefaultPromo:
            return shouldShowDefaultBrowserPromoCard()
        case .shouldTriggerWalletOrSignupPromo:
            return !Defaults[.signedInOnce] && !Defaults[.didDismissPreviewSignUpCard]
        case .shouldTriggerReferralPromo:
            return NeevaFeatureFlags[.referralPromo] && !Defaults[.didDismissReferralPromoCard]
        case .shouldTriggerSignInPromo:
            return !NeevaUserInfo.shared.hasLoginCookie()
                && (Defaults[.signedInOnce] || !Defaults[.didDismissPreviewSignUpCard])
        }
    }

    func setDisplayPromoCard(_ promocard: PromoCardTrigger) {
        switch promocard {
        case .shouldTriggerArmDefaultPromo:
            promoCard = .defaultBrowser {
                self.handlePromoCard(interaction: .PromoDefaultBrowser)
                self.bvc.presentDBOnboardingViewController(triggerFrom: .defaultBrowserPromoCard)
            } onClose: {
                self.handlePromoCard(interaction: .CloseDefaultBrowserPromo)
                self.promoCard = nil
                Defaults[.didDismissDefaultBrowserCard] = true
            }
        case .shouldTriggerWalletOrSignupPromo:
            if Defaults[.didFirstNavigation] {
                promoCard = .previewModeSignUp {
                    self.handlePromoCard(interaction: .PreviewModePromoSignup)
                    self.signIn()
                } onClose: {
                    self.handlePromoCard(interaction: .ClosePreviewSignUpPromo)
                    self.promoCard = nil
                    Defaults[.didDismissPreviewSignUpCard] = true
                }
            } else {
                promoCard = nil
            }
        case .shouldTriggerReferralPromo:
            promoCard = .referralPromo {
                self.handlePromoCard(interaction: .OpenReferralPromo)
                self.delegate?.zeroQueryPanel(
                    didSelectURL: NeevaConstants.appReferralsURL,
                    visitType: .bookmark)
            } onClose: {
                // log closing referral promo from zero query
                self.handlePromoCard(interaction: .CloseReferralPromo)
                self.promoCard = nil
                Defaults[.didDismissReferralPromoCard] = true
            }
        case .shouldTriggerSignInPromo:
            promoCard = .neevaSignIn {
                self.handlePromoCard(interaction: .PromoSignin)
                self.signIn()
            }
        }
    }

    func updateState() {
        isIncognito = bvc.incognitoModel.isIncognito

        // TODO: remove once all users have upgraded
        if UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") {
            UserDefaults.standard.removeObject(forKey: "DidDismissDefaultBrowserCard")
            Defaults[.didDismissDefaultBrowserCard] = true
        }

        if let card = promoCardPriority.first(where: { shouldDisplayPromoCard($0) }) {
            setDisplayPromoCard(card)
        } else {
            promoCard = nil
        }

        // In case the ratings card server update was unsuccessful: each time we enter a ZeroQueryPage, check whether local change has been synced to server
        // The check is only performed once the local ratings card has been hidden
        if Defaults[.ratingsCardHidden] && UserFlagStore.shared.state == .ready
            && !UserFlagStore.shared.hasFlag(.dismissedRatingPromo)
        {
            UserFlagStore.shared.setFlag(.dismissedRatingPromo, action: {})
        }

        showRatingsCard =
            NeevaFeatureFlags[.appStoreRatingPromo]
            && promoCard == nil
            && Defaults[.loginLastWeekTimeStamp].count
                == AppRatingPromoCardRule.numOfAppForegroundLastWeek
            && (!Defaults[.ratingsCardHidden]
                || (UserFlagStore.shared.state == .ready
                    && !UserFlagStore.shared.hasFlag(.dismissedRatingPromo)))

        if showRatingsCard {
            ClientLogger.shared.logCounter(.RatingsRateExperience)
        }
    }

    func shouldShowDefaultBrowserPromoCard() -> Bool {
        let introSeenDuration = Defaults[.introSeenDate]?.hoursBetweenDate(toDate: Date()) ?? 0

        // Show default browser promo if the user is not a default browser user for the first three days
        return !Defaults[.didDismissDefaultBrowserCard]
            && !Defaults[.didSetDefaultBrowser]
            && Defaults[.didFirstNavigation]
            && introSeenDuration <= DefaultBrowserPromoRules.hoursAfterInterstitialForPromoCard
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
