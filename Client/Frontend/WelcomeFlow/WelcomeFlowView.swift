// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

// it's assumed that this view will be rendered as an overlay cover
struct WelcomeFlowView: View {
    @ObservedObject var model: WelcomeFlowModel

    var body: some View {
        ZStack(alignment: .top) {
            // background
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(Color.brand.variant.adaptive.polar)
                .ignoresSafeArea()

            // foreground
            VStack(spacing: 0) {
                // top spacing
                if UIDevice.current.useTabletInterface {
                    Spacer()
                } else {
                    Spacer().frame(height: UIConstants.hasHomeButton ? 30 : 70)
                }

                // this is the main container
                ScrollView {
                    VStack(spacing: 0) {
                        // nav buttons (back and close)
                        HStack(alignment: .bottom) {
                            if model.prevScreens.count != 0 {
                                Button(action: {
                                    model.logCounter(.PreviousScreenClick)
                                    model.goToPreviousScreen()
                                }) {
                                    Symbol(decorative: .arrowBackwardCircleFill, size: 30)
                                        .foregroundColor(Color.secondary)
                                }
                            }

                            Spacer()

                            if model.showCloseButton {
                                Button(action: { model.complete() }) {
                                    Symbol(decorative: .xmarkCircleFill, size: 30)
                                        .foregroundColor(Color.secondary)
                                }
                            }
                        }
                        .frame(minHeight: 40)
                        .padding(.top, 10)
                        .padding(.horizontal, 10)

                        // word mark
                        Image("neeva-letter-only")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 100)
                            .foregroundColor(Color.secondary)
                            .padding(.bottom, 25)

                        // screen content
                        Group {
                            switch model.currentScreen {
                            case .plans:
                                WelcomeFlowPlansView(model: model)
                            case .signUp:
                                WelcomeFlowSignUpView(
                                    model: model, emailOptIn: !model.authStore.marketingEmailOptOut)
                            case .signUpEmail:
                                WelcomeFlowSignUpEmailView(model: model)
                            case .signIn:
                                WelcomeFlowSignInView(model: model)
                            case .signInQRCode:
                                WelcomeFlowSignInQRCodeView(model: model)
                            case .defaultBrowser:
                                WelcomeFlowDefaultBrowserView(model: model)
                            default:
                                WelcomeFlowIntroView(model: model)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                .frame(
                    maxWidth: UIDevice.current.useTabletInterface ? 380 : .infinity,
                    maxHeight: UIDevice.current.useTabletInterface ? 650 : .infinity
                )
                .background(Color(UIColor.systemBackground)).cornerRadius(
                    20,
                    corners: !UIConstants.hasHomeButton || UIDevice.current.useTabletInterface
                        ? [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
                        : [.topLeading, .topTrailing])

                // bottom spacing
                if UIDevice.current.useTabletInterface {
                    Spacer()
                }
            }
        }
        .onAppear {
            if model.currentScreen == .intro && !Defaults[.firstRunImpressionLogged] {
                model.logCounter(
                    .FirstRunImpression,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                if PremiumStore.isOfferedInLanguage() {
                    model.logCounter(.PremiumEligible)
                }
                ConversionLogger.log(event: .launchedApp)
                Defaults[.firstRunImpressionLogged] = true
            }

            /*
             NOTE: Prime the `PremiumStore` products request.
             Swift constructs the object lazily, so any access
             will trigger initialization.
             */
            _ = PremiumStore.shared.products.count
        }
    }
}
