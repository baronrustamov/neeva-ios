// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Foundation
import SwiftUI

private let log = Logger.browser

/// Information associated with a user account, fetched from the server.
public struct UserInfo {
    let id: String?
    let name: String?
    let email: String?
    let pictureUrl: String?
    let authProvider: String?
    let featureFlags: [UserInfoQuery.Data.User.FeatureFlag]
    let userFlags: [String]
    let subscriptionType: SubscriptionType?
    let isVerified: Bool

    public init(
        id: String?, name: String?, email: String?, pictureUrl: String?, authProvider: String?,
        featureFlags: [UserInfoQuery.Data.User.FeatureFlag], userFlags: [String],
        subscriptionType: SubscriptionType?, isVerified: Bool
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.pictureUrl = pictureUrl
        self.authProvider = authProvider
        self.featureFlags = featureFlags
        self.userFlags = userFlags
        self.subscriptionType = subscriptionType
        self.isVerified = isVerified
    }
}

/// Enum container for the result of fetching `UserInfo` from the server.
public enum UserInfoResult {
    /// On success, the `UserInfo` parameter provides information about the user.
    case success(UserInfo)

    /// If unable to fetch user info due to an authentication error.
    case failureAuthenticationError

    /// If unable to fetch user info due to a temporary error (e.g., network
    /// connection issue).
    case failureTemporaryError
}

/// Used to fetch UserInfo from the server. The implementation can be overridden
/// for testing purposes.
open class UserInfoProvider {
    public static var shared = UserInfoProvider()

    public init() {
    }

    open func fetch(completion: @escaping (UserInfoResult) -> Void) {
        UserInfoQuery().fetch { result in
            var userInfoResult: UserInfoResult
            switch result {
            case .success(let data):
                userInfoResult = .success(
                    UserInfo(
                        id: data.user?.id,
                        name: data.user?.profile.displayName,
                        email: data.user?.profile.email,
                        pictureUrl: data.user?.profile.pictureUrl,
                        authProvider: data.user?.authProvider,
                        featureFlags: data.user?.featureFlags ?? [],
                        userFlags: data.user?.flags ?? [],
                        subscriptionType: data.user?.subscriptionType,
                        isVerified: data.user?.isVerified ?? true
                    ))
            case .failure(let error):
                userInfoResult = .failureTemporaryError
                if let errors = (error as? GraphQLAPI.Error)?.errors {
                    let messages = errors.filter({ $0.message != nil }).map({ $0.message! })
                    let errorMsg =
                        "Error fetching UserInfo: \(messages.joined(separator: "\n"))"
                    log.error(errorMsg)
                    if errorMsg.range(of: "login required", options: .caseInsensitive) != nil {
                        userInfoResult = .failureAuthenticationError
                    }
                } else {
                    log.error("Error fetching UserInfo: \(error)")
                }
            }
            completion(userInfoResult)
        }
    }
}

public class ResendVerificationEmailRequest: MutationRequest<ResendVerificationEmailMutation> {
    public init() {
        super.init(mutation: ResendVerificationEmailMutation())
    }
}
