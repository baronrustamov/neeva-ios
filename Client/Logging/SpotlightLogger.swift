// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

class SpotlightLogger {
    static let shared = SpotlightLogger()

    init() {
        // This logger always gets initialized
        // Force enable Spotlight integration
        if Defaults[.overwriteSpotlightDefaults] {
            Defaults[.createUserActivities] = true
            Defaults[.makeActivityAvailForSearch] = true
            Defaults[.addThumbnailToActivities] = true
            Defaults[.addSpacesToCS] = true
            Defaults[.addSpaceURLsToCS] = true
            Defaults[.overwriteSpotlightDefaults] = false
        }
    }
}

extension SpotlightLogger: SpaceStoreSpotlightEventDelegate {
    func willIndex(_ spaces: [Space]) {
        Defaults[.numOfWillIndexEvents] += 1
    }

    func willIndexEntities(for space: Space, count: Int) {
        Defaults[.numOfWillIndexEvents] += 1
    }

    func didIndex(_ spaces: [Space], error: Error?) {
        Defaults[.numOfDidIndexEvents] += 1
    }

    func didIndexEntities(for space: Space, error: Error?) {
        Defaults[.numOfDidIndexEvents] += 1
    }

    func willClearIndex(for domainIdentifier: String) {
        return
    }

    func didFailClearIndex(for domainIdentifier: String, error: Error) {
        let itemType: LogConfig.SpotlightAttribute.ItemType
        switch domainIdentifier {
        case SpaceStore.CSConst.spaceDomainIdentifier:
            itemType = .space
        case SpaceStore.CSConst.spacePageDomainIdentifier:
            itemType = .spaceEntity
        default:
            itemType = .all
        }
        ClientLogger.shared.logCounter(
            .clearIndexError,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.error,
                    value: error.localizedDescription),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.itemType,
                    value: itemType.rawValue),
            ]
        )
    }
}
