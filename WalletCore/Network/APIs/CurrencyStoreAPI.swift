// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

public enum CurrencyStoreAPI: URLRequestBuilder {
    case currencies
}

extension CurrencyStoreAPI {
    public var baseURL: URL {
        return URL(string: "https://api.coingecko.com")!
    }

    public var path: String {
        switch self {
        case .currencies:
            return
                "/api/v3/simple/price"
        }
    }

    public var headers: HTTPHeaders {
        switch self {
        case .currencies:
            return ["Accept": "application/json"]
        }
    }

    public var parameters: Parameters? {
        switch self {
        case .currencies:
            return [
                "ids": "ethereum,matic-network,usd-coin,tether,shiba-inu",
                "vs_currencies": "usd",
                "include_24hr_change": "true",
                "include_last_updated_at": "true",
            ]
        }
    }

    public var method: HTTPMethod {
        return .get
    }
}
