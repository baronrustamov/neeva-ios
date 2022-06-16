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
    var showSecondaryOnboardingButton: Bool

    var onOpenSettingsAction: (() -> Void)?
    var onCloseAction: (() -> Void)?

    var didTakeAction = false

    var isInExperimentArm: Bool
    var onboardingState: OnboardingState

    var onboardingAppearTimestamp: Date?

    var player: QueuePlayerUIView?

    enum OnboardingState {
        case initialState
        case continueState
        case openedSettingsState
    }

    init(
        trigger: OpenDefaultBrowserOnboardingTrigger = .defaultBrowserFirstScreen,
        showRemindButton: Bool = true,
        showCloseButton: Bool = true,
        showSecondaryOnboardingButton: Bool = true,
        isInExperimentArm: Bool = false,
        onboardingState: OnboardingState = .initialState,
        onOpenSettingsAction: (() -> Void)? = nil,
        onCloseAction: (() -> Void)? = nil
    ) {
        self.trigger = trigger
        self.showRemindButton = showRemindButton
        self.showCloseButton = showCloseButton
        self.onOpenSettingsAction = onOpenSettingsAction
        self.onCloseAction = onCloseAction
        self.showSecondaryOnboardingButton = showSecondaryOnboardingButton
        self.onboardingState = onboardingState
        self.isInExperimentArm = isInExperimentArm

        self.openButtonText = "Open Neeva Settings"
        self.remindButtonText = "Remind Me Later"
    }

    func openSettingsButtonClickAction(
        interaction: LogConfig.Interaction = .DefaultBrowserOnboardingInterstitialOpen
    ) {
        if let onOpenSettingsAction = onOpenSettingsAction {
            onOpenSettingsAction()
        }
        didTakeAction = true
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

    func closeAction(shouldLog: Bool = true) {
        if let onCloseAction = onCloseAction {
            onCloseAction()
        }
        didTakeAction = true
        Defaults[.lastDefaultBrowserInterstitialChoice] =
            DefaultBrowserInterstitialChoice.skipForNow.rawValue
        if shouldLog {
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
    }

    func welcomePageBullets() -> [String] {
        return [
            "Ad-Free Search",
            "Block Ads. Block Trackers",
            "Block Cookie Pop-ups",
        ]
    }

    func onboardingPageBullets() -> [String] {
        return [
            "Browse the Web Ad-Free",
            "Block Trackers, and Pop-ups",
        ]
    }
}
