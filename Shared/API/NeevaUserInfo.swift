// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Defaults
import Foundation
import Reachability
import SwiftUI
import WebKit

public class NeevaUserInfo: ObservableObject {
    public static let shared = NeevaUserInfo()

    @Published public private(set) var id: String?
    @Published public private(set) var displayName: String?
    @Published public private(set) var email: String?
    @Published public private(set) var pictureUrl: String?
    @Published public private(set) var pictureData: Data?
    @Published public private(set) var authProvider: SSOProvider?
    @Published public private(set) var subscriptionType: SubscriptionType?
    @Published public private(set) var isLoading = false
    @Published public private(set) var isVerified = false

    /// Using optimistic approach, the user is considered `LoggedIn = true` until we receive a login required GraphQL error.
    // TODO: consider not taking the optimistic approach; preview mode code paths should be able to depend on this
    @Published public private(set) var isUserLoggedIn: Bool = true

    // TODO: fetch this from the API!
    @Published public var countryCode: String = "US"

    private let reachability = try! Reachability()
    private var connection: Reachability.Connection?

    public init(
        previewDisplayName displayName: String?, email: String?, pictureUrl: String?,
        authProvider: SSOProvider?
    ) {
        self.displayName = displayName
        self.email = email
        self.pictureUrl = pictureUrl
        self.authProvider = (authProvider?.rawValue).flatMap(SSOProvider.init(rawValue:))
        isUserLoggedIn = true
        fetchUserPicture()
    }

    public static let previewLoggedOut = NeevaUserInfo(previewLoggedOut: ())
    public static let previewLoading = NeevaUserInfo(previewLoading: ())
    private init(previewLoggedOut: ()) {
        isUserLoggedIn = false
    }
    private init(previewLoading: ()) {
        isLoading = true
    }

    private init() {
        reachability.whenReachable = { reachability in
            self.connection = reachability.connection
            self.fetch()
        }
        reachability.whenUnreachable = { reachability in
            self.connection = nil
        }
        try! reachability.startNotifier()
    }

    func fetch() {
        if !isDeviceOnline {
            print("Warn: the device is offline, forcing cached information load.")
            self.loadUserInfoFromDefaults()
            return
        }

        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserInfoProvider.shared.fetch { result in
                self.isLoading = false
                switch result {
                case .success(let userInfo):
                    self.saveUserInfoToDefaults(userInfo: userInfo)
                    self.fetchUserPicture()
                    self.isUserLoggedIn = true
                    self.isVerified = userInfo.isVerified
                    NeevaFeatureFlags.update(featureFlags: userInfo.featureFlags)
                    UserFlagStore.shared.onUpdateUserFlags(userInfo.userFlags)
                    /// Once we've fetched UserInfo sucessfully, we don't need to keep monitoring connectivity anymore.
                    self.reachability.stopNotifier()
                case .failureAuthenticationError:
                    self.isUserLoggedIn = false
                    self.clearUserInfoCache()
                    self.loadUserInfoFromDefaults()
                case .failureTemporaryError:
                    self.loadUserInfoFromDefaults()
                }
            }
        }
    }

    public func reload() {
        if !self.isLoading {
            self.fetch()
        }
    }

    public func didLogOut() {
        clearCache()
        isUserLoggedIn = false
        fetch()
    }

    public func clearCache() {
        self.clearUserInfoCache()
    }

    public func updateLoginCookieFromWebKitCookieStore(completion: @escaping () -> Void) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            if let authCookie = cookies.first(where: Self.matchesLoginCookie) {
                self.setLoginCookie(authCookie.value)
                completion()
            }
        }
    }

    public func setLoginCookie(_ value: String) {
        // check if token has changed, when different, save new token
        // and fetch user info
        if self.getLoginCookie() == value {
            self.isUserLoggedIn = true
            self.loadUserInfoFromDefaults()
            self.fetchUserPicture()
            self.reachability.stopNotifier()
        } else {
            try? NeevaConstants.keychain.set(value, key: NeevaConstants.loginKeychainKey)
            self.fetch()
        }
    }

    public func getLoginCookie() -> String? {
        return try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey)
    }

    public func hasLoginCookie() -> Bool {
        let token = getLoginCookie()
        if token != nil {
            return true
        }
        return false
    }

    public func deleteLoginCookie() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            if let authCookie = cookies.first(where: Self.matchesLoginCookie) {
                cookieStore.delete(authCookie)
            }
        }
        try? NeevaConstants.keychain.remove(NeevaConstants.loginKeychainKey)
    }

    private static func matchesLoginCookie(cookie: HTTPCookie) -> Bool {
        // Allow non-HTTPS for testing purposes.
        NeevaConstants.isAppHost(cookie.domain) && cookie.name == "httpd~login"
            && (NeevaConstants.appURL.scheme != "https" || cookie.isSecure)
    }

    public func loadUserInfoFromDefaults() {
        let userInfoDict = Defaults[.neevaUserInfo]

        self.id = userInfoDict["userId"]
        self.displayName = userInfoDict["userDisplayName"]
        self.email = userInfoDict["userEmail"]
        self.pictureUrl = userInfoDict["userPictureUrl"]
        self.authProvider = userInfoDict["userAuthProvider"].flatMap(SSOProvider.init(rawValue:))
        self.subscriptionType = userInfoDict["userSubscriptionType"].flatMap(
            SubscriptionType.init(rawValue:))
    }

    private func fetchUserPicture() {
        guard let url = URL(string: pictureUrl ?? "") else {
            return
        }

        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print(
                    "Error fetching UserPicture: \(String(describing: error?.localizedDescription))"
                )
                return
            }

            // fixes an error caused by updating UI on the background thread
            DispatchQueue.main.async {
                self.pictureData = data
            }
        }

        dataTask.resume()
    }

    private var isDeviceOnline: Bool {
        if let connection = connection, connection != .unavailable {
            return true
        }

        return false
    }

    private func saveUserInfoToDefaults(userInfo: UserInfo) {
        Defaults[.neevaUserInfo] = [
            "userId": userInfo.id,
            "userDisplayName": userInfo.name,
            "userEmail": userInfo.email,
            "userPictureUrl": userInfo.pictureUrl,
            "userAuthProvider": userInfo.authProvider,
            "userSubscriptionType": userInfo.subscriptionType?.rawValue,
        ].compactMapValues { $0 }

        displayName = userInfo.name
        email = userInfo.email
        pictureUrl = userInfo.pictureUrl
        authProvider = userInfo.authProvider.flatMap(SSOProvider.init(rawValue:))
        subscriptionType = userInfo.subscriptionType
    }

    private func clearUserInfoCache() {
        displayName = nil
        email = nil
        pictureUrl = nil
        pictureData = nil
        id = nil
        authProvider = nil
        subscriptionType = nil
        self.reachability.stopNotifier()
    }
}
