// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct ErrorViewBackgroundPreferenceKey: PreferenceKey {
    static var defaultValue: Color? = nil
    static func reduce(value: inout Color?, nextValue: () -> Color?) {
        value = nextValue()
    }
}

/// A view that displays an `Error`
public struct ErrorView: View {
    let error: Error
    let tryAgain: (() -> Void)?
    let viewName: String

    /// - Parameters:
    ///   - error: The error to display.
    ///   - in: Pass `self` to provide the name of your view in any feedback the user sends from this screen.
    ///   - tryAgain: If provided, a “Reload” button will be displayed. Tapping the button will call this closure.
    public init<T: View>(_ error: Error, in _: T, tryAgain: (() -> Void)? = nil) {
        self.error = error
        self.tryAgain = tryAgain
        self.viewName = "\(T.self)"
    }

    /// - Parameters:
    ///   - error: The error to display.
    ///   - viewName: The name of the view to include in any feedback the user sends from this screen.
    ///   - tryAgain: If provided, a “Reload” button will be displayed. Tapping the button will call this closure.
    public init(_ error: Error, viewName: String, tryAgain: (() -> Void)? = nil) {
        self.error = error
        self.tryAgain = tryAgain
        self.viewName = viewName
    }

    @ObservedObject private var reachability = NetworkReachability.shared
    @State private var sendingFeedback = false

    var gqlErrors: [String]? {
        (error as? GraphQLAPI.Error)?.errors.compactMap(\.message)
    }

    var isLoginError: Bool {
        guard let first = gqlErrors?.first, gqlErrors?.count == 1 else { return false }
        return first == "login required to access this field" || first == "unauthorized access"
    }

    public var body: some View {
        HStack {
            Spacer(minLength: 0)
            VStack(spacing: 20) {
                if isLoginError {
                    LoginView()
                } else if let isOnline = reachability.isOnline, !isOnline {
                    OfflineView(tryAgain: tryAgain)
                } else {
                    GenericErrorView(viewName: viewName, error: error, gqlErrors: gqlErrors)
                    if let tryAgain = tryAgain {
                        Button(action: tryAgain) {
                            Label("Reload", systemImage: "arrow.clockwise")
                        }
                        .font(Font.footnote.bold())
                        .padding(.vertical)
                    }
                }
            }.onChange(of: reachability.isOnline) { nowOnline in
                if nowOnline == true {
                    tryAgain?()
                }
            }
            Spacer(minLength: 0)
        }
    }
}

/// Displays a generic “Error” screen. Used as a fallback if we don’t have special display for the error message.
private struct GenericErrorView: View {
    let viewName: String
    let error: Error
    let gqlErrors: [String]?

    @State private var sendingFeedback = false

    var errorsForFeedback: String {
        if let errors = gqlErrors {
            return "• \(errors.joined(separator: "\n• "))"
        }
        return error.localizedDescription
    }

    var body: some View {
        VStack(spacing: 20) {
            Label("Error", systemImage: "exclamationmark.octagon.fill")
                .font(Font.title.bold())
                .foregroundColor(.red)
            GroupBox {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        if let errors = gqlErrors {
                            ForEach(errors, id: \.self) { error in
                                Text(error)
                            }
                        } else {
                            Text(error.localizedDescription)
                        }
                    }
                    .font(.system(.body, design: .monospaced))
                }.frame(maxHeight: 130)
            }.padding()
            // TODO: proper screenshot?
            Button(action: { sendingFeedback = true }) {
                Label("Send Feedback", systemSymbol: .bubbleLeftFill)
            }.sheet(isPresented: $sendingFeedback) {
                SendFeedbackView(
                    screenshot: nil, url: nil,
                    initialText: "\n\nReceived these errors in \(viewName):\n\(errorsForFeedback)",
                    onFeedbackSend: { _ in }
                ).font(.body)
            }
        }
    }
}

/// Prompts the user to log into Neeva
private struct LoginView: View {
    @Environment(\.onOpenURL) var onOpenURL
    @Environment(\.onSigninOrJoinNeeva) var onSigninOrJoinNeeva
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ZStack(alignment: .top) {
            Color.brand.offwhite
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 22)
                Spacer(minLength: 0).repeated(2)
                Text("Oops, this page is a little shy")
                    .font(.custom("Roobert", size: 24, relativeTo: .title))
                    .foregroundColor(.ui.gray20)
                Spacer(minLength: 4)
                Spacer(minLength: 0)
                Text("Please sign in to Neeva to view this page")
                    .withFont(.bodyLarge)
                    .foregroundColor(.ui.gray50)
                // hide the image on small iPhones in landscape
                if horizontalSizeClass == .regular || verticalSizeClass == .regular {
                    Group {
                        Spacer(minLength: 22)
                        Spacer(minLength: 0).repeated(9)
                        // TODO: fix on non-main bundles
                        Image("logged-out-decoration", bundle: .main)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minHeight: 115, maxHeight: 163)
                            .accessibilityHidden(true)
                        Spacer(minLength: 0).repeated(7)
                        Spacer(minLength: 34)
                    }
                } else {
                    Spacer().repeated(2)
                }
                Button(action: onSigninOrJoinNeeva) {
                    HStack {
                        Image("neeva-logo", bundle: .main)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 19)
                            .padding(.trailing, 3)
                        Spacer()
                        Text("Sign in or Join Neeva")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                }
                .buttonStyle(.neeva(.primary))
                .padding(.bottom, 25)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
            .frame(maxHeight: 522)
        }
        .preference(key: ErrorViewBackgroundPreferenceKey.self, value: Color.brand.offwhite)
        .colorScheme(.light)
    }
}

/// Displayed when the device is offline
private struct OfflineView: View {
    let tryAgain: (() -> Void)?

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Text("Unable to connect to internet")
                .withFont(.headingXLarge)
            Text("Your internet seems to be lost. Check your internet connection and try again.")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            // hide the image on small iPhones in landscape
            if horizontalSizeClass == .regular || verticalSizeClass == .regular {
                HStack {
                    Spacer(minLength: 0)
                    Image("offline-decoration")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 305, minHeight: 100)
                    Spacer(minLength: 0)
                }
                Spacer().repeated(2)
            }
            if let tryAgain = tryAgain {
                Button(action: tryAgain) {
                    HStack {
                        Spacer()
                        Text("Reload Page").withFont(.labelLarge)
                        Symbol(decorative: .arrowClockwise)
                        Spacer()
                    }
                }.buttonStyle(.neeva(.primary))
            }
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Image("mock-large", bundle: .main)
                .ignoresSafeArea()
            ErrorView(
                GraphQLAPI.Error([.init(["message": "login required to access this field"])]),
                viewName: "\(Self.self)"
            )
            .padding(.top, 106)
        }
        .previewDevice("iPhone X")

        ZStack(alignment: .bottom) {
            Image("mock", bundle: .main)
            ErrorView(
                GraphQLAPI.Error([.init(["message": "login required to access this field"])]),
                viewName: "\(Self.self)"
            )
            .frame(height: 435 - 52 - 34)
            .padding(.bottom, 34)
        }
        .previewDevice("iPhone X")
        .previewLayout(.fixed(width: 375, height: 435))

        ErrorView(
            GraphQLAPI.Error([.init(["message": "login required to access this field"])]),
            viewName: "\(Self.self)", tryAgain: {})
        ErrorView(
            GraphQLAPI.Error(
                Array(repeating: .init(["message": "failed to reticulate the splines"]), count: 10)),
            viewName: "\(Self.self)")
        ErrorView(
            GraphQLAPI.Error([
                .init(["message": "failed to reticulate the splines"]),
                .init(["message": "the server room is on fire"]),
            ]), viewName: "\(Self.self)")
        ErrorView(
            GraphQLAPI.Error([
                .init(["message": "failed to reticulate the splines"]),
                .init(["message": "the server room is on fire"]),
            ]), viewName: "\(Self.self)", tryAgain: {})
        OfflineView(tryAgain: nil)
        OfflineView(tryAgain: {})
    }
}
