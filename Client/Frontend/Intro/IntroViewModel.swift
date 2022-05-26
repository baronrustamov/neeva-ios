// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AuthenticationServices
import CodeScanner
import Combine
import CryptoKit
import Defaults
import Shared
import SwiftUI
import UIKit

private let log = Logger.auth
private let browserLog = Logger.browser

enum FirstRunButtonActions {
    case signin
    case signinWithQRCode
    case signupWithApple(Bool?, String?, String?)
    case signupWithOther
    case skipToBrowser
    case oktaSignup(String, String, String, Bool)  //email, first name, password, marketing option
    case oktaSignin(String)  // email
    case oauthWithProvider(NeevaConstants.OAuthProvider, Bool, String, String)
    case oktaAccountCreated(String)  // token
}

class IntroViewModel: NSObject, ObservableObject {
    @Published var marketingEmailOptOut = true
    @Published var onOtherOptionsPage: Bool = false
    @Published var onSignInMode: Bool = false
    @Published var showSignInError = false
    @Published var showQRScanner = false

    public var signInErrorMessage: String = ""
    public var presentationController: UIViewController
    public var overlayManager: OverlayManager
    public var toastViewManager: ToastViewManager

    private var onDismiss: ((FirstRunButtonActions) -> Void)?

    public func buttonAction(_ option: FirstRunButtonActions) {
        // Make sure all actions are run on the main thread to prevent runtime errors
        DispatchQueue.main.async {
            switch option {
            case FirstRunButtonActions.signupWithApple(let marketingEmailOptOut, _, _):
                if !Defaults[.introSeen] {
                    Defaults[.firstRunPath] = "FirstRunSignupWithApple"
                }
                self.marketingEmailOptOut = marketingEmailOptOut ?? false
                self.doSignupWithApple()
            case FirstRunButtonActions.skipToBrowser:
                if !Defaults[.introSeen] {
                    Defaults[.firstRunPath] = "FirstRunSkipToBrowser"
                }

                self.dismiss(.skipToBrowser)
            case FirstRunButtonActions.oktaSignup(
                let email,
                let firstname,
                let password,
                let marketingEmailOptOut
            ):
                self.createOktaAccount(
                    email: email,
                    firstname: firstname,
                    password: password,
                    marketingEmailOptOut: marketingEmailOptOut
                )
            case FirstRunButtonActions.oktaSignin(let email):
                self.dismiss(.oktaSignin(email))
            case FirstRunButtonActions.oauthWithProvider(
                let provider, let marketingEmailOptOut, _, let email):
                self.marketingEmailOptOut = marketingEmailOptOut
                self.oauthWithProvider(provider: provider, email: email)
            case FirstRunButtonActions.signinWithQRCode:
                self.signInwithQRCode()
            default:
                break
            }
        }
    }

    // MARK: - Presenting/Dismissing
    public func present(
        onDismiss: @escaping ((FirstRunButtonActions) -> Void), completion: @escaping (() -> Void)
    ) {
        self.onDismiss = onDismiss

        overlayManager.presentFullScreenModal(
            content: AnyView(
                IntroFirstRunView()
                    .environmentObject(self)
                    .onAppear {
                        AppDelegate.setRotationLock(to: .portrait)
                    }
                    .onDisappear {
                        AppDelegate.setRotationLock(to: .all)
                    }
            )
        ) {
            completion()
        }
    }

    public func dismiss(_ firstRunButtonAction: FirstRunButtonActions?) {
        Defaults[.introSeen] = true

        overlayManager.hideCurrentOverlay(ofPriorities: [.modal, .fullScreen]) {
            browserLog.info("Dismissed introVC")

            guard let firstRunButtonAction = firstRunButtonAction else {
                return
            }

            self.onDismiss?(firstRunButtonAction)
            self.onDismiss = nil
        }
    }

    // MARK: - Auth Methods
    private func doSignupWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func oauthWithProvider(provider: NeevaConstants.OAuthProvider, email: String) {
        guard
            let authURL = provider == .okta
                ? URL(
                    string: NeevaConstants.signupOAuthString(
                        provider: provider,
                        mktEmailOptOut: self.marketingEmailOptOut,
                        email: email))
                : URL(
                    string: NeevaConstants.signupOAuthString(
                        provider: provider,
                        mktEmailOptOut: self.marketingEmailOptOut))
        else { return }

        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: NeevaConstants.neevaOAuthCallbackScheme()
        ) { [self] callbackURL, error in

            if error != nil {
                Logger.browser.error(
                    "ASWebAuthenticationSession OAuth failed: \(String(describing: error))")
            }

            guard error == nil, let callbackURL = callbackURL else { return }
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            let token = queryItems?.filter({ $0.name == "sessionKey" }).first?.value
            let serverErrorCode = queryItems?.filter({ $0.name == "retry" }).first?.value

            if let errorCode = serverErrorCode {
                var errorMessage = "Some unknown error occurred"

                switch errorCode {
                case "NL003":
                    errorMessage =
                        "There is already an account for this email address. Please sign in with Google instead."
                    break
                case "NL004":
                    errorMessage =
                        "There is already an account for this email address. Please sign in with Apple instead."
                    break
                case "NL005":
                    errorMessage =
                        "There is already an account for this email address. Please sign in with Microsoft instead."
                    break
                case "NL013":
                    errorMessage =
                        "There is already an account for this email address. Please sign in with your email address instead."
                    break
                case "NL002":
                    errorMessage = "There is already an account for this email address."
                    break
                default:
                    break
                }
                showErrorAlert(errMsg: errorMessage)
            } else if let cookie = token {
                self.dismiss(
                    .oauthWithProvider(provider, self.marketingEmailOptOut, cookie, email))
            }
        }

        session.presentationContextProvider = self
        session.start()
    }

    func showErrorAlert(errMsg: String) {
        signInErrorMessage = errMsg
        showSignInError = true
        Logger.browser.error(
            "Showed error alert message: \(errMsg)"
        )
    }

    // MARK: - Init
    public init(
        presentationController: UIViewController,
        overlayManager: OverlayManager,
        toastViewManager: ToastViewManager
    ) {
        self.presentationController = presentationController
        self.overlayManager = overlayManager
        self.toastViewManager = toastViewManager
    }
}

// MARK: - Sign In With Apple
extension IntroViewModel: ASWebAuthenticationPresentationContextProviding,
    ASAuthorizationControllerPresentationContextProviding
{
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return presentationController.view.window!
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentationController.view.window!
    }
}

extension IntroViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // redirect and create account
            guard let identityToken = appleIDCredential.identityToken else {
                log.error("Unable to fetch identity token")
                return
            }
            guard let authorizationCode = appleIDCredential.authorizationCode else {
                log.error("Unable to fetch authorization code")
                return
            }
            guard let identityTokenStr = String(data: identityToken, encoding: .utf8) else {
                log.error("Unable to convert identity token to utf8")
                return
            }
            guard let authorizationCodeStr = String(data: authorizationCode, encoding: .utf8) else {
                log.error("Unable to convert authorization code to utf8")
                return
            }

            // only log for users who signed in at least once
            if Defaults[.signedInOnce] {
                ClientLogger.shared.logCounter(
                    .SignInWithAppleSuccess,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes()
                )
            }
            self.dismiss(
                .signupWithApple(self.marketingEmailOptOut, identityTokenStr, authorizationCodeStr))
            break
        default:
            break
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let errorAttribute = ClientLogCounterAttribute(
            key: "error",
            value: "\(error)"
        )

        // only log for users who signed in at least once
        if Defaults[.signedInOnce] {
            ClientLogger.shared.logCounter(
                .SignInWithAppleFailed,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes() + [errorAttribute]
            )
        }
    }
}

// MARK: - OKTA
extension IntroViewModel {
    struct OktaAccountRequestBodyModel: Codable {
        let email: String
        let firstname: String
        let lastname: String
        let password: String
        let salt: String
        let visitorID: String
        let expVisitorID: String
        let expVisitorOverrides: String
        let emailSubmissionID: String
        let referralCode: String
        let marketingEmailOptOut: Bool
        let ignoreCountryCode: Bool
    }

    struct ErrorResponse: Codable {
        let error: String
    }

    func createOktaAccount(
        email: String,
        firstname: String,
        password: String,
        marketingEmailOptOut: Bool
    ) {
        var request = URLRequest(url: NeevaConstants.createOktaAccountURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let salt = generateSalt()
        let salt_and_password = salt + password

        let saltAndPasswordData = Data(salt_and_password.utf8)
        let hashedSaltAndPassword = SHA512.hash(data: saltAndPasswordData)

        let hashedSaltAndPasswordEncoded = Data(hashedSaltAndPassword).base64EncodedString()

        guard let saltEncoded = salt.data(using: .utf8)?.base64EncodedString()
        else { return }

        let requestBody = OktaAccountRequestBodyModel(
            email: email,
            firstname: firstname.isEmpty ? "Member" : firstname,
            lastname: "",
            password: hashedSaltAndPasswordEncoded,
            salt: saltEncoded,
            visitorID: "",
            expVisitorID: "",
            expVisitorOverrides: "",
            emailSubmissionID: "",
            referralCode: "",
            marketingEmailOptOut: marketingEmailOptOut,
            ignoreCountryCode: true
        )
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            Logger.browser.error(
                "Error decoding request body for create okta account")
            return
        }

        request.httpBody = jsonData

        let config = URLSessionConfiguration.default
        let delegate = OktaAccountCreatedDelegate(onDismiss: dismiss)
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)

        session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 400 {
                    if let data = data {
                        var errorMsg = "Some unknown error occurred"
                        do {
                            let res = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            switch res.error {
                            case "UsedEmail":
                                errorMsg = "This email is associated with an existing Neeva account"
                                break
                            case "InternalError":
                                errorMsg = "Unexpected error occurred"
                                break
                            case "InvalidEmail":
                                errorMsg = "Invalid email used to register"
                                break
                            case "InvalidRequest":
                                errorMsg = "Invalid name and/or password"
                                break
                            case "InvalidToken":
                                errorMsg = "Token has already been used"
                                break
                            case "UsedToken":
                                errorMsg = "Token has already been used"
                                break
                            default:
                                errorMsg = res.error
                            }
                        } catch let err {
                            Logger.browser.error(
                                "Error creating Okta account: \(String(describing: err))")
                        }

                        DispatchQueue.main.async {
                            self.showErrorAlert(errMsg: errorMsg)
                        }
                    }
                }
            }
        }.resume()
    }

    func generateSalt() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let salt = String((0..<12).map { _ in letters.randomElement()! })
        return salt
    }
}

// MARK: - QR CODE
extension IntroViewModel {
    public func signInwithQRCode() {
        overlayManager.presentFullScreenModal(
            content: AnyView(
                ZStack(alignment: .topTrailing) {
                    CodeScannerView(codeTypes: [.qr]) { result in
                        self.showQRScanner = false
                        self.overlayManager.hideCurrentOverlay()
                        switch result {
                        case .success(let result):
                            guard let url = URL(string: result.string),
                                let delegate = SceneDelegate.getCurrentSceneDelegateOrNil()
                            else { return }
                            if !delegate.checkForSignInToken(in: url) {
                                DispatchQueue.main.async {
                                    self.toastViewManager.makeToast(text: "Invalid QR Code")
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.toastViewManager.makeToast(
                                    text: "QR Code: \(error.localizedDescription)"
                                )
                            }
                        }
                    }
                    CloseButton(action: {
                        self.overlayManager.hideCurrentOverlay()
                    })
                    .padding(.trailing, 20)
                    .padding(.top, 40)
                    .background(Color.clear)
                }
            )
        )
    }
}
