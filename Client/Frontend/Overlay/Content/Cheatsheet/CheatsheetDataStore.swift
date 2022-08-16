// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

//MARK: - Interface
private protocol Expirable {
    var hasExpired: Bool { get }
}

private protocol DateProvider {
    associatedtype DateType: Expirable

    func getDeadline(in time: TimeInterval) -> DateType
}

final private class TimeIntervalDeadlineProvider: DateProvider {
    fileprivate struct TimeIntervalDeadline: Expirable {
        let deadline: TimeInterval

        var hasExpired: Bool {
            Date().timeIntervalSince1970 >= deadline
        }
    }

    fileprivate func getDeadline(in time: TimeInterval) -> TimeIntervalDeadline {
        let deadline = Date().timeIntervalSince1970 + time
        return TimeIntervalDeadline(deadline: deadline)
    }
}

// MARK: - Time Based Cache
/// NSCache wrapper with time to live checks
final private class TTLCache<Key: Hashable, Value, D: DateProvider> {
    fileprivate enum Budget {
        case count(Int)
        case cost(Int)
    }

    private let cache = NSCache<WrappedKey, WrappedObject>()
    private let dateProvider: D
    // Setting this parameter will not change the TTL of objects already in the cache
    var defaultEntryLifeTime: TimeInterval

    init(
        dateProvider: D,
        defaultLifeTime: TimeInterval,
        budget: Budget? = nil
    ) {
        self.dateProvider = dateProvider
        self.defaultEntryLifeTime = defaultLifeTime

        if let budget = budget {
            switch budget {
            case .count(let count):
                cache.countLimit = count
            case .cost(let cost):
                cache.totalCostLimit = cost
            }
        }
    }

    func insert(_ value: Value, for key: Key, expiringIn timeInterval: TimeInterval? = nil) {
        let ttl = timeInterval ?? defaultEntryLifeTime

        let deadline = dateProvider.getDeadline(in: ttl)
        cache.setObject(
            WrappedObject(value: value, deadline: deadline),
            forKey: WrappedKey(key)
        )
    }

    func value(for key: Key) -> Value? {
        guard let object = cache.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard !object.deadline.hasExpired else {
            object.value = nil
            return nil
        }

        return object.value
    }

    func removeValue(for key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }
}

extension TTLCache {
    fileprivate final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }

    fileprivate final class WrappedObject: NSDiscardableContent {
        var value: Value?
        let deadline: D.DateType

        var accessCount: Int = 0

        init(value: Value, deadline: D.DateType) {
            self.value = value
            self.deadline = deadline
        }

        // Conformance to NSDiscardableContent
        func beginContentAccess() -> Bool {
            guard let value = value else {
                return false
            }

            // Passdown call if available
            guard let object = value as? NSDiscardableContent else {
                accessCount += 1
                return true
            }

            if object.beginContentAccess() {
                accessCount += 1
                return true
            } else {
                return false
            }
        }

        func endContentAccess() {
            // Passdown call if available
            if let object = value as? NSDiscardableContent {
                object.endContentAccess()
            }

            if accessCount != 0 {
                accessCount -= 1
            }
        }

        func discardContentIfPossible() {
            // Passdown call if available
            if let object = value as? NSDiscardableContent {
                object.discardContentIfPossible()
            }

            if accessCount == 0 {
                value = nil
            }
        }

        func isContentDiscarded() -> Bool {
            guard let value = value else {
                return true
            }

            // Passdown call if available
            if let object = value as? NSDiscardableContent {
                return object.isContentDiscarded()
            } else {
                return false
            }
        }
    }
}

// MARK: - Data Store Class
public class CheatsheetDataStore {
    private struct InfoParams: Hashable {
        let url: String
        let title: String
    }

    private struct SearchParams: Hashable {
        let query: String
    }

    // MARK: - Static Properties
    // count of info results to cache
    static let infoBudget: Int = 15
    // count of search results to cache
    static let searchBudget: Int = 15

    // MARK: - Private Properties
    private let infoCache: TTLCache<InfoParams, CheatsheetInfo, TimeIntervalDeadlineProvider>
    private let searchCache: TTLCache<SearchParams, SearchResult, TimeIntervalDeadlineProvider>

    // MARK: - Init
    public init(
        infoTTL: TimeInterval,
        searchTTL: TimeInterval
    ) {
        precondition(infoTTL > 0 && searchTTL > 0)
        self.infoCache = TTLCache(
            dateProvider: TimeIntervalDeadlineProvider(),
            defaultLifeTime: infoTTL,
            budget: .count(Self.infoBudget)
        )
        self.searchCache = TTLCache(
            dateProvider: TimeIntervalDeadlineProvider(),
            defaultLifeTime: searchTTL,
            budget: .count(Self.searchBudget)
        )
    }

    // MARK: - Public Methods
    func getCheatsheetInfo(
        url: String,
        title: String
    ) -> CheatsheetInfo? {
        let key = InfoParams(url: url, title: title)
        return infoCache.value(for: key)
    }

    func insertCheatsheetInfo(
        _ cheatsheetInfo: CheatsheetInfo,
        url: String,
        title: String
    ) {
        let key = InfoParams(url: url, title: title)
        infoCache.insert(cheatsheetInfo, for: key)
    }

    func getRichResult(query: String) -> SearchResult? {
        return searchCache.value(for: SearchParams(query: query))
    }

    func insertRichResult(_ result: SearchResult, query: String) {
        searchCache.insert(result, for: SearchParams(query: query))
    }
}
