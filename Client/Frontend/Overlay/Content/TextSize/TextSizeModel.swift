// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import WebKit

// Having page zoom issues? Take a look at an earlier commit (e.g., a2139914469ec4aa97364f66735295339601c8d0).
// A fallback page zoom method was removed to simplify the code.
class TextSizeModel: ObservableObject {
    private let tab: Tab

    init(tab: Tab) {
        self.tab = tab
    }

    // If tab.webView is nil here, something is very wrong
    private var observer: AnyCancellable?
    var pageZoom: CGFloat {
        get {
            tab.webView?.neeva_zoomAmount ?? 1.0
        }
        set {
            objectWillChange.send()
            if let webView = tab.webView {
                webView.neeva_zoomAmount = newValue
                let originalOffset = webView.scrollView.contentOffset
                // Fix the scroll position after changing zoom level
                let newOffset = CGPoint(
                    x: originalOffset.x, y: originalOffset.y * newValue / pageZoom)
                observer = webView.scrollView.publisher(for: \.contentOffset)
                    .sink { offset in
                        if offset != originalOffset {
                            webView.scrollView.contentOffset = newOffset
                            self.observer = nil
                        }
                    }
            }
        }
    }

    // observed from Safari on iOS 14.6 (18F72)
    let levels: [CGFloat] = [0.5, 0.75, 0.85, 1, 1.15, 1.25, 1.5, 1.75, 2, 2.5, 3]

    var canZoomIn: Bool { pageZoom != levels.last }
    var canZoomOut: Bool { pageZoom != levels.first }

    func zoomIn() {
        if pageZoom < levels.first! {
            pageZoom = levels.first!
        } else if pageZoom < levels.last! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower <= pageZoom, pageZoom < upper {
                    pageZoom = upper
                    return
                }
            }
        }
        // otherwise, keep as-is
    }

    func zoomOut() {
        if pageZoom > levels.last! {
            pageZoom = levels.last!
        } else if pageZoom > levels.first! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower < pageZoom, pageZoom <= upper {
                    pageZoom = lower
                    return
                }
            }
        }
        // otherwise, keep as-is
    }

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    var label: String {
        let percent = formatter.string(from: pageZoom as NSNumber)!
        if !canZoomIn {
            return "maximum, \(percent)"
        }
        if !canZoomOut {
            return "minimum, \(percent)"
        }
        if pageZoom == 1 {
            return "default, \(percent)"
        }
        return percent
    }

}
