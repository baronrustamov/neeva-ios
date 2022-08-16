/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

private let defaultFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter
}()

public enum DateGroupedTableDataSection: String, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case older = "Older"

    /// The order in which the section is displayed in the `HistoryPanelView`.
    public var index: Int {
        // When adding a new case, must implment a method in `numberOfItemsForSection`.
        switch self {
        case .today:
            return 0
        case .yesterday:
            return 1
        case .older:
            return 2
        }
    }
}

public struct DateGroupedTableData<T: Equatable> {
    public struct Section: Hashable {
        private let id = UUID()
        public let dateString: String
        public let data: [T]

        init(dateString: String, data: [T]) {
            self.dateString = dateString
            self.data = data
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id.uuidString)
        }
    }

    var today: [T] = []
    var yesterday: [T] = []
    var older: [String: [T]] = [:]

    public var isEmpty: Bool {
        return today.isEmpty && yesterday.isEmpty && older.isEmpty
    }

    public init() {}

    @discardableResult mutating public func add(_ item: T, date: Date) -> IndexPath {
        if date.isToday() {
            today.append(item)
            return IndexPath(row: today.count - 1, section: 0)
        } else if date.isYesterday() {
            yesterday.append(item)
            return IndexPath(row: yesterday.count - 1, section: 1)
        } else {
            let date = date.formatToString(formatter: defaultFormatter)
            older[date, default: []].append(item)

            return IndexPath(row: older.count - 1, section: 2)
        }
    }

    mutating public func remove(_ item: T) {
        if let index = today.firstIndex(where: { item == $0 }) {
            today.remove(at: index)
        } else if let index = yesterday.firstIndex(where: { item == $0 }) {
            yesterday.remove(at: index)
        } else {
            for key in older.keys {
                if let index = older[key]?.firstIndex(of: item) {
                    older[key]?.remove(at: index)
                    break
                }
            }
        }
    }

    public func numberOfItemsForSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return today.count
        case 1:
            return yesterday.count
        default:
            return older.values.map {
                $0.count
            }.reduce(0, +)
        }
    }

    public func itemsForSection(_ section: DateGroupedTableDataSection) -> [Section] {
        switch section {
        case .today:
            return [
                Section(
                    dateString: Date.getDate(dayOffset: 0).formatToString(
                        formatter: defaultFormatter), data: today.map({ $0 })
                )
            ]
        case .yesterday:
            return [
                Section(
                    dateString: Date.getDate(dayOffset: -1).formatToString(
                        formatter: defaultFormatter),
                    data: yesterday.map({ $0 }))
            ]
        case .older:
            let other = older.sorted {
                Date.getDate(from: $0.key, formatter: defaultFormatter)! > Date.getDate(
                    from: $1.key, formatter: defaultFormatter)!
            }
            return other.map { Section(dateString: $0.key, data: $0.value) }
        }
    }
}
