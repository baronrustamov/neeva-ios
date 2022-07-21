// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

private let log = Logger.browser

/// Corresponds with messages sent from CookieCutterHelper.js
private enum CookieScriptMessage: String {
    case flagSite = "flag-site"
    case getPreferences = "get-preferences"
    case increaseCounter = "increase-cookie-stats"
    case isSiteFlagged = "is-site-flagged"
    case logProvider = "log-provider-usage"
    case noticeHandled = "cookie-notice-handled"
    case started = "started-running"
}

class CookieCutterHelper: TabContentScript {
    let cookieCutterModel: CookieCutterModel

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

        let currentWebView = message.webView
        let domain = currentWebView?.url?.host

        if let scriptMessage = CookieScriptMessage(rawValue: update) {
            switch scriptMessage {
            case .flagSite:
                if let domain = domain {
                    cookieCutterModel.flagSite(domain: domain)
                }
            case .getPreferences:
                if let domain = domain, let webView = currentWebView {
                    if currentWebView?.url?.isNeevaURL() ?? false,
                        cookieCutterModel.optIntoNeevaCookies
                    {
                        // Pass false so Cookie Cutter does not block these cookies.
                        // The user has already consented to these cookies on first run.
                        sendResponse(
                            data: [
                                "cookieCutterEnabled":
                                    TrackingPreventionConfig.trackersPreventedFor(
                                        domain, checkCookieCutterState: true),
                                "marketing": false,
                                "analytic": false,
                                "social": false,
                            ], webView: webView)
                    } else {
                        sendResponse(
                            data: [
                                "cookieCutterEnabled":
                                    TrackingPreventionConfig.trackersPreventedFor(
                                        domain, checkCookieCutterState: true),
                                "marketing": !cookieCutterModel.marketingCookiesAllowed,
                                "analytic": !cookieCutterModel.analyticCookiesAllowed,
                                "social": !cookieCutterModel.socialCookiesAllowed,
                            ], webView: webView)
                    }
                }
            case .increaseCounter:
                cookieCutterModel.cookiesBlocked += 1
            case .isSiteFlagged:
                if let domain = domain, let webView = currentWebView {
                    sendResponse(
                        data: ["isFlagged": cookieCutterModel.isSiteFlagged(domain: domain)],
                        webView: webView)
                }
            case .logProvider:
                if let provider = data["provider"] as? String {
                    let attributes = [
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.CookieCutterProviderUsed,
                            value: provider
                        )
                    ]

                    ClientLogger.shared.logCounter(.CookieNoticeHandled, attributes: attributes)
                }
            case .noticeHandled:
                let bvc = SceneDelegate.getBVC(for: currentWebView)
                cookieCutterModel.cookieWasHandled(bvc: bvc, domain: domain)
            case .started:
                if let domain = domain, cookieCutterModel.isSiteFlagged(domain: domain) {
                    cookieCutterModel.cookiesBlocked = 1
                } else {
                    cookieCutterModel.cookiesBlocked = 0
                }
            }
        }

        log.info("Cookie Cutter script updated: \(update)")
    }

    private func sendResponse(data: [String: Bool], webView: WKWebView) {
        do {
            if let escapedEncoded = String(data: try JSONEncoder().encode(data), encoding: .utf8) {
                webView.evaluateJavascriptInDefaultContentWorld(
                    "__firefox__.setIsSiteFlagged(\(escapedEncoded))")
            }
        } catch {
            print("Error encoding escaped value: \(error)")
        }
    }

    // MARK: - init
    init(cookieCutterModel: CookieCutterModel) {
        self.cookieCutterModel = cookieCutterModel
    }
}
