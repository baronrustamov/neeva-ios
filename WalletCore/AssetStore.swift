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

    public func refresh(cursor: String? = nil, onCompletion: (() -> Void)? = nil) {
        guard !Defaults[.cryptoPublicKey].isEmpty else {
            return
        }
        DispatchQueue.main.async {
            self.state = .syncing
        }
        var params: Parameters = [
            "order_direction": "desc",
            "limit": "50",
            "owner": Defaults[.cryptoPublicKey],
        ]

        if let cursor = cursor {
            params["cursor"] = cursor
        } else {
            assets = []
        }

        Web3NetworkProvider.default.request(
            target: OpenSeaAPI.assets(params: params),
            model: AssetsResult.self,
            completion: { [weak self] response in
                guard let self = self else {
                    return
                }
                switch response {
                case .success(let result):
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
                        self.refresh(cursor: result.next!, onCompletion: onCompletion)
                    } else {
                        onCompletion?()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.state = .error
                }
            })
    }

    public func fetch(collection slug: String, onFetch: @escaping (Collection) -> Void) {
        Web3NetworkProvider.default.request(
            target: OpenSeaAPI.collection(slug: slug),
            model: CollectionResult.self,
            completion: { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let result):
                    self.collections.remove(result.collection)
                    self.collections.insert(result.collection)
                    onFetch(result.collection)
                    self.state = .ready
                case .failure:
                    self.state = .error
                }
            })
    }

    public func fetchCollections(_ onCompletion: (() -> Void)? = nil) {
        let params: Parameters = [
            "limit": "300",
            "asset_owner": Defaults[.cryptoPublicKey],
        ]
        Web3NetworkProvider.default.request(
            target: OpenSeaAPI.collections(params: params),
            model: [Collection].self,
            completion: { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let result):
                    result.forEach({
                        self.collections.remove($0)
                        self.collections.insert($0)
                    })
                    self.state = .ready
                    onCompletion?()
                case .failure(let error):
                    print(error)
                    self.state = .error
                }
            })
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
