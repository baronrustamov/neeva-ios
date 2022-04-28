// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack {
            VStack { Divider().background(Color.ui.gray96) }.padding(.trailing, 20)
            Spacer()
            Text("OR")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.ui.gray30)
            Spacer()
            VStack { Divider().background(Color.ui.gray96) }.padding(.leading, 20)
        }
        .padding(.vertical, 20)
    }
}

enum PasswordStrength: String {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case strong = "strong"
}

public struct EmailForm: View {
    @EnvironmentObject var model: IntroViewModel
    @Binding private var email: String
    @Binding private var firstname: String
    @Binding private var password: String
    @State private var passwordStrengthLabel: String = ""
    @State private var passwordStrength: PasswordStrength = .none
    @State private var passwordStrengthColor: Color = Color.gray
    @State private var passwordStrengthPercent = 0.0
    @State private var showPassword = false

    var action: () -> Void

    init(
        email: Binding<String>,
        firstname: Binding<String>,
        password: Binding<String>,
        action: @escaping () -> Void
    ) {
        self._email = email
        self._firstname = firstname
        self._password = password
        self.action = action
    }

    public var body: some View {
        VStack {
            TextField(emailPlaceHolder(), text: $email)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(Color(UIColor.systemGray5), lineWidth: 1.0)
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.brand.white)

            if !model.onSignInMode {
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 12.0)
                                .stroke(Color(UIColor.systemGray5), lineWidth: 1.0)
                        )
                        .background(Color.brand.white)

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

                Button(action: action) {
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
                .disabled(email.isEmpty || password.isEmpty)
            } else {
                Button(action: action) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Continue")
                        Symbol(decorative: .arrowRight)
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
                .disabled(email.isEmpty)
            }
        }
    }

    func emailPlaceHolder() -> String {
        return model.onSignInMode ? "Email" : "Email (required)"
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

struct OtherOptionsPage: View {
    @EnvironmentObject var model: IntroViewModel

    @State var email = ""
    @State var firstname = ""
    @State var password = ""

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Spacer()

                Group {
                    if model.onSignInMode {
                        Text("Sign In")
                            .font(.roobert(.medium, size: 20))
                            .padding(.top, 20)
                            .padding(.bottom, 6)
                        SignUpButton(action: {
                            model.onSignInMode = false
                        })
                    } else {
                        Text("Join Neeva")
                            .font(.roobert(.medium, size: 20))
                            .padding(.top, 20)
                            .padding(.bottom, 6)
                        SignInButton(action: {
                            model.onSignInMode = true
                        })
                    }
                }

                Spacer()

                EmailForm(
                    email: $email,
                    firstname: $firstname,
                    password: $password,
                    action: {
                        model.buttonAction(
                            model.onSignInMode
                                ? .oauthWithProvider(.okta, model.marketingEmailOptOut, "", email)
                                : .oktaSignup(
                                    email, firstname, password, model.marketingEmailOptOut)
                        )
                    }
                )
                Spacer()
                OrDivider()
                Spacer()
                Group {
                    SignUpWithAppleButton(
                        action: {
                            logOtherOptionsSignUpWithAppleClick()
                            model.buttonAction(
                                .signupWithApple(model.marketingEmailOptOut, nil, nil))
                        }, onSignInMode: $model.onSignInMode
                    )

                    SignUpWithGoogleButton(
                        action: {
                            logOtherOptionsSignUpWithGoogleClick()
                            model.buttonAction(
                                .oauthWithProvider(.google, model.marketingEmailOptOut, "", ""))
                        },
                        onSignInMode: $model.onSignInMode
                    ).padding(.top, 10)

                    SignUpWithMicrosoftButton(
                        action: {
                            logOtherOptionsSignupWithMicrosoftClick()
                            model.buttonAction(
                                .oauthWithProvider(.microsoft, model.marketingEmailOptOut, "", ""))
                        },
                        onSignInMode: $model.onSignInMode
                    ).padding(.top, 10)
                }
                Spacer()

                if model.onSignInMode {
                    Spacer()
                    Spacer()
                }
            }
            .padding(35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func logOtherOptionsSignUpWithAppleClick() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionSignupWithApple,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionSignupWithApple,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logOtherOptionsSignUpWithGoogleClick() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionSignupWithGoogle,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionSignupWithGoogle,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logOtherOptionsSignupWithMicrosoftClick() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionSignupWithMicrosoft,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionSignupWithMicrosoft,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }
}
