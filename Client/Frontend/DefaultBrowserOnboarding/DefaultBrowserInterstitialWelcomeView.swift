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
    var header: some View {
        if interstitialModel.isInWelcomeScreenExperimentArms() {
            Image(interstitialModel.imageForWelcomeExperiment(), bundle: .main).resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 475)
                .border(Color.tertiaryLabel, width: 1).padding(.horizontal, -32)
        } else {
            Text("Welcome to Neeva")
                .font(.system(size: 32, weight: .light))
                .padding(.bottom, 5)
            Text("The first ad-free, private search engine")
                .withFont(.bodyLarge)
        }
    }

    @ViewBuilder
    var detail: some View {
        if interstitialModel.isInWelcomeScreenExperimentArms() {
            VStack(alignment: .leading) {
                Text(interstitialModel.titleForFirstScreenWelcomeExperiment())
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, 5)
                Text(interstitialModel.bodyForFirstScreenWelcomeExperiment())
                    .foregroundColor(Color.ui.gray30)
                    .withFont(.bodyXLarge)
            }
        } else {
            Image("default-browser-prompt", bundle: .main)
                .resizable()
                .frame(width: 300, height: 205)
                .padding(.bottom, 32)
        }
    }

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView()
        } else {
            DefaultBrowserInterstitialView(
                detail: detail,
                header: header,
                primaryButton: interstitialModel.isInWelcomeScreenExperimentArms()
                    ? "Let's go" : "Get Started",
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
