// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

class InterstitialViewModel: ObservableObject {
    @Published var openButtonText: String
    @Published var remindButtonText: String

    var trigger: OpenDefaultBrowserOnboardingTrigger
    var showRemindButton: Bool
    var showCloseButton: Bool

    var onOpenSettingsAction: (() -> Void)?
    var onCloseAction: (() -> Void)?

    var didTakeAction = false

    init(
        trigger: OpenDefaultBrowserOnboardingTrigger = .defaultBrowserFirstScreen,
        showRemindButton: Bool = true,
        showCloseButton: Bool = true,
        onOpenSettingsAction: (() -> Void)? = nil,
        onCloseAction: (() -> Void)? = nil
    ) {
        self.trigger = trigger
        self.showRemindButton = showRemindButton
        self.showCloseButton = showCloseButton
        self.onOpenSettingsAction = onOpenSettingsAction
        self.onCloseAction = onCloseAction

        self.openButtonText = "Open Neeva Settings"
        self.remindButtonText = "Remind Me Later"
    }

    func openSettingsButtonClickAction() {
        if let onOpenSettingsAction = onOpenSettingsAction {
            onOpenSettingsAction()
        }
        didTakeAction = true
        Defaults[.lastDefaultBrowserInterstitialChoice] =
            DefaultBrowserInterstitialChoice.openSettings.rawValue
        ClientLogger.shared.logCounter(
            .DefaultBrowserOnboardingInterstitialOpen,
            attributes: [
                ClientLogCounterAttribute(
                    key:
                        LogConfig.PromoCardAttribute
                        .defaultBrowserInterstitialTrigger,
                    value: trigger.rawValue
                )
            ]
        )
        UIApplication.shared.openSettings(
            triggerFrom: trigger
        )
    }

    func defaultBrowserSecondaryButtonAction() {
        remindLaterAction()
        didTakeAction = true
    }

    func remindLaterAction() {
        NotificationPermissionHelper.shared.requestPermissionIfNeeded(
            callSite: .defaultBrowserInterstitial
        ) { authorized in
            if authorized {
                LocalNotifications.scheduleNeevaOnboardingCallback(
                    notificationType: .neevaOnboardingDefaultBrowser)
            }
        }

        closeAction()
        Defaults[.lastDefaultBrowserInterstitialChoice] =
            DefaultBrowserInterstitialChoice.skipForNow.rawValue
        ClientLogger.shared.logCounter(
            .DefaultBrowserOnboardingInterstitialRemind,
            attributes: [
                ClientLogCounterAttribute(
                    key:
                        LogConfig.PromoCardAttribute.defaultBrowserInterstitialTrigger,
                    value: trigger.rawValue
                )
            ]
        )
    }

    func closeAction() {
        if let onCloseAction = onCloseAction {
            onCloseAction()
        }
        didTakeAction = true
        Defaults[.lastDefaultBrowserInterstitialChoice] =
            DefaultBrowserInterstitialChoice.skipForNow.rawValue
        ClientLogger.shared.logCounter(
            .DefaultBrowserOnboardingInterstitialSkip,
            attributes: [
                ClientLogCounterAttribute(
                    key:
                        LogConfig.PromoCardAttribute.defaultBrowserInterstitialTrigger,
                    value: trigger.rawValue
                )
            ]
        )
    }

    func isInWelcomeScreenExperimentArms() -> Bool {
        return
            NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .privacyMsg
            || NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .trackingMsg
    }

    func imageForWelcomeExperiment() -> String {
        if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .trackingMsg {
            return "neeva_interstitial_welcome_page_tracking"
        } else if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .privacyMsg {
            return "neeva_interstitial_welcome_page_privacy"
        } else {
            return ""
        }
    }

    func titleForFirstScreenWelcomeExperiment() -> String {
        if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .trackingMsg {
            return "No Ads. No Tracking"
        } else if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .privacyMsg {
            return "Privacy Made Easy"
        } else {
            return ""
        }
    }

    func bodyForFirstScreenWelcomeExperiment() -> String {
        if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .trackingMsg {
            return "You’re just a step away from blocking ads, trackers and annoying pop-ups"
        } else if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .privacyMsg {
            return
                "You’re just a step away from ad-free search, and browsing without ads, trackers or pop-ups"
        } else {
            return ""
        }
    }

    func bodyForSecondScreenWelcomeExperiment() -> String {
        if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .trackingMsg {
            return "With Neeva as your default, you can open links without ads, trackers or pop-ups"
        } else if NeevaExperiment.arm(for: .defaultBrowserWelcomeScreen) == .privacyMsg {
            return
                "With Neeva as your default, you can search and browse ad-free. No annoying trackers or pop-ups."
        } else {
            return ""
        }
    }
}
