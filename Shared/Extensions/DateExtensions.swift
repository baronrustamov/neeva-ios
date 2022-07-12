// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension Date {
    static public func getDate(dayOffset: Int) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let today = calendar.date(from: components)!
        return calendar.date(byAdding: .day, value: dayOffset, to: today)!
    }

    // MARK: - Format
    /// Formats the `Date` to user facing `String`.
    /// - Parameters:
    ///     - format: How the `Date` should be written.
    ///         - Default format: Wednesday, July 1
    ///         - Examples: https://stackoverflow.com/questions/35700281/date-format-in-swift
    public func formatToString(formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }

    public static func getDate(from string: String, formatter: DateFormatter) -> Date? {
        return formatter.date(from: string)
    }
}
