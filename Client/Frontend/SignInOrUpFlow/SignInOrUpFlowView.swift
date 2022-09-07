// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

// it's assumed that this view will be rendered as an overlay cover
struct SignInOrUpFlowView: View {
    @ObservedObject var model: SignInOrUpFlowModel

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
                        case .signUp:
                            SignInOrUpFlowSignUpView(
                                model: model, emailOptIn: !model.authStore.marketingEmailOptOut)
                        case .signUpEmail:
                            SignInOrUpFlowSignUpEmailView(model: model)
                        case .signIn:
                            SignInOrUpFlowSignInView(model: model)
                        case .signInQRCode:
                            SignInOrUpFlowSignInQRCodeView(model: model)
                        default:
                            SignInOrUpFlowPlansView(model: model)
                        }
                    }
                    .padding(.horizontal, 25)

                    Spacer()
                }
                .frame(
                    maxWidth: UIDevice.current.useTabletInterface ? 380 : .infinity,
                    maxHeight: UIDevice.current.useTabletInterface ? 580 : .infinity
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
    }
}
