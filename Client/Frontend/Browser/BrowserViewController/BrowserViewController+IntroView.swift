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
        // Confirm a introView isn't already visible.
        guard !introViewModel.isDisplaying else {
            return
        }

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
        DispatchQueue.main.async {
            self.openURLInNewTab(url)
            self.hideCardGrid(withAnimation: false)
        }
    }

    private func setTokenAndOpenURL(token: String, url: URL) {
        NeevaUserInfo.shared.setLoginCookie(token)

        if let notificationToken = Defaults[.notificationToken] {
            NotificationPermissionHelper.shared
                .registerDeviceTokenWithServer(deviceToken: notificationToken)
        }

        let httpCookieStore = self.tabManager.configuration.websiteDataStore.httpCookieStore
        httpCookieStore.setCookie(NeevaConstants.loginCookie(for: token)) {
            DispatchQueue.main.async {
                self.openURLFromAuth(url)
            }
        }
    }
}

// MARK: - Welcome flow
extension BrowserViewController {
    func presentWelcomeFlow(startScreen: WelcomeFlowScreen?) {
        let welcomeFlowModel = WelcomeFlowModel(
            authStore: AuthStore(bvc: self),
            onCloseAction: {
                self.overlayManager.hideCurrentOverlay()
            }
        )
        if let startScreen = startScreen {
            // handle restoring from the default browser screen
            if startScreen == .defaultBrowser {
                welcomeFlowModel.defaultBrowserContinueMode = true
                welcomeFlowModel.showCloseButton = true
            }

            welcomeFlowModel.currentScreen = startScreen
        }

        overlayManager.presentFullScreenCover(
            content: AnyView(
                WelcomeFlowView(model: welcomeFlowModel)
                    .onAppear {
                        /*
                         NOTE: orientation locking does not work on iPads
                         without breaking multitasking support
                         https://stackoverflow.com/a/55528118
                        */
                        AppDelegate.setRotationLock(to: .portrait)
                    }
                    .onDisappear {
                        AppDelegate.setRotationLock(to: .all)
                    }
            ),
            ignoreSafeArea: true
        ) {
            // noop
        }
    }
}

// MARK: - Sign In or Up
extension BrowserViewController {
    func presentSignInOrUpFlow(
        startScreen: SignInOrUpFlowScreen?, onCompleteDismissZeroQuery: Bool = false
    ) {
        let signInOrUpFlowModel = SignInOrUpFlowModel(
            authStore: AuthStore(bvc: self),
            onCloseAction: {
                self.overlayManager.hideCurrentOverlay()

                if onCompleteDismissZeroQuery {
                    self.dismissEditingAndHideZeroQuery()
                }
            }
        )

        if let startScreen = startScreen {
            signInOrUpFlowModel.currentScreen = startScreen
        }

        overlayManager.presentFullScreenCover(
            content: AnyView(
                SignInOrUpFlowView(model: signInOrUpFlowModel)
                    .onAppear {
                        /*
                         NOTE: orientation locking does not work on iPads
                         without breaking multitasking support
                         https://stackoverflow.com/a/55528118
                        */
                        AppDelegate.setRotationLock(to: .portrait)
                    }
                    .onDisappear {
                        AppDelegate.setRotationLock(to: .all)
                    }
            ),
            ignoreSafeArea: true
        ) {
            // noop
        }
    }
}

// MARK: - Default Browser
extension BrowserViewController {
    // TODO: clean up unused code paths in favor of new welcome flow
    func presentDefaultBrowserFirstRun() {
        let interstitialModel = InterstitialViewModel(
            onCloseAction: {
                self.overlayManager.hideCurrentOverlay()
            }
        )
        self.interstitialViewModel = interstitialModel
        overlayManager.presentFullScreenModal(
            content: AnyView(
                DefaultBrowserInterstitialWelcomeView()
                    .onAppear {
                        AppDelegate.setRotationLock(to: .portrait)
                    }
                    .onDisappear {
                        AppDelegate.setRotationLock(to: .all)
                    }
                    .environmentObject(interstitialModel)
            ),
            ignoreSafeArea: false
        ) {
            Defaults[.didShowDefaultBrowserInterstitialFromSkipToBrowser] = true
            Defaults[.introSeen] = true
            Defaults[.firstRunSeenAndNotSignedIn] = true
            Defaults[.didDismissDefaultBrowserInterstitial] = false
            Defaults[.introSeenDate] = Date()
            ClientLogger.shared.logCounter(
                .DefaultBrowserInterstitialImp
            )
        }
    }

    func restoreDefaultBrowserFirstRun() {
        let interstitialModel = InterstitialViewModel(
            restoreFromBackground: true,
            onboardingState: .openedSettingsState,
            onCloseAction: {
                self.overlayManager.hideCurrentOverlay()
            }
        )
        overlayManager.presentFullScreenModal(
            content: AnyView(
                DefaultBrowserInterstitialOnboardingView()
                    .onAppear {
                        AppDelegate.setRotationLock(to: .portrait)
                    }
                    .onDisappear {
                        AppDelegate.setRotationLock(to: .all)
                    }
                    .environmentObject(interstitialModel)
            ),
            animate: false,
            ignoreSafeArea: false
        ) {
            ClientLogger.shared.logCounter(
                .DefaultBrowserInterstitialRestoreImp
            )
        }
    }

    // Default browser onboarding
    func presentDBOnboardingViewController(
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
