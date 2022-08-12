/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import GCDWebServers
import SwiftKeychainWrapper
import WebKit

let LabelAddressAndSearch = "Address and Search"

extension XCTestCase {
    func tester(_ file: String = #file, _ line: Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(_ file: String = #file, _ line: Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFUITestActor {
    /// Looks for a view with the given accessibility hint.
    func tryFindingViewWithAccessibilityHint(_ hint: String) -> Bool {
        let element = UIApplication.shared.accessibilityElement { element in
            return element?.accessibilityHint! == hint
        }

        return element != nil
    }

    func waitForViewWithAccessibilityHint(_ hint: String) -> UIView? {
        var view: UIView? = nil
        autoreleasepool {
            wait(
                for: nil, view: &view,
                withElementMatching: NSPredicate(format: "accessibilityHint = %@", hint),
                tappable: false)
        }
        return view
    }

    func viewExistsWithLabel(_ label: String) -> Bool {
        do {
            try self.tryFindingView(withAccessibilityLabel: label)
            return true
        } catch {
            return false
        }
    }

    func viewExistsWithLabelPrefixedBy(_ prefix: String) -> Bool {
        let element = UIApplication.shared.accessibilityElement { element in
            return element?.accessibilityLabel?.hasPrefix(prefix) ?? false
        }
        return element != nil
    }

    /// Waits for and returns a view with the given accessibility value.
    func waitForViewWithAccessibilityValue(_ value: String) -> UIView {
        var element: UIAccessibilityElement!

        run { _ in
            element = UIApplication.shared.accessibilityElement { element in
                return element?.accessibilityValue == value
            }

            return (element == nil) ? KIFTestStepResult.wait : KIFTestStepResult.success
        }

        return UIAccessibilityElement.viewContaining(element)
    }

    /// There appears to be a KIF bug where waitForViewWithAccessibilityLabel returns the parent
    /// UITableView instead of the UITableViewCell with the given label.
    /// As a workaround, retry until KIF gives us a cell.
    /// Open issue: https://github.com/kif-framework/KIF/issues/336
    func waitForCellWithAccessibilityLabel(_ label: String) -> UITableViewCell {
        var cell: UITableViewCell!

        run { _ in
            let view = self.waitForView(withAccessibilityLabel: label)
            cell = view as? UITableViewCell
            return (cell == nil) ? KIFTestStepResult.wait : KIFTestStepResult.success
        }

        return cell
    }

    /// Finding views by accessibility label doesn't currently work with WKWebView:
    ///     https://github.com/kif-framework/KIF/issues/460
    /// As a workaround, inject a KIFHelper class that iterates the document and finds
    /// elements with the given textContent or title.
    func waitForWebViewElementWithAccessibilityLabel(
        _ text: String, timeout: TimeInterval = KIFTestActor.defaultTimeout()
    ) {
        run(
            { error in
                if self.hasWebViewElementWithAccessibilityLabel(text) {
                    return KIFTestStepResult.success
                }

                return KIFTestStepResult.wait
            }, timeout: timeout)
    }

    /// Sets the text for a WKWebView input element with the given name.
    func enterText(_ text: String, intoWebViewInputWithName inputName: String) {
        let webView = getWebViewWithKIFHelper()
        var stepResult = KIFTestStepResult.wait

        let escaped = text.replacingOccurrences(of: "\"", with: "\\\"")
        webView.evaluateJavascriptInDefaultContentWorld(
            "KIFHelper.enterTextIntoInputWithName(\"\(escaped)\", \"\(inputName)\");"
        ) { success, _ in
            stepResult =
                ((success as? Bool)!) ? KIFTestStepResult.success : KIFTestStepResult.failure
        }

        run { error in
            if stepResult == KIFTestStepResult.failure {
                error?.pointee = NSError(
                    domain: "KIFHelper", code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Input element not found in webview: \(escaped)"
                    ])
            }
            return stepResult
        }
    }

    /// Clicks a WKWebView element with the given label.
    func tapWebViewElementWithAccessibilityLabel(_ text: String) {
        let webView = getWebViewWithKIFHelper()
        var stepResult = KIFTestStepResult.wait

        let escaped = text.replacingOccurrences(of: "\"", with: "\\\"")
        webView.evaluateJavascriptInDefaultContentWorld(
            "KIFHelper.tapElementWithAccessibilityLabel(\"\(escaped)\")"
        ) { success, _ in
            stepResult =
                ((success as? Bool)!) ? KIFTestStepResult.success : KIFTestStepResult.failure
        }

        run { error in
            if stepResult == KIFTestStepResult.failure {
                error?.pointee = NSError(
                    domain: "KIFHelper", code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Accessibility label not found in webview: \(escaped)"
                    ])
            }
            return stepResult
        }
    }

    /// Determines whether an element in the page exists.
    func hasWebViewElementWithAccessibilityLabel(_ text: String) -> Bool {
        let webView = getWebViewWithKIFHelper()
        var stepResult = KIFTestStepResult.wait
        var found = false

        let escaped = text.replacingOccurrences(of: "\"", with: "\\\"")
        webView.evaluateJavascriptInDefaultContentWorld(
            "KIFHelper.hasElementWithAccessibilityLabel(\"\(escaped)\")"
        ) { success, _ in
            found = success as? Bool ?? false
            stepResult = KIFTestStepResult.success
        }

        run { _ in return stepResult }

        return found
    }

    fileprivate func getWebViewWithKIFHelper() -> WKWebView {
        let webView = waitForView(withAccessibilityLabel: "Web content") as! WKWebView

        // Wait for the web view to stop loading.
        run { _ in
            return webView.isLoading ? KIFTestStepResult.wait : KIFTestStepResult.success
        }
        var stepResult = KIFTestStepResult.wait

        webView.evaluateJavaScript("typeof KIFHelper") { result, _ in
            if result as! String == "undefined" {
                let bundle = Bundle(for: BundleHelper.self)
                let path = bundle.path(forResource: "KIFHelper", ofType: "js")!
                let source = try! String(contentsOfFile: path, encoding: .utf8)
                webView.evaluateJavaScript(source, completionHandler: nil)
            }
            stepResult = KIFTestStepResult.success
        }

        run { _ in return stepResult }

        return webView
    }

    public func deleteCharacterFromFirstResponser() {
        self.enterText(intoCurrentFirstResponder: "\u{0008}")
    }
}

private class BundleHelper {}

class SimplePageServer {
    class func getPageData(_ name: String, ext: String = "html") -> String {
        let pageDataPath = Bundle(for: self).path(forResource: name, ofType: ext)!
        return try! String(contentsOfFile: pageDataPath, encoding: .utf8)
    }

    static var useLocalhostInsteadOfIP = false

    class func start() -> String {
        let webServer: GCDWebServer = GCDWebServer()

        webServer.addHandler(
            forMethod: "GET", path: "/image.png", request: GCDWebServerRequest.self
        ) { (request) -> GCDWebServerResponse? in
            let img = UIImage(named: "defaultFavicon")!.pngData()!
            return GCDWebServerDataResponse(data: img, contentType: "image/png")
        }

        for page in ["findPage", "noTitle", "readablePage", "JSPrompt", "blobURL", "neevaScheme"] {
            webServer.addHandler(
                forMethod: "GET", path: "/\(page).html", request: GCDWebServerRequest.self
            ) { (request) -> GCDWebServerResponse? in
                return GCDWebServerDataResponse(html: self.getPageData(page))
            }
        }

        // we may create more than one of these but we need to give them uniquie accessibility ids in the tab manager so we'll pass in a page number
        webServer.addHandler(
            forMethod: "GET", path: "/scrollablePage.html", request: GCDWebServerRequest.self
        ) { (request) -> GCDWebServerResponse? in
            var pageData = self.getPageData("scrollablePage")
            let page = Int(request.query!["page"]!)
            pageData = pageData.replacingOccurrences(of: "{page}", with: page!.description)
            return GCDWebServerDataResponse(html: pageData as String)
        }

        webServer.addHandler(
            forMethod: "GET", path: "/numberedPage.html", request: GCDWebServerRequest.self
        ) { (request) -> GCDWebServerResponse? in
            var pageData = self.getPageData("numberedPage")

            let page = Int(request.query!["page"]!)
            pageData = pageData.replacingOccurrences(of: "{page}", with: page!.description)

            return GCDWebServerDataResponse(html: pageData as String)
        }

        webServer.addHandler(
            forMethod: "GET", path: "/readerContent.html", request: GCDWebServerRequest.self
        ) { (request) -> GCDWebServerResponse? in
            return GCDWebServerDataResponse(html: self.getPageData("readerContent"))
        }

        webServer.addHandler(
            forMethod: "GET", path: "/loginForm.html", request: GCDWebServerRequest.self
        ) { _ in
            return GCDWebServerDataResponse(html: self.getPageData("loginForm"))
        }

        webServer.addHandler(
            forMethod: "GET", path: "/navigationDelegate.html", request: GCDWebServerRequest.self
        ) { _ in
            return GCDWebServerDataResponse(html: self.getPageData("navigationDelegate"))
        }

        webServer.addHandler(
            forMethod: "GET", path: "/localhostLoad.html", request: GCDWebServerRequest.self
        ) { _ in
            return GCDWebServerDataResponse(html: self.getPageData("localhostLoad"))
        }

        webServer.addHandler(
            forMethod: "GET", path: "/auth.html", request: GCDWebServerRequest.self
        ) { (request: GCDWebServerRequest?) in
            // "user:pass", Base64-encoded.
            let expectedAuth = "Basic dXNlcjpwYXNz"

            let response: GCDWebServerDataResponse
            if request?.headers["Authorization"] == expectedAuth && request?.query?["logout"] == nil
            {
                response = GCDWebServerDataResponse(html: "<html><body>logged in</body></html>")!
            } else {
                // Request credentials if the user isn't logged in.
                response = GCDWebServerDataResponse(html: "<html><body>auth fail</body></html>")!
                response.statusCode = 401
                response.setValue("Basic realm=\"test\"", forAdditionalHeader: "WWW-Authenticate")
            }

            return response
        }

        func htmlForImageBlockingTest(imageURL: String) -> String {
            let html =
                """
                <html><head><script>
                        function testImage(URL) {
                            var tester = new Image();
                            tester.onload = imageFound;
                            tester.onerror = imageNotFound;
                            tester.src = URL;
                            document.body.appendChild(tester);
                        }

                        function imageFound() {
                            alert('image loaded.');
                        }

                        function imageNotFound() {
                            alert('image not loaded.');
                        }

                        window.onload = function(e) {
                            // Disabling TP stats reporting using JS execution on the wkwebview happens async;
                            // setTimeout(1 sec) is plenty of delay to ensure the JS has executed.
                            setTimeout(() => { testImage('\(imageURL)'); }, 1000);
                        }
                    </script></head>
                <body>TEST IMAGE BLOCKING</body></html>
                """
            return html
        }

        // Add tracking protection check page
        webServer.addHandler(
            forMethod: "GET", path: "/tracking-protection-test.html",
            request: GCDWebServerRequest.self
        ) { (request: GCDWebServerRequest?) in
            return GCDWebServerDataResponse(
                html: htmlForImageBlockingTest(imageURL: "http://ymail.com/favicon.ico"))
        }

        // Add image blocking test page
        webServer.addHandler(
            forMethod: "GET", path: "/hide-images-test.html", request: GCDWebServerRequest.self
        ) { (request: GCDWebServerRequest?) in
            return GCDWebServerDataResponse(
                html: htmlForImageBlockingTest(imageURL: "https://www.mozilla.com/favicon.ico"))
        }

        if !webServer.start(withPort: 0, bonjourName: nil) {
            XCTFail("Can't start the GCDWebServer")
        }

        // We use 127.0.0.1 explicitly here, rather than localhost, in order to avoid our
        // history exclusion code (Bug 1188626).

        let webRoot =
            "http://\(useLocalhostInsteadOfIP ? "localhost" : "127.0.0.1"):\(webServer.port)"
        return webRoot
    }
}

// From iOS 10, below methods no longer works
class DynamicFontUtils {
    // Need to leave time for the notification to propagate
    static func bumpDynamicFontSize(_ tester: KIFUITestActor) {
        let value = UIContentSizeCategory.accessibilityExtraLarge
        UIApplication.shared.setValue(value, forKey: "preferredContentSizeCategory")
        tester.wait(forTimeInterval: 0.3)
    }

    static func lowerDynamicFontSize(_ tester: KIFUITestActor) {
        let value = UIContentSizeCategory.extraSmall
        UIApplication.shared.setValue(value, forKey: "preferredContentSizeCategory")
        tester.wait(forTimeInterval: 0.3)
    }

    static func restoreDynamicFontSize(_ tester: KIFUITestActor) {
        let value = UIContentSizeCategory.medium
        UIApplication.shared.setValue(value, forKey: "preferredContentSizeCategory")
        tester.wait(forTimeInterval: 0.3)
    }
}

// see also `skipTest` in ClientTests, StorageTests, and XCUITests
func skipTest(issue: Int, _ message: String) throws {
    throw XCTSkip("#\(issue): \(message)")
}
