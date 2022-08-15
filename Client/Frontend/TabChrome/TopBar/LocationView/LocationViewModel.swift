// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import SwiftUI

/// One instance per window. Contains information about the current tab.
class LocationViewModel: ObservableObject {
    @Published var url: URL?
    @Published private var hasOnlySecureContentListener: AnyCancellable?
    /// `true` if all assets on the page are secure (i.e. there is no mixed content)
    @Published private var hasOnlySecureContent = false
    var isSecure: Bool? { hasOnlySecureContentListener == nil ? nil : hasOnlySecureContent }

    func updateSecureListener(with webView: WKWebView) {
        hasOnlySecureContentListener = webView.publisher(
            for: \.hasOnlySecureContent, options: [.initial, .new]
        ).assign(to: \.hasOnlySecureContent, on: self)
    }

    func resetSecureListener() {
        hasOnlySecureContentListener = nil
    }

    init() {}
    init(previewURL: URL?, isSecure: Bool?) {
        self.url = previewURL

        if let isSecure = isSecure {
            self.hasOnlySecureContent = isSecure
            self.hasOnlySecureContentListener = AnyCancellable({})
        } else {
            self.hasOnlySecureContentListener = nil
        }
    }
}
