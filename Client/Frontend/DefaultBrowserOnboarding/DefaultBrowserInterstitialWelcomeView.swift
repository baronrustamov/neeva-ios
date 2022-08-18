// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct DefaultBrowserInterstitialWelcomeView: View {
    @EnvironmentObject var interstitialModel: InterstitialViewModel

    @State private var switchToDefaultBrowserScreen = false
    @State private var collectUsageStatsCheckbox = true

    var termsButton: some View {
        SafariVCLink("Terms of Service", url: NeevaConstants.appTermsURL)
    }

    var privacyButton: some View {
        SafariVCLink("Privacy Policy", url: NeevaConstants.appPrivacyURL)
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading) {
            Text("Neeva puts you in charge of\nyour life online.")
                .font(.system(size: UIConstants.hasHomeButton ? 24 : 36, weight: .bold))
                .padding(.bottom, 15)
            ForEach(interstitialModel.welcomePageBullets(), id: \.self) {
                bulletText in
                HStack {
                    Symbol(decorative: .checkmarkCircleFill, size: 20)
                        .foregroundColor(Color.ui.adaptive.blue)
                    Text(LocalizedStringKey(bulletText)).font(.system(size: 16, weight: .bold))
                }
                .padding(.vertical, 5)
            }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 45)
    }

    @ViewBuilder
    var footerContent: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Button(action: {
                    collectUsageStatsCheckbox.toggle()
                }) {
                    collectUsageStatsCheckbox
                        ? Symbol(decorative: .checkmarkCircleFill, size: 20)
                            .foregroundColor(Color.blue)
                        : Symbol(decorative: .circle, size: 20)
                            .foregroundColor(Color.tertiaryLabel)
                    Text("Help improve this app by sending usage statistics to Neeva.")
                        .withFont(.bodyMedium)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 18)
            .padding(.horizontal, 30)
            HStack {
                termsButton
                Text("·").foregroundColor(.secondaryLabel)
                privacyButton
            }
            .withFont(unkerned: .bodySmall)
            .padding(.bottom, 15)
        }
    }

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView()
        } else {
            DefaultBrowserInterstitialView(
                content: DefaultBrowserInterstitialBackdrop(content: content),
                footerContent: footerContent,
                primaryButton: "Let's Go",
                primaryAction: {
                    switchToDefaultBrowserScreen = true
                    ClientLogger.shared.logCounter(.GetStartedInWelcome)
                    Defaults[.shouldCollectUsageStats] = collectUsageStatsCheckbox
                    if Defaults[.shouldCollectUsageStats] == true {
                        ClientLogger.shared.flushLoggingQueue()
                    }
                }
            )
            .onAppear {
                if !Defaults[.firstRunImpressionLogged] {
                    ClientLogger.shared.logCounter(
                        .FirstRunImpression,
                        attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                    ConversionLogger.log(event: .launchedApp)
                    Defaults[.firstRunImpressionLogged] = true
                }
            }
            .onDisappear {
                Defaults[.shouldCollectUsageStats] = collectUsageStatsCheckbox
                if Defaults[.shouldCollectUsageStats] == true {
                    ClientLogger.shared.flushLoggingQueue()
                }
            }
        }
    }
}

struct DefaultBrowserInterstitialWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserInterstitialWelcomeView()
    }
}
