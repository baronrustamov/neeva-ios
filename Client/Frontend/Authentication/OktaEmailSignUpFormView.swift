// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum PasswordStrength: String {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case strong = "strong"
}

struct OktaEmailSignUpFormView: View {
    @Binding private var email: String
    @Binding private var password: String
    @State private var passwordStrengthLabel: String = ""
    @State private var passwordStrength: PasswordStrength = .none
    @State private var passwordStrengthColor: Color = Color.gray
    @State private var passwordStrengthPercent = 0.0
    @State private var showPassword = false
    @State private var loading = false

    var action: () -> Void

    init(
        email: Binding<String>,
        password: Binding<String>,
        action: @escaping () -> Void
    ) {
        self._email = email
        self._password = password
        self.action = action
    }

    var body: some View {
        VStack {
            TextField("Email (required)", text: $email)
                .padding()
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.foreground, lineWidth: 1)
                )

            VStack {
                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword == true {
                            TextField("Password (required)", text: $password)
                        } else {
                            SecureField("Password (required)", text: $password)
                        }
                    }
                    // the default height of a `TextField`, `SecureField`s are a smidge shorter
                    .frame(height: 24.666667)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .fixedSize(horizontal: false, vertical: true)
                    .onChange(of: password, perform: passwordOnChange)
                    .textContentType(.newPassword)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.background)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.foreground, lineWidth: 1)
                    )

                    Button(
                        action: {
                            self.showPassword.toggle()
                        },
                        label: {
                            Symbol(decorative: .eye, style: .bodyLarge)
                        }
                    )
                    .foregroundColor(showPassword ? .label : .secondaryLabel)
                    .padding()
                }

                if passwordStrength != .none {
                    VStack(alignment: .leading) {
                        ProgressView(value: passwordStrengthPercent, total: 100)
                            .accentColor(passwordStrengthColor)
                        Text(passwordStrengthLabel)
                            .foregroundColor(passwordStrengthColor)
                            .withFont(.bodySmall)
                    }
                }
            }

            Button(action: {
                self.loading = true
                action()
                self.loading = false
            }) {
                HStack(alignment: .center) {
                    Spacer()
                    Image("neevaMenuIcon")
                        .renderingMode(.template)
                        .frame(width: 14, height: 14)
                    Spacer()
                    Text("Create Neeva account")
                    Spacer()
                    Spacer()
                }
                .foregroundColor(.brand.white)
                .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
            }
            .background(Color.brand.blue)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
            .padding(.top, 20)
            .font(.roobert(.semibold, size: 18))
            .disabled(email.isEmpty || password.isEmpty || self.loading)
        }
    }

    func passwordOnChange(newValue: String) {
        let passwordWithSpecialCharacter =
            NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{6,}$")
        let passwordWithOneBigLetterAndSpecialCharater =
            NSPredicate(
                format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        let passwordWithOneBigLetterAndOneDigit =
            NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")

        if newValue.count > 0 {
            if newValue.count > 10
                && (passwordWithOneBigLetterAndSpecialCharater.evaluate(with: newValue)
                    || passwordWithSpecialCharacter.evaluate(with: newValue))
            {
                passwordStrength = .strong
                passwordStrengthColor = Color.brand.blue
                passwordStrengthLabel = "Wow! Now that's a strong password"
                passwordStrengthPercent = 100.0
            } else if newValue.count > 8
                && passwordWithOneBigLetterAndOneDigit.evaluate(with: newValue)
            {
                passwordStrength = .medium
                passwordStrengthColor = .green
                passwordStrengthLabel = "Good password"
                passwordStrengthPercent = 60.0
            } else {
                passwordStrength = .low
                passwordStrengthColor = .red
                passwordStrengthLabel = "Weak password"

                if newValue.count > 4 {
                    passwordStrengthPercent = 30.0
                } else {
                    passwordStrengthPercent = 0.0
                }
            }
        } else {
            passwordStrength = .none
            passwordStrengthColor = .gray
            passwordStrengthLabel = ""
            passwordStrengthPercent = 0.0
        }
    }
}
