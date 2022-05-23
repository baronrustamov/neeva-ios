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
                            showRemindButton:
                                NeevaExperiment.arm(for: .defaultBrowserChangeButton)
                                == .changeButton,
                            inButtonTextExperiment:
                                NeevaExperiment.arm(for: .defaultBrowserChangeButton)
                                == .changeButton,
                            showCloseButton: false,
                            onOpenSettingsAction: {
                                openSettings()
                            }
                        )
                    )
            }
        }
    }

    init(didOpenSettings: @escaping () -> Void, triggerFrom: OpenDefaultBrowserOnboardingTrigger) {
        super.init(rootView: Content(openSettings: {}, onCancel: {}, triggerFrom: triggerFrom))
        self.rootView = Content(
            openSettings: { [weak self] in
                if NeevaExperiment.arm(for: .defaultBrowserChangeButton) == .changeButton {
                    didOpenSettings()
                } else {
                    self?.dismiss(animated: true) {
                        didOpenSettings()
                    }
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

    @ViewBuilder
    var header: some View {
        Text("Make Neeva your Default Browser")
            .font(.system(size: 32, weight: .light))
        Text(
            "Block invasive trackers across the Web. Open links safely with blazing fast browsing and peace of mind."
        )
        .withFont(.bodyLarge)
        .foregroundColor(.secondaryLabel)
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
        VStack(alignment: .leading, spacing: 10) {
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

    var body: some View {
        ZStack {
            if !interstitialModel.inButtonTextExperiment && interstitialModel.showCloseButton {
                VStack {
                    HStack {
                        Spacer()
                        CloseButton(action: {
                            interstitialModel.closeAction()
                        })
                        .padding(.trailing, 20)
                        .padding(.top, 40)
                        .background(Color.clear)
                    }
                    Spacer()
                }
            }
            DefaultBrowserInterstitialView(
                detail: detail,
                header: header,
                primaryButton: interstitialModel.openButtonText,
                secondaryButton: interstitialModel.showRemindButton
                    ? interstitialModel.remindButtonText : nil,
                primaryAction: {
                    interstitialModel.openSettingsButtonClickAction()
                },
                secondaryAction: interstitialModel.showRemindButton
                    ? {
                        interstitialModel.defaultBrowserSecondaryButtonAction()
                    } : nil
            )
        }
        .onDisappear {
            if !interstitialModel.didTakeAction {
                interstitialModel.closeAction()
            }
            Defaults[.didDismissDefaultBrowserInterstitial] = true
        }
    }
}

struct DefaultBrowserInterstitialOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserInterstitialOnboardingView()
    }
}
