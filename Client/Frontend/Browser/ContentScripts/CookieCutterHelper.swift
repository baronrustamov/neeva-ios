// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

    func userContentController(didReceiveScriptMessage message: WKScriptMessage) {
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
                do {
                    if let domain = domain {
                        var cookieCutterEnabled = TrackingPreventionConfig.trackersPreventedFor(
                            domain, checkCookieCutterState: true)
                        // Don't dismiss the cookie consent on neeva.com
                        if currentWebView?.url?.isNeevaURL() ?? false {
                            cookieCutterEnabled = false
                        }
                        if let escapedEncoded = String(
                            data: try JSONEncoder().encode([
                                "cookieCutterEnabled": cookieCutterEnabled,
                                "analyticAllowed": cookieCutterModel.analyticCookiesAllowed,
                                "marketingAllowed": cookieCutterModel.marketingCookiesAllowed,
                                "socialAllowed": cookieCutterModel.socialCookiesAllowed,
                            ]), encoding: .utf8)
                        {
                            currentWebView?.evaluateJavascriptInDefaultContentWorld(
                                "__firefox__.setPreference(\(escapedEncoded))")
                        }
                    }
                } catch {
                    print("Error encoding escaped value: \(error)")
                }
            case .increaseCounter:
                cookieCutterModel.cookiesBlocked += 1
            case .isSiteFlagged:
                do {
                    if let domain = domain,
                        let escapedEncoded = String(
                            data: try JSONEncoder().encode([
                                "isFlagged": cookieCutterModel.isSiteFlagged(domain: domain)
                            ]), encoding: .utf8)
                    {
                        currentWebView?.evaluateJavascriptInDefaultContentWorld(
                            "__firefox__.setIsSiteFlagged(\(escapedEncoded))")
                    }
                } catch {
                    print("Error encoding escaped value: \(error)")
                }
            case .logProvider:
                if let provider = data["provider"] as? String {
                    let attributes = [
                        ClientLogCounterAttribute(
                            key: LogConfig.CookieCutterAttribute.CookieCutterProviderUsed,
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

    func connectedTabChanged(_ tab: Tab) {}

    // MARK: - init
    init(cookieCutterModel: CookieCutterModel) {
        self.cookieCutterModel = cookieCutterModel
    }
}
