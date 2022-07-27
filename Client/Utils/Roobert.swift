// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension Font.Weight {
    fileprivate var roobertName: String {
        switch self {
        case .light, .ultraLight, .thin:
            return "Roobert-Light"
        case .regular:
            return "Roobert-Regular"
        case .medium:
            return "Roobert-Medium"
        case .semibold:
            return "Roobert-SemiBold"
        case .bold:
            return "Roobert-Bold"
        case .heavy, .black:
            return "Roobert-Heavy"
        default:
            print("Unsupported Font.Weight: \(self)")
            return "Roobert-Regular"
        }
    }
}

extension Font {
    static func roobert(_ weight: Font.Weight = .regular, size: CGFloat) -> Self {
        custom(weight.roobertName, size: size)
    }
}
