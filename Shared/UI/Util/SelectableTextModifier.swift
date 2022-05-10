// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import SwiftUI

struct SelectableText: ViewModifier {
    var allowSelection: Bool

    func body(content: Content) -> some View {
        Group {
            if #available(iOS 15, *) {
                if allowSelection {
                    content
                        .textSelection(.enabled)
                } else {
                    content
                        .textSelection(.disabled)
                }
            } else {
                content
            }
        }
    }
}

extension View {
    /// Apply `.textSelection` modifier if iOS 15 is available
    public func selectableIfAvailable(_ allowSelection: Bool) -> some View {
        modifier(SelectableText(allowSelection: allowSelection))
    }
}
