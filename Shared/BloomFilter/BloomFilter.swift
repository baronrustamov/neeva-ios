// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Implementation of bloom filter datastructure
///
/// Read only filter. Multiple hash function is emulated using FNV1Hash. see ``mayContain(key:)``
///
/// Supports decoding from a json file with values:
///
///     {
///         "Data": <base 64 encoded string for the bits>,
///         "K": <number of hash functions>
///     }
///
public struct BloomFilter: Decodable {
    static let ln2: Double = log(2.0)

    /// Bytes in array of UInt8
    let data: Data
    /// Number of bits in data
    let numBits: UInt32
    /// Number of hash functions
    let k: UInt32

    /// Coding keys to bridge between Swift naming convention and JSON format
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case k = "K"
    }

    /// Supporting function for decoding filter from JSON data
    ///
    /// This function is needed to transform the data value in the json from base 64 encoded string to raw bits.
    /// The decoder should have a container with the keys in ``CodingKeys``.
    ///
    /// It also sets the ``numBits`` property from the length of the decoded data
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.k = try container.decode(UInt32.self, forKey: .k)

        // Bytes are stored in base64 encoded string
        let dataString = try container.decode(String.self, forKey: .data)
        guard let data = Data(base64Encoded: dataString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .data, in: container,
                debugDescription: "Unable to decode base64encoded data from string"
            )
        }
        self.data = data
        self.numBits = UInt32(data.count * 8)
    }

    /// Load filter from a binary file
    /// Do not use synchronously to request network-based URLs
    /// - Parameters:
    ///     - url: url to binary file
    /// - Throws:
    /// Throw error from loading or decoding data
    /// - Returns:
    /// `BloomFilter` object containing data encoded in the binary file
    public static func load(from url: URL) throws -> BloomFilter {
        precondition(!Thread.isMainThread)
        let data = try Data(contentsOf: url, options: .uncached)
        return try JSONDecoder().decode(BloomFilter.self, from: data)
    }

    /// Returns a Boolean value that indicates whether a given key may be a member of the bloom filter
    ///
    /// This function emulated k independent hashes by iteratively applying bit manipulations to a FNV1a hash of the input
    ///
    /// - Parameters:
    ///     - key: `String` key to look for in the bloom filter
    /// - Returns:
    ///  `true` if bloom filter may contain this element; `false` if the bloom filter does not contain this element
    public func mayContain(key: String) -> Bool {
        let keyHash = FNVHash.fnv1aMod(bytes: key.utf8)

        var h1: UInt32 = UInt32((keyHash >> 31) & 0xffff_ffff)
        let h2: UInt32 = UInt32(keyHash & 0xffff_ffff)

        for _ in 0..<k {
            let bit = h1 % numBits
            h1 = h1 &+ h2
            if data[Int(bit / 8)] & (1 << (bit % 8)) == 0 {
                return false
            }
        }
        return true
    }

    /// Approximate length of bloom filter
    ///  - parameters:
    ///     - n: number of elements to be inserted in the filter
    ///     - p: desired false positive probability
    ///  - returns:
    ///  size of the bloom filter in bytes
    public static func numBytes(n: Int, p: Double) -> UInt {
        let numBits: UInt = UInt(-1 * Double(n) * log(p) / pow(ln2, 2))
        return (numBits + 7) / 8
    }

    /// Approximate number of hash functions
    ///  - parameters:
    ///     - p: desired false positive probability
    ///  - returns:
    ///  number of hash functions needed
    public static func numHashes(p: Double) -> UInt {
        return UInt(-1 * log2(p))
    }
}
