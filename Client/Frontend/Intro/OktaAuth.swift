// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class OktaAccountCreatedDelegate: NSObject, URLSessionTaskDelegate {
    var onDismiss: ((FirstRunButtonActions) -> Void)

    init(onDismiss: @escaping ((FirstRunButtonActions) -> Void)) {
        self.onDismiss = onDismiss
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        if let cookie = response.allHeaderFields["Set-Cookie"] as? String {
            guard
                let token = cookie.split(
                    separator: ";"
                ).first?.replacingOccurrences(
                    of: "httpd~login=", with: ""
                )
            else { return }

            DispatchQueue.main.async {
                self.onDismiss(.oktaAccountCreated(token))
            }
        }
    }
}
