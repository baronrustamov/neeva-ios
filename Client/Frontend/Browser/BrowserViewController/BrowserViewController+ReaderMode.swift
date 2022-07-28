/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Shared
import XCGLogger

private let log = Logger.browser

extension BrowserViewController: ReaderModeDelegate {
    func readerMode(didChangeReaderModeState state: ReaderModeState, forTab tab: Tab) {
        // If this reader mode availability state change is for the tab that we currently show, then update
        // the button. Otherwise do nothing and the button will be updated when the tab is made active.
        if tabManager.selectedTab === tab {
            readerModeModel.setReadingModeState(state: state)
        }
    }

    func readerMode(didDisplayReaderizedContentForTab tab: Tab) {
        tab.showContent(true)
    }

    func readerMode(didParseReadabilityResult readabilityResult: ReadabilityResult, forTab tab: Tab)
    {
    }

    func readerMode(didConfigureStyle style: ReaderModeStyle, isUsingUserDefinedColor: Bool) {
        var newStyle = style
        if !isUsingUserDefinedColor {
            newStyle.ensurePreferredColorThemeIfNeeded()
        }

        // Persist the new style to Defaults
        Defaults[.readerModeStyle] = style
        // Change the reader mode style on all tabs that have reader mode active
        for tabIndex in 0..<tabManager.count {
            if let tab = tabManager[tabIndex] {
                if let readerMode = tab.getContentScript(name: "ReaderMode") as? ReaderMode {
                    if readerMode.state == ReaderModeState.active {
                        readerMode.style = ReaderModeStyle(
                            theme: newStyle.theme,
                            fontType: ReaderModeFontType(type: newStyle.fontType.rawValue))
                    }
                }
            }
        }
    }
}

extension BrowserViewController {
    /// There are two ways we can enable reader mode. In the simplest case we open a URL to our internal reader mode
    /// and be done with it. In the more complicated case, reader mode was already open for this page and we simply
    /// navigated away from it. So we look to the left and right in the BackForwardList to see if a readerized version
    /// of the current page is there. And if so, we go there.
    func enableReaderMode() {
        guard let tab = tabManager.selectedTab, let webView = tab.webView else { return }

        let backList = webView.backForwardList.backList
        let forwardList = webView.backForwardList.forwardList

        guard let currentURL = webView.backForwardList.currentItem?.url,
            let readerModeURL = currentURL.encodeReaderModeURL(
                WebServer.sharedInstance.baseReaderModeURL())
        else { return }

        if backList.count > 1 && backList.last?.url == readerModeURL {
            webView.go(to: backList.last!)
        } else if forwardList.count > 0 && forwardList.first?.url == readerModeURL {
            webView.go(to: forwardList.first!)
        } else {
            // Store the readability result in the cache and load it. This will later move to the ReadabilityHelper.
            webView.evaluateJavascriptInDefaultContentWorld(
                "\(ReaderModeNamespace).readerize()"
            ) {
                object, error in
                if let readabilityResult = ReadabilityResult(object: object as AnyObject?) {
                    try? self.readerModeCache.put(currentURL, readabilityResult)
                    if let nav = webView.load(
                        PrivilegedRequest(url: readerModeURL) as URLRequest)
                    {
                        self.ignoreNavigationInTab(navigation: nav)
                        log.info("Navigating to reading mode (READING MODE)")
                    }
                }

                if let error = error {
                    log.error("Failed to render reading mode (READING MODE): \(error)")
                }
            }
        }
    }

    /// Disabling reader mode can mean two things. In the simplest case we were opened from the reading list, which
    /// means that there is nothing in the BackForwardList except the internal url for the reader mode page. In that
    /// case we simply open a new page with the original url. In the more complicated page, the non-readerized version
    /// of the page is either to the left or right in the BackForwardList. If that is the case, we navigate there.
    func disableReaderMode() {
        if let tab = tabManager.selectedTab,
            let webView = tab.webView
        {
            let backList = webView.backForwardList.backList
            let forwardList = webView.backForwardList.forwardList

            if let currentURL = webView.backForwardList.currentItem?.url {
                if let originalURL = currentURL.decodeReaderModeURL {
                    if backList.count > 1 && backList.last?.url == originalURL {
                        webView.go(to: backList.last!)
                    } else if forwardList.count > 0 && forwardList.first?.url == originalURL {
                        webView.go(to: forwardList.first!)
                    } else {
                        if let nav = webView.load(URLRequest(url: originalURL)) {
                            self.ignoreNavigationInTab(navigation: nav)
                        }
                    }
                }
            }
        }
    }

    func appyThemeForPreferences(contentScript: TabContentScript) {
        readerModeModel.applyTheme(contentScript: contentScript)
    }
}
