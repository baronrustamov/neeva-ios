/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import SafariServices
import Shared
import StoreKit
import SwiftyJSON
import UIKit
import WebKit

#if XYZ
    import WalletConnectSwift
#endif

private let log = Logger.browser

/// List of schemes that are allowed to be opened in new tabs.
private let schemesAllowedToBeOpenedAsPopups = ["http", "https", "javascript", "data", "about"]

private func logCookie(_ cookie: String) {
    let sha1 = cookie.sha1.map { String(format: "%02hhx", $0) }.joined()
    Logger.auth.info("\(sha1) [len=\(cookie.count) prefix=\(cookie.prefix(2))]")
}

private func setCookiesForNeeva(webView: WKWebView, isIncognito: Bool) {
    let httpCookieStore = webView.configuration.websiteDataStore.httpCookieStore

    // DEPRECATED in favor of BrowserType and BrowserVersion cookies.
    httpCookieStore.setCookie(NeevaConstants.deviceTypeCookie)

    // Set device name cookie
    httpCookieStore.setCookie(NeevaConstants.deviceNameCookie)

    // Let the website know who we are. Needed as we send a Safari UA string.
    // Unfortunately, setting a customUserAgent is ignored by WebKit for
    // redirected requests. See https://github.com/neevaco/neeva/issues/40875
    // for more details.
    httpCookieStore.setCookie(NeevaConstants.browserTypeCookie)
    httpCookieStore.setCookie(NeevaConstants.browserVersionCookie)

    // Make sure the login cookie--if we have one--is set. The presence of the
    // login cookie in the keychain is considered the source of truth for login
    // state. This may be an invalid login cookie, and in that case, we'll get
    // a new value for the cookie after going through a login flow.
    if !isIncognito, let cookieValue = NeevaUserInfo.shared.getLoginCookie() {
        httpCookieStore.setCookie(NeevaConstants.loginCookie(for: cookieValue))
        logCookie(cookieValue)
    }

    // Some feature flags need to be echoed to neeva.com to ensure that both
    // the browser and the site are using consistent feature flag values. This
    // helps protect against possible race conditions with the two learning
    // about feature flags at different times. List feature flags below that
    // should be synchronized in this fashion.

    let boolFlags: [NeevaFeatureFlags.BoolFlag] = [
        .browserQuests,
        .neevaMemory,
        .feedbackQuery,
        .welcomeTours,
        .calculatorSuggestion,
        .recipeCheatsheet,
        .recipeCardNavigate,
    ]
    let intFlags: [NeevaFeatureFlags.IntFlag] = []
    let floatFlags: [NeevaFeatureFlags.FloatFlag] = []
    let stringFlags: [NeevaFeatureFlags.StringFlag] = []

    var data: [[String: Any]] = []
    data.append(
        contentsOf: boolFlags.map { ["ID": $0.rawValue, "Value": NeevaFeatureFlags[$0]] })
    data.append(
        contentsOf: intFlags.map { ["ID": $0.rawValue, "IntValue": NeevaFeatureFlags[$0]] })
    data.append(
        contentsOf: floatFlags.map { ["ID": $0.rawValue, "FloatValue": NeevaFeatureFlags[$0]] })
    data.append(
        contentsOf: stringFlags.map { ["ID": $0.rawValue, "StringValue": NeevaFeatureFlags[$0]] })

    var json: JSON = []
    json.arrayObject = data

    if let base64 = json.stringify()?.data(using: .utf8)?.base64EncodedString() {
        httpCookieStore.setCookie(
            HTTPCookie(properties: [
                .name: "ClientOverrides",
                .value: base64,
                .domain: NeevaConstants.appHost,
                .path: "/",
            ])!)
    }
}

extension BrowserViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let parentTab = tabManager[webView] else { return nil }

        guard !navigationAction.isInternalUnprivileged,
            shouldRequestBeOpenedAsPopup(navigationAction.request)
        else {
            print("Denying popup from request: \(navigationAction.request)")
            return nil
        }

        if let currentTab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(currentTab)
        }

        guard let bvc = parentTab.browserViewController else { return nil }

        // If the page uses `window.open()` or `[target="_blank"]`, open the page in a new tab.
        // IMPORTANT!!: WebKit will perform the `URLRequest` automatically!! Attempting to do
        // the request here manually leads to incorrect results!!
        let newTab = tabManager.addPopupForParentTab(
            bvc: bvc, parentTab: parentTab, configuration: configuration)
        newTab.setURL(.aboutBlank)

        return newTab.webView
    }

    fileprivate func shouldRequestBeOpenedAsPopup(_ request: URLRequest) -> Bool {
        // Treat `window.open("")` the same as `window.open("about:blank")`.
        if request.url?.absoluteString.isEmpty ?? false {
            return true
        }

        if let scheme = request.url?.scheme?.lowercased(),
            schemesAllowedToBeOpenedAsPopups.contains(scheme)
        {
            return true
        }

        return false
    }

    fileprivate func shouldDisplayJSAlertForWebView(_ webView: WKWebView) -> Bool {
        // Only display a JS Alert if we are selected and there isn't anything being shown
        return
            ((tabManager.selectedTab == nil ? false : tabManager.selectedTab!.webView == webView))
            && (self.presentedViewController == nil)
    }

    func webView(
        _ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void
    ) {
        let messageAlert = MessageAlert(
            message: message, frame: frame, completionHandler: completionHandler)
        if shouldDisplayJSAlertForWebView(webView) {
            present(messageAlert.alertController(), animated: true, completion: nil)
        } else if let promptingTab = tabManager[webView] {
            promptingTab.queueJavascriptAlertPrompt(messageAlert)
        } else {
            // This should never happen since an alert needs to come from a web view but just in case call the handler
            // since not calling it will result in a runtime exception.
            completionHandler()
        }
    }

    func webView(
        _ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void
    ) {
        let confirmAlert = ConfirmPanelAlert(
            message: message, frame: frame, completionHandler: completionHandler)
        if shouldDisplayJSAlertForWebView(webView) {
            present(confirmAlert.alertController(), animated: true, completion: nil)
        } else if let promptingTab = tabManager[webView] {
            promptingTab.queueJavascriptAlertPrompt(confirmAlert)
        } else {
            completionHandler(false)
        }
    }

    func webView(
        _ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?, initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        let textInputAlert = TextInputAlert(
            message: prompt, frame: frame, completionHandler: completionHandler,
            defaultText: defaultText)
        if shouldDisplayJSAlertForWebView(webView) {
            present(textInputAlert.alertController(), animated: true, completion: nil)
        } else if let promptingTab = tabManager[webView] {
            promptingTab.queueJavascriptAlertPrompt(textInputAlert)
        } else {
            completionHandler(nil)
        }
    }

    func webViewDidClose(_ webView: WKWebView) {
        if let tab = tabManager[webView] {
            // Need to wait here in case we're waiting for a pending `window.open()`.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabManager.removeTab(tab, showToast: false)
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo,
        completionHandler: @escaping (UIContextMenuConfiguration?) -> Void
    ) {
        let clonedWebView = WKWebView(frame: webView.frame, configuration: webView.configuration)
        completionHandler(
            UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: {
                    guard let url = elementInfo.linkURL, Defaults[.contextMenuShowLinkPreviews]
                    else { return nil }
                    let previewViewController = UIViewController()
                    previewViewController.view.isUserInteractionEnabled = false

                    previewViewController.view.addSubview(clonedWebView)
                    clonedWebView.makeAllEdges(equalTo: previewViewController.view)
                    clonedWebView.load(URLRequest(url: url))

                    return previewViewController
                },
                actionProvider: { (suggested) -> UIMenu? in
                    guard let url = elementInfo.linkURL,
                        let currentTab = self.tabManager.selectedTab,
                        let contextHelper = currentTab.getContentScript(
                            name: ContextMenuHelper.name()) as? ContextMenuHelper,
                        let elements = contextHelper.elements
                    else { return nil }
                    let isIncognito = currentTab.isIncognito
                    let addTab = { (rURL: URL, isIncognito: Bool) in
                        self.openURLInBackground(rURL, isIncognito: isIncognito)
                    }

                    let getImageData = { (_ url: URL, success: @escaping (Data) -> Void) in
                        makeURLSession(
                            userAgent: UserAgent.getUserAgent(),
                            configuration: URLSessionConfiguration.default
                        ).dataTask(with: url) { (data, response, error) in
                            if let _ = validatedHTTPResponse(response, statusCode: 200..<300),
                                let data = data
                            {
                                success(data)
                            }
                        }.resume()
                    }

                    var actions = [UIAction]()

                    if !isIncognito {
                        actions.append(
                            UIAction(
                                title: Strings.ContextMenuOpenInNewTab,
                                image: UIImage(systemName: "plus.square"),
                                identifier: UIAction.Identifier(
                                    rawValue: "linkContextMenu.openInNewTab")
                            ) { _ in
                                addTab(url, false)
                            })
                    }

                    actions.append(
                        UIAction(
                            title: Strings.ContextMenuOpenInNewIncognitoTab,
                            image: UIImage.templateImageNamed("incognito"),
                            identifier: UIAction.Identifier("linkContextMenu.openInNewIncognitoTab")
                        ) { _ in
                            addTab(url, true)
                        })

                    actions.append(
                        UIAction(
                            title: "Add to Space", image: UIImage(systemName: "bookmark"),
                            identifier: UIAction.Identifier("linkContextMenu.addToSpace")
                        ) { _ in
                            self.showAddToSpacesSheet(
                                url: url, title: elements.title, webView: clonedWebView)
                        })

                    actions.append(
                        UIAction(
                            title: Strings.ContextMenuDownloadLink,
                            image: UIImage.templateImageNamed("menu-panel-Downloads"),
                            identifier: UIAction.Identifier("linkContextMenu.download")
                        ) { _ in
                            // This checks if download is a blob, if yes, begin blob download process
                            if !DownloadContentScript.requestBlobDownload(url: url, tab: currentTab)
                            {
                                //if not a blob, set pendingDownloadWebView and load the request in the webview, which will trigger the WKWebView navigationResponse delegate function and eventually downloadHelper.open()
                                self.pendingDownloadWebView = currentTab.webView
                                let request = URLRequest(url: url)
                                currentTab.webView?.load(request)
                            }
                        })

                    actions.append(
                        UIAction(
                            title: Strings.ContextMenuCopyLink, image: UIImage(systemName: "link"),
                            identifier: UIAction.Identifier("linkContextMenu.copyLink")
                        ) { _ in
                            UIPasteboard.general.url = url
                        })

                    actions.append(
                        UIAction(
                            title: Strings.ContextMenuShareLink,
                            image: UIImage(systemName: "square.and.arrow.up"),
                            identifier: UIAction.Identifier("linkContextMenu.share")
                        ) { _ in
                            guard let tab = self.tabManager[webView],
                                let helper = tab.getContentScript(name: ContextMenuHelper.name())
                                    as? ContextMenuHelper
                            else { return }
                            // This is only used on ipad for positioning the popover. On iPhone it is an action sheet.
                            let p = webView.convert(helper.touchPoint, to: self.view)
                            self.presentActivityViewController(
                                url as URL, sourceView: self.view,
                                sourceRect: CGRect(origin: p, size: CGSize(width: 10, height: 10)),
                                arrowDirection: .unknown)
                        })

                    if let url = elements.image {
                        actions.append(
                            UIAction(
                                title: Strings.ContextMenuSaveImage,
                                identifier: UIAction.Identifier("linkContextMenu.saveImage")
                            ) { _ in
                                getImageData(url) { data in
                                    guard let image = UIImage(data: data) else { return }
                                    self.writeToPhotoAlbum(image: image)
                                }
                            })

                        actions.append(
                            UIAction(
                                title: Strings.ContextMenuCopyImage,
                                identifier: UIAction.Identifier("linkContextMenu.copyImage")
                            ) { _ in
                                // put the actual image on the clipboard
                                // do this asynchronously just in case we're in a low bandwidth situation
                                let pasteboard = UIPasteboard.general
                                pasteboard.url = url as URL
                                let changeCount = pasteboard.changeCount
                                let application = UIApplication.shared
                                var taskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(
                                    rawValue: 0)
                                taskId = application.beginBackgroundTask(expirationHandler: {
                                    application.endBackgroundTask(taskId)
                                })

                                makeURLSession(
                                    userAgent: UserAgent.getUserAgent(),
                                    configuration: URLSessionConfiguration.default
                                ).dataTask(with: url) { (data, response, error) in
                                    guard
                                        let _ = validatedHTTPResponse(
                                            response, statusCode: 200..<300)
                                    else {
                                        application.endBackgroundTask(taskId)
                                        return
                                    }

                                    // Only set the image onto the pasteboard if the pasteboard hasn't changed since
                                    // fetching the image; otherwise, in low-bandwidth situations,
                                    // we might be overwriting something that the user has subsequently added.
                                    if changeCount == pasteboard.changeCount, let imageData = data,
                                        error == nil
                                    {
                                        pasteboard.addImageWithData(imageData, forURL: url)
                                    }

                                    application.endBackgroundTask(taskId)
                                }.resume()
                            })

                        actions.append(
                            UIAction(
                                title: Strings.ContextMenuCopyImageLink,
                                identifier: UIAction.Identifier("linkContextMenu.copyImageLink")
                            ) { _ in
                                UIPasteboard.general.url = url as URL
                            })
                    }

                    return UIMenu(title: url.absoluteString, children: actions)
                }))
    }

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(
        _ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer
    ) {
        guard error != nil else { return }
        DispatchQueue.main.async {
            let accessDenied = UIAlertController(
                title: Strings.PhotoLibraryNeevaWouldLikeAccessTitle,
                message: Strings.PhotoLibraryNeevaWouldLikeAccessMessage, preferredStyle: .alert)
            let dismissAction = UIAlertAction(
                title: Strings.CancelString, style: .default, handler: nil)
            accessDenied.addAction(dismissAction)
            let settingsAction = UIAlertAction(title: Strings.OpenSettingsString, style: .default) {
                _ in
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!, options: [:])
            }
            accessDenied.addAction(settingsAction)
            self.present(accessDenied, animated: true, completion: nil)
        }
    }
}

extension WKNavigationAction {
    /// Allow local requests only if the request is privileged.
    var isInternalUnprivileged: Bool {
        guard let url = request.url else {
            return true
        }

        if let url = InternalURL(url) {
            return !url.isAuthorized
        } else {
            return false
        }
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logJSConsoleOutputIfEnabled(for: webView)

        locationModel.resetSecureListener()
        updateFindInPageVisibility(visible: false)

        // If we are going to navigate to a new page, hide the reader mode button. Unless we
        // are going to a about:reader page. Then we keep it on screen: it will change status
        // (orange color) as soon as the page has loaded.
        if let url = webView.url {
            if !url.isReaderModeURL {
                readerModeModel.setReadingModeState(state: .unavailable)
            }
        }
    }

    // Recognize a iTunes Store URL. These all trigger the native apps. Note that appstore.com and phobos.apple.com
    // used to be in this list. I have removed them because they now redirect to itunes.apple.com. If we special case
    // them then iOS will actually first open Safari, which then redirects to the app store. This works but it will
    // leave a 'Back to Safari' button in the status bar, which we do not want.
    fileprivate func isStoreURL(_ url: URL) -> Bool {
        if url.scheme == "http" || url.scheme == "https" || url.scheme == "itms-apps"
            || url.scheme == "itms-appss"
        {
            if url.host == "apps.apple.com" || url.host == "itunes.apple.com" {
                return true
            }
        }

        return false
    }

    /// Checks if a file is a special format for Apple Devices (ex. .ics, .mobileconfig, wallet passes).
    /// These URLs should be opened in a SafariViewController
    fileprivate func isSpecialAppleURL(_ url: URL) -> Bool {
        return url.pathExtension == "ics" || url.pathExtension == "mobileconfig"
            || (url.host?.contains("storepass.apple.com") ?? false)
    }

    fileprivate func isGooglePolicyURL(_ url: URL) -> Bool {
        return (url.host?.contains("mdm.googleusercontent") ?? false)
    }

    fileprivate func getAppStoreID(_ url: URL) -> String? {
        let prefix = "id"
        guard let id = url.pathComponents.last(where: { $0.hasPrefix(prefix) }) else {
            return nil
        }

        return String(id.dropFirst(prefix.count))
    }

    // Use for links, that do not show a confirmation before opening.
    fileprivate func showOverlay(forExternalUrl url: URL) {
        tabManager.selectedTab?.stop()

        showModal(style: .grouped) {
            OpenInAppOverlayContent(url: url) {
                ToastDefaults().showToast(
                    with:
                        "Unable to open link in external app. Check if the app is installed on this device.",
                    toastViewManager: self.toastViewManager)
            }.environment(\.hideOverlay, { self.overlayManager.hideCurrentOverlay() })
        }
    }

    /// Used for URLs that WebView cannot handle, but work when used in Safari.
    fileprivate func openURLInSafariViewController(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .formSheet
        present(safariVC, animated: true, completion: nil)
    }

    // This is the place where we decide what to do with a new navigation action. There are a number of special schemes
    // and http(s) urls that need to be handled in a different way. All the logic for that is inside this delegate
    // method.
    func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url, let tab = tabManager[webView] else {
            decisionHandler(.cancel)
            return
        }

        if InternalURL.isValid(url: url) {
            if navigationAction.navigationType != .backForward,
                navigationAction.isInternalUnprivileged
            {
                log.warning("Denying unprivileged request: \(navigationAction.request)")
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
            return
        }

        // Prompt the user before redirecting to an external app.
        if ["sms", "mailto"].contains(url.scheme) {
            showOverlay(forExternalUrl: url)

            decisionHandler(.cancel)
            return
        }

        // These schemes always show a system prompt, so we don’t need to show our own
        if ["tel", "facetime", "facetime-audio"].contains(url.scheme) {
            UIApplication.shared.open(url, options: [:])

            decisionHandler(.cancel)
            return
        }

        if url.scheme == "about" {
            decisionHandler(.allow)
            return
        }

        // Disabled due to https://bugzilla.mozilla.org/show_bug.cgi?id=1588928
        //        if url.scheme == "javascript", navigationAction.request.isPrivileged {
        //            decisionHandler(.cancel)
        //            if let javaScriptString = url.absoluteString.replaceFirstOccurrence(of: "javascript:", with: "").removingPercentEncoding {
        //                webView.evaluateJavaScript(javaScriptString)
        //            }
        //            return
        //        }

        if isStoreURL(url), let appStoreID = getAppStoreID(url) {
            let productVC = SKStoreProductViewController()
            productVC.delegate = self
            productVC.loadProduct(withParameters: [
                SKStoreProductParameterITunesItemIdentifier: appStoreID
            ]) { _, error in
                if let error = error {
                    print("Error loading SKStoreProductViewController:", error)
                    self.showOverlay(forExternalUrl: url)
                }
            }

            present(productVC, animated: true, completion: nil)

            decisionHandler(.cancel)
            return
        }

        if isSpecialAppleURL(url) || isGooglePolicyURL(url) {
            if url.pathExtension == "mobileconfig"
                && url.host?.hasSuffix("developer.apple.com") ?? false
            {
                // .mobileconfig files from Apple Developer have to be redirected to root page to be downloaded
                // If we try to open the specific download URL, the user will see an auth error
                openURLInSafariViewController(URL(string: "https://developer.apple.com/download/")!)
            } else {
                openURLInSafariViewController(url)
            }

            if !tab.canGoBack && !tab.canGoForward {
                // Close Tab since it will be blank.
                tabManager.removeTab(tab, showToast: false)
            }

            decisionHandler(.cancel)
            return
        }

        // https://blog.mozilla.org/security/2017/11/27/blocking-top-level-navigations-data-urls-firefox-59/
        if url.scheme == "data" {
            let url = url.absoluteString
            // Allow certain image types
            if url.hasPrefix("data:image/") && !url.hasPrefix("data:image/svg+xml") {
                decisionHandler(.allow)
                return
            }

            // Allow video, and certain application types
            if url.hasPrefix("data:video/") || url.hasPrefix("data:application/pdf")
                || url.hasPrefix("data:application/json")
            {
                decisionHandler(.allow)
                return
            }

            // Allow plain text types.
            // Note the format of data URLs is `data:[<media type>][;base64],<data>` with empty <media type> indicating plain text.
            if url.hasPrefix("data:;base64,") || url.hasPrefix("data:,")
                || url.hasPrefix("data:text/plain,") || url.hasPrefix("data:text/plain;")
            {
                decisionHandler(.allow)
                return
            }

            decisionHandler(.cancel)
            return
        }

        // This is the normal case, opening a http or https url, which we handle by loading them in this WKWebView. We
        // always allow this. Additionally, data URIs are also handled just like normal web pages.

        if ["http", "https", "blob", "file"].contains(url.scheme) {
            if navigationAction.targetFrame?.isMainFrame ?? false {
                tab.changedUserAgent = Tab.ChangeUserAgent.contains(
                    url: url, isIncognito: tab.isIncognito)
            }

            pendingRequests[url.absoluteString] = navigationAction.request

            if NeevaConstants.isAppHost(url.host) {
                webView.customUserAgent = UserAgent.neevaAppUserAgent()
                setCookiesForNeeva(webView: webView, isIncognito: tab.isIncognito)
            } else if tab.changedUserAgent {
                let platformSpecificUserAgent = UserAgent.oppositeUserAgent(
                    domain: url.baseDomain ?? "")
                webView.customUserAgent = platformSpecificUserAgent
            } else {
                webView.customUserAgent = UserAgent.getUserAgent(domain: url.baseDomain ?? "")
            }

            // Neeva incognito logic
            var request = navigationAction.request
            if NeevaConstants.isAppHost(url.host), request.httpMethod == "GET", tab.isIncognito,
                !url.path.starts(with: "/incognito")
            {
                let cookies = webView.configuration.websiteDataStore.httpCookieStore
                cookies.getAllCookies { (cookies) in
                    if !cookies.contains(where: {
                        NeevaConstants.isAppHost($0.domain) && $0.name == "httpd~incognito"
                            && $0.isSecure
                    }) {
                        GraphQLAPI.shared.perform(
                            mutation: StartIncognitoMutation(url: url)
                        ) { result in
                            decisionHandler(.cancel)
                            switch result {
                            case .failure(let error):
                                print(
                                    (error as? GraphQLAPI.Error)?.errors.map(\.message)
                                        ?? error.localizedDescription)
                            case .success(let data):
                                request.url = URL(string: data.startIncognito)
                                webView.load(request)
                            }
                        }
                    }
                    decisionHandler(.allow)
                }
                return
            }

            // for Neeva signup or signin page, open native auth panel
            if NeevaConstants.isAppHost(url.host), request.httpMethod == "GET" {
                let query = url.getQuery()

                if url.path == "/p/signup" {
                    // check if query param contains email
                    // if user already enter email,
                    // let user stay on the web sign up flow
                    if query["e"] == nil {
                        self.presentIntroViewController(true)
                        decisionHandler(.cancel)
                        return
                    }
                } else if url.path == "/signin" {
                    self.presentIntroViewController(true, signInMode: true)
                    decisionHandler(.allow)
                    return
                }
            }
            #if XYZ
                if url.lastPathComponent == "wc" {
                    if url.query == nil {
                        // If this is only for invoking a wallet app with no params, cancel the navigation.
                        decisionHandler(.cancel)
                    } else if let components = URLComponents(string: url.absoluteString),
                        let uri = components.valueForQuery("uri"),
                        let wcURL = WCURL(uri.removingPercentEncoding ?? ""),
                        SceneDelegate.getBVC(with: tabManager.scene).connectWallet(to: wcURL)
                    {
                        // If we can establish a connection through existing wallet, cancel the navigation.
                        decisionHandler(.cancel)

                    }
                }
            #endif
            decisionHandler(.allow)
            return
        }

        // Only show OpenInAppOverlay for schemes other than Neeva,
        if !(url.scheme?.contains("neeva") ?? true),
            navigationAction.targetFrame?.isMainFrame ?? false  // and from the main frame.
        {
            showOverlay(forExternalUrl: url)
        }

        decisionHandler(.cancel)
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        let response = navigationResponse.response
        let responseURL = response.url

        var request: URLRequest?
        if let url = responseURL {
            request = pendingRequests.removeValue(forKey: url.absoluteString)
        }

        // We can only show this content in the web view if this web view is not pending
        // download via the context menu.
        let canShowInWebView =
            navigationResponse.canShowMIMEType && (webView != pendingDownloadWebView)
        let forceDownload = webView == pendingDownloadWebView

        // Check if this response should be handed off to Passbook.
        if let passbookHelper = OpenPassBookHelper(
            request: request, response: response, canShowInWebView: canShowInWebView,
            forceDownload: forceDownload, browserViewController: self)
        {
            // Open our helper and cancel this response from the webview.
            passbookHelper.open()
            decisionHandler(.cancel)
            return
        }

        // Check if this response should be displayed in a QuickLook for USDZ files.
        if let previewHelper = OpenQLPreviewHelper(
            request: request, response: response, canShowInWebView: canShowInWebView,
            forceDownload: forceDownload, browserViewController: self)
        {

            // Certain files are too large to download before the preview presents, block and use a temporary document instead
            if let tab = tabManager[webView] {
                if navigationResponse.isForMainFrame, response.mimeType != MIMEType.HTML,
                    let request = request
                {
                    tab.temporaryDocument = TemporaryDocument(
                        preflightResponse: response, request: request)
                    previewHelper.url = tab.temporaryDocument!.getURL().value as NSURL

                    // Open our helper and cancel this response from the webview.
                    previewHelper.open()
                    decisionHandler(.cancel)
                    return
                } else {
                    tab.temporaryDocument = nil
                }
            }

            // We don't have a temporary document, fallthrough
        }

        // Check if this response should be downloaded.
        if let downloadHelper = DownloadHelper(
            request: request, response: response, canShowInWebView: canShowInWebView,
            forceDownload: forceDownload, browserViewController: self)
        {
            // Clear the pending download web view so that subsequent navigations from the same
            // web view don't invoke another download.
            pendingDownloadWebView = nil

            // Open our helper and cancel this response from the webview.
            downloadHelper.open()
            decisionHandler(.cancel)
            return
        }

        // If the content type is not HTML, create a temporary document so it can be downloaded and
        // shared to external applications later. Otherwise, clear the old temporary document.
        // NOTE: This should only happen if the request/response came from the main frame, otherwise
        // we may end up overriding the "Share Page With..." action to share a temp file that is not
        // representative of the contents of the web view.
        if navigationResponse.isForMainFrame, let tab = tabManager[webView] {
            if response.mimeType != MIMEType.HTML, let request = request {
                tab.provisionalTemporaryDocument = TemporaryDocument(
                    preflightResponse: response, request: request)
            } else {
                tab.provisionalTemporaryDocument = nil
            }
        }

        // If none of our helpers are responsible for handling this response,
        // just let the webview handle it as normal.
        decisionHandler(.allow)
    }

    /// Invoked when an error occurs while starting to load data for the main frame.
    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        log.error(
            "Failed to navigate webview: \(navigation.debugDescription), with error: \(error)")

        if let tab = tabManager[webView] {
            tab.provisionalTemporaryDocument = nil
        }

        locationModel.updateSecureListener(with: webView)

        // Ignore the "Frame load interrupted" error that is triggered when we cancel a request
        // to open an external application and hand it over to UIApplication.openURL(). The result
        // will be that we switch to the external app, for example the app store, while keeping the
        // original web page in the tab instead of replacing it with an error page.
        let error = error as NSError
        if error.domain == "WebKitErrorDomain" && error.code == 102 {
            return
        }

        if checkIfWebContentProcessHasCrashed(webView, error: error as NSError) {
            return
        }

        if error.code == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue) {
            if let tab = tabManager[webView], tab === tabManager.selectedTab {
                locationModel.url = tab.url?.displayURL
            }
            return
        }

        if let url = error.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
            ErrorPageHelper(certStore: profile.certStore).loadPage(
                error, forUrl: url, inWebView: webView)
        }
    }

    fileprivate func checkIfWebContentProcessHasCrashed(_ webView: WKWebView, error: NSError)
        -> Bool
    {
        if error.code == WKError.webContentProcessTerminated.rawValue
            && error.domain == "WebKitErrorDomain"
        {
            print("WebContent process has crashed. Trying to reload to restart it.")
            webView.reload()
            return true
        }

        return false
    }

    func webView(
        _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        // If this is a certificate challenge, see if the certificate has previously been
        // accepted by the user.
        let origin = "\(challenge.protectionSpace.host):\(challenge.protectionSpace.port)"
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let trust = challenge.protectionSpace.serverTrust,
            let cert = SecTrustGetCertificateAtIndex(trust, 0),
            profile.certStore.containsCertificate(cert, forOrigin: origin)
        {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }

        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic
                || challenge.protectionSpace.authenticationMethod
                    == NSURLAuthenticationMethodHTTPDigest
                || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM,
            let tab = tabManager[webView]
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // If this is a request to our local web server, use our private credentials.
        if challenge.protectionSpace.host == "localhost"
            && challenge.protectionSpace.port == Int(WebServer.sharedInstance.server.port)
        {
            completionHandler(.useCredential, WebServer.sharedInstance.credentials)
            return
        }

        // The challenge may come from a background tab, so ensure it's the one visible.
        tabManager.selectTab(tab, notify: true)

        let loginsHelper = tab.getContentScript(name: LoginsHelper.name()) as? LoginsHelper
        Authenticator.handleAuthRequest(self, challenge: challenge)
            .uponQueue(.main) { res in
                if let credentials = res.successValue {
                    completionHandler(.useCredential, credentials.credentials)
                } else {
                    completionHandler(.rejectProtectionSpace, nil)
                }
            }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let tab = tabManager[webView] else { return }
        tab.setURL(webView.url)

        if let url = webView.url {
            // if user never signed in, log page load
            if !Defaults[.signedInOnce] {
                var attributes = EnvironmentHelper.shared.getFirstRunAttributes()

                // if user visiting Neeva page, log path and query
                if url.origin == NeevaConstants.appURL.origin {
                    let query = url.query ?? ""
                    attributes.append(
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.FirstRunSearchPathQuery,
                            value: url.path + query))

                    // for preview mode, increase counter for preview mode queries
                    if !Defaults[.signedInOnce] && !query.isEmpty {
                        Defaults[.previewModeQueries].insert(query)
                    }
                }

                ClientLogger.shared.logCounter(
                    .FirstRunPageLoad,
                    attributes: attributes)
            }

            // increment page load count
            PerformanceLogger.shared.incrementPageLoad(url: url)
        }

        // The document has changed. This metadata is now invalid.
        tab.pageMetadata = nil

        // Note: We would not have received a decidePolicyFor:response callback if the
        // document came out of the page cache. In that case, temporaryDocument would
        // not have been updated, so we effectively clear it here.
        tab.temporaryDocument = tab.provisionalTemporaryDocument
        tab.provisionalTemporaryDocument = nil

        locationModel.updateSecureListener(with: webView)

        self.browserModel.scrollingControlModel.resetZoomState()

        if tabManager.selectedTab === tab {
            updateUIForReaderHomeStateForTab(tab)
        }

        tab.attachCurrentSearchQueryToCurrentNavigation()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let tab = tabManager[webView] else { return }

        navigateInTab(tab: tab, to: navigation, webViewStatus: .finishedNavigation)

        // If this tab had previously crashed, wait 5 seconds before resetting
        // the consecutive crash counter. This allows a successful webpage load
        // without a crash to reset the consecutive crash counter in the event
        // that the tab begins crashing again in the future.
        if tab.consecutiveCrashes > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if tab.consecutiveCrashes > 0 {
                    tab.consecutiveCrashes = 0
                }
            }
        }

        // Every time a user visits a Neeva page, we extract the login cookie and save it to the
        // keychain. If however we find that they are on the sign in page, then we need to assume
        // our cached login cookie is no longer valid.
        if !tab.isIncognito,
            let url = webView.url,
            url.origin == NeevaConstants.appURL.origin
        {
            let userInfo = NeevaUserInfo.shared
            if url.path == NeevaConstants.appSigninURL.path {
                if userInfo.hasLoginCookie() {
                    ClientLogger.shared.logCounter(
                        .ImplicitDeleteCookie,
                        attributes: EnvironmentHelper.shared.getFirstRunAttributes()
                    )
                    NotificationPermissionHelper.shared.deleteDeviceTokenFromServer()
                    userInfo.deleteLoginCookie()
                    userInfo.didLogOut()
                }
            } else {
                // Log .LoginAfterFirstRun when user signed in for the first time
                // after seeing first run screen
                if Defaults[.firstRunSeenAndNotSignedIn] && userInfo.hasLoginCookie() {
                    var attributes = EnvironmentHelper.shared.getFirstRunAttributes()
                    attributes.append(
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.FirstSessionUUID,
                            value: Defaults[.firstSessionUUID])
                    )
                    ClientLogger.shared.logCounter(
                        .LoginAfterFirstRun, attributes: attributes)
                    Defaults[.firstRunSeenAndNotSignedIn] = false
                }

                userInfo.updateLoginCookieFromWebKitCookieStore {
                    // We have a fresh login cookie.
                    Defaults[.signedInOnce] = true

                    if url.absoluteString.starts(with: NeevaConstants.appSpacesURL.absoluteString)
                        && url != NeevaConstants.appSpacesURL
                        && !SpaceStore.shared.allSpaces.contains(where: {
                            $0.id.id == url.lastPathComponent
                        })
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            SpaceStore.shared.refresh()
                        }
                    }
                }
            }
        }

        // if on neeva search result path and never signed in, user is in preview
        // mode, and we will show the preview mode sign up prompt
        // we will show the promp for both incognito and normal mode
        if let url = webView.url, url.origin == NeevaConstants.appURL.origin {
            if !Defaults[.signedInOnce] && NeevaConstants.currentTarget == .client {
                if let query = SearchEngine.current.queryForSearchURL(url),
                    Defaults[.previewModeQueries].count == Defaults[.maxQueryLimit]
                        || Defaults[.previewModeQueries].count % Defaults[.signupPromptInterval]
                            == 0
                {
                    self.showModal(
                        style: OverlayStyle(
                            showTitle: false,
                            backgroundColor: .systemBackground,
                            nonDismissible: true
                        )
                    ) {
                        SignUpTwoButtonsPromptViewOverlayContent(
                            query: query,
                            skippable: Defaults[.previewModeQueries].count
                                != Defaults[.maxQueryLimit],
                            openOtherSignUpOption: { marketingEmailOptOut in
                                self.presentIntroViewController(
                                    true, onOtherOptionsPage: true,
                                    marketingEmailOptOut: marketingEmailOptOut)
                            },
                            openSignIn: {
                                self.presentIntroViewController(true, signInMode: true)
                            }
                        )
                        .padding(.top, 4)
                        .environment(\.openInNewTab) { url, _ in
                            self.openURLInNewTab(url)
                        }
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        // If the page failed to fully load, we still consider it finished.
        if let tab = tabManager[webView] {
            navigateInTab(tab: tab, to: navigation, webViewStatus: .finishedNavigation)
        }
    }
}

extension BrowserViewController: WKScriptMessageHandler {
    /// Prints/Logs everything from JS console.
    func logJSConsoleOutputIfEnabled(for webView: WKWebView) {
        guard Defaults[.enableWebKitConsoleLogging] else { return }

        let source = """
                (function() {
                     let originalLog = console.log;
                     let originalWarn = console.warn;
                     let originalError = console.error;
                     let originalDebug = console.debug;

                     function handleMessage(msg, type, log) {
                         window.webkit.messageHandlers.logHandler.postMessage('[' + type + '] ' + msg);
                         log(msg);
                     };

                     window.console.log = function captureLog(msg) { handleMessage(msg, 'log', originalLog); };
                     window.console.warn = function captureWarn(msg) { handleMessage(msg, 'warn', originalWarn);  };
                     window.console.error = function captureError(msg) { handleMessage(msg, 'error', originalError); };
                     window.console.debug = function captureDebug(msg) { handleMessage(msg, 'debug', originalDebug); };
                })();
            """

        // inject JS to capture console.log output and send to iOS
        let script = WKUserScript(
            source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)

        if !webView.configuration.userContentController.userScripts.contains(script) {
            webView.configuration.userContentController.addUserScript(script)

            // register the bridge script that listens for the output
            webView.configuration.userContentController.removeScriptMessageHandler(
                forName: "logHandler")
            webView.configuration.userContentController.add(self, name: "logHandler")
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
        if Defaults[.enableWebKitConsoleLogging] {
            log.info("WebKit Console Log: \(message.body)")
        }
    }
}
