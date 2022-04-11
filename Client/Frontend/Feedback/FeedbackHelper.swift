// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

func showFeedbackPanel(
    bvc: BrowserViewController, screenshot: UIImage? = nil, shareURL: Bool = true
) {
    let url = shareURL ? bvc.tabManager.selectedTab?.canonicalURL : nil
    let query = SearchEngine.current.queryForSearchURL(url)

    getSearchRequestID(bvc: bvc) { requestId in
        bvc.present(
            SendFeedbackPanel(
                requestId: requestId, screenshot: screenshot, url: url, query: query,
                onOpenURL: {
                    bvc.dismiss(animated: true, completion: nil)
                    bvc.openURLInNewTab($0)
                }), animated: true)
    }
}

func getSearchRequestID(
    bvc: BrowserViewController, completion: @escaping (_ requestIdString: String?) -> Void
) {
    guard let webView = bvc.tabManager.selectedTab?.webView else {
        completion(nil)
        return
    }
    webView.evaluateJavaScript("window.__neevaNativeBridge.messaging.getRequestID()") {
        (data, error) in
        completion(data as? String)
        if let error = error {
            print("evaluateJavaScript Error : \(String(describing: error))")
        }
    }
}
