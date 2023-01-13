// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import Storage

protocol GenericTab: Identifiable {
    var url: URL? { get }  // TODO: Make this non-optional
    var displayTitle: String { get }
    var lastExecutedTime: Timestamp { get }
    var isPinned: Bool { get }
    var tabUUID: String { get }

    /// All tabs with the same `rootUUID` are considered part of the same group.
    var rootUUID: String { get }
    var parentSpaceID: String? { get }
}

func shouldBeArchived(basedOn lastExecutedTime: Timestamp) -> Bool {
    func isIncluded(in section: TabSection) -> Bool {
        section.includes(isPinned: false, lastExecutedTime: lastExecutedTime)
    }

    switch Defaults[.archivedTabsDuration] {
    case .week:
        return
            !(isIncluded(in: .today)
            || isIncluded(in: .yesterday)
            || isIncluded(in: .lastWeek))
    case .month:
        return
            !(isIncluded(in: .today)
            || isIncluded(in: .yesterday)
            || isIncluded(in: .lastWeek)
            || isIncluded(in: .lastMonth))
    case .forever:
        return false
    }
}
