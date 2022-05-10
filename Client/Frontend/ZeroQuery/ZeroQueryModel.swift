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
    case tabTray
    case openTab(Tab?)
    case createdTab
    case backButton
    case newTabButton

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
                self.bvc.hideZeroQuery()
            })
    }

    func handleReferralPromo() {
        // log click referral promo from zero query page
        var attributes = EnvironmentHelper.shared.getAttributes()
        attributes.append(ClientLogCounterAttribute(key: "source", value: "zero query"))
        ClientLogger.shared.logCounter(
            .OpenReferralPromo, attributes: attributes)
        self.delegate?.zeroQueryPanel(
            didSelectURL: NeevaConstants.appReferralsURL,
            visitType: .bookmark)
    }

    func updateState() {
        isIncognito = bvc.incognitoModel.isIncognito

        // TODO: remove once all users have upgraded
        if UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") {
            UserDefaults.standard.removeObject(forKey: "DidDismissDefaultBrowserCard")
            Defaults[.didDismissDefaultBrowserCard] = true
        }

        // TODO: refactor the promo card triggering logic to make it easier to customize
        let promoCardTypeArm = NeevaExperiment.arm(for: .promoCardTypeAfterFirstRun)

        if (promoCardTypeArm == .control || promoCardTypeArm == nil)
            && shouldShowDefaultBrowserPromoCard()
        {
            promoCard = defaultPromoCard()
        } else if !Defaults[.signedInOnce] && !Defaults[.didDismissPreviewSignUpCard] {
            #if XYZ
                if Defaults[.cryptoPublicKey].isEmpty {
                    promoCard = .walletPromo {
                        self.bvc.web3Model.showWalletPanel()
                    }
                } else {
                    promoCard = nil
                }
            #else
                if Defaults[.didFirstNavigation] && NeevaConstants.currentTarget != .xyz {
                    promoCard = .previewModeSignUp {
                        ClientLogger.shared.logCounter(
                            .PreviewModePromoSignup,
                            attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                        self.signIn()
                    } onClose: {
                        ClientLogger.shared.logCounter(
                            .ClosePreviewSignUprPromo,
                            attributes: EnvironmentHelper.shared.getAttributes()
                        )
                        self.promoCard = nil
                        Defaults[.didDismissPreviewSignUpCard] = true
                    }
                } else {
                    promoCard = nil
                }
            #endif
        } else if NeevaFeatureFlags[.referralPromo] && !Defaults[.didDismissReferralPromoCard] {
            promoCard = .referralPromo {
                self.handleReferralPromo()
            } onClose: {
                // log closing referral promo from zero query
                var attributes = EnvironmentHelper.shared.getAttributes()
                attributes.append(ClientLogCounterAttribute(key: "source", value: "zero query"))
                ClientLogger.shared.logCounter(
                    .CloseReferralPromo, attributes: attributes)
                self.promoCard = nil
                Defaults[.didDismissReferralPromoCard] = true
            }
        } else if !NeevaUserInfo.shared.hasLoginCookie()
            && (Defaults[.signedInOnce] || !Defaults[.didDismissPreviewSignUpCard])
        {
            promoCard = .neevaSignIn {
                ClientLogger.shared.logCounter(
                    .PromoSignin, attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                self.signIn()
            }
        } else if !Defaults[.seenBlackFridayFollowPromo]
            && NeevaFeatureFlags.latestValue(.enableBlackFridayPromoCard)
            && !SpaceStore.shared.allSpaces.contains(where: {
                $0.id.id == SpaceStore.promotionalSpaceId
            })
        {
            promoCard = .blackFridayFollowPromo(
                action: {
                    ClientLogger.shared.logCounter(
                        .BlackFridayPromo)
                    let spaceId = SpaceStore.promotionalSpaceId
                    self.bvc.browserModel.openSpace(
                        spaceId: spaceId, bvc: self.bvc,
                        completion: {
                            self.bvc.hideZeroQuery()
                            self.promoCard = nil
                        }
                    )
                },
                onClose: {
                    ClientLogger.shared.logCounter(
                        .CloseBlackFridayPromo)
                    Defaults[.seenBlackFridayFollowPromo] = true
                    self.promoCard = nil
                })
        } else if promoCardTypeArm == .previewSignUp && shouldShowDefaultBrowserPromoCard() {
            promoCard = defaultPromoCard()
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

    func defaultPromoCard() -> PromoCardType? {
        return .defaultBrowser {
            ClientLogger.shared.logCounter(
                .PromoDefaultBrowser,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
            self.bvc.presentDBOnboardingViewController(triggerFrom: .defaultBrowserPromoCard)
        } onClose: {
            ClientLogger.shared.logCounter(
                .CloseDefaultBrowserPromo,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
            self.promoCard = nil
            Defaults[.didDismissDefaultBrowserCard] = true
        }
    }

    func satisfyDefaultBrowserPromoFreqRule() -> Bool {
        return Defaults[.numOfDailyZeroQueryImpression] != 0
            && (Defaults[.introSeenDate] == nil
                || Defaults[.introSeenDate]?.hoursBetweenDate(toDate: Date()) ?? 0
                    >= DefaultBrowserPromoRules.hoursAfterInterstitialForPromoCard)
            && Defaults[.numOfDailyZeroQueryImpression]
                % DefaultBrowserPromoRules.nthZeroQueryImpression == 0
            && Defaults[.numOfDailyZeroQueryImpression]
                <= DefaultBrowserPromoRules.nthZeroQueryImpression
                * DefaultBrowserPromoRules.maxDailyPromoImpression
    }

    func shouldShowDefaultBrowserPromoCard() -> Bool {
        let notSeenInterstitial =
            !Defaults[.didShowDefaultBrowserInterstitial]
            && !Defaults[.didShowDefaultBrowserInterstitialFromSkipToBrowser]

        return NeevaConstants.currentTarget == .client && !Defaults[.didDismissDefaultBrowserCard]
            && !Defaults[.didSetDefaultBrowser]
            && Defaults[.didFirstNavigation]
            && (notSeenInterstitial
                || satisfyDefaultBrowserPromoFreqRule()
                || DefaultBrowserInterstitialChoice(
                    rawValue: Defaults[.lastDefaultBrowserInterstitialChoice]) == .skipForNow)
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

    public func reset(
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
            bvc.tabManager.selectedTab?.webView?.goBack()
        }

        isLazyTab = false
        openedFrom = nil
        targetTab = .defaultValue
    }
}
