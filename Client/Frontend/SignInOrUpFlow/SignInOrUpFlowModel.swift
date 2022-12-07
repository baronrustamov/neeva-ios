// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

enum SignInOrUpFlowScreen: String, CaseIterable {
    case plans
    case signUp
    case signUpEmail
    case signIn
    case signInQRCode
}

class SignInOrUpFlowModel: ObservableObject {
    var onCloseAction: (() -> Void)?
    var authStore: AuthStore
    @Published var currentScreen: SignInOrUpFlowScreen = .plans
    @Published var prevScreens: [SignInOrUpFlowScreen] = []
    @Published var showCloseButton = true
    @Published var showAllSignUpOptions = false
    @Published var currentPremiumPlan: PremiumPlan? = .annual  // nil is the free plan
    var justSignedIn = false  // is set back to false when the flow is finished see `self.complete`
    var justSignedUp = false  // is set back to false when the flow is finished see `self.complete`

    init(authStore: AuthStore, onCloseAction: (() -> Void)? = nil) {
        self.authStore = authStore
        self.onCloseAction = onCloseAction
    }

    func changeScreenTo(_ screen: SignInOrUpFlowScreen) {
        self.currentScreen = screen
    }

    func goToPreviousScreen() {
        guard let prev = self.prevScreens.popLast() else { return }
        self.currentScreen = prev
    }

    func clearPreviousScreens() {
        self.prevScreens = []
    }

    func complete() {
        self.onCloseAction?()
        self.onCloseAction = nil
        self.justSignedIn = false
        self.justSignedUp = false
    }

    func logCounter(
        _ interaction: LogConfig.Interaction,
        attributes: [ClientLogCounterAttribute]? = nil
    ) {
        ClientLogger.shared.logCounter(
            interaction,
            attributes: (attributes ?? []) + [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.source, value: "SignInOrUpFlow"
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
