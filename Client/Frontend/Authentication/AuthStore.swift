// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AuthenticationServices
import CryptoKit
import Defaults
import Shared

private let log = Logger.auth

class AuthStore: NSObject, ObservableObject {
    var bvc: BrowserViewController
    private var onError: ((_ message: String) -> Void)?
    private var onSuccess: (() -> Void)?
    var marketingEmailOptOut = false

    init(bvc: BrowserViewController) {
        self.bvc = bvc
    }

    private func setLoginToken(token: String) {
        NeevaUserInfo.shared.setLoginCookie(token)

        if let notificationToken = Defaults[.notificationToken] {
            NotificationPermissionHelper.shared
                .registerDeviceTokenWithServer(deviceToken: notificationToken)
        }

        let httpCookieStore = self.bvc.tabManager.configuration.websiteDataStore.httpCookieStore

        httpCookieStore.setCookie(NeevaConstants.loginCookie(for: token)) {
            DispatchQueue.main.async {
                // NOTE: there's some dependency on loading a neeva.com URL to fully realize authenticating
                self.bvc.openURLInBackground(NeevaConstants.appSearchURL, showToast: false)
            }
        }
    }

    // MARK: - Auth Initializers

    // NOTE: look further down in this file for the extensions that support Apple auth
    func signUpWithApple(onError: ((_ message: String) -> Void)?, onSuccess: (() -> Void)?) {
        self.onError = onError
        self.onSuccess = onSuccess

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func oauthWithProvider(
        provider: NeevaConstants.OAuthProvider, email: String,
        onError: ((_ message: String) -> Void)?, onSuccess: (() -> Void)?
    ) {
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

        self.onError = onError
        self.onSuccess = onSuccess

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

                self.onError?(errorMessage)
            } else if let cookie = token {
                self.handleOauthWithProvider(token: cookie)
            }
        }

        session.presentationContextProvider = self
        session.start()
    }

    // MARK: - Auth Handlers

    private func handleSignUpWithApple(identityToken: String?, authorizationCode: String?) {
        if let identityToken = identityToken, let authorizationCode = authorizationCode {
            let authURL = NeevaConstants.appleAuthURL(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                marketingEmailOptOut: self.marketingEmailOptOut,
                signup: true)

            self.bvc.openURLInBackground(authURL, showToast: false)
        }

        self.finalizeAuthentication()
    }

    private func handleOauthWithProvider(token: String) {
        self.setLoginToken(token: token)

        self.finalizeAuthentication()
    }

    private func handleOktaAccountCreated(token: String) {
        self.setLoginToken(token: token)

        self.finalizeAuthentication()
    }

    private func finalizeAuthentication() {
        self.onSuccess?()

        if NeevaUserInfo.shared.hasLoginCookie() {
            if let notificationToken = Defaults[.notificationToken] {
                NotificationPermissionHelper.shared
                    .registerDeviceTokenWithServer(deviceToken: notificationToken)
            }
        }

        SpaceStore.shared.refresh(force: true)
    }
}

// MARK: - Apple Auth Support

extension AuthStore: ASWebAuthenticationPresentationContextProviding,
    ASAuthorizationControllerPresentationContextProviding
{
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.bvc.view.window!
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.bvc.view.window!
    }
}

extension AuthStore: ASAuthorizationControllerDelegate {
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

            self.handleSignUpWithApple(
                identityToken: identityTokenStr, authorizationCode: authorizationCodeStr)
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
// MARK: - OKTA Support

extension AuthStore {
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
        password: String,
        onError: ((_ message: String) -> Void)?,
        onSuccess: (() -> Void)?
    ) {
        self.onError = onError
        self.onSuccess = onSuccess

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
            firstname: "Member",
            lastname: "",
            password: hashedSaltAndPasswordEncoded,
            salt: saltEncoded,
            visitorID: "",
            expVisitorID: "",
            expVisitorOverrides: "",
            emailSubmissionID: "",
            referralCode: "",
            marketingEmailOptOut: self.marketingEmailOptOut,
            ignoreCountryCode: true
        )
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            Logger.browser.error(
                "Error decoding request body for create okta account")
            return
        }

        request.httpBody = jsonData

        let config = URLSessionConfiguration.default
        let delegate = OktaAccountCreationDelegate(callback: { token in
            self.handleOktaAccountCreated(token: token)
        })
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)

        session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 400 {
                    if let data = data {
                        var errorMessage = "Some unknown error occurred"
                        do {
                            let res = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            switch res.error {
                            case "UsedEmail":
                                errorMessage =
                                    "This email is associated with an existing Neeva account"
                                break
                            case "InternalError":
                                errorMessage = "Unexpected error occurred"
                                break
                            case "InvalidEmail":
                                errorMessage = "Invalid email used to register"
                                break
                            case "InvalidRequest":
                                errorMessage = "Invalid name and/or password"
                                break
                            case "InvalidToken":
                                errorMessage = "Token has already been used"
                                break
                            case "UsedToken":
                                errorMessage = "Token has already been used"
                                break
                            default:
                                errorMessage = res.error
                            }
                        } catch let err {
                            Logger.browser.error(
                                "Error creating Okta account: \(String(describing: err))")
                        }

                        self.onError?(errorMessage)
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

class OktaAccountCreationDelegate: NSObject, URLSessionTaskDelegate {
    var callback: ((_: String) -> Void)?

    init(callback: ((_: String) -> Void)?) {
        self.callback = callback
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        if let cookie = response.allHeaderFields["Set-Cookie"] as? String {
            guard
                let token = cookie.split(
                    separator: ";"
                ).first?.replacingOccurrences(
                    of: "httpd~login=", with: ""
                )
            else { return }

            DispatchQueue.main.async {
                self.callback?(token)
            }
        }
    }
}

// MARK: - QR Code Support

extension AuthStore {
    public func signInwithQRCode() {
        // TODO:
        /*
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
         */
    }
}
