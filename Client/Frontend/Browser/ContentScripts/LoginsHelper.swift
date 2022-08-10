/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import Shared
import Storage
import SwiftyJSON
import WebKit
import XCGLogger

private let log = Logger.browser

class LoginsHelper: TabContentScript {
    fileprivate weak var tab: Tab?
    fileprivate let profile: Profile

    class func name() -> String {
        return "LoginsHelper"
    }

    required init(tab: Tab, profile: Profile) {
        self.tab = tab
        self.profile = profile
    }

    func scriptMessageHandlerName() -> String? {
        return "loginsManagerMessageHandler"
    }

    fileprivate func getOrigin(_ uriString: String, allowJS: Bool = false) -> String? {
        guard let uri = URL(string: uriString),
            let scheme = uri.scheme, !scheme.isEmpty,
            let host = uri.host
        else {
            // bug 159484 - disallow url types that don't support a hostPort.
            // (although we handle "javascript:..." as a special case above.)
            log.debug("Couldn't parse origin for \(uriString)")
            return nil
        }

        if allowJS && scheme == "javascript" {
            return "javascript:"
        }

        var realm = "\(scheme)://\(host)"

        // If the URI explicitly specified a port, only include it when
        // it's not the default. (We never want "http://foo.com:80")
        if let port = uri.port {
            realm += ":\(port)"
        }

        return realm
    }

    func loginRecordFromScript(_ script: [String: Any], url: URL) -> LoginRecord? {
        guard let username = script["username"] as? String,
            let password = script["password"] as? String,
            let origin = getOrigin(url.absoluteString)
        else {
            return nil
        }

        var dict: [String: Any] = [
            "hostname": origin,
            "username": username,
            "password": password,
        ]

        if let string = script["formSubmitURL"] as? String,
            let formSubmitURL = getOrigin(string)
        {
            dict["formSubmitURL"] = formSubmitURL
        }

        if let passwordField = script["passwordField"] as? String {
            dict["passwordField"] = passwordField
        }

        if let usernameField = script["usernameField"] as? String {
            dict["usernameField"] = usernameField
        }

        return LoginRecord(fromJSONDict: dict)
    }

    func userContentController(didReceiveScriptMessage message: WKScriptMessage) {
        guard let res = message.body as? [String: Any],
            let type = res["type"] as? String
        else {
            return
        }

        // We don't use the WKWebView's URL since the page can spoof the URL by using document.location
        // right before requesting login data. See bug 1194567 for more context.
        if let url = message.frameInfo.request.url {
            // Since responses go to the main frame, make sure we only listen for main frame requests
            // to avoid XSS attacks.
            if message.frameInfo.isMainFrame && type == "request" {
                requestLogins(res, url: url)
            } else if type == "submit" {
                // TODO(issue/281): Disabled by default. Figure out our password management story.
                if Defaults[.saveLogins] {
                    if let login = loginRecordFromScript(res, url: url) {
                        setCredentials(login)
                    }
                }
            }
        }
    }

    func connectedTabChanged(_ tab: Tab) {
        self.tab = tab
    }

    func setCredentials(_ login: LoginRecord) {
        if login.password.isEmpty {
            log.debug("Empty password")
            return
        }

        profile.logins
            .getLoginsForProtectionSpace(login.protectionSpace, withUsername: login.username)
            .uponQueue(.main) { res in
                if let data = res.successValue {
                    log.debug("Found \(data.count) logins.")
                    for saved in data {
                        if let saved = saved {
                            if saved.password == login.password {
                                _ = self.profile.logins.use(login: saved)
                                return
                            }

                            self.promptUpdateFromLogin(login: saved, toLogin: login)
                            return
                        }
                    }
                }

                self.promptSave(login)
            }
    }

    fileprivate func promptSave(_ login: LoginRecord) {
        guard login.isValid.isSuccess else {
            return
        }

        /* TODO: Add prompt message to save the user's credentials back here
        let promptMessage: String
        let https = "^https:\\/\\/"
        let url = login.hostname.replacingOccurrences(
            of: https, with: "", options: .regularExpression, range: nil)
        let userName = login.username
        if !userName.isEmpty {
            promptMessage = String(format: Strings.SaveLoginUsernamePrompt, userName, url)
        } else {
            promptMessage = String(format: Strings.SaveLoginPrompt, url)
        } */
    }

    fileprivate func promptUpdateFromLogin(login old: LoginRecord, toLogin new: LoginRecord) {
        guard new.isValid.isSuccess else {
            return
        }

        new.id = old.id

        /* TODO: Add prompt message to update the user's credentials back here
        let formatted: String
        let userName = new.username
        if !userName.isEmpty {
            formatted = String(format: Strings.UpdateLoginUsernamePrompt, userName, new.hostname)
        } else {
            formatted = String(format: Strings.UpdateLoginPrompt, new.hostname)
        } */
    }

    fileprivate func requestLogins(_ request: [String: Any], url: URL) {
        guard let requestId = request["requestId"] as? String,
            // Even though we don't currently use these two fields,
            // verify that they were received as additional confirmation
            // that this is a valid request from LoginsHelper.js.
            let _ = request["formOrigin"] as? String,
            let _ = request["actionOrigin"] as? String,

            // We pass in the webview's URL and derive the origin here
            // to workaround Bug 1194567.
            let origin = getOrigin(url.absoluteString)
        else {
            return
        }

        let protectionSpace = URLProtectionSpace.fromOrigin(origin)

        profile.logins.getLoginsForProtectionSpace(protectionSpace).uponQueue(.main) { res in
            guard let cursor = res.successValue else {
                return
            }

            let logins: [[String: Any]] = cursor.compactMap { login in
                // `requestLogins` is for webpage forms, not for HTTP Auth, and the latter has httpRealm != nil; filter those out.
                return login?.httpRealm == nil ? login?.toJSONDict() : nil
            }

            log.debug("Found \(logins.count) logins.")

            let dict: [String: Any] = [
                "requestId": requestId,
                "name": "RemoteLogins:loginsFound",
                "logins": logins,
            ]

            let json = JSON(dict)
            let injectJavaScript = "window.__firefox__.logins.inject(\(json.stringify()!))"
            self.tab?.webView?.evaluateJavascriptInDefaultContentWorld(injectJavaScript)
        }
    }
}
