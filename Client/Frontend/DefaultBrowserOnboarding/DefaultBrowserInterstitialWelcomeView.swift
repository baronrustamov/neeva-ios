// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

struct DefaultBrowserInterstitialWelcomeView: View {
    @EnvironmentObject var interstitialModel: InterstitialViewModel

    @State private var switchToDefaultBrowserScreen = false

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
                    Text(bulletText).font(.system(size: 16, weight: .bold))
                }
                .padding(.vertical, 5)
            }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 45)
    }

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView()
        } else {
            DefaultBrowserInterstitialView(
                showLogo: true,
                content: DefaultBrowserInterstitialBackdrop(content: content),
                primaryButton: "Let's Go",
                primaryAction: {
                    switchToDefaultBrowserScreen = true
                    ClientLogger.shared.logCounter(.GetStartedInWelcome)
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
        }
    }
}

struct DefaultBrowserInterstitialWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserInterstitialWelcomeView()
    }
}
