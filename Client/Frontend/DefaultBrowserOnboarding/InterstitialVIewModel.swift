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

        self.openButtonText =
            restoreFromBackground
            ? Strings.FirstRun.Onboarding.BackToSettings
            : Strings.FirstRun.Onboarding.OpenNeevaSettings
        self.remindButtonText =
            restoreFromBackground
            ? Strings.FirstRun.Onboarding.ContinueToNeeva
            : Strings.FirstRun.Onboarding.RemindMeLater
    }

    func openSettingsButtonClickAction(
        interaction: LogConfig.Interaction = .DefaultBrowserOnboardingInterstitialOpen
    ) {
        if let onOpenSettingsAction = onOpenSettingsAction {
            onOpenSettingsAction()
        }
        didTakeAction = true

        openButtonText = Strings.FirstRun.Onboarding.BackToSettings
        if Defaults[.didDismissDefaultBrowserInterstitial] == false
            && !Defaults[.didFirstNavigation]
        {
            remindButtonText = Strings.FirstRun.Onboarding.ContinueToNeeva
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
                Strings.FirstRun.Welcome.FirstBulletExp,
                Strings.FirstRun.Welcome.SecondBulletExp,
                Strings.FirstRun.Welcome.ThirdBulletExp,
            ]
        } else {
            return [
                Strings.FirstRun.Welcome.FirstBullet,
                Strings.FirstRun.Welcome.SecondBullet,
                Strings.FirstRun.Welcome.ThirdBullet,
            ]
        }
    }

    func onboardingPageBullets() -> [String] {
        return [
            Strings.FirstRun.Onboarding.FirstBullet,
            Strings.FirstRun.Onboarding.SecondBullet,
        ]
    }
}
