// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import StoreKit

extension SearchEngine {
    public static var current: SearchEngine {
        let autoEngine = Defaults[.customSearchEngine].flatMap { all[$0] }

        if NeevaConstants.currentTarget == .xyz {
            let countryCode = SKPaymentQueue.default().storefront?.countryCode
            let defaultEngine: SearchEngine =
                countryCode == "USA"
                ? .neeva
                : .google
            return autoEngine ?? defaultEngine
        }

        return autoEngine ?? .neeva
    }
}
