// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Storage

struct InsertTabLocation {
    var index: Int? = nil
    weak var parent: Tab? = nil
    var keepInParentTabGroup: Bool = true

    static let `default`: Self = InsertTabLocation()
}

/// Parameters with which TabManager configures a tab after its creation
struct TabConfig {
    /// URL request to load into the webview
    var request: URLRequest?
    /// WKWebView instance to restore onto the tab
    var webView: WKWebView? = nil
    /// Location at which tab should be inserted
    var insertLocation: InsertTabLocation = .default
    var flushToDisk: Bool = true
    var zombie: Bool = false
    var isPopup: Bool = false
    var query: String? = nil
    var suggestedQuery: String? = nil
    var queryLocation: QueryForNavigation.Query.Location = .suggestion
    var visitType: VisitType? = nil

    static let `default`: Self = TabConfig()
}
