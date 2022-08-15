// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// An in-memory cache of N most-recently used values.
/// - This cache keeps a strong reference to the inserted keys and values.
/// - This cache does not respond to memory warnings.
/// - This cache is NOT THREAD SAFE!!
public class MRUCache<KeyType: Hashable, ValueType: Any> {
    private class Entry {
        let key: KeyType
        let value: ValueType

        var next: Entry?
        var prev: Entry?

        init(key: KeyType, value: ValueType) {
            self.key = key
            self.value = value
            self.next = nil
            self.prev = nil
        }

        func removeFromList() {
            if let prev = prev {
                prev.next = next
            }
            if let next = next {
                next.prev = prev
            }
            prev = nil
            next = nil
        }
    }

    // Implemented as a map for efficient lookup and a linked list of entries
    // sorted from most recent to least recent.
    private var map: [KeyType: Entry] = [:]
    private var head: Entry?
    private var tail: Entry?  // Evict from here.

    let maxEntries: Int

    var count: Int {
        map.count
    }

    public init(maxEntries: Int) {
        assert(Thread.isMainThread)  // This class is not thread-safe.

        self.maxEntries = maxEntries
    }

    /// Store and retrieve keyed objects from the cache.
    public subscript(key: KeyType) -> ValueType? {
        get {
            fetch(for: key)
        }
        set(newValue) {
            store(for: key, value: newValue)
        }
    }

    private func fetch(for key: KeyType) -> ValueType? {
        assert(Thread.isMainThread)  // This class is not thread-safe.

        guard let entry = map[key] else {
            return nil
        }

        if entry !== head {
            // Bump entry to head
            if entry === tail {
                tail = entry.prev
            }
            entry.removeFromList()
            insertAsHead(entry: entry)
        }

        return entry.value
    }

    private func store(for key: KeyType, value: ValueType?) {
        assert(Thread.isMainThread)  // This class is not thread-safe.

        // Remove any existing entry
        if let entry = map[key] {
            if entry === head {
                head = entry.next
            }
            if entry === tail {
                tail = entry.prev
            }
            entry.removeFromList()
            map[key] = nil
        }

        guard let value = value else {
            return
        }

        let entry = Entry(key: key, value: value)
        map[key] = entry
        insertAsHead(entry: entry)
        if tail == nil {
            tail = entry
        }

        // Remove from tail if we have too many entries.
        if map.count > maxEntries {
            let doomed = tail!
            tail = doomed.prev
            doomed.removeFromList()
            map[doomed.key] = nil
        }
    }

    private func insertAsHead(entry: Entry) {
        assert(entry.next == nil)
        assert(entry.prev == nil)

        entry.next = head
        if let head = head {
            head.prev = entry
        }
        head = entry
    }
}
