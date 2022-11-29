/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

class SavedTab: NSObject, NSCoding {
    let isSelected: Bool
    let title: String?
    let url: URL?
    let isIncognito: Bool
    let isPinned: Bool
    let pinnedTime: TimeInterval?
    let lastExecutedTime: Timestamp?
    let sessionData: SessionData?
    let screenshotUUID: UUID?
    let faviconURL: URL?
    let tabUUID: String
    let rootUUID: String
    let parentUUID: String?
    let manuallyArchived: Bool?

    // Used to support undo close tab, so that we can remember where to re-insert
    // the tab upon restore.
    // TODO(darin): A tombstone in the tabs array would be a better approach.
    let tabIndex: Int?

    let parentSpaceID: String?
    let pageZoom: CGFloat?

    init(
        screenshotUUID: UUID?,
        isSelected: Bool,
        title: String?,
        isIncognito: Bool,
        isPinned: Bool,
        pinnedTime: TimeInterval?,
        lastExecutedTime: Timestamp,
        faviconURL: URL?,
        url: URL?,
        sessionData: SessionData?,
        uuid: String,
        rootUUID: String,
        parentUUID: String,
        manuallyArchived: Bool?,
        tabIndex: Int?,
        parentSpaceID: String,
        pageZoom: CGFloat
    ) {
        self.screenshotUUID = screenshotUUID
        self.isSelected = isSelected
        self.title = title
        self.isIncognito = isIncognito
        self.isPinned = isPinned
        self.pinnedTime = pinnedTime
        self.lastExecutedTime = lastExecutedTime
        self.faviconURL = faviconURL
        self.url = url
        self.sessionData = sessionData
        self.tabUUID = uuid
        self.rootUUID = rootUUID
        self.parentUUID = parentUUID
        self.manuallyArchived = manuallyArchived
        self.tabIndex = tabIndex
        self.parentSpaceID = parentSpaceID
        self.pageZoom = pageZoom

        super.init()
    }

    required init(coder: NSCoder) {
        self.sessionData = coder.decodeObject(forKey: "sessionData") as? SessionData
        self.screenshotUUID = coder.decodeObject(forKey: "screenshotUUID") as? UUID
        self.isSelected = coder.decodeBool(forKey: "isSelected")
        self.isPinned = coder.decodeBool(forKey: "isPinned")
        self.pinnedTime = coder.decodeObject(forKey: "pinnedTime") as? TimeInterval
        self.lastExecutedTime = coder.decodeObject(forKey: "lastExecutedTime") as? Timestamp
        self.title = coder.decodeObject(forKey: "title") as? String
        self.isIncognito = coder.decodeBool(forKey: "isPrivate")
        self.faviconURL = (coder.decodeObject(forKey: "faviconURL") as? URL)
        self.url = coder.decodeObject(forKey: "url") as? URL
        self.tabUUID = coder.decodeObject(forKey: "UUID") as? String ?? UUID().uuidString
        self.rootUUID = coder.decodeObject(forKey: "rootUUID") as? String ?? UUID().uuidString
        self.parentUUID = coder.decodeObject(forKey: "parentUUID") as? String
        self.manuallyArchived = coder.decodeObject(forKey: "manuallyArchived") as? Bool
        self.tabIndex = coder.decodeObject(forKey: "tabIndex") as? Int
        self.parentSpaceID = coder.decodeObject(forKey: "parentSpaceID") as? String
        self.pageZoom = coder.decodeObject(forKey: "pageZoom") as? CGFloat
    }

    func encode(with coder: NSCoder) {
        coder.encode(sessionData, forKey: "sessionData")
        coder.encode(screenshotUUID, forKey: "screenshotUUID")
        coder.encode(isSelected, forKey: "isSelected")
        coder.encode(isPinned, forKey: "isPinned")
        coder.encode(pinnedTime, forKey: "pinnedTime")
        coder.encode(lastExecutedTime, forKey: "lastExecutedTime")
        coder.encode(title, forKey: "title")
        coder.encode(isIncognito, forKey: "isPrivate")
        coder.encode(faviconURL, forKey: "faviconURL")
        coder.encode(url, forKey: "url")
        coder.encode(tabUUID, forKey: "UUID")
        coder.encode(rootUUID, forKey: "rootUUID")
        coder.encode(parentUUID, forKey: "parentUUID")
        coder.encode(manuallyArchived, forKey: "manuallyArchived")
        coder.encode(tabIndex, forKey: "tabIndex")
        coder.encode(parentSpaceID, forKey: "parentSpaceID")
        coder.encode(pageZoom, forKey: "pageZoom")
    }
}
