/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

extension Array where Element: Any {
    /// Checks if an item exists at an index before attempting to read it.
    /// If element does not exists, returns nil.
    public subscript(safeIndex index: Int) -> Element? {
        if self.indices.contains(index) {
            return self[index]
        }

        return nil
    }

    /// Finds the item before the passed index. If it does not exist, returns nil.
    public func previousItem(before index: Int) -> Element? {
        let index = index - 1
        if indices.contains(index) {
            return self[index]
        }

        return nil
    }

    /// Finds the item after the passed index. If it does not exist, returns nil.
    public func nextItem(after index: Int) -> Element? {
        let index = index + 1
        if indices.contains(index) {
            return self[index]
        }

        return nil
    }
}

extension Array where Element: Equatable {
    /// Returns this array, with all duplicate elements removed
    public func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        return result
    }

    /// Finds the item before the passed item. If the passed item or the previous item does not exist, returns nil.
    public func previousItem(before item: Element) -> Element? {
        guard let itemIndex = firstIndex(of: item) else { return nil }
        return previousItem(before: itemIndex)
    }

    /// Finds the item after the passed item. If the passed item or the next item does not exist, returns nil.
    public func nextItem(after item: Element) -> Element? {
        guard let itemIndex = firstIndex(of: item) else { return nil }
        return nextItem(after: itemIndex)
    }
}

extension ArraySlice {
    /// Convert an `ArraySlice` to an `Array`.
    /// Useful in a chaining context.
    public func toArray() -> [Element] {
        Array(self)
    }
}

extension Array {
    public mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
