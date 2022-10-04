// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct WelcomeFlowIntroView: View {
    @ObservedObject var model: WelcomeFlowModel

    // TODO: persist this in the view model?
    @State private var collectUsageStats = Defaults[.shouldCollectUsageStats] ?? true

    var bullets = [
        ("Private", "Search anonymously and block trackers"),
        ("Unbiased", "No advertisers controlling what you see"),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            WelcomeFlowHeaderView(
                text: "Search and browse, free from corporate influence", alignment: .leading)

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

            Group {
                Button(
                    action: {
                        model.logCounter(.GetStartedInWelcome)

                        if PremiumStore.shared.loadingProducts {
                            /*
                             NOTE: We do nothing here on purpose. I would rather have
                             disabled the button until we know products are done loading.
                             However we can't do that statically since using the `PremiumStore`
                             requires iOS 15. The good news is that only a very long lag
                             will make this something a user notices.
                             */
                        } else if PremiumStore.isOfferedInCountry() {
                            model.clearPreviousScreens()
                            model.changeScreenTo(.plans)
                        } else {
                            model.clearPreviousScreens()
                            model.changeScreenTo(.defaultBrowser)
                        }
                    },
                    label: {
                        Text("Let's Go")
                            .withFont(.labelLarge)
                            .foregroundColor(.brand.white)
                            .frame(maxWidth: .infinity)
                    }
                )
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

            Spacer()

            WelcomeFlowPrivacyAndTermsLinksView()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .onAppear {
            model.logCounter(.ScreenImpression)
        }
    }
}
