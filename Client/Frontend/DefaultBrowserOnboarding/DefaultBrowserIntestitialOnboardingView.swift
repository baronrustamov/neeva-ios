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
    @State private var showVideo = false

    @ViewBuilder
    var header: some View {
        if interstitialModel.isInExperimentArm {
            VStack(alignment: .leading) {
                Text("Make Neeva your Default Browser to")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, 10)
                ForEach(interstitialModel.onboardingPageBullets(), id: \.self) { bulletText in
                    HStack {
                        Symbol(decorative: .checkmarkCircleFill, size: 16)
                            .foregroundColor(Color.ui.adaptive.blue)
                        Text(bulletText).withFont(unkerned: .bodyLarge).foregroundColor(
                            Color.ui.gray30)
                    }
                    .padding(.vertical, 5)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            if interstitialModel.isInWelcomeScreenExperimentArms() {
                Text("Make Neeva your Default Browser")
                    .font(.system(size: 32, weight: .bold))
                Text(
                    interstitialModel.bodyForSecondScreenWelcomeExperiment()
                )
                .withFont(.bodyXLarge)
                .foregroundColor(Color.ui.gray30)
            } else {
                Text("Make Neeva your Default Browser")
                    .font(.system(size: 32, weight: .light))
                Text(
                    "Block invasive trackers across the Web. Open links safely with blazing fast browsing and peace of mind."
                )
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    var detail: some View {
        VStack(alignment: .leading) {
            Text("Follow these 3 easy steps:")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .leading) {
            HStack {
                Symbol(decorative: .gear, size: 16)
                    .foregroundColor(.secondaryLabel)
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )
                Text("1. Open Neeva Settings")
                    .withFont(.bodyXLarge)
                    .padding(.leading, 15)
            }
            Divider()
            HStack {
                Symbol(decorative: .chevronForward, size: 16)
                    .foregroundColor(.secondaryLabel)
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )

                Text("2. Tap Default Browser App")
                    .withFont(.bodyXLarge)
                    .padding(.leading, 15)
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

                Text("3. Select Neeva")
                    .withFont(.bodyXLarge)
                    .padding(.leading, 15)
            }
        }.padding(20)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 5)
            )
            .padding(.horizontal, -16)
    }

    @ViewBuilder
    var detailExp: some View {
        VStack(alignment: .leading) {
            Text("Follow these 2 easy steps:")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .leading)
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
                    .padding(.leading, 15)
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
                    .padding(.leading, 15)
            }
        }.padding(20)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 5)
            )
            .padding(.horizontal, -16)
        if NeevaExperiment.arm(for: .defaultBrowserNewScreen) == .newScreenWithVideo {
            Button(
                action: {
                    withAnimation {
                        showVideo.toggle()
                        ClientLogger.shared.logCounter(
                            .DefaultBrowserOnboardingInterstitialVideo
                        )
                    }
                },
                label: {
                    Label("Show me how", systemSymbol: .playCircleFill).withFont(
                        unkerned: .bodyLarge)
                }
            ).padding(.vertical, 20)
        }
    }

    @ViewBuilder
    var content: some View {
        if interstitialModel.isInExperimentArm {
            VStack(alignment: .leading) {
                Spacer().repeated(2)
                header
                Spacer()
                if showSteps || interstitialModel.onboardingState == .openedSettingsState {
                    if NeevaExperiment.arm(for: .defaultBrowserNewScreen) == .newScreenWithVideo {
                        ZStack {
                            if showVideo {
                                VStack {
                                    LoopingPlayer(viewModel: interstitialModel).frame(
                                        width: 320, height: 240
                                    ).cornerRadius(10.0)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10).stroke(
                                                Color.tertiaryLabel, lineWidth: 3)
                                        )
                                }.padding(.bottom, 15)
                            } else {
                                VStack {
                                    detailExp
                                }
                            }
                        }
                    } else {
                        detailExp
                            .padding(.bottom, 15)
                    }
                }
            }
        } else {
            Spacer()
            header
            Spacer()
            detail
            Spacer()
        }
    }

    var body: some View {
        ZStack {
            if interstitialModel.showCloseButton {
                VStack {
                    HStack {
                        Spacer()
                        CloseButton(action: {
                            interstitialModel.closeAction()
                        })
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                        .background(Color.clear)
                    }
                    Spacer()
                }
            }
            DefaultBrowserInterstitialView(
                showSecondaryButton: interstitialModel.showSecondaryOnboardingButton,
                content: content,
                primaryButton: interstitialModel.openButtonText,
                secondaryButton: interstitialModel.showRemindButton
                    && notificationPermissionState
                        == NotificationPermissionStatus.undecided.rawValue
                    ? interstitialModel.remindButtonText : nil,
                primaryAction: {
                    if interstitialModel.isInExperimentArm {
                        // TODO: refactor to use the view model for this action
                        switch interstitialModel.onboardingState {
                        case .initialState:
                            withAnimation {
                                showSteps.toggle()
                                interstitialModel.showSecondaryOnboardingButton = false
                            }
                            interstitialModel.openButtonText = "Continue"
                            interstitialModel.onboardingState = .continueState
                            ClientLogger.shared.logCounter(
                                .DefaultBrowserOnboardingInterstitialOpen)
                        case .continueState:
                            interstitialModel.openButtonText = "Open Neeva Settings"
                            interstitialModel.showSecondaryOnboardingButton = true
                            interstitialModel.openSettingsButtonClickAction(
                                interaction: .DefaultBrowserOnboardingInterstitialContinue
                            )
                            interstitialModel.onboardingState = .openedSettingsState
                        case .openedSettingsState:
                            interstitialModel.openSettingsButtonClickAction(
                                interaction: .DefaultBrowserOnboardingInterstitialOpenAgain
                            )
                        }

                    } else {
                        interstitialModel.openSettingsButtonClickAction()
                    }
                },
                secondaryAction: interstitialModel.showRemindButton
                    && notificationPermissionState
                        == NotificationPermissionStatus.undecided.rawValue
                    ? {
                        interstitialModel.defaultBrowserSecondaryButtonAction()
                    } : nil
            )
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
