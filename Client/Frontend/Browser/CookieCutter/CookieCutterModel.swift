// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

enum CookieNotices: CaseIterable, Encodable, Decodable {
    case declineNonEssential
    case userSelected
}

extension Defaults.Keys {
    static let cookieCutterOnboardingShowed = Defaults.Key<Bool>(
        "profile_prefkey_cookieCutter_onboardingShowed", default: false)
    static let cookieCutterEnabled = Defaults.Key<Bool>(
        "profile_prefkey_cookieCutter_isEnabled", default: true)

    fileprivate static let sitesFlaggedCookieCutter = Defaults.Key<[String]>(
        "profile_prefkey_cookieCutter_flaggedSites", default: [])

    fileprivate static let cookieNotices = Defaults.Key<CookieNotices>(
        "profile_prefkey_cookieCutter_cookieNotices", default: .declineNonEssential)
    fileprivate static let marketingCookies = Defaults.Key<Bool>(
        "profile_prefkey_cookieCutter_allowMarketingCookies", default: false)
    fileprivate static let analyticCookies = Defaults.Key<Bool>(
        "profile_prefkey_cookieCutter_allowAnalyticCookies", default: false)
    fileprivate static let socialCookies = Defaults.Key<Bool>(
        "profile_prefkey_cookieCutter_allowSocialCookies", default: false)
}

class CookieCutterModel: ObservableObject {
    // MARK: - Properties
    @Published var cookieNoticeStateShouldReset = false
    @Published var cookieNotices: CookieNotices {
        didSet {
            guard cookieNotices != oldValue else {
                return
            }

            Defaults[.cookieNotices] = cookieNotices

            let allowed = cookieNotices != .declineNonEssential
            marketingCookiesAllowed = allowed
            analyticCookiesAllowed = allowed
            socialCookiesAllowed = allowed
        }
    }
    @Published var cookiesBlocked = 0

    @Default(.cookieCutterEnabled) var cookieCutterEnabled {
        didSet {
            for tabManager in SceneDelegate.getAllTabManagers() {
                tabManager.flagAllTabsToReload()
            }
        }
    }

    // User selected settings.
    @Default(.marketingCookies) var marketingCookiesAllowed {
        didSet {
            checkIfCookieNoticeStateShouldReset()
        }
    }
    @Default(.analyticCookies) var analyticCookiesAllowed {
        didSet {
            checkIfCookieNoticeStateShouldReset()
        }
    }
    @Default(.socialCookies) var socialCookiesAllowed {
        didSet {
            checkIfCookieNoticeStateShouldReset()
        }
    }

    // MARK: - Methods
    func cookieWasHandled(bvc: BrowserViewController, domain: String?) {
        if NeevaExperiment.arm(for: .adBlockOnboarding) != .adBlock {
            if !Defaults[.cookieCutterOnboardingShowed] {
                Defaults[.cookieCutterOnboardingShowed] = true

                bvc.overlayManager.showModal(
                    style: OverlayStyle(showTitle: false, expandPopoverWidth: true)
                ) {
                    CookieCutterOnboardingView {
                        bvc.overlayManager.hideCurrentOverlay(ofPriority: .modal) {
                            bvc.trackingStatsViewModel.showTrackingStatsViewPopover = true
                        }
                    } onRemindMeLater: {
                        NotificationPermissionHelper.shared.requestPermissionIfNeeded(
                            from: bvc,
                            showChangeInSettingsDialogIfNeeded: true,
                            callSite: .defaultBrowserInterstitial
                        ) { _ in
                            LocalNotifications.scheduleNeevaOnboardingCallback(
                                notificationType: .neevaOnboardingCookieCutter)
                        }
                    } onDismiss: {
                        bvc.overlayManager.hideCurrentOverlay(ofPriority: .modal)
                    }
                    .overlayIsFixedHeight(isFixedHeight: true)
                    .environmentObject(bvc.trackingStatsViewModel)
                }
            }
        }

        bvc.trackingStatsViewModel.didBlockCookiePopup = cookiesBlocked
        if cookiesBlocked == 1 {
            bvc.trackingStatsViewModel.showOnboardingIfNecessary(onboardingBlockType: .cookiePopup)
        }

        if let domain = domain {
            // Also flag site here in case flagSite wasn't called by the engine.
            flagSite(domain: domain)
        }
    }

    private func checkIfCookieNoticeStateShouldReset() {
        if cookieNotices == .userSelected
            && !marketingCookiesAllowed
            && !analyticCookiesAllowed
            && !socialCookiesAllowed
        {
            cookieNoticeStateShouldReset = true
        }

        // Flagged sites should be reset when preferences change.
        resetSiteFlags()
    }

    // MARK: - Flag Site
    func flagSite(domain: String) {
        Defaults[.sitesFlaggedCookieCutter].append(domain)
    }

    func isSiteFlagged(domain: String) -> Bool {
        Defaults[.sitesFlaggedCookieCutter].contains(domain)
    }

    func resetSiteFlags() {
        Defaults[.sitesFlaggedCookieCutter] = []
    }

    // MARK: - init
    init() {
        self.cookieNotices = Defaults[.cookieNotices]
    }
}
