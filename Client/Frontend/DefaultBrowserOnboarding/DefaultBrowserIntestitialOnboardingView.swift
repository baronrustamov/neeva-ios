// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

public enum DefaultBrowserInterstitialChoice: Int {
    case undecided = 0
    case openSettings = 1
    case skipForNow = 2
}

class DefaultBrowserInterstitialOnboardingViewController: UIHostingController<
    DefaultBrowserInterstitialOnboardingViewController.Content
>
{
    struct Content: View {
        let openSettings: () -> Void
        let onCancel: () -> Void
        let onDismiss: () -> Void
        let triggerFrom: OpenDefaultBrowserOnboardingTrigger

        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    CloseButton(action: onCancel)
                        .padding(.trailing, 20)
                        .padding(.top)
                        .background(Color.clear)
                }
                DefaultBrowserInterstitialOnboardingView()
                    .environmentObject(
                        InterstitialViewModel(
                            trigger: triggerFrom,
                            showCloseButton: false,
                            onboardingState: .openedSettingsState,
                            onOpenSettingsAction: {
                                openSettings()
                            },
                            onCloseAction: {
                                onDismiss()
                            }
                        )
                    )
            }
        }
    }

    init(didOpenSettings: @escaping () -> Void, triggerFrom: OpenDefaultBrowserOnboardingTrigger) {
        super.init(
            rootView: Content(
                openSettings: {}, onCancel: {}, onDismiss: {}, triggerFrom: triggerFrom))
        self.rootView = Content(
            openSettings: { [weak self] in
                self?.dismiss(animated: true) {
                    didOpenSettings()
                }
                // Don't show default browser card if this button is tapped
                Defaults[.didDismissDefaultBrowserCard] = true
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true) {
                    ClientLogger.shared.logCounter(
                        .DismissDefaultBrowserOnboardingScreen,
                        attributes: [
                            ClientLogCounterAttribute(
                                key: LogConfig.UIInteractionAttribute.openSysSettingTriggerFrom,
                                value: triggerFrom.rawValue
                            )
                        ]
                    )
                }

            },
            onDismiss: { [weak self] in
                self?.dismiss(animated: true) {

                }
            },
            triggerFrom: triggerFrom
        )
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum OpenDefaultBrowserOnboardingTrigger: String {
    case defaultBrowserFirstScreen
    case defaultBrowserPromoCard
    case defaultBrowserSettings
    case defaultBrowserReminderNotification

    var defaultBrowserIntent: Bool {
        true  // Update if we ever have other reasons to guide users to system settings.
    }
}

struct DefaultBrowserInterstitialOnboardingView: View {
    @EnvironmentObject var interstitialModel: InterstitialViewModel

    @Default(.notificationPermissionState) var notificationPermissionState

    @State private var showSteps = false

    @ViewBuilder
    var detail: some View {
        VStack(alignment: .leading) {
            Text("Follow these 2 easy steps:")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 45)

        VStack(alignment: .leading) {
            HStack {
                Symbol(decorative: .chevronForward, size: 16)
                    .foregroundColor(.secondaryLabel)
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )

                Text("1. Tap Default Browser App")
                    .withFont(.bodyXLarge)
                    .padding(.leading, 8)
            }
            Divider()
            HStack {
                Image("neevaMenuIcon")
                    .frame(width: 32, height: 32)
                    .background(Color(.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text("2. Select Neeva")
                    .withFont(.bodyXLarge)
                    .padding(.leading, 8)
            }
        }
        .padding(15)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor.systemGray5), lineWidth: 5)
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading) {
            Text("Make Neeva your Default Browser")
                .font(.system(size: UIConstants.hasHomeButton ? 24 : 36, weight: .bold))
                .padding(.bottom, 10)

            ForEach(interstitialModel.onboardingPageBullets(), id: \.self) { bulletText in
                HStack {
                    Symbol(decorative: .checkmarkCircleFill, size: 16)
                        .foregroundColor(Color.ui.adaptive.blue)
                    Text(bulletText).font(.system(size: 16, weight: .bold))
                }
                .padding(.vertical, 5)
            }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 45)
    }

    @ViewBuilder
    var content: some View {
        header
        Spacer()
        detail
            .padding(.bottom, 15)
    }

    var body: some View {
        ZStack {
            DefaultBrowserInterstitialView(
                content: DefaultBrowserInterstitialBackdrop(content: content),
                primaryButton: interstitialModel.openButtonText,
                secondaryButton: interstitialModel.showRemindButton
                    && notificationPermissionState
                        == NotificationPermissionStatus.undecided.rawValue
                    ? interstitialModel.remindButtonText : nil,
                primaryAction: {
                    // TODO: refactor to use the view model for this action
                    switch interstitialModel.onboardingState {
                    case .initialState:
                        interstitialModel.openButtonText = "Back to Settings"
                        interstitialModel.remindButtonText = "Continue to Neeva"
                        interstitialModel.openSettingsButtonClickAction(
                            interaction: .DefaultBrowserOnboardingInterstitialOpen
                        )
                        interstitialModel.onboardingState = .openedSettingsState
                    case .openedSettingsState:
                        interstitialModel.openSettingsButtonClickAction(
                            interaction: .DefaultBrowserOnboardingInterstitialOpenAgain
                        )
                    }
                },
                secondaryAction: interstitialModel.showRemindButton
                    && notificationPermissionState
                        == NotificationPermissionStatus.undecided.rawValue
                    ? {
                        interstitialModel.defaultBrowserSecondaryButtonAction()
                    } : nil
            )
            if interstitialModel.showCloseButton {
                VStack {
                    Spacer().frame(height: UIConstants.hasHomeButton ? 10 : 50)
                    HStack {
                        Spacer()
                        CloseButton(action: {
                            interstitialModel.closeAction()
                        })
                        .padding(.trailing, 10)
                        .padding(.top, 16)
                        .background(Color.clear)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            interstitialModel.onboardingAppearTimestamp = Date()
        }
        .onDisappear {
            if !interstitialModel.didTakeAction {
                interstitialModel.closeAction()
            }
            Defaults[.didDismissDefaultBrowserInterstitial] = true
            interstitialModel.player = nil

            if let appearTime = interstitialModel.onboardingAppearTimestamp {
                let timeSpent = appearTime.timeDiffInMilliseconds(from: Date())
                ClientLogger.shared.logCounter(
                    .DefaultBrowserOnboardingInterstitialScreenTime,
                    attributes: [
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.InterstitialTimeSpent,
                            value: String(timeSpent)
                        )
                    ]
                )
            }
        }
    }
}

struct DefaultBrowserInterstitialOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserInterstitialOnboardingView()
    }
}
