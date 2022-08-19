// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

struct GenericTabGroup<TabType: GenericTab> {
    var children: [TabType]
    var id: String
    var lastExecutedTime: Timestamp {
        children.map { $0.lastExecutedTime }.max()
            ?? Date.nowMilliseconds()
    }

    var hasPinnedChild: Bool {
        children.contains { $0.isPinned }
    }

    var displayTitle: String {
        title ?? inferredTitle ?? "\(children.count) Tabs"
    }

    var title: String? {
        Defaults[.tabGroupNames][id] ?? children.first?.displayTitle
    }

    var inferredTitle: String? {
        if let spaceID = children.first?.parentSpaceID, spaceID == children.first?.rootUUID {
            if let spaceTitle = SpaceStore.shared.get(for: spaceID)?.displayTitle {
                return spaceTitle
            } else if NeevaConstants.currentTarget == .xyz && spaceID == Defaults[.cryptoPublicKey]
            {
                return "Your NFTs"
            }
        }
        return children.first?.displayTitle
    }

    func isIncluded(in tabSection: TabSection) -> Bool {
        return tabSection.includes(isPinned: hasPinnedChild, lastExecutedTime: lastExecutedTime)
    }
}

typealias TabGroup = GenericTabGroup<Tab>
typealias ArchivedTabGroup = GenericTabGroup<ArchivedTab>
