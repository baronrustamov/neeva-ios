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
                DefaultBrowserInterstitialOnboardingView(
                    trigger: triggerFrom,
                    showSkipButton: false,
                    skipAction: {},
                    buttonAction: {
                        openSettings()
                    }
                )
            }
        }
    }

    init(didOpenSettings: @escaping () -> Void, triggerFrom: OpenDefaultBrowserOnboardingTrigger) {
        super.init(rootView: Content(openSettings: {}, onCancel: {}, triggerFrom: triggerFrom))
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
            triggerFrom: triggerFrom
        )
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DefaultBrowserInterstitialWelcomeScreen: View {
    @State private var switchToDefaultBrowserScreen = false

    var isInDefaultBrowserEnhancementExp: Bool = false

    var skipAction: () -> Void
    var buttonAction: () -> Void

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView(
                trigger: .defaultBrowserFirstScreen,
                isInDefaultBrowserEnhancementExp: isInDefaultBrowserEnhancementExp,
                skipAction: skipAction,
                buttonAction: buttonAction
            )
        } else {
            VStack(spacing: 0) {
                VStack(spacing: 30) {
                    Spacer().repeated(2)
                    VStack(alignment: .leading) {
                        Text("Welcome to Neeva")
                            .font(.system(size: 32, weight: .light))
                            .padding(.bottom, 5)
                        Text("The first ad-free, private search engine")
                            .withFont(.bodyLarge)
                    }

                    Image("default-browser-prompt", bundle: .main)
                        .resizable()
                        .frame(width: 300, height: 205)
                        .padding(.bottom, 32)
                    Spacer().repeated(2)
                    Button(
                        action: {
                            switchToDefaultBrowserScreen = true
                            ClientLogger.shared.logCounter(.GetStartedInWelcome)
                        },
                        label: {
                            Text("Get Started")
                                .withFont(.labelLarge)
                                .foregroundColor(.brand.white)
                                .padding(13)
                                .frame(maxWidth: .infinity)
                        }
                    )
                    .buttonStyle(.neeva(.primary))

                    Spacer()
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 35)
            .onAppear {
                if !Defaults[.firstRunImpressionLogged] {
                    ClientLogger.shared.logCounter(
                        .FirstRunImpression,
                        attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                    ConversionLogger.log(event: .launchedApp)
                    Defaults[.firstRunImpressionLogged] = true
                }
            }
        }
    }
}

// TODO merge this with the settings trigger as we are standardize the default browser screen now
public enum OpenDefaultBrowserOnboardingTrigger: String {
    case defaultBrowserFirstScreen
    case defaultBrowserPromoCard
    case defaultBrowserSettings
    case defaultBrowserReminderNotification

    var defaultBrowserIntent: Bool {
        true  // Update if we ever have other reasons to guide users to system settings.
    }
}

struct DefaultBrowserEducationView: View {
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    @State private var currentIdx = 0

    @State private var fontWeights: [Font.Weight] = [.medium, .light, .light]

    var animateInstructions: Bool = false

    let numOfImgs = 3

    var body: some View {
        //VStack {
        if animateInstructions {
            TabView(selection: $currentIdx) {
                ForEach(0..<numOfImgs, id: \.self) { num in
                    Image("default-browser-education-\(num)")
                        .resizable()
                        .scaledToFill()
                        .tag(num)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 180)
            .onReceive(timer) { _ in
                withAnimation(.linear(duration: 0.5)) {
                    currentIdx = currentIdx < numOfImgs - 1 ? currentIdx + 1 : 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        for i in 0..<fontWeights.count {
                            fontWeights[i] = (i == currentIdx) ? .medium : .light
                        }
                    }
                }
            }
        } else {
            Spacer()
            VStack(alignment: .leading) {
                Text("Follow these 3 easy steps:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 32)
        }

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
                    .fontWeight(fontWeights[0])
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
                    .fontWeight(fontWeights[1])
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
                    .fontWeight(fontWeights[2])
                    .withFont(.bodyXLarge)
                    .padding(.leading, 15)
            }
        }
        .padding(20)
        .if(!animateInstructions) { view in
            view.overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 5)
            )
        }
        .padding(.horizontal, 16)
        //}
    }
}

struct DefaultBrowserInterstitialOnboardingView: View {
    @State private var didTakeAction = false

    var trigger: OpenDefaultBrowserOnboardingTrigger = .defaultBrowserFirstScreen
    var showSkipButton: Bool = true
    var isInDefaultBrowserEnhancementExp: Bool = false

    var skipAction: () -> Void
    var buttonAction: () -> Void

    var body: some View {
        ZStack {
            if isInDefaultBrowserEnhancementExp {
                VStack {
                    HStack {
                        Spacer()
                        CloseButton(action: {
                            tapSkip()
                            didTakeAction = true
                        })
                        .padding(.trailing, 20)
                        .padding(.top, 40)
                        .background(Color.clear)
                    }
                    Spacer()
                }
            }
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

                DefaultBrowserEducationView(animateInstructions: true)

                Spacer()

                Button(
                    action: {
                        buttonAction()
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
                            isInDefaultBrowserEnhancementExp ? tapRemindMe() : tapSkip()
                            didTakeAction = true
                        },
                        label: {
                            Text(
                                isInDefaultBrowserEnhancementExp
                                    ? "Remind Me Later" : "Skip for Now"
                            )
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
        }
        .onDisappear {
            if !didTakeAction {
                tapSkip()
            }
        }
        .padding(.bottom, 20)
    }

    private func tapRemindMe() {
        NotificationPermissionHelper.shared.requestPermissionIfNeeded(
            completion: { authorized in
                if authorized {
                    LocalNotifications.scheduleNeevaOnboardingCallback(
                        notificationType: .neevaOnboardingDefaultBrowser)
                }
            }, openSettingsIfNeeded: false, callSite: .defaultBrowserInterstitial
        )
        skipAction()
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

    private func tapSkip() {
        skipAction()
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
