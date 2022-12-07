// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SignInOrUpFlowSignUpView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var model: SignInOrUpFlowModel

    @State var emailOptIn: Bool
    @State var error = ""
    @State var showError = false

    var body: some View {
        VStack(spacing: 0) {
            SignInOrUpFlowHeaderView(text: "Create your account")
                .padding(.bottom, 20)

            Text(
                "Neeva Premium is an account type that unlocks benefits, including insider perks and privacy-protecting tools."
            )
            .font(
                .system(
                    size: UIDevice.current.useTabletInterface || UIConstants.hasHomeButton
                        ? 18 : 24, weight: .regular)
            )
            .padding(.bottom, 20)

            AuthButtonView(
                icon: Image(systemSymbol: .applelogo),
                label: "Sign up with Apple",
                foregroundColor: colorScheme == .light ? .white : .black,
                backgroundColor: colorScheme == .light ? .black : .white
            ) {
                model.logCounter(.AuthSignUpWithApple)

                model.authStore.signUpWithApple(onError: { message in
                    self.error = message
                    self.showError = true
                }) {
                    model.justSignedUp = true
                    model.changeScreenTo(.plans)
                }
            }

            if !model.showAllSignUpOptions {
                AuthButtonView(
                    icon: nil,
                    label: "Other Sign-up Options",
                    foregroundColor: .white,
                    backgroundColor: .blue
                ) {
                    model.logCounter(.AuthOtherSignUpOptions)
                    model.showAllSignUpOptions.toggle()
                }
            } else {
                AuthButtonView(
                    icon: Image(systemSymbol: .envelope),
                    label: "Sign up with email",
                    foregroundColor: .primary,
                    backgroundColor: .secondary.opacity(0.25)
                ) {
                    model.prevScreens.append(.signUp)
                    model.changeScreenTo(.signUpEmail)
                }

                AuthButtonView(
                    icon: Image("google_icon"),
                    label: "Sign up with Google",
                    foregroundColor: .primary,
                    backgroundColor: .secondary.opacity(0.25)
                ) {
                    model.logCounter(.AuthOptionSignupWithGoogle)

                    model.authStore.oauthWithProvider(
                        provider: .google, email: "",
                        onError: { message in
                            self.error = message
                            self.showError = true
                        }
                    ) {
                        model.justSignedUp = true
                        model.changeScreenTo(.plans)
                    }
                }

                AuthButtonView(
                    icon: Image("microsoft"),
                    label: "Sign up with Microsoft",
                    foregroundColor: .primary,
                    backgroundColor: .secondary.opacity(0.25)
                ) {
                    model.logCounter(.AuthOptionSignupWithMicrosoft)

                    model.authStore.oauthWithProvider(
                        provider: .microsoft, email: "",
                        onError: { message in
                            self.error = message
                            self.showError = true
                        }
                    ) {
                        model.justSignedUp = true
                        model.changeScreenTo(.plans)
                    }
                }
            }

            HStack {
                Button(action: { emailOptIn.toggle() }) {
                    emailOptIn
                        ? Symbol(decorative: .checkmarkCircleFill, size: 20)
                            .foregroundColor(Color.blue)
                        : Symbol(decorative: .circle, size: 20)
                            .foregroundColor(Color.tertiaryLabel)
                    Text("Send me product & privacy tips")
                        .withFont(.bodyMedium)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 30)
            .onChange(of: emailOptIn) { newValue in
                model.authStore.marketingEmailOptOut = !newValue
            }
            .padding(.top)
        }
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

            // ensure we can get back to the plans page
            if model.prevScreens.count == 0 {
                model.prevScreens.append(.plans)
            }
        }
    }
}
