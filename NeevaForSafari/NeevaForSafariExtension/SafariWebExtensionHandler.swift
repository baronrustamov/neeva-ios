// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SafariServices
import os.log

private struct CookieCutterKeys {
    // Global key.
    static let CookieCutter = "cookieCutter"
    static let FlaggedSites = "cookieCutter.flaggedSites"
    static let AcceptCookies = "acceptCookies"
    
    static let Analytic = "analytic"
    static let Marketing = "marketing"
    static let Social = "social"
}

private enum CookieCutterUpdate: String {
    case CookieNoticeHandled = "cookie-notice-handled"
    case GetPreferences = "get-preferences"
    case FlagSite = "flag-site"
    case IncreaseCookieStats = "increase-cookie-stats"
    case LogProviderUsage = "log-provider-usage"
    case StartedRunning = "started-running"
}

private enum ExtensionRequests: String {
    case CookieCutterUpdate = "cookieCutterUpdate"
    case GetPreference = "getPreference"
    case SavePreference = "savePreference"
}

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    private let defaults = UserDefaults.standard

    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems[0] as? NSExtensionItem,
                let data = item.userInfo?["message"] as? [String: Any] else {
            return
        }

        if let savePreference = data[ExtensionRequests.SavePreference.rawValue] as? String, let value = data["value"] as? Bool {
            os_log(.default, "Saving user preference: %{private}@ -- (NEEVA FOR SAFARI)", savePreference)
            defaults.set(value, forKey: savePreference)
            
            if savePreference == CookieCutterKeys.AcceptCookies {
                resetFlaggedSiteList()
                
                defaults.set(value, forKey: CookieCutterKeys.Analytic)
                defaults.set(value, forKey: CookieCutterKeys.Marketing)
                defaults.set(value, forKey: CookieCutterKeys.Social)
            }
        } else if let getPreference = data[ExtensionRequests.GetPreference.rawValue] as? String {
            os_log(.default, "Retrieving user preference: %{private}@ -- (NEEVA FOR SAFARI)", getPreference)

            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["value": defaults.bool(forKey: getPreference)]]
            context.completeRequest(returningItems: [response]) { _ in
                os_log(.default, "Returned data to extension: %{private}@ -- (NEEVA FOR SAFARI)", response.userInfo!)
            }
        } else if data[ExtensionRequests.CookieCutterUpdate.rawValue] as? String != nil {
            handleCookieCutterUpdate(context: context, data: data)
        } else {
            os_log(.default, "Received request with no usable instructions -- (NEEVA FOR SAFARI)")
        }
    }
    
    private func handleCookieCutterUpdate(context: NSExtensionContext, data: [String: Any]) {
        guard let cookieCutterUpdate = data[ExtensionRequests.CookieCutterUpdate.rawValue] as? String,
                let update = CookieCutterUpdate(rawValue: cookieCutterUpdate),
                let domain = data["domain"] as? String else {
            return
        }
        
        os_log(.default, "Cookie Cutter update received: %{private}@ -- (NEEVA FOR SAFARI)", cookieCutterUpdate)
        os_log(.default, "Cookie Cutter domain: %{private}@ -- (NEEVA FOR SAFARI)", domain)
        
        switch update {
        case .CookieNoticeHandled:
            flagSite(domain: domain)
        case .FlagSite:
            flagSite(domain: domain)
        case .GetPreferences:
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: [
                "cookieCutterEnabled": defaults.bool(forKey: CookieCutterKeys.CookieCutter),
                CookieCutterKeys.Analytic: !defaults.bool(forKey: CookieCutterKeys.Analytic),
                CookieCutterKeys.Marketing: !defaults.bool(forKey: CookieCutterKeys.Marketing),
                CookieCutterKeys.Social: !defaults.bool(forKey: CookieCutterKeys.Social),
                "isFlagged": isSiteFlagged(domain: domain)
            ]]
            
            context.completeRequest(returningItems: [response]) { _ in
                os_log(.default, "Returned data to Cookie Cutter: %{private}@ -- (NEEVA FOR SAFARI)", response.userInfo!)
            }
        case .IncreaseCookieStats:
            break
        case .LogProviderUsage:
            break
        case .StartedRunning:
            break
        }
    }
    
    private func flagSite(domain: String) {
        var currentFlagList = defaults.array(forKey: CookieCutterKeys.FlaggedSites) as? [String] ?? []
        currentFlagList.append(domain)
        
        defaults.set(currentFlagList, forKey: CookieCutterKeys.FlaggedSites)
    }
    
    private func isSiteFlagged(domain: String) -> Bool {
        let currentFlagList = defaults.array(forKey: CookieCutterKeys.FlaggedSites) as? [String] ?? []
        return currentFlagList.contains(domain)
    }
    
    private func resetFlaggedSiteList() {
        defaults.set([], forKey: CookieCutterKeys.FlaggedSites)
    }
}
