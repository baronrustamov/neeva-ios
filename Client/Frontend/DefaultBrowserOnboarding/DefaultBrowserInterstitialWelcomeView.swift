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
        if interstitialModel.isInExperimentArm {
            ZStack(alignment: .top) {
                VStack {
                    Image("welcome-gradient", bundle: .main).resizable()
                        .frame(height: 400)
                        .padding(.horizontal, -32)
                        .ignoresSafeArea()
                }
                VStack {
                    Spacer()
                    Image("welcome-logo", bundle: .main)
                        .frame(width: 100, height: 20)
                    Spacer()
                    ZStack {
                        Color.white.clipShape(RoundedRectangle(cornerRadius: 20))
                        VStack(alignment: .leading) {
                            Image("welcome-shield", bundle: .main).frame(width: 32, height: 32)
                            Text("Privacy Made Easy")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color.ui.adaptive.blue)
                            ForEach(interstitialModel.welcomePageBullets(), id: \.self) {
                                bulletText in
                                HStack {
                                    Symbol(decorative: .checkmarkCircleFill, size: 16)
                                        .foregroundColor(Color.ui.adaptive.blue)
                                    Text(bulletText).withFont(unkerned: .bodyLarge).foregroundColor(
                                        Color(white: 0.3))
                                }
                                .padding(.vertical, 5)
                            }
                        }.padding(48).frame(width: 315).overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.ui.gray96, lineWidth: 2)
                        )
                    }
                    .fixedSize()
                    .padding(.top, 10)
                    Spacer()
                }
            }
            Spacer()
        } else {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Image("neeva_interstitial_welcome_page_privacy", bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 475)
                        .border(Color.tertiaryLabel, width: 1).padding(.horizontal, -32)
                        .padding(.top, 30)
                }
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Privacy Made Easy")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, 5)
                Text(
                    "You’re just a step away from ad-free search, and browsing without ads, trackers or pop-ups"
                )
                .foregroundColor(Color.ui.gray30)
                .withFont(.bodyXLarge)
            }
            Spacer()
        }
    }

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView()
        } else {
            DefaultBrowserInterstitialView(
                content: content,
                primaryButton: interstitialModel.isInExperimentArm
                    ? "Let's Go" : "Get Started",
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
