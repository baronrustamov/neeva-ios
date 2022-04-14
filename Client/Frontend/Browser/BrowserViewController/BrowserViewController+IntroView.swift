// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

// MARK: - Sign In
extension BrowserViewController {
    func presentIntroViewController(
        _ alwaysShow: Bool = false,
        signInMode: Bool = false,
        onOtherOptionsPage: Bool = false,
        marketingEmailOptOut: Bool = false,
        completion: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        if alwaysShow || !Defaults[.introSeen] {
            showProperIntroVC(
                signInMode: signInMode,
                onOtherOptionsPage: onOtherOptionsPage,
                marketingEmailOptOut: marketingEmailOptOut,
                completion: completion,
                onDismiss: onDismiss
            )
        }
    }

    private func showProperIntroVC(
        signInMode: Bool = false, onOtherOptionsPage: Bool = false,
        marketingEmailOptOut: Bool = false, completion: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        introViewModel.onSignInMode = signInMode
        introViewModel.onOtherOptionsPage = onOtherOptionsPage
        introViewModel.marketingEmailOptOut = marketingEmailOptOut
        introViewModel.present { action in
            switch action {
            case .signupWithApple(
                let marketingEmailOptOut, let identityToken, let authorizationCode):
                if let identityToken = identityToken,
                    let authorizationCode = authorizationCode
                {
                    let authURL = NeevaConstants.appleAuthURL(
                        identityToken: identityToken,
                        authorizationCode: authorizationCode,
                        marketingEmailOptOut: marketingEmailOptOut ?? false,
                        signup: true)
                    self.openURLInNewTab(authURL)
                }
            case .skipToBrowser:
                if let onDismiss = onDismiss {
                    onDismiss()
                }
            case .oktaSignin(let email):
                self.openURLFromAuth(NeevaConstants.oktaSigninURL(email: email))
            case .oauthWithProvider(_, _, let token, _):
                // loading appSearchURL to prevent showing marketing site
                self.setTokenAndOpenURL(token: token, url: NeevaConstants.appSearchURL)
            case .oktaAccountCreated(let token):
                self.setTokenAndOpenURL(
                    token: token, url: NeevaConstants.verificationRequiredURL)
            default:
                break
            }

            if NeevaUserInfo.shared.hasLoginCookie() {
                if let notificationToken = Defaults[.notificationToken] {
                    NotificationPermissionHelper.shared
                        .registerDeviceTokenWithServer(deviceToken: notificationToken)
                }
            }

            SpaceStore.shared.refresh(force: true)
        } completion: {
            completion?()
        }
    }

    private func openURLFromAuth(_ url: URL) {
        if tabManager.selectedTab == nil {
            // Open URL in new tab to avoid overriding the user's current tab content.
            openURLInNewTab(url)
        }

        DispatchQueue.main.async {
            self.hideCardGrid(withAnimation: false)
        }
    }

    private func setTokenAndOpenURL(token: String, url: URL) {
        NeevaUserInfo.shared.setLoginCookie(token)

        if let notificationToken = Defaults[.notificationToken] {
            NotificationPermissionHelper.shared
                .registerDeviceTokenWithServer(deviceToken: notificationToken)
        }

        NeevaUserInfo.shared.setLoginCookie(token)
        DispatchQueue.main.async {
            self.openURLFromAuth(url)
        }
    }

    private func introVCPresentHelper(
        introViewController: UIViewController, completion: (() -> Void)?
    ) {
        // On iPad we present it modally in a controller
        if traitCollection.horizontalSizeClass == .regular
            && traitCollection.verticalSizeClass == .regular
        {
            introViewController.preferredContentSize = CGSize(width: 375, height: 667)
            introViewController.modalPresentationStyle = .formSheet
        } else {
            introViewController.modalPresentationStyle = .fullScreen
        }
        present(introViewController, animated: true, completion: completion)
    }
}

// MARK: - Default Browser
extension BrowserViewController {
    func presentDefaultBrowserFirstRun() {
        // TODO: refactor the logic into view model
        overlayManager.presentFullScreenModal(
            content: AnyView(
                DefaultBrowserInterstitialWelcomeScreen {
                    self.overlayManager.hideCurrentOverlay()
                } buttonAction: {
                    self.overlayManager.hideCurrentOverlay()
                }
                .onAppear {
                    AppDelegate.setRotationLock(to: .portrait)
                }
                .onDisappear {
                    AppDelegate.setRotationLock(to: .all)
                }
            )
        ) {
            Defaults[.didShowDefaultBrowserInterstitialFromSkipToBrowser] = true
            Defaults[.introSeen] = true
            Defaults[.firstRunSeenAndNotSignedIn] = true
            ClientLogger.shared.logCounter(
                .DefaultBrowserInterstitialImp
            )
        }
    }

    // Default browser onboarding
    func presentDBOnboardingViewController(
        _ force: Bool = false,
        modalTransitionStyle: UIModalTransitionStyle? = nil,
        triggerFrom: OpenDefaultBrowserOnboardingTrigger
    ) {
        let onboardingVC = DefaultBrowserInterstitialOnboardingViewController(
            didOpenSettings: { [weak self] in
                guard let self = self else { return }
                self.zeroQueryModel.updateState()
            }, triggerFrom: triggerFrom)

        onboardingVC.modalPresentationStyle = .formSheet

        if let modalTransitionStyle = modalTransitionStyle {
            onboardingVC.modalTransitionStyle = modalTransitionStyle
        }

        present(onboardingVC, animated: true, completion: nil)
    }
}
