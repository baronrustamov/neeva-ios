// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct WelcomeFlowDefaultBrowserView: View {
    @ObservedObject var model: WelcomeFlowModel

    var bullets = [
        ("Protected", "Open links without trackers and pop-ups"),
        ("Faster", "Browse the web with no ads in your way"),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            WelcomeFlowHeaderView(text: "Make Neeva your default browser")

            Spacer()

            ForEach(bullets, id: \.self.0) { (primary, secondary) in
                HStack(alignment: .top) {
                    Symbol(decorative: .checkmark, size: 20)
                        .foregroundColor(Color.ui.adaptive.blue)
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey(primary)).font(.system(size: 18, weight: .bold))
                        Text(LocalizedStringKey(secondary)).font(.system(size: 14))
                    }
                }
                .padding(.vertical, 10)
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("Follow these 2 easy steps:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

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
                    .stroke(Color(UIColor.systemGray5), lineWidth: 3)
            )

            Spacer()

            Group {
                Button(
                    action: {
                        if model.defaultBrowserContinueMode {
                            model.logCounter(.DefaultBrowserOnboardingInterstitialOpenAgain)
                        } else {
                            model.logCounter(.DefaultBrowserOnboardingInterstitialOpen)
                        }

                        Defaults[.welcomeFlowRestoreToDefaultBrowser] = true
                        model.defaultBrowserContinueMode = true
                        model.showCloseButton = true
                        UIApplication.shared.openSettings(triggerFrom: .defaultBrowserFirstScreen)
                    },
                    label: {
                        Text(
                            model.defaultBrowserContinueMode
                                ? "Back to settings" : "Open Neeva settings"
                        )
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(.neeva(.primary))

                Button(
                    action: {
                        if model.defaultBrowserContinueMode {
                            // do not schedule reminder, just complete
                            model.logCounter(
                                .DefaultBrowserOnboardingInterstitialContinueToNeeva)
                        } else {
                            // schedule a reminder, then complete
                            model.logCounter(.DefaultBrowserOnboardingInterstitialRemind)
                            model.scheduleDefaultBrowserReminder()
                        }
                        model.complete()
                    },
                    label: {
                        Text(
                            model.defaultBrowserContinueMode
                                ? "Continue to Neeva" : "Remind me later"
                        )
                        .withFont(.labelLarge)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(.neeva(.secondary))
            }

            Spacer()
        }
        .onAppear {
            model.logCounter(.ScreenImpression)

            model.flushLoggingQueue()
        }
    }
}
