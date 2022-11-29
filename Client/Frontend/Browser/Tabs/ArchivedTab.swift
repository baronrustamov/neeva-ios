// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage

class ArchivedTab: NSObject {
    let savedTab: SavedTab

    init(savedTab: SavedTab) {
        self.savedTab = savedTab
    }
}

extension ArchivedTab: GenericTab {
    var id: String { tabUUID }
    var url: URL? { savedTab.url ?? savedTab.sessionData?.currentUrl }
    var displayTitle: String { savedTab.title ?? "" }
    var lastExecutedTime: Timestamp { savedTab.lastExecutedTime ?? 0 }
    var tabUUID: String { savedTab.tabUUID }
    var rootUUID: String { savedTab.rootUUID }
    var isPinned: Bool { false }  // Cannot be pinned
    var parentSpaceID: String? { nil }  // Cannot have a parent
    var manuallyArchived: Bool { savedTab.manuallyArchived ?? false }
}
