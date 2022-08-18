// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

class TextSizeModel: ObservableObject {
    private let tab: Tab

    init(tab: Tab) {
        self.tab = tab
    }

    // observed from Safari on iOS 14.6 (18F72)
    let levels: [CGFloat] = [0.5, 0.75, 0.85, 1, 1.15, 1.25, 1.5, 1.75, 2, 2.5, 3]

    var canZoomIn: Bool { tab.pageZoom != levels.last }
    var canZoomOut: Bool { tab.pageZoom != levels.first }

    func resetZoom() {
        tab.pageZoom = 1.0
    }

    func zoomIn() {
        if tab.pageZoom < levels.first! {
            tab.pageZoom = levels.first!
        } else if tab.pageZoom < levels.last! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower <= tab.pageZoom, tab.pageZoom < upper {
                    tab.pageZoom = upper
                    return
                }
            }
        }
        // otherwise, keep as-is
    }

    func zoomOut() {
        if tab.pageZoom > levels.last! {
            tab.pageZoom = levels.last!
        } else if tab.pageZoom > levels.first! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower < tab.pageZoom, tab.pageZoom <= upper {
                    tab.pageZoom = lower
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
        let percent = formatter.string(from: tab.pageZoom as NSNumber)!
        if !canZoomIn {
            return "maximum, \(percent)"
        }
        if !canZoomOut {
            return "minimum, \(percent)"
        }
        if tab.pageZoom == 1 {
            return "default, \(percent)"
        }
        return percent
    }

}
