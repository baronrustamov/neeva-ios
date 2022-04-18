// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared

public class WalletQuery: QueryController<CryptoWalletQuery, WalletQuery.WalletInfo> {
    public typealias WalletInfo = CryptoWalletQuery.Data.CryptoWallet

    public override class func processData(_ data: CryptoWalletQuery.Data)
        -> WalletInfo
    {
        data.cryptoWallet ?? WalletInfo(ens: [])
    }

    @discardableResult public static func getWalletInfo(
        query: String,
        completion: @escaping (Result<WalletInfo, Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: CryptoWalletQuery(query: query), completion: completion)
    }
}
