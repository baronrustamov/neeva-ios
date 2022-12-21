// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension SubscriptionType {
    public var displayName: LocalizedStringKey {
        switch self {
        case .basic: return "Free Basic"
        case .premium, .lifetime: return "Premium"
        case .unlimited: return "Unlimited"
        default: return "\(Image(systemSymbol: .exclamationmarkTriangleFill)) Membership Unknown"
        }
    }

    public var color: Color {
        switch self {
        case .basic: return .brand.polar
        case .premium, .lifetime, .unlimited: return .brand.variant.offwhite
        default: return .secondarySystemFill
        }
    }
}
