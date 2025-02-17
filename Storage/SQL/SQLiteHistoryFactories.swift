/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

/*
 * Factory methods for converting rows from SQLite into model objects
 */
extension SQLiteHistory {
    class func basicHistoryColumnFactory(_ row: SDRow) -> Site? {
        let id = row["historyID"] as? Int

        guard
            let url = row["url"] as? String,
            let title = row["title"] as? String,
            let guid = row["guid"] as? String,
            let url = URL(string: url)
        else {
            return nil
        }

        let site = Site(url: url, title: title)
        site.guid = guid
        site.id = id

        // Find the most recent visit, regardless of which column it might be in.
        let local = row.getTimestamp("localVisitDate") ?? 0
        let remote = row.getTimestamp("remoteVisitDate") ?? 0
        let either = row.getTimestamp("visitDate") ?? 0

        let latest = max(local, remote, either)
        if latest > 0 {
            site.latestVisit = Visit(date: latest, type: VisitType.unknown)
        }

        return site
    }

    class func iconColumnFactory(_ row: SDRow) -> Favicon? {
        if let iconURL = (row["iconURL"] as? String)?.asURL,
            let iconDate = row["iconDate"] as? Double,
            let _ = row["iconID"] as? Int
        {
            let date = Date(timeIntervalSince1970: iconDate)
            return Favicon(url: iconURL, date: date)
        }
        return nil
    }

    class func pageMetadataColumnFactory(_ row: SDRow) -> PageMetadata? {
        guard let siteURL = (row["url"] as? String)?.asURL else {
            return nil
        }

        return PageMetadata(
            id: row["metadata_id"] as? Int, siteURL: siteURL, mediaURL: row["media_url"] as? String,
            title: row["metadata_title"] as? String, description: row["description"] as? String,
            type: row["type"] as? String, providerName: row["provider_name"] as? String)
    }

    class func iconHistoryColumnFactory(_ row: SDRow) -> Site? {
        let site = basicHistoryColumnFactory(row)
        site?.icon = iconColumnFactory(row)
        return site
    }

    class func iconHistoryMetadataColumnFactory(_ row: SDRow) -> Site? {
        let site = iconHistoryColumnFactory(row)
        site?.metadata = pageMetadataColumnFactory(row)
        return site
    }

    class func basicHistoryMetadataColumnFactory(_ row: SDRow) -> Site? {
        let site = basicHistoryColumnFactory(row)
        site?.metadata = pageMetadataColumnFactory(row)
        return site
    }
}
