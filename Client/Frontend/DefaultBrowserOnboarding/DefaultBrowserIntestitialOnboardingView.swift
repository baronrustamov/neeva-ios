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
    var oldHeader: some View {
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
    }

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
        .padding(.horizontal, FeatureFlag[.oldDBFirstRun] ? 0 : 45)

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
                    .padding(.leading, FeatureFlag[.oldDBFirstRun] ? 15 : 8)
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
                    .padding(.leading, FeatureFlag[.oldDBFirstRun] ? 15 : 8)
            }
        }.padding(FeatureFlag[.oldDBFirstRun] ? 20 : 15)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 5)
            )
            .padding(.horizontal, FeatureFlag[.oldDBFirstRun] ? -16 : 40)
        if NeevaExperiment.arm(for: .defaultBrowserVideo) == .video {
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
                    if FeatureFlag[.oldDBFirstRun] {
                        Label("Show me how", systemSymbol: .playCircleFill).withFont(
                            unkerned: .bodyXLarge)
                    } else {
                        HStack {
                            Symbol(decorative: .playCircleFill, size: 20)
                                .frame(width: 32, height: 32)
                            Text("Show Me How").font(.system(size: 16, weight: .medium))
                        }
                    }
                }
            )
            .padding(.top, FeatureFlag[.oldDBFirstRun] ? 20 : 30)
            .padding(.bottom, FeatureFlag[.oldDBFirstRun] ? 20 : 10)
        }
    }

    @ViewBuilder
    var oldContent: some View {
        VStack(alignment: .leading) {
            Spacer().repeated(2)
            oldHeader
            Spacer()
            if NeevaExperiment.arm(for: .defaultBrowserVideo) == .video {
                ZStack {
                    if showVideo {
                        VStack(alignment: .center) {
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
                            detail
                        }
                    }
                }
            } else {
                detail
                    .padding(.bottom, 15)
            }
        }
    }

    @ViewBuilder
    var newHeader: some View {
        VStack(alignment: .leading) {
            Text("Want to use\nNeeva for all your browsing?")
                .font(.system(size: UIConstants.hasHomeButton ? 24 : 36, weight: .bold))
                .padding(.bottom, 15)

            Text("Make Neeva your default browser.")
                .font(.system(size: 16, weight: .bold))
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 45)
    }

    @ViewBuilder
    var newContent: some View {
        newHeader
        Spacer()
        if NeevaExperiment.arm(for: .defaultBrowserVideo) == .video {
            ZStack {
                if showVideo {
                    HStack {
                        Spacer()
                        VStack {
                            LoopingPlayer(viewModel: interstitialModel).frame(
                                width: 320, height: 240
                            ).cornerRadius(10.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10).stroke(
                                        Color.tertiaryLabel, lineWidth: 3)
                                )
                        }
                        .padding(.bottom, 15)
                        Spacer()
                    }
                } else {
                    VStack {
                        detail
                    }
                }
            }
        } else {
            detail
                .padding(.bottom, 15)
        }
    }

    @ViewBuilder
    var content: some View {
        if FeatureFlag[.oldDBFirstRun] {
            oldContent
        } else {
            DefaultBrowserInterstitialBackdrop(content: newContent)
        }
    }

    var body: some View {
        ZStack {
            DefaultBrowserInterstitialView(
                content: content,
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
                    if !FeatureFlag[.oldDBFirstRun] {
                        Spacer().frame(height: UIConstants.hasHomeButton ? 10 : 50)
                    }
                    HStack {
                        Spacer()
                        CloseButton(action: {
                            interstitialModel.closeAction()
                        })
                        .padding(.trailing, FeatureFlag[.oldDBFirstRun] ? 20 : 10)
                        .padding(.top, FeatureFlag[.oldDBFirstRun] ? 20 : 16)
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
