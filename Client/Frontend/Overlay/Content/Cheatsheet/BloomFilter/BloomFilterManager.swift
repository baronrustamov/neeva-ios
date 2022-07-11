// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared

private struct Checksum: Decodable {
    let sha: String
    let md5: String

    static func load(from url: URL) throws -> Self {
        precondition(!Thread.isMainThread)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Checksum.self, from: data)
    }
}

private enum BloomFilterLoader {
    typealias LoaderResult = Swift.Result<BloomFilter, Error>

    enum LoaderError: Error {
        case invalidInput
        case invalidFilePath
        case invalidChecksumData
        case invalidFilterBinaryFile
        case downloadedFileNotFound
    }

    struct ResourceLocation {
        let checksumURL: URL
        let binUrl: URL
        let saveToURL: URL
    }

    static private let fileManager = FileManager.default

    static private var downloadQueue: OperationQueue = {
        // Use utility-level serial queue for download operations
        let queue = OperationQueue()
        queue.name = "co.neeva.app.ios.browser.BloomFilterLoader"
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    static private var defaultSession: URLSession = {
        return URLSession(configuration: .default, delegate: nil, delegateQueue: downloadQueue)
    }()

    static private var restrictedSession: URLSession = {
        // Disable downloading over cellular and restricted networks
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.allowsExpensiveNetworkAccess = false
        config.allowsConstrainedNetworkAccess = false
        config.waitsForConnectivity = true
        return URLSession(configuration: config, delegate: nil, delegateQueue: downloadQueue)
    }()

    static func loadFilter(
        with locations: ResourceLocation, completion: @escaping (LoaderResult) -> Void
    ) {
        // check url validity
        guard locations.binUrl.lastPathComponent.hasSuffix(".bin"),
            locations.checksumURL.lastPathComponent.hasSuffix(".json"),
            locations.saveToURL.isFileURL
        else {
            completion(.failure(LoaderError.invalidInput))
            return
        }

        // get new checksum file from network
        defaultSession.downloadTask(with: locations.checksumURL) { tempURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempURL = tempURL else {
                completion(.failure(LoaderError.downloadedFileNotFound))
                return
            }

            var checksum: Checksum
            @discardableResult
            func verifyAndLoad(from url: URL) throws -> BloomFilter? {
                guard isLocalFileReadble(url: url),
                    try verifyFile(at: url, with: checksum)
                else {
                    return nil
                }

                return try BloomFilter.load(from: url)
            }

            do {
                checksum = try Checksum.load(from: tempURL)
            } catch {
                completion(.failure(error))
                return
            }
            // check if local file matches new checksum
            if let localFilter = try? verifyAndLoad(from: locations.saveToURL) {
                completion(.success(localFilter))
                return
            }

            // Cannot return from current local file. Acquire new one
            restrictedSession.downloadTask(with: locations.binUrl) {
                tempFilterURL, filterResponse, filterError in
                if let error = filterError {
                    completion(.failure(error))
                    return
                }

                guard let tempFilterURL = tempFilterURL else {
                    completion(.failure(LoaderError.downloadedFileNotFound))
                    return
                }

                do {
                    guard let loadedFilter = try verifyAndLoad(from: tempFilterURL)
                    else {
                        throw LoaderError.invalidFilterBinaryFile
                    }

                    do {
                        try moveDownloadedFilter(from: tempFilterURL, to: locations.saveToURL)
                    } catch {
                        Logger.storage.error("Error saving downloaded bloom filter: \(error)")
                    }

                    completion(.success(loadedFilter))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }.resume()
    }

    static private func isLocalFileReadble(url: URL) -> Bool {
        guard url.isFileURL,
            fileManager.fileExists(atPath: url.path),
            fileManager.isReadableFile(atPath: url.path)
        else {
            return false
        }

        return true
    }

    static private func verifyFile(at url: URL, with checksum: Checksum) throws -> Bool {
        let fileHashes = try FileHasher.computeHashOfFile(at: url, using: [.sha256, .md5])
        guard let shaHash = fileHashes[.sha256],
            let md5Hash = fileHashes[.md5],
            shaHash == checksum.sha,
            md5Hash == checksum.md5
        else {
            return false
        }
        return true
    }

    static private func moveDownloadedFilter(from srcURL: URL, to dstURL: URL) throws {
        if fileManager.fileExists(atPath: dstURL.path) {
            try fileManager.removeItem(at: dstURL)
        }

        let dstDirURL = dstURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: dstDirURL.path) {
            try createDirectory(dstDirURL)
        }

        try fileManager.moveItem(at: srcURL, to: dstURL)
    }

    static private func createDirectory(_ url: URL) throws {
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return
            }
            try fileManager.removeItem(at: url)
        }

        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

        do {
            var values = URLResourceValues()
            values.isHidden = true
            values.isExcludedFromBackup = true
            var url = URL(fileURLWithPath: url.path)
            try url.setResourceValues(values)
        } catch {
            Logger.storage.error("Unable to exclude directory from backup: \(error)")
        }

        return
    }
}

// MARK: - FilterResource
private class FilterResource {
    struct Configuration {
        let identifier: String
        let filterURL: URL
        let checksumURL: URL
        var localURL: URL

        static let reddit = Configuration(
            identifier: "reddit",
            filterURL: URL(string: "https://s.neeva.co/web/neevascope/v1/reddit.bin")!,
            checksumURL: URL(string: "https://s.neeva.co/web/neevascope/v1/reddit_latest.json")!,
            localURL: URL(fileURLWithPath: "")
        )
    }

    enum State: CustomStringConvertible {
        case notInitialized
        case loading
        case ready(BloomFilter)
        case error(Error)

        var description: String {
            switch self {
            case .notInitialized:
                return "notInitialized"
            case .loading:
                return "loading"
            case .ready:
                return "ready"
            case .error(let error):
                return "Error: \(error)"
            }
        }
    }

    // MARK: - Private Properteis
    private let identifier: String
    private var state: State = .notInitialized {
        didSet {
            switch state {
            case .ready, .error:
                Defaults[.redditFilterHealth] = state.description
            default:
                break
            }
        }
    }

    private let queue = DispatchQueue(
        label: "co.neeva.app.ios.browser.BloomFilterResource",
        qos: .userInteractive,
        attributes: .concurrent,
        autoreleaseFrequency: .inherit,
        target: nil
    )

    private let filterURL: URL
    private let checksumURL: URL
    private let saveToPath: URL

    var filter: BloomFilter? {
        precondition(!Thread.isMainThread)
        return queue.sync {
            guard case let .ready(filter) = self.state else {
                return nil
            }
            return filter
        }
    }

    init(_ configuration: Configuration) {
        self.identifier = configuration.identifier
        self.filterURL = configuration.filterURL
        self.checksumURL = configuration.checksumURL
        self.saveToPath = configuration.localURL
    }

    func load() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self,
                // read this value again with barrier flag on
                case .notInitialized = self.state
            else {
                return
            }

            self.state = .loading

            BloomFilterLoader.loadFilter(
                with: BloomFilterLoader.ResourceLocation(
                    checksumURL: self.checksumURL,
                    binUrl: self.filterURL,
                    saveToURL: self.saveToPath
                )
            ) { [weak self] result in
                // BloomFilterLoader may call completion handler on some other thread
                // return to the instance's private queue for state mutation
                self?.queue.async(flags: .barrier) {
                    switch result {
                    case .success(let filter):
                        self?.state = .ready(filter)
                    case .failure(let error):
                        self?.state = .error(error)
                        self?.reportError(error)
                    }
                }
            }
        }
        return
    }

    private func reportError(_ error: Error) {
        Logger.browser.error("Error loading bloom filter \(error)")
    }

    fileprivate func reset() {
        queue.async(flags: .barrier) { [weak self] in
            self?.state = .notInitialized
        }
    }
}

class BloomFilterManager {
    static let shared = BloomFilterManager()
    static let subFolderName = "BloomFilter"

    private var redditFiler: FilterResource?

    init() {
        var redditConfig = FilterResource.Configuration.reddit
        if let saveToDirectory = Self.getSaveToDirectory() {
            redditConfig.localURL = saveToDirectory.appendingPathComponent(
                redditConfig.filterURL.lastPathComponent
            )
        }
        redditFiler = FilterResource(redditConfig)
    }

    func contains(_ key: String) -> Bool? {
        guard let filter = redditFiler?.filter else {
            redditFiler?.load()
            return nil
        }

        return filter.mayContain(key: key)
    }

    class func getSaveToDirectory() -> URL? {
        var appSupportDir: URL?
        do {
            appSupportDir = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        } catch {
            Logger.storage.error("Error getting application support directory \(error)")
        }

        return appSupportDir?
            .appendingPathComponent(Self.subFolderName, isDirectory: true)
    }

    @discardableResult
    class func clearSaveToDirectory() -> Bool {
        guard let dirURL = getSaveToDirectory() else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: dirURL)
            return true
        } catch {
            Logger.storage.error("Error removing Bloom Filter save dir: \(error)")
            return false
        }
    }
}
