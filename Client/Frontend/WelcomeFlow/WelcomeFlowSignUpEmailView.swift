// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct WelcomeFlowSignUpEmailView: View {
    @ObservedObject var model: WelcomeFlowModel

    @State var email = ""
    @State var password = ""
    @State var error = ""
    @State var showError = false

    var body: some View {
        WelcomeFlowHeaderView(text: "Create your account")
            .padding(.bottom, 20)

        OktaEmailSignUpFormView(
            email: $email,
            password: $password,
            action: {
                model.logCounter(.AuthOptionSignupWithEmail)
                model.authStore.createOktaAccount(
                    email: self.email, password: self.password,
                    onError: { message in
                        self.error = message
                        self.showError = true
                    }
                ) {
                    model.clearPreviousScreens()
                    model.changeScreenTo(.plans)
                }
            }
        )
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
