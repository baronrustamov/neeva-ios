// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Corresponds with messages sent from CookieCutterHelper.js
private enum CookieScriptMessage: String {
    case getPreferences = "get-preferences"
    case increaseCounter = "increase-cookie-stats"
    case noticeHandled = "cookie-notice-handled"
    case started = "started-running"
}

class CookieCutterHelper: TabContentScript {
    let cookieCutterModel: CookieCutterModel
    var currentWebView: WKWebView?

    // MARK: - Script Methods
    static func name() -> String {
        "CookieCutterHelper"
    }

    func scriptMessageHandlerName() -> String? {
        "cookieCutterHandler"
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage
    ) {
        guard
            let data = message.body as? [String: Any], let update = data["update"] as? String
        else {
            return
        }

        if let scriptMessage = CookieScriptMessage(rawValue: update) {
            switch scriptMessage {
            case .getPreferences:
                do {
                    guard
                        let escapedEncoded = String(
                            data: try JSONEncoder().encode([
                                "marketing": !cookieCutterModel.marketingCookiesAllowed,
                                "analytic": !cookieCutterModel.analyticCookiesAllowed,
                                "social": !cookieCutterModel.socialCookiesAllowed,
                            ]), encoding: .utf8)
                    else { return }

                    if let currentWebView = currentWebView {
                        currentWebView.evaluateJavascriptInDefaultContentWorld(
                            "__firefox__.setPreference(\(escapedEncoded))")
                    }
                } catch {
                    print("Error encoding escaped value: \(error)")
                }
            case .increaseCounter:
                cookieCutterModel.cookiesBlocked += 1
            case .noticeHandled:
                let bvc = SceneDelegate.getBVC(for: currentWebView)
                cookieCutterModel.cookieWasHandled(bvc: bvc)
            case .started:
                cookieCutterModel.cookiesBlocked = 0
            }
        } else {
            print("CookieCutterHandler recieved message (not handled): ", update)
        }
    }

    // MARK: - init
    init(cookieCutterModel: CookieCutterModel) {
        self.cookieCutterModel = cookieCutterModel
    }
}
