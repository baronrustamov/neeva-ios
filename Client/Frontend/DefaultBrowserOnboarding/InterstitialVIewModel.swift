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
}
