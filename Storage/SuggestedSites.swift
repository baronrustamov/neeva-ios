/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit

open class SuggestedSite: Site {
    override open var tileURL: URL {
        url
    }

    init(data: SuggestedSiteData) {
        super.init(url: data.url, title: data.title)
        // A guid is required in the case the site might become a pinned site
        self.guid = "default" + data.title
        if let faviconURL = URL(string: data.faviconUrl) {
            self.icon = Favicon(url: faviconURL)
        }
    }
}

open class SuggestedSitesCursor: ArrayCursor<SuggestedSite> {
    public init(identifier: String = "default") {
        let locale = Locale.current
        let sites =
            DefaultSuggestedSites.sites[locale.identifier] ?? DefaultSuggestedSites.sites[
                identifier]! as [SuggestedSiteData]
        let tiles = sites.map({ data -> SuggestedSite in
            var site = data
            if let domainMap = DefaultSuggestedSites.urlMap[data.url],
                let localizedURL = domainMap[locale.identifier]
            {
                site.url = localizedURL
            }
            return SuggestedSite(data: site)
        })
        super.init(data: tiles, status: .success, statusMessage: "Loaded")
    }
}

struct SuggestedSiteData {
    var url: URL
    var bgColor: String
    var imageUrl: String
    var faviconUrl: String
    var trackingId: Int
    var title: String
}
