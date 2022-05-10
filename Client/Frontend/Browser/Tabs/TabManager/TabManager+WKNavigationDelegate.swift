// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import WebKit

extension TabManager: WKNavigationDelegate {
    // Note the main frame JSContext (i.e. document, window) is not available yet.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Save stats for the page we are leaving.
        if let tab = self[webView], let blocker = tab.contentBlocker, let url = tab.url {
            blocker.pageStatsCache[url] = blocker.stats
        }
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        // Clear stats for the page we are newly generating.
        if navigationResponse.isForMainFrame, let tab = self[webView],
            let blocker = tab.contentBlocker, let url = navigationResponse.response.url
        {
            blocker.pageStatsCache[url] = nil
        }
        decisionHandler(.allow)
    }

    // The main frame JSContext is available, and DOM parsing has begun.
    // Do not excute JS at this point that requires running prior to DOM parsing.
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let tab = self[webView] else { return }

        tab.hasContentProcess = true

        if let url = webView.url, let blocker = tab.contentBlocker {
            // Initialize to the cached stats for this page. If the page is being fetched
            // from WebKit's page cache, then this will pick up stats from when that page
            // was previously loaded. If not, then the cached value will be empty.
            blocker.stats = blocker.pageStatsCache[url] ?? TPPageStats()
            if !blocker.isEnabled {
                webView.evaluateJavascriptInDefaultContentWorld(
                    "window.__firefox__.TrackingProtectionStats.setEnabled(false, \(UserScriptManager.appIdToken))"
                )
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let pageZoom = selectedTab?.pageZoom,
            webView.value(forKey: "viewScale") as? CGFloat != pageZoom
        {
            // Trigger the didSet hook
            selectedTab?.pageZoom = pageZoom
        }

        // tab restore uses internal pages, so don't call storeChanges unnecessarily on startup
        if let url = webView.url {
            if let internalUrl = InternalURL(url), internalUrl.isSessionRestore {
                return
            }

            storeChanges()
        }
    }

    /// Called when the WKWebView's content process has gone away. If this happens for the currently selected tab
    /// then we immediately reload it.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard let tab = self[webView] else { return }

        tab.hasContentProcess = false

        if tab == selectedTab {
            tab.consecutiveCrashes += 1

            // Only automatically attempt to reload the crashed
            // tab three times before giving up.
            if tab.consecutiveCrashes < 3 {
                webView.reload()
            } else {
                tab.consecutiveCrashes = 0
            }
        }
    }
}

// WKNavigationDelegates must implement NSObjectProtocol
class TabManagerNavDelegate: NSObject, WKNavigationDelegate {
    fileprivate var delegates = WeakList<WKNavigationDelegate>()

    func insert(_ delegate: WKNavigationDelegate) {
        delegates.insert(delegate)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didCommit: navigation)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)"), error: \(error)")

        for delegate in delegates {
            delegate.webView?(webView, didFail: navigation, withError: error)
        }
    }

    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)"), error: \(error)")

        for delegate in delegates {
            delegate.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didFinish: navigation)
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webViewWebContentProcessDidTerminate?(webView)
        }
    }

    func webView(
        _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        let authenticatingDelegates = delegates.filter { wv in
            return wv.responds(to: #selector(webView(_:didReceive:completionHandler:)))
        }

        guard let firstAuthenticatingDelegate = authenticatingDelegates.first else {
            return completionHandler(.performDefaultHandling, nil)
        }

        firstAuthenticatingDelegate.webView?(webView, didReceive: challenge) {
            (disposition, credential) in
            completionHandler(disposition, credential)
        }
    }

    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Logger.network.info("webView.url: \(webView.url ?? "(nil)")")

        for delegate in delegates {
            delegate.webView?(webView, didStartProvisionalNavigation: navigation)
        }
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        Logger.network.info(
            "webView.url: \(webView.url?.absoluteString ?? "(nil)"), request.url: \(navigationAction.request.url?.absoluteString ?? "(nil)"), isMainFrame: \(navigationAction.targetFrame?.isMainFrame.description ?? "(nil)")"
        )

        var res = WKNavigationActionPolicy.allow
        for delegate in delegates {
            delegate.webView?(
                webView, decidePolicyFor: navigationAction,
                decisionHandler: { policy in
                    if policy == .cancel {
                        res = policy
                    }
                })
        }
        decisionHandler(res)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        Logger.network.info(
            "webView.url: \(webView.url ?? "(nil)"), response.url: \(navigationResponse.response.url ?? "(nil)"), isMainFrame: \(navigationResponse.isForMainFrame)"
        )

        var res = WKNavigationResponsePolicy.allow
        for delegate in delegates {
            delegate.webView?(
                webView, decidePolicyFor: navigationResponse,
                decisionHandler: { policy in
                    if policy == .cancel {
                        res = policy
                    }
                })
        }

        decisionHandler(res)
    }
}
