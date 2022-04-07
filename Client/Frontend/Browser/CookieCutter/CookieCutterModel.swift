// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import SwiftUI

enum CookieNotices: CaseIterable, Encodable, Decodable {
    case declineNonEssential
    case userSelected
}

extension Defaults.Keys {
    fileprivate static let cookieNotices = Defaults.Key<CookieNotices>(
        "profile.prefkey.cookieCutter.cookieNotices", default: .declineNonEssential)
    fileprivate static let marketingCookies = Defaults.Key<Bool>(
        "profile.prefkey.cookieCutter.allowMarketingCookies", default: false)
    fileprivate static let analyticCookies = Defaults.Key<Bool>(
        "profile.prefkey.cookieCutter.allowAnalyticCookies", default: false)
    fileprivate static let socialCookies = Defaults.Key<Bool>(
        "profile.prefkey.cookieCutter.allowSocialCookies", default: false)
}

class CookieCutterModel: ObservableObject {
    @Published var cookieNoticeStateShouldReset = false
    @Published var cookieNotices: CookieNotices {
        didSet {
            guard cookieNotices != oldValue else {
                return
            }

            Defaults[.cookieNotices] = cookieNotices

            let allowed = cookieNotices != .declineNonEssential
            marketingCookiesAllowed = allowed
            analyticCookiesAllowed = allowed
            socialCookiesAllowed = allowed
        }
    }

    // User selected settings.
    @Default(.marketingCookies) var marketingCookiesAllowed {
        didSet {
            checkIfCookieNoticeStateShouldReset()
        }
    }
    @Default(.analyticCookies) var analyticCookiesAllowed {
        didSet {
            checkIfCookieNoticeStateShouldReset()
        }
    }
    @Default(.socialCookies) var socialCookiesAllowed {
        didSet {
            checkIfCookieNoticeStateShouldReset()
        }
    }

    private func checkIfCookieNoticeStateShouldReset() {
        if cookieNotices == .userSelected
            && !marketingCookiesAllowed
            && !analyticCookiesAllowed
            && !socialCookiesAllowed
        {
            cookieNoticeStateShouldReset = true
        }
    }

    init() {
        self.cookieNotices = Defaults[.cookieNotices]
    }
}
