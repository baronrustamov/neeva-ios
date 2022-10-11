// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared

enum ArchivedTabRow: Equatable {
    case tab(ArchivedTab)
    case tabGroup(ArchivedTabGroup)

    var lastExcecutedTime: Timestamp {
        switch self {
        case .tab(let tab):
            return tab.lastExecutedTime
        case .tabGroup(let group):
            return group.lastExecutedTime
        }
    }

    var id: String {
        switch self {
        case .tab(let tab):
            return tab.id
        case .tabGroup(let group):
            return group.id
        }
    }

    var isTabGroup: Bool {
        switch self {
        case .tab(_):
            return false
        case .tabGroup(_):
            return true
        }
    }

    static func == (lhs: ArchivedTabRow, rhs: ArchivedTabRow) -> Bool {
        switch (lhs, rhs) {
        case (.tab(let tabLhs), .tab(let tabRhs)):
            return tabLhs.id == tabRhs.id
        case (.tabGroup(let groupLhs), .tabGroup(let groupRhs)):
            return groupLhs.id == groupRhs.id
        default:
            return false
        }
    }
}
