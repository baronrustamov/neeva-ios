// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

class DefaultBrowserInterstitialOnboardingViewController: UIHostingController<
    DefaultBrowserInterstitialOnboardingViewController.Content
>
{
    struct Content: View {
        let openSettings: () -> Void
        let onCancel: () -> Void
        let triggerFrom: OpenSysSettingTrigger

        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    CloseButton(action: onCancel)
                        .padding(.trailing, 20)
                        .padding(.top)
                        .background(Color.clear)
                }
                DefaultBrowserInterstitialOnboardingView(
                    showSkipButton: false,
                    skipAction: {},
                    buttonAction: {
                        openSettings()
                    }
                )
            }
        }
    }

    init(didOpenSettings: @escaping () -> Void, triggerFrom: OpenSysSettingTrigger) {
        super.init(rootView: Content(openSettings: {}, onCancel: {}, triggerFrom: triggerFrom))
        self.rootView = Content(
            openSettings: { [weak self] in
                self?.dismiss(animated: true) {
                    UIApplication.shared.openSettings(
                        triggerFrom: triggerFrom
                    )
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
            triggerFrom: triggerFrom
        )
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DefaultBrowserInterstitialOnboardingView: View {
    var fromSkipToBrowser: Bool = false
    var showSkipButton: Bool = true

    var skipAction: () -> Void
    var buttonAction: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading) {
                Text("Make Neeva your Default Browser")
                    .font(.system(size: 32, weight: .light))

                Text(
                    "Block invasive trackers across the Web. Open links safely with blazing fast browsing and peace of mind."
                )
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(alignment: .leading) {
                Text("Follow these 3 easy steps:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 32)
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
                .padding(.horizontal, 16)

            Spacer()

            Button(
                action: {
                    buttonAction()
                    if NeevaUserInfo.shared.hasLoginCookie() || fromSkipToBrowser {
                        ClientLogger.shared.logCounter(
                            .DefaultBrowserOnboardingInterstitialOpen,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.PromoCardAttribute.fromSkipToBrowser,
                                    value: String(fromSkipToBrowser))
                            ]
                        )
                    } else {
                        Defaults[.lastDefaultBrowserPromptInteraction] =
                            LogConfig.Interaction.DefaultBrowserOnboardingInterstitialOpen.rawValue
                    }
                },
                label: {
                    Text("Open Neeva Settings")
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.neeva(.primary))
            .padding(.horizontal, 16)
            if showSkipButton {
                Button(
                    action: {
                        skipAction()
                        if NeevaUserInfo.shared.hasLoginCookie() || fromSkipToBrowser {
                            ClientLogger.shared.logCounter(
                                .DefaultBrowserOnboardingInterstitialSkip,
                                attributes: [
                                    ClientLogCounterAttribute(
                                        key: LogConfig.PromoCardAttribute.fromSkipToBrowser,
                                        value: String(fromSkipToBrowser))
                                ]
                            )
                        } else {
                            Defaults[.lastDefaultBrowserPromptInteraction] =
                                LogConfig.Interaction.DefaultBrowserOnboardingInterstitialSkip.rawValue
                        }
                    },
                    label: {
                        Text("Skip for now")
                            .withFont(.labelLarge)
                            .foregroundColor(.ui.adaptive.blue)
                            .padding(13)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                    }
                )
                .padding(.top, 10)
                .padding(.bottom, 30)
            } else {
                Spacer()
            }
        }
        .padding(.bottom, 20)
    }
}

struct DefaultBrowserInterstitialOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserInterstitialOnboardingView(
            skipAction: {
            },
            buttonAction: {
            }
        )
    }
}
