// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import KeychainAccess
import UIKit

extension Defaults.Keys {
    public static let neevaHost = Defaults.Key<String>(
        "neevaHost", default: "neeva.com", suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)
}

public struct NeevaConstants {
    /// The App Group, used for the keychain and UserDefaults
    public static let appGroup = "group." + AppInfo.baseBundleIdentifier
    public static let neevaAppGroup = "group.co.neeva.app.ios.browser"

    /// The host for the Neeva API/website, such as `neeva.com`
    public static var appHost: String {
        get { Defaults[.neevaHost] }
        set { Defaults[.neevaHost] = newValue }
    }

    public static func isAppHost(_ host: String?, allowM1: Bool = false) -> Bool {
        let host = host?.lowercased()
        return host == appHost || (host == "m1.neeva.com" && allowM1)
    }

    // This function provides a layer of indirection to allow tests to override how URLs on
    // `appHost` are formed.
    public static var buildAppURL: (String) -> URL = { path in
        URL(string: "https://\(appHost)/\(path)")!
    }

    /// The URL form of `appHost` and various routes:
    public static var appURL: URL { buildAppURL("") }
    public static var appSearchURL: URL { buildAppURL("search") }
    public static var appSpacesURL: URL { buildAppURL("spaces") }
    public static var appSettingsURL: URL { buildAppURL("settings") }
    public static var appReferralsURL: URL { buildAppURL("settings/referrals") }
    public static var appMembershipURL: URL { buildAppURL("settings/membership") }
    public static var appConnectionsURL: URL { buildAppURL("connections") }
    public static var appMemoryModeURL: URL { buildAppURL("settings#memory-mode") }
    public static var appSigninURL: URL { buildAppURL("signin") }
    public static var appSignupURL: URL { buildAppURL("p/signup") }
    public static var appFAQURL: URL { buildAppURL("faq") }
    public static var appWelcomeToursURL: URL { buildAppURL("#modal-hello") }
    public static var configureNewsProviderURL: URL { buildAppURL("settings/news-providers") }
    public static var appDeepLinkURL: URL { buildAppURL("app/") }

    public static var createOktaAccountURL: URL { buildAppURL("login/create") }
    public static var oktaLoginBaseURL: URL { buildAppURL("login") }
    public static var verificationRequiredURL: URL { buildAppURL("p/signup/verification-required") }

    public static let appMarketingURL: URL = "https://neeva.com/"
    public static let appHelpCenterURL: URL = "https://help.neeva.com/"
    public static let appPrivacyURL = appMarketingURL / "privacy"
    public static let appTermsURL = appMarketingURL / "terms"
    public static let cookieCutterHelpURL: URL =
        "https://help.neeva.com/hc/en-us/articles/4486326606355"

    public static var xyzURL: URL {
        URL(string: "https://neeva.xyz/\(Defaults[.cryptoPublicKey])") ?? "https://neeva.xyz/"
    }

    /// The keychain key to store the Neeva login cookie into
    public static var loginKeychainKey: String { "neevaHttpdLogin-\(appHost)" }

    /// The keychain key to store the Neeva-Wallet properties
    public static var cryptoPrivateKey: String { "neevaCryptoPrivateKey-\(appHost)" }
    public static var cryptoSecretPhrase: String { "neevaCryptoSecretPhrase-\(appHost)" }

    /// The shared keychain accessible to the Neeva app and its extensions
    public static let keychain = Keychain(service: "Neeva", accessGroup: appGroup)
    public static let cryptoKeychain = Keychain(service: "Neeva-Wallet")
        .accessibility(.whenUnlockedThisDeviceOnly)

    public static var deviceTypeValue: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return "tablet"
        case .mac:
            return "desktop"
        default:
            return "phone"
        }
    }

    public static var deviceNameValue: String = DeviceInfo.specificModelName

    public struct Header {
        public let name: String
        public let value: String
        private init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }

        /// Pass this header to all requests to Neeva from the iOS app.
        public static let deviceType = Header("X-Neeva-Device-Type", deviceTypeValue)
        public static let deviceName = Header("X-Neeva-Device-Name", deviceNameValue)
    }

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var deviceTypeCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "DeviceType",
            .value: deviceTypeValue,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var deviceNameCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "DeviceName",
            .value: deviceNameValue,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var browserTypeCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "BrowserType",
            .value: "neeva-ios",
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// This cookie is set on requests to identify the version of the browser.
    public static var browserVersionCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "BrowserVersion",
            .value: AppInfo.appVersionReportedToNeeva,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// Generates a login cookie from the given cookie value.
    public static func loginCookie(for value: String) -> HTTPCookie {
        HTTPCookie(properties: [
            .name: "httpd~login",
            .value: value,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
            .secure: true,
            .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
            // ! potentially undocumented API
            .init("HttpOnly"): true,
        ])!
    }

    public static let sharedBundle = Bundle(for: BundleHookClass.self)

    // Returns true if the page has an embedded search box, indicating that we
    // should not show the same query in the URL bar.
    // TODO: This should probably be server controlled through a feature flag.
    public static func isNeevaPageWithSearchBox(url: URL?) -> Bool {
        return url?.scheme == NeevaConstants.appSearchURL.scheme
            && url?.host == NeevaConstants.appSearchURL.host
            && url?.path == NeevaConstants.appSearchURL.path
            && url?.hasQueryParam("c", value: "Maps") == true
    }

    public static func isNeevaSearchResultPage(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        let appSearchURL = NeevaConstants.appSearchURL
        // origin checks for scheme and host
        return url.origin == appSearchURL.origin && url.path == appSearchURL.path
    }

    public static func isInNeevaDomain(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        // origin checks for scheme and host
        return url.origin == appURL.origin
    }

    // Construct auth url for signin with apple
    public static func appleAuthURL(
        identityToken: String,
        authorizationCode: String,
        marketingEmailOptOut: Bool,
        signup: Bool
    ) -> URL {
        let authURL = buildAppURL("login-mobile")
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "provider", value: "neeva.co/auth/oauth2/authenticators/apple"),
            URLQueryItem(name: "identityToken", value: identityToken),
            URLQueryItem(name: "serverAuthCode", value: identityToken),
            URLQueryItem(name: "authorizationCode", value: authorizationCode),
            URLQueryItem(name: "mktEmailOptOut", value: String(marketingEmailOptOut)),
            URLQueryItem(name: "signup", value: String(signup)),
            URLQueryItem(name: "ignoreCountryCode", value: "true"),
        ]
        return authURL.withQueryParams(queryItems)
    }

    public static func encodeEmail(email: String) -> String? {
        let emailAllowedCharacter = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: emailAllowedCharacter)
        return encodedEmail
    }

    // Construct url for okta signup
    public static func oktaSignupURL(email: String, marketingEmailOptOut: Bool) -> URL {
        var oktaURL = appSignupURL.absoluteString

        if let encodedEmail = encodeEmail(email: email) {
            oktaURL =
                appSignupURL.absoluteString
                + "?emp="
                + String(marketingEmailOptOut ? "oo" : "oi")
                + "&e=" + encodedEmail
                + "&q=i"
        }
        return URL(string: oktaURL)!
    }

    // Construct url for okta signin
    public static func oktaSigninURL(email: String) -> URL {
        var oktaLoginURL = oktaLoginBaseURL.absoluteString

        if let encodedEmail = encodeEmail(email: email) {
            oktaLoginURL =
                oktaLoginBaseURL.absoluteString
                + "?provider=neeva.co/auth/oauth2/authenticators/okta&loginHint="
                + encodedEmail
        }
        return URL(string: oktaLoginURL)!
    }

    public enum OAuthProvider: String {
        case google = "google"
        case microsoft = "microsoft"
        case okta = "okta"
    }

    // Construct signup OAuth string
    public static func signupOAuthString(
        provider: OAuthProvider, mktEmailOptOut: Bool, email: String = ""
    ) -> String {
        switch provider {
        case .google, .microsoft:
            return
                "https://\(appHost)/login?provider=neeva.co/auth/oauth2/authenticators/\(provider.rawValue)&finalPath=%2F&signup=true&ignoreCountryCode=true&mktEmailOptOut=\(String(mktEmailOptOut))&loginCallbackType=ios"
        case .okta:
            let oktaBaseURL =
                "https://\(appHost)/login?provider=neeva.co/auth/oauth2/authenticators/\(provider.rawValue)&loginCallbackType=ios&finalPath=%2F%3Fnva&loginHint="
            if !email.isEmpty {
                if let encodedEmail = encodeEmail(email: email) {
                    return oktaBaseURL + encodedEmail
                }
            }
            return oktaBaseURL
        }
    }

    // Neeva OAuth callback scheme
    public static func neevaOAuthCallbackScheme() -> String? {
        return "neeva://login/cb".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}

private class BundleHookClass {}
