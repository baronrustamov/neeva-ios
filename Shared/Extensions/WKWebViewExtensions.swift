/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

// Temporary flag to test the new sandboxed javascript environment
// in iOS 14
private let USE_NEW_SANDBOX_APIS = false

extension WKWebView {

    /// This calls different WebKit evaluateJavaScript functions depending on iOS version
    ///  - If iOS14 or higher, evaluates Javascript in a .defaultClient sandboxed content world
    ///  - If below iOS14, evaluates Javascript without sandboxed environment
    /// - Parameters:
    ///     - javascript: String representing javascript to be evaluated
    public func evaluateJavascriptInDefaultContentWorld(_ javascript: String) {
        if USE_NEW_SANDBOX_APIS {
            self.evaluateJavaScript(
                javascript, in: nil, in: .defaultClient, completionHandler: { _ in })
        } else {
            self.evaluateJavaScript(javascript)
        }
    }

    /// This calls different WebKit evaluateJavaScript functions depending on iOS version with a completion that passes a tuple with optional data or an optional error
    ///  - If iOS14 or higher, evaluates Javascript in a .defaultClient sandboxed content world
    ///  - If below iOS14, evaluates Javascript without sandboxed environment
    /// - Parameters:
    ///     - javascript: String representing javascript to be evaluated
    ///     - completion: Tuple containing optional data and an optional error
    public func evaluateJavascriptInDefaultContentWorld(
        _ javascript: String, _ completion: @escaping ((Any?, Error?) -> Void)
    ) {
        if USE_NEW_SANDBOX_APIS {
            self.evaluateJavaScript(javascript, in: nil, in: .defaultClient) { result in
                switch result {
                case .success(let value):
                    completion(value, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        } else {
            self.evaluateJavaScript(javascript) { data, error in
                completion(data, error)
            }
        }
    }
}

extension WKUserContentController {
    public func addInDefaultContentWorld(scriptMessageHandler: WKScriptMessageHandler, name: String)
    {
        if USE_NEW_SANDBOX_APIS {
            add(scriptMessageHandler, contentWorld: .defaultClient, name: name)
        } else {
            add(scriptMessageHandler, name: name)
        }
    }
}

extension WKUserScript {
    public class func createInDefaultContentWorld(
        source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool
    ) -> WKUserScript {
        if USE_NEW_SANDBOX_APIS {
            return WKUserScript(
                source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly,
                in: .defaultClient)
        } else {
            return WKUserScript(
                source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
        }
    }
}

extension WKBackForwardList {
    public var all: [WKBackForwardListItem] {
        return (backList + [currentItem] + forwardList).compactMap { $0 }
    }

    public var navigationStackIndex: Int {
        backList.count
    }
}
