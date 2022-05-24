// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

public struct AuthButton: View {
    let action: () -> Void
    let icon: Image
    let isSignIn: Bool
    let service: String
    let textColor: Color
    let backgroundColor: Color
    var tintIcon: Bool = false

    public var body: some View {
        Button(action: action) {
            let label = Text(isSignIn ? "Sign in with \(service)" : "Sign up with \(service)")
            HStack {
                icon
                    .renderingMode(tintIcon ? .template : .none)
                    .padding(.leading, 28)
                Spacer()
                label
                Spacer()
            }
            .foregroundColor(textColor)
            .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
        }
        .background(backgroundColor)
        .clipShape(Capsule())
        .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
        .font(.roobert(.semibold, size: 18))
    }
}

public struct SignUpWithAppleButton: View {
    var action: () -> Void
    @Binding public var onSignInMode: Bool

    public var body: some View {
        AuthButton(
            action: action,
            icon: Image(systemSymbol: .applelogo),
            isSignIn: onSignInMode,
            service: "Apple",
            textColor: .white,
            backgroundColor: .black,
            tintIcon: true)
    }
}

public struct SignUpWithGoogleButton: View {
    var action: () -> Void
    @Binding public var onSignInMode: Bool

    public var body: some View {
        AuthButton(
            action: action,
            icon: Image("google_icon"),
            isSignIn: onSignInMode,
            service: "Google",
            textColor: .ui.gray20,
            backgroundColor: .brand.white)
    }
}

public struct SignUpWithMicrosoftButton: View {
    var action: () -> Void
    @Binding public var onSignInMode: Bool

    public var body: some View {
        AuthButton(
            action: action,
            icon: Image("microsoft"),
            isSignIn: onSignInMode,
            service: "Microsoft",
            textColor: .ui.gray20,
            backgroundColor: .brand.white)
    }
}

struct SignInButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            (Text("Already have an account? ")
                .foregroundColor(.secondaryLabel)
                + Text("Sign In")
                .foregroundColor(.black).fontWeight(.medium))
                .withFont(.labelMedium)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 10)
    }
}

struct SignUpButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            (Text("Don't have an account? ")
                .foregroundColor(.secondaryLabel)
                + Text("Sign Up")
                .foregroundColor(.black).fontWeight(.medium))
                .withFont(.labelMedium)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 10)
    }
}

struct FirstRunCloseButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button(action: action) {
                Symbol(.xmark, style: .headingXLarge, label: "Close")
                    .foregroundColor(Color.ui.gray60)
            }
            .frame(width: 58, height: 58, alignment: .center)
        }
    }
}

public struct QRCodeScanButton: View {
    var action: () -> Void

    public var body: some View {
        Button(action: action) {
            let label = Text("Sign in with QR Code")
            HStack {
                Symbol(decorative: .qrcodeViewfinder, style: .labelMedium)
                    .foregroundColor(.black)
                    .padding(.leading, 28)
                Spacer()
                label
                Spacer()
            }
            .foregroundColor(.ui.gray20)
            .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
        }
        .backgroundColorOrGradient(.white)
        .clipShape(Capsule())
        .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
        .font(.roobert(.semibold, size: 18))
    }
}

struct AuthButton_Previews: PreviewProvider {
    static var previews: some View {
        SignUpWithAppleButton(action: {}, onSignInMode: .constant(false))
    }
}
