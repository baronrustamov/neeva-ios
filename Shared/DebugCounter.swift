// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if DEBUG
    private var debugCounters: [String: Int] = [:]
#endif

/// Useful for logging how often certain code paths are hit.
///
/// Can be added into a SwiftUI scene like so:
///
///    struct MyView: View {
///        var body: some View {
///            let _ = debugCount("MyView.body")
///            ...
///        }
///    }
///
public func debugCount(_ label: String) -> Int {
    #if DEBUG
        var newCount: Int
        if let count = debugCounters[label] {
            newCount = count + 1
        } else {
            newCount = 1
        }
        debugCounters[label] = newCount
        print(">>> \(label): \(newCount)")
        return newCount
    #else
        return 0
    #endif
}
