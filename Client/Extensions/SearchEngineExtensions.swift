//
//  SearchEngineExtensions.swift
//  Client
//
//  Created by Burak Üstün on 31.03.2022.
//  Copyright © 2022 Neeva. All rights reserved.
//

import Defaults
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
