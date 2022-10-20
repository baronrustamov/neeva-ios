// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct WelcomeFlowSignInView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var model: WelcomeFlowModel

    @State var error = ""
    @State var showError = false

    var body: some View {
        VStack(spacing: 0) {
            AuthButtonView(
                icon: Image(systemSymbol: .applelogo),
                label: "Sign in with Apple",
                foregroundColor: colorScheme == .light ? .white : .black,
                backgroundColor: colorScheme == .light ? .black : .white
            ) {
                model.authStore.signUpWithApple(onError: { message in
                    self.error = message
                    self.showError = true
                }) {
                    model.clearPreviousScreens()
                    model.changeScreenTo(.defaultBrowser)
                }
            }

            AuthButtonView(
                icon: Image(systemSymbol: .envelope),
                label: "Sign in with email",
                foregroundColor: .primary,
                backgroundColor: .secondary.opacity(0.25)
            ) {
                model.authStore.oauthWithProvider(
                    provider: .okta, email: "",
                    onError: { message in
                        self.error = message
                        self.showError = true
                    }
                ) {
                    model.clearPreviousScreens()
                    model.changeScreenTo(.defaultBrowser)
                }
            }

            AuthButtonView(
                icon: Image("google_icon"),
                label: "Sign in with Google",
                foregroundColor: .primary,
                backgroundColor: .secondary.opacity(0.25)
            ) {
                model.authStore.oauthWithProvider(
                    provider: .google, email: "",
                    onError: { message in
                        self.error = message
                        self.showError = true
                    }
                ) {
                    model.clearPreviousScreens()
                    model.changeScreenTo(.defaultBrowser)
                }
            }

            AuthButtonView(
                icon: Image("microsoft"),
                label: "Sign in with Microsoft",
                foregroundColor: .primary,
                backgroundColor: .secondary.opacity(0.25)
            ) {
                model.authStore.oauthWithProvider(
                    provider: .microsoft, email: "",
                    onError: { message in
                        self.error = message
                        self.showError = true
                    }
                ) {
                    model.clearPreviousScreens()
                    model.changeScreenTo(.defaultBrowser)
                }
            }

            if FeatureFlag[.qrCodeSignIn] {
                AuthButtonView(
                    icon: Image(systemSymbol: .qrcode),
                    label: "Sign in with QR Code",
                    foregroundColor: .primary,
                    backgroundColor: .secondary.opacity(0.25)
                ) {
                    model.prevScreens.append(.signIn)
                    model.changeScreenTo(.signInQRCode)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .alert(isPresented: self.$showError) {
            Alert(
                title: Text("Error"),
                message: Text(self.error),
                dismissButton: .default(
                    Text("OK"), action: { self.showError = false }
                )
            )
        }
        .onAppear {
            model.logCounter(.ScreenImpression)
        }
    }
}
