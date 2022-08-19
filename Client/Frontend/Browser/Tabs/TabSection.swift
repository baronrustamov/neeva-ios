// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

public enum TabSection: String, CaseIterable {
    case all = "All"
    case pinned = "Pinned"
    case today = "Today"
    case yesterday = "Yesterday"
    case lastWeek = "Past 7 Days"
    case lastMonth = "Past 30 Days"
    case overAMonth = "Older"

    func includes(isPinned: Bool, lastExecutedTime: Timestamp) -> Bool {
        // lastExecutedTime is passed in milliseconds, needs to be converted to seconds.
        let lastExecutedTimeSeconds = lastExecutedTime / 1000
        let dateLastExecutedTime = Date(
            timeIntervalSince1970: TimeInterval(lastExecutedTimeSeconds))

        // If someone sets their device clock forward and then
        // back, this prevents them from losing tabs.
        let isExecutedTimeAFutureDate = dateLastExecutedTime.daysFromToday() < 0

        if isPinned {
            switch self {
            case .all, .pinned:
                return true
            default:
                return false
            }
        } else {
            switch self {
            case .all:
                return true
            case .pinned:
                return false
            case .today:
                return dateLastExecutedTime.isToday() || isExecutedTimeAFutureDate
            case .yesterday:
                return dateLastExecutedTime.isYesterday()
            case .lastWeek:
                return dateLastExecutedTime.isWithinLast7Days()
                    && !(dateLastExecutedTime.isToday() || dateLastExecutedTime.isYesterday())
            case .lastMonth:
                return !dateLastExecutedTime.isWithinLast7Days()
                    && dateLastExecutedTime.isWithinLastMonth()
            case .overAMonth:
                return !dateLastExecutedTime.isWithinLastMonth()
            }
        }
    }
}
