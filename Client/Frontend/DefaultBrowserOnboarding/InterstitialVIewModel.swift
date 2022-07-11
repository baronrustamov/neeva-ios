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

    @Published var shouldHide: Bool = true

    var trigger: OpenDefaultBrowserOnboardingTrigger
    var showRemindButton: Bool
    var showCloseButton: Bool
    var restoreFromBackground: Bool

    var onOpenSettingsAction: (() -> Void)?
    var onCloseAction: (() -> Void)?

    var didTakeAction = false

    var onboardingState: OnboardingState

    var onboardingAppearTimestamp: Date?

    var player: QueuePlayerUIView?

    enum OnboardingState {
        case initialState
        case openedSettingsState
    }

    init(
        trigger: OpenDefaultBrowserOnboardingTrigger = .defaultBrowserFirstScreen,
        showRemindButton: Bool = true,
        restoreFromBackground: Bool = false,
        showCloseButton: Bool = true,
        onboardingState: OnboardingState = .initialState,
        onOpenSettingsAction: (() -> Void)? = nil,
        onCloseAction: (() -> Void)? = nil
    ) {
        self.trigger = trigger
        self.showRemindButton = showRemindButton
        self.showCloseButton = showCloseButton
        self.restoreFromBackground = restoreFromBackground
        self.onOpenSettingsAction = onOpenSettingsAction
        self.onCloseAction = onCloseAction
        self.onboardingState = onboardingState

        self.openButtonText = restoreFromBackground ? "Back to Settings" : "Open Neeva Settings"
        self.remindButtonText = restoreFromBackground ? "Continue to Neeva" : "Remind Me Later"
    }

    func openSettingsButtonClickAction(
        interaction: LogConfig.Interaction = .DefaultBrowserOnboardingInterstitialOpen
    ) {
        if let onOpenSettingsAction = onOpenSettingsAction {
            onOpenSettingsAction()
        }
        didTakeAction = true

        openButtonText = "Back to Settings"
        if Defaults[.didDismissDefaultBrowserInterstitial] == false
            && !Defaults[.didFirstNavigation]
        {
            remindButtonText = "Continue to Neeva"
            // TODO once we decide on arm, should convert this to be a state
            // as we are not really in restore state, this will work for all
            // arms right now
            restoreFromBackground = true
        }

        Defaults[.lastDefaultBrowserInterstitialChoice] =
            DefaultBrowserInterstitialChoice.openSettings.rawValue
        ClientLogger.shared.logCounter(
            interaction,
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
        if restoreFromBackground {
            closeAction(
                interaction: .DefaultBrowserOnboardingInterstitialContinueToNeeva
            )
        } else {
            remindLaterAction()
        }
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

        closeAction(shouldLog: false)
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

    func closeAction(
        shouldLog: Bool = true,
        interaction: LogConfig.Interaction = .DefaultBrowserOnboardingInterstitialSkip
    ) {
        if let onCloseAction = onCloseAction {
            onCloseAction()
        }
        didTakeAction = true
        Defaults[.lastDefaultBrowserInterstitialChoice] =
            DefaultBrowserInterstitialChoice.skipForNow.rawValue
        if shouldLog {
            ClientLogger.shared.logCounter(
                interaction,
                attributes: [
                    ClientLogCounterAttribute(
                        key:
                            LogConfig.PromoCardAttribute.defaultBrowserInterstitialTrigger,
                        value: trigger.rawValue
                    )
                ]
            )
        }
    }

    func welcomePageBullets() -> [String] {
        if NeevaExperiment.arm(for: .defaultBrowserWelcomeV2) == .welcomeV2 {
            return [
                "Ad-free search results",
                "Browser without ads or trackers",
                "Cookie pop-up blocker",
            ]
        } else {
            return [
                "Ad-Free Search",
                "Block Ads. Block Trackers",
                "Block Cookie Pop-ups",
            ]
        }
    }

    func onboardingPageBullets() -> [String] {
        return [
            "Browse the Web Ad-Free",
            "Block Trackers, and Pop-ups",
        ]
    }
}
