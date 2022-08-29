/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import Shared
import Storage
import UIKit
import WidgetKit

struct TopSitesHandler {
    private static func siteKey(_ site: Site) -> String? {
        site.url.normalizedHost
    }

    static func getTopSites(profile: Profile) -> Deferred<[Site]> {
        let maxItems = UIDevice.current.useTabletInterface ? 32 : 16
        return profile.history.getTopSitesWithLimit(maxItems).both(
            profile.history.getPinnedTopSites()
        ).bindQueue(.main) { (topsites, pinnedSites) in

            let deferred = Deferred<[Site]>()

            guard let mySites = topsites.successValue?.asArray().compactMap({ $0 }),
                let pinned = pinnedSites.successValue?.asArray().compactMap({ $0 })
            else {
                return deferred
            }

            // Fetch the default sites
            let defaultSites = defaultTopSites()

            var mergedSites = mySites
            var seenSites = Set(mergedSites.map(siteKey(_:)))
            for site in defaultSites {
                let key = siteKey(site)
                if !seenSites.contains(key) {
                    seenSites.insert(key)
                    mergedSites.append(site)
                }
            }

            // Prevent duplication with neeva home, searches and spaces
            mergedSites = mergedSites.filter { !$0.url.isNeevaURL() }

            let allSites: [Site]
            if FeatureFlag[.pinToTopSites] {
                // create PinnedSite objects. used by the view layer to tell topsites apart
                let pinnedSites: [Site] = pinned.map(PinnedSite.init(site:))
                let pinnedKeys = Set(pinnedSites.map(siteKey(_:)))
                // no need to update pinnedKeys since mergedSites is already deduplicated
                allSites = pinnedSites + mergedSites.filter { !pinnedKeys.contains(siteKey($0)) }
            } else {
                allSites = mergedSites
            }

            // Favor top sites from defaultSites as they have better favicons. But keep PinnedSites.
            let newSites = allSites.map { site -> Site in
                if let _ = site as? PinnedSite {
                    return site
                }
                let domain = site.url.shortDisplayString
                return defaultSites.first { $0.title.lowercased() == domain } ?? site
            }

            deferred.fill(newSites)

            return deferred
        }
    }

    static func writeWidgetKitTopSites(profile: Profile) {
        TopSitesHandler.getTopSites(profile: profile).uponQueue(.main) { result in
            var widgetkitTopSites = [WidgetKitTopSiteModel]()
            result.forEach { site in
                // Favicon icon url
                let iconUrl = site.icon?.url.absoluteString ?? ""
                let imageKey = site.tileURL.baseDomain ?? ""
                widgetkitTopSites.append(
                    WidgetKitTopSiteModel(
                        title: site.title, faviconUrl: iconUrl, url: site.url, imageKey: imageKey))
                // fetch favicons and cache them on disk
                FaviconSupport.downloadFaviconAndCache(
                    imageURL: !iconUrl.isEmpty ? URL(string: iconUrl) : nil, imageKey: imageKey)
            }
            // save top sites for widgetkit use
            WidgetKitTopSiteModel.save(widgetKitTopSites: widgetkitTopSites)
            // Update widget timeline
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static private let suggestedSites = SuggestedSitesCursor(identifier: "default")

    static func defaultTopSites() -> [Site] {
        let suggested = suggestedSites.asArray()
        let deleted = Defaults[.deletedSuggestedSites]
        return suggested.filter { !deleted.contains($0.url.absoluteString) }
    }
}

open class PinnedSite: Site {
    let isPinnedSite = true

    init(site: Site) {
        super.init(url: site.url, title: site.title)
        self.icon = site.icon
        self.metadata = site.metadata
    }
}
