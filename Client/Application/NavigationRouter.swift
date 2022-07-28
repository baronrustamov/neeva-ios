/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

#if XYZ
    import WalletConnectSwift
#endif

extension URLComponents {
    // Return the first query parameter that matches
    func valueForQuery(_ param: String) -> String? {
        return self.queryItems?.first { $0.name == param }?.value
    }
}

// The root navigation for the Router. Look at the tests to see a complete URL
enum NavigationPath {
    case url(webURL: URL?, isIncognito: Bool)
    case widgetUrl(webURL: URL?, uuid: String)
    case closeIncogntioTabs
    case space(String, [String]?, Bool)
    case spaceDigest
    case openSetting(SettingsPage?)
    case fastTap(String, Bool)
    case configNewsProvider(isIncognito: Bool)
    case openDefaultBrowserEducation
    #if XYZ
        case walletConnect(wcURL: WCURL)
    #endif

    init?(url: URL) {
        let urlString = url.absoluteString
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        guard
            let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes")
                as? [AnyObject],
            let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String]
        else {
            // Something very strange has happened
            return nil
        }

        // Schemes are case-insensitive per RFC 3986
        guard let scheme = components.scheme?.lowercased(), urlSchemes.contains(scheme) else {
            return nil
        }

        if urlString.starts(with: "\(scheme)://open-url") {
            self = .openUrlFromComponents(components: components)
        } else if let widgetKitNavPath = NavigationPath.handleWidgetKitQuery(
            urlString: urlString, scheme: scheme, components: components)
        {
            self = widgetKitNavPath
        } else if scheme == "http" || scheme == "https" {
            self = .url(
                webURL: NavigationPath.maybeRewriteURL(url, components) ?? url,
                // Use the last browsing mode the user was in
                isIncognito: Defaults[.lastSessionPrivate]
            )
        } else if urlString.starts(with: "\(scheme)://space-digest") {
            self = .spaceDigest
        } else if urlString.starts(with: "\(scheme)://space"),
            let spaceId = components.valueForQuery("id")
        {
            var updatedItemIds: [String]?
            if let ids = components.valueForQuery("updatedItemIds") {
                updatedItemIds = ids.components(separatedBy: ",")
            }
            self = .space(spaceId, updatedItemIds, Defaults[.lastSessionPrivate])
        } else if urlString.starts(with: "\(scheme)://fast-tap"),
            let query =
                components.valueForQuery("query")?.replacingOccurrences(of: "+", with: " ")
        {
            self = .fastTap(query, components.valueForQuery("no-delay") != nil)
        } else if urlString.starts(with: "\(scheme)://configure-news-provider") {
            self = .configNewsProvider(isIncognito: Defaults[.lastSessionPrivate])
        } else if urlString.starts(with: "\(scheme)://wc?uri=") {
            #if XYZ
                if let wcURL = WCURL(
                    urlString.dropFirst("\(scheme)://wc?uri=".count).removingPercentEncoding ?? "")
                {
                    self = .walletConnect(wcURL: wcURL)
                    return
                }
            #endif
            return nil

        } else if urlString.starts(with: "\(scheme)://open-default-browser-education") {
            self = .openDefaultBrowserEducation
        } else if urlString.starts(with: "\(scheme)://open-setting"),
            let pageParam = components.valueForQuery("page"),
            let page = SettingsPage(rawValue: pageParam)
        {
            self = .openSetting(page)
        } else {
            return nil
        }
    }

    static func handle(nav: NavigationPath, with bvc: BrowserViewController) {
        switch nav {
        case .url(let url, let isIncognito):
            NavigationPath.handleURL(url: url, isIncognito: isIncognito, with: bvc)
        case .closeIncogntioTabs:
            NavigationPath.handleCloseIncognitoTabs(with: bvc)
        case .widgetUrl(let webURL, let uuid):
            NavigationPath.handleWidgetURL(url: webURL, uuid: uuid, with: bvc)
        case .spaceDigest:
            NavigationPath.handleSpaceDigest(with: bvc)
        case .space(let spaceId, let updatedItemIds, let isIncognito):
            NavigationPath.handleSpace(
                spaceId: spaceId, updatedItemIds: updatedItemIds, with: bvc)
        case .fastTap(let query, let noDelay):
            NavigationPath.handleFastTap(query: query, with: bvc, noDelay: noDelay)
        case .configNewsProvider(let isIncognito):
            NavigationPath.handleURL(
                url: NeevaConstants.configureNewsProviderURL, isIncognito: isIncognito, with: bvc)
        case .openDefaultBrowserEducation:
            NavigationPath.handleOpenDefaultBrowserEducation(with: bvc)
        #if XYZ
            case .walletConnect(let wcURL):
                bvc.connectWallet(to: wcURL)
        #endif
        case .openSetting(let page):
            NavigationPath.handleOpenSetting(page: page, with: bvc)
        }
    }

    static func navigationPath(from url: URL) -> NavigationPath? {
        guard url.absoluteString.hasPrefix(NeevaConstants.appDeepLinkURL.absoluteString),
            let deepLink = URL(
                string: "neeva://"
                    + url.absoluteString.dropFirst(
                        NeevaConstants.appDeepLinkURL.absoluteString.count))
        else {
            return nil
        }

        return NavigationPath(url: deepLink)
    }

    private static func handleWidgetKitQuery(
        urlString: String, scheme: String, components: URLComponents
    ) -> NavigationPath? {
        if urlString.starts(with: "\(scheme)://widget-medium-topsites-open-url") {
            // Widget Top sites - open url
            return .openUrlFromComponents(components: components)
        } else if urlString.starts(with: "\(scheme)://widget-small-quicklink-open-url") {
            // Widget Quick links - small - open url private or regular
            return .openUrlFromComponents(components: components)
        } else if urlString.starts(with: "\(scheme)://widget-medium-quicklink-open-url") {
            // Widget Quick Actions - medium - open url private or regular
            return .openUrlFromComponents(components: components)
        } else if urlString.starts(with: "\(scheme)://widget-small-quicklink-open-copied")
            || urlString.starts(with: "\(scheme)://widget-medium-quicklink-open-copied")
            || urlString.starts(with: "\(scheme)://open-copied")
        {
            // Widget Quick links - medium - open copied url
            return .openCopiedUrl()
        } else if urlString.starts(with: "\(scheme)://widget-small-quicklink-close-private-tabs")
            || urlString.starts(with: "\(scheme)://widget-medium-quicklink-close-private-tabs")
        {
            // Widget Quick links - medium - close private tabs
            return .closeIncogntioTabs
        }

        return nil
    }

    private static func openUrlFromComponents(components: URLComponents)
        -> NavigationPath
    {
        let url = components.valueForQuery("url")?.asURL
        // Unless the `open-url` URL specifies a `private` parameter,
        // use the last browsing mode the user was in.
        let isIncognito =
            Bool(components.valueForQuery("private") ?? "") ?? Defaults[.lastSessionPrivate]
        return .url(webURL: url, isIncognito: isIncognito)
    }

    private static func openCopiedUrl() -> NavigationPath? {
        guard let url = UIPasteboard.general.url else {
            if let string = UIPasteboard.general.string, let url = URL(string: string) {
                return .url(webURL: url, isIncognito: Defaults[.lastSessionPrivate])
            } else {
                return nil
            }
        }

        return .url(webURL: url, isIncognito: Defaults[.lastSessionPrivate])
    }

    private static func handleCloseIncognitoTabs(with bvc: BrowserViewController) {
        bvc.tabManager.removeTabs(bvc.tabManager.incognitoTabs)
        guard let tab = mostRecentTab(inTabs: bvc.tabManager.normalTabs) else {
            bvc.tabManager.selectTab(bvc.tabManager.addTab(), notify: true)
            return
        }
        bvc.tabManager.selectTab(tab, notify: true)
    }

    private static func handleURL(url: URL?, isIncognito: Bool, with bvc: BrowserViewController) {
        if let newURL = url {
            if newURL.isNeevaURL() && newURL.path.hasPrefix("/spaces") {
                let spaceId = newURL.lastPathComponent
                if spaceId != "spaces" {
                    NavigationPath.handleSpace(
                        spaceId: spaceId, updatedItemIds: [], with: bvc
                    )
                } else {
                    bvc.browserModel.showSpaces()
                }
            } else {
                bvc.switchToTabForURLOrOpen(newURL, isIncognito: isIncognito)
            }
        } else {
            bvc.openLazyTab(
                openedFrom: .openTab(bvc.tabManager.selectedTab), switchToIncognitoMode: isIncognito
            )
        }
    }

    private static func handleWidgetURL(url: URL?, uuid: String, with bvc: BrowserViewController) {
        if let newURL = url {
            bvc.switchToTabForWidgetURLOrOpen(newURL, uuid: uuid, isIncognito: false)
        } else {
            bvc.openLazyTab(
                openedFrom: .openTab(bvc.tabManager.selectedTab), switchToIncognitoMode: false
            )
        }
    }

    private static func handleSpaceDigest(with bvc: BrowserViewController) {
        guard NeevaFeatureFlags[.enableSpaceDigestDeeplink] else { return }
        bvc.browserModel.openSpaceDigest(bvc: bvc)
    }

    private static func handleOpenDefaultBrowserEducation(with bvc: BrowserViewController) {
        bvc.presentDBOnboardingViewController(triggerFrom: .defaultBrowserReminderNotification)
    }

    private static func handleSpace(
        spaceId: String, updatedItemIds: [String]?, with bvc: BrowserViewController
    ) {
        // navigate to SpaceId
        let gridModel = bvc.gridModel
        if let updatedItemIDs = updatedItemIds, !updatedItemIDs.isEmpty {
            gridModel.spaceCardModel.updatedItemIDs = updatedItemIDs
        }

        bvc.browserModel.openSpace(spaceId: spaceId)
    }

    private static func handleFastTap(query: String, with bvc: BrowserViewController, noDelay: Bool)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + (noDelay ? 0 : 1.5)) {
            bvc.openLazyTab()
            bvc.searchQueryModel.value = query
        }
    }

    private static func handleOpenSetting(page: SettingsPage?, with bvc: BrowserViewController) {
        guard let page = page else {
            return
        }
        // TODO: look for a better solution to make sure the app state is set up properly before handling the notification deep link
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            bvc.openSettings(openPage: page)
        }
    }

}

extension NavigationPath: Equatable {}

func == (lhs: NavigationPath, rhs: NavigationPath) -> Bool {
    switch (lhs, rhs) {
    case let (.url(lhsURL, lhsPrivate), .url(rhsURL, rhsPrivate)):
        return lhsURL == rhsURL && lhsPrivate == rhsPrivate
    default:
        return false
    }
}
