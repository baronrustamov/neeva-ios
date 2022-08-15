// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

enum WelcomeFlowScreen: String, CaseIterable {
    case intro
    case plans
    case defaultBrowser
    case signUp
    case signUpEmail
    case signIn
}

class WelcomeFlowModel: ObservableObject {
    var onCloseAction: (() -> Void)?
    var authStore: AuthStore
    @Published var currentScreen: WelcomeFlowScreen = .intro
    @Published var prevScreen: WelcomeFlowScreen?
    @Published var showCloseButton = false
    @Published var showAllSignUpOptions = false
    @Published var defaultBrowserContinueMode = false
    @Published var currentPremiumPlan: PremiumPlan? = .annual  // nil is the free plan

    init(authStore: AuthStore, onCloseAction: (() -> Void)? = nil) {
        self.authStore = authStore
        self.onCloseAction = onCloseAction
    }

    func changeScreenTo(_ screen: WelcomeFlowScreen) {
        self.currentScreen = screen
    }

    func goToPreviousScreen() {
        guard let prev = self.prevScreen else { return }
        self.currentScreen = prev
        self.prevScreen = nil
    }

    func scheduleDefaultBrowserReminder() {
        NotificationPermissionHelper.shared.requestPermissionIfNeeded(
            callSite: .defaultBrowserInterstitial
        ) { authorized in
            if authorized {
                LocalNotifications.scheduleNeevaOnboardingCallback(
                    notificationType: .neevaOnboardingDefaultBrowser)
            }
        }
    }

    func complete() {
        Defaults[.introSeen] = true
        self.onCloseAction?()
        self.onCloseAction = nil

        if let tab = authStore.bvc.tabManager.activeTabs.first {
            authStore.bvc.tabManager.selectTab(tab, notify: false)
        }
    }

    func flushLoggingQueue() {
        // set the default usage collect state if it hasn't been set (default value unchanged)
        if Defaults[.shouldCollectUsageStats] == nil {
            Defaults[.shouldCollectUsageStats] = true
        }

        if Defaults[.shouldCollectUsageStats] == true {
            ClientLogger.shared.flushLoggingQueue()
        }
    }

    func logCounter(
        _ interaction: LogConfig.Interaction,
        attributes: [ClientLogCounterAttribute]? = nil
    ) {
        ClientLogger.shared.logCounter(
            interaction,
            attributes: (attributes ?? []) + [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.source, value: "WelcomeFlow"
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.screenName,
                    value: self.currentScreen.rawValue),
            ]
        )
    }

    func premiumPlanLogAttributeValue() -> String {
        switch self.currentPremiumPlan {
        case .annual:
            return "Annual"
        case .monthly:
            return "Monthly"
        default:
            return "Free"
        }
    }
}
