// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct EmailVerificationPrompt: View {
    @Environment(\.colorScheme) var colorScheme

    let email: String
    let dismiss: () -> Void

    public init(email: String, dismiss: @escaping () -> Void) {
        self.email = email
        self.dismiss = dismiss
    }

    @State var request: ResendVerificationEmailRequest?

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Symbol(decorative: .checkmark, style: .displayMedium)
                    .foregroundColor(.brand.white)
                    .frame(width: 70, height: 70)
                    .background(
                        colorScheme == .light ? Color.brand.variant.mint : Color.brand.green
                    )
                    .clipShape(Circle())
                Spacer()
                    .frame(height: 3)
                    .background(
                        colorScheme == .light ? Color.brand.variant.mint : Color.brand.green)
                Symbol(decorative: .envelopeBadge, style: .displayMedium)
                    .foregroundColor(.brand.white)
                    .frame(width: 70, height: 70)
                    .background(colorScheme == .light ? Color.brand.blue : Color.brand.variant.blue)
                    .clipShape(Circle())
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [4]))
                    .foregroundColor(
                        colorScheme == .light ? Color.brand.variant.mint : Color.brand.green
                    )
                    .frame(height: 3)
                Image("hands-magic")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 36, height: 36)
                    .foregroundColor(.brand.green)
                    .frame(width: 70, height: 70)
                    .background(Color.brand.white)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(colorScheme == .light ? Color.brand.mint : Color.brand.variant.green)
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            VStack(spacing: 0) {
                Text("Please verify your email address to use this feature")
                    .withFont(.labelLarge)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                (Text("We've sent an email to ") + Text("**\(email)**")
                    + Text(". Verify your email address by clicking the link in your inbox."))
                    .font(.system(size: 14))
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                Button(
                    action: {
                        request = ResendVerificationEmailRequest()
                        dismiss()
                    },
                    label: {
                        Label(
                            title: {
                                Text("Resend email")
                            },
                            icon: {
                                Symbol(decorative: .envelope, style: .labelMedium)
                            }
                        ).frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.neeva(.primary))
                    .padding(.vertical, 10)

                Group {
                    Text("Want to use a different email address?")
                    Text("You can **sign up** again.")

                }
                .withFont(unkerned: .bodyXSmall)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .padding(.bottom, 60)
            .frame(maxWidth: .infinity)
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct EmailVerificationPrompt_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmailVerificationPrompt(email: "lily@example.com", dismiss: {})
                .preferredColorScheme(.light)
            EmailVerificationPrompt(email: "lily@example.com", dismiss: {})
                .preferredColorScheme(.dark)
        }
    }
}
