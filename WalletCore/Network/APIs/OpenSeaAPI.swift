// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum OpenSeaAPI: URLRequestBuilder {
    case collection(slug: String)
    case collections(params: Parameters)
    case assets(params: Parameters)
}

extension OpenSeaAPI {
    public var baseURL: URL {
        return URL(string: "https://api.opensea.io")!
    }

    public var path: String {
        switch self {
        case .collection(let slug):
            return "/api/v1/collection/" + slug
        case .collections:
            return "/api/v1/collections"
        case .assets:
            return "/api/v1/assets"
        }
    }

    public var headers: HTTPHeaders {
        switch self {
        case .assets:
            if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENSEA_API_KEY") as? String {
                return [
                    "Accept": "application/json",
                    "X-API-KEY": apiKey,
                ]
            }
            return ["Accept": "application/json"]
        default:
            return [:]
        }
    }

    public var parameters: Parameters? {
        switch self {
        case .assets(let params),
            .collections(let params):
            return params
        default:
            return nil
        }
    }

    public var method: HTTPMethod {
        return .get
    }
}
