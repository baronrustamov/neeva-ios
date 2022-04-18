// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

public enum AssetStoreState {
    case ready, syncing, error
}

public class AssetStore: ObservableObject {
    public static var shared = AssetStore()

    @Published public private(set) var state: AssetStoreState = .ready
    public var assets: [Asset] = []
    public var collections = Set<Collection>()
    public var availableThemes = Set<Web3Theme>()

    public func refresh(cursor: String? = nil) {
        guard
            let url = URL(
                string:
                    "https://api.opensea.io/api/v1/assets?order_direction=desc\(cursor == nil ? "" : ("&cursor=" + (cursor?.addingPercentEncoding(withAllowedCharacters: .alphanumerics))!))&limit=50&owner=\(Defaults[.cryptoPublicKey])"
            )
        else {
            return
        }
        if cursor == nil {
            assets = []
        }
        DispatchQueue.main.async {
            self.state = .syncing
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENSEA_API_KEY") as? String {
            request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data = data else { return }

            guard let result = try? JSONDecoder().decode(AssetsResult.self, from: data) else {
                DispatchQueue.main.async {
                    self.state = .error
                }
                return
            }
            DispatchQueue.main.async {
                self.assets.append(contentsOf: result.assets)
                self.assets.forEach({
                    guard let collection = $0.collection else { return }
                    if let theme = Web3Theme.allCases.first(
                        where: { $0.rawValue == collection.openSeaSlug })
                    {
                        self.availableThemes.insert(theme)
                    }
                    self.collections.insert(collection)
                })
                self.state = .ready
                if result.next?.isEmpty == false {
                    self.refresh(cursor: result.next!)
                }
            }
        }.resume()
    }

    public func fetch(collection slug: String, onFetch: @escaping (Collection) -> Void) {
        guard let url = URL(string: "https://api.opensea.io/api/v1/collection/\(slug)") else {
            return
        }
        self.state = .syncing
        if let data = try? Data(contentsOf: url) {
            guard let result = try? JSONDecoder().decode(CollectionResult.self, from: data) else {
                DispatchQueue.main.async {
                    self.state = .error
                }
                return
            }
            if let current = collections.first(where: {
                $0.openSeaSlug == result.collection.openSeaSlug
            }) {
                collections.remove(current)
            }
            collections.insert(result.collection)
            onFetch(result.collection)
            DispatchQueue.main.async {
                self.state = .ready
            }
        }
    }

    public func fetchCollections() {
        collections.forEach({ fetch(collection: $0.openSeaSlug, onFetch: { _ in }) })
    }
}

public struct AssetsResult: Codable {
    public let assets: [Asset]
    public let previous: String?
    public let next: String?
}

public struct CollectionResult: Codable {
    public let collection: Collection
}
