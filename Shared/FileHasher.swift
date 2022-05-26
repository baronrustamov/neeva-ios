// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CryptoKit
import Foundation

/// Helper iterator that reads data in chunks from an input using `FileHandle`
private class FileDataIterator: IteratorProtocol {
    typealias Element = Swift.Result<Data, Error>

    private let url: URL
    private let bufferSize: Int
    private var fh: FileHandle

    init(url: URL, bufferSize: Int = 1024 * 1024) throws {
        self.url = url
        self.bufferSize = bufferSize
        self.fh = try FileHandle(forReadingFrom: url)
    }

    func next() -> Element? {
        do {
            let data = try fh.read(upToCount: bufferSize)
            guard let data = data,
                !data.isEmpty
            else {
                return nil
            }
            return Element.success(data)
        } catch {
            return Element.failure(error)
        }
    }
}

/// Types of cryptographic algorithms supported for computing file checksums
public enum HashAlgo: CaseIterable {
    case md5
    case sha256

    fileprivate var hasher: Hasher {
        switch self {
        case .md5:
            return Insecure.MD5()
        case .sha256:
            return SHA256()
        }
    }
}

/// Helper conformance to type erase the various hash structs in CryptoKit
private protocol Hasher {
    var type: HashAlgo { get }
    mutating func update<D: DataProtocol>(data: D)
    mutating func finalizeToString() -> String
}

extension Insecure.MD5: Hasher {
    fileprivate var type: HashAlgo { .md5 }

    fileprivate mutating func finalizeToString() -> String {
        self.finalize().map { String(format: "%02hhx", $0) }.joined()
    }
}

extension SHA256: Hasher {
    fileprivate var type: HashAlgo { .sha256 }

    fileprivate mutating func finalizeToString() -> String {
        self.finalize().map { String(format: "%02hhx", $0) }.joined()
    }
}

/// Functions to compute checksums for files
public enum FileHasher {
    /// Compute checksums for file by reading data in chunks and updating one or many hash functions in one pass
    ///
    /// - Parameters:
    ///     - url: URL of the file, device, or named socket to access.
    ///     - bufferSize: size of chunks in which data is read from the input
    ///     - algos: set of cryptographic algorithms to compute
    public static func computeHashOfFile(
        at url: URL,
        with bufferSize: Int = 1024 * 1024,
        using algos: Set<HashAlgo>
    ) throws -> [HashAlgo: String] {
        let fileDataIter = try FileDataIterator(url: url, bufferSize: bufferSize)

        var hashers = algos.map { $0.hasher }

        while let result = fileDataIter.next() {
            switch result {
            case .failure(let error):
                throw error
            case .success(let data):
                for idx in hashers.indices {
                    hashers[idx].update(data: data)
                }
            }
        }

        var result: [HashAlgo: String] = [:]

        for idx in hashers.indices {
            result[hashers[idx].type] = hashers[idx].finalizeToString()
        }

        return result
    }

    /// Compute md5 hash for file by reading data in chunks
    ///
    /// - Parameters:
    ///     - url: URL of the file, device, or named socket to access.
    ///     - bufferSize: size of chunks in which data is read from the input
    public static func md5(forFileAt url: URL, bufferSize: Int = 1024 * 1024) throws -> String {
        let fileDataIter = try FileDataIterator(url: url, bufferSize: bufferSize)

        var hash = Insecure.MD5()

        while let result = fileDataIter.next() {
            switch result {
            case .failure(let error):
                throw error
            case .success(let data):
                hash.update(data: data)
            }
        }

        let digest = hash.finalize()

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    /// Compute sha256 hash for file by reading data in chunks
    ///
    /// - Parameters:
    ///     - url: e URL of the file, device, or named socket to access.
    ///     - bufferSize: size of chunks in which data is read from the input
    public static func sha256(forFileAt url: URL, bufferSize: Int = 1024 * 1024) throws -> String {
        let fileDataIter = try FileDataIterator(url: url, bufferSize: bufferSize)

        var hash = SHA256()

        while let result = fileDataIter.next() {
            switch result {
            case .failure(let error):
                throw error
            case .success(let data):
                hash.update(data: data)
            }
        }

        let digest = hash.finalize()

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
