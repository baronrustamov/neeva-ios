// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Implementation for FNVHash for 64 bit architectures
enum FNVHash {
    static let offset: UInt = 14_695_981_039_346_656_037
    static let prime: UInt = 1_099_511_628_211

    static func fnv1aMod<S: BidirectionalCollection>(bytes: S) -> UInt where S.Element == UInt8 {
        var hash = offset
        var idx = bytes.startIndex

        let subIndices = bytes.indices.dropLast(2)
        let lastGroupStartIdx = subIndices.isEmpty ? idx : (subIndices.last ?? idx)

        while idx < lastGroupStartIdx {
            let combined: UInt =
                UInt(bytes[idx]) | UInt(bytes[bytes.index(idx, offsetBy: 1)]) << 8 | UInt(
                    bytes[bytes.index(idx, offsetBy: 2)]) << 16 | UInt(
                    bytes[bytes.index(idx, offsetBy: 3)]) << 24
            hash ^= combined
            hash = hash &* prime
            idx = bytes.index(idx, offsetBy: 4)
        }
        while idx < bytes.endIndex {
            hash ^= UInt(bytes[idx])
            hash = hash &* prime
            idx = bytes.index(after: idx)
        }
        return hash
    }
}
