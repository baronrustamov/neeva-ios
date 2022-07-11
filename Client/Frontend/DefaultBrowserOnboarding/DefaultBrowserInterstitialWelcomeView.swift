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
    var oldContent: some View {
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
                    }
                    .padding(48)
                    .frame(width: 315)
                    .overlay(
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
    }

    @ViewBuilder
    var newContent: some View {
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

    @ViewBuilder
    var content: some View {
        if NeevaExperiment.arm(for: .defaultBrowserWelcomeV2) != .welcomeV2 {
            oldContent
        } else {
            DefaultBrowserInterstitialBackdrop(content: newContent)
        }
    }

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView()
        } else {
            DefaultBrowserInterstitialView(
                showLogo: true,
                content: content,
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
