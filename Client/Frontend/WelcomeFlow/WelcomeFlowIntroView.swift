// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct WelcomeFlowIntroView: View {
    @ObservedObject var model: WelcomeFlowModel
    @ObservedObject var premiumStore: PremiumStore = PremiumStore.shared

    // TODO: persist this in the view model?
    @State private var collectUsageStats = Defaults[.shouldCollectUsageStats] ?? true

    var bullets = [
        ("Private", "Search anonymously and block trackers"),
        ("Unbiased", "No advertisers controlling what you see"),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            WelcomeFlowHeaderView(
                text: "Search and browse, free from corporate influence", alignment: .leading
            )
            .padding(.bottom)

            ForEach(bullets, id: \.self.0) { (primary, secondary) in
                HStack(alignment: .top) {
                    Symbol(decorative: .checkmark, size: 20)
                        .foregroundColor(Color.ui.adaptive.blue)
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey(primary)).font(.system(size: 18, weight: .bold))
                        Text(LocalizedStringKey(secondary)).font(.system(size: 14))
                    }
                }
                .padding(.bottom)
            }

            Spacer()

            Group {
                Button(
                    action: {
                        model.logCounter(.GetStartedInWelcome)

                        if PremiumStore.isOfferedInLanguage()
                            && premiumStore.products.count > 0
                        {
                            model.clearPreviousScreens()
                            model.changeScreenTo(.plans)
                        } else {
                            model.clearPreviousScreens()
                            model.changeScreenTo(.defaultBrowser)
                        }
                    },
                    label: {
                        Text(premiumStore.loadingProducts ? "Loading..." : "Let's Go")
                            .withFont(.labelLarge)
                            .foregroundColor(.brand.white)
                            .frame(maxWidth: .infinity)

                    }
                )
                .disabled(premiumStore.loadingProducts)
                .buttonStyle(.neeva(.primary))

                Button(
                    action: {
                        model.logCounter(.SignInClick)
                        model.changeScreenTo(.signIn)
                        model.prevScreens.append(.intro)
                    },
                    label: {
                        Text("Already have an account? Sign in")
                            .withFont(.labelLarge)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(.neeva(.secondary))
                .padding(.bottom)
            }

            Spacer()

            HStack {
                Button(action: { collectUsageStats.toggle() }) {
                    collectUsageStats
                        ? Symbol(decorative: .checkmarkCircleFill, size: 20)
                            .foregroundColor(Color.blue)
                        : Symbol(decorative: .circle, size: 20)
                            .foregroundColor(Color.tertiaryLabel)
                    Text("Help improve this app by sending usage statistics to Neeva.")
                        .withFont(.bodyMedium)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .onChange(of: collectUsageStats) { newValue in
                    Defaults[.shouldCollectUsageStats] = newValue
                }
            }
            .padding(.bottom, 18)
            .padding(.horizontal, 30)

            WelcomeFlowPrivacyAndTermsLinksView()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .onAppear {
            model.logCounter(.ScreenImpression)
        }
    }
}
