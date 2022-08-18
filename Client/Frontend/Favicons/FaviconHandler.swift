/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SDWebImage
import Shared
import Storage

private let maximumFaviconSize = 1 * 1024 * 1024  // 1 MiB file size limit

class FaviconError: MaybeErrorType {
    internal var description: String {
        return "No Image Loaded"
    }
}

class FaviconHandler {
    init() {
        register(self, forTabEvents: .didLoadPageMetadata, .pageMetadataNotAvailable)
    }

    func loadFaviconURL(_ faviconURL: String, forTab tab: Tab) -> Deferred<Maybe<(Favicon, Data?)>>
    {
        guard let iconURL = URL(string: faviconURL), let currentURL = tab.url else {
            return deferMaybe(FaviconError())
        }

        let deferred = Deferred<Maybe<(Favicon, Data?)>>()
        let manager = SDWebImageManager.shared
        let site = Site(url: currentURL, title: "")
        let options: SDWebImageOptions =
            tab.isIncognito
            ? [SDWebImageOptions.lowPriority, SDWebImageOptions.fromCacheOnly]
            : SDWebImageOptions.lowPriority

        var fetch: SDWebImageOperation?

        let onProgress: SDWebImageDownloaderProgressBlock = {
            (receivedSize, expectedSize, _) -> Void in
            if receivedSize > maximumFaviconSize || expectedSize > maximumFaviconSize {
                fetch?.cancel()
            }
        }

        let onSuccess: (Favicon, Data?) -> Void = { [weak tab] (favicon, data) -> Void in
            tab?.favicon = favicon

            guard !(tab?.isIncognito ?? true) else {
                deferred.fill(Maybe(success: (favicon, data)))
                return
            }

            getAppDelegate().profile.favicons.addFavicon(favicon, forSite: site) >>> {
                deferred.fill(Maybe(success: (favicon, data)))
            }
            FaviconResolver.updateCache(for: site, with: favicon)
        }

        let onCompletedSiteFavicon: SDInternalCompletionBlock = {
            (img, data, _, _, _, url) -> Void in
            guard let url = url else {
                deferred.fill(Maybe(failure: FaviconError()))
                return
            }

            let favicon = Favicon(url: url, date: Date())

            guard let img = img else {
                // The download failed, but we still want to remember this as the icon URL for the
                // site. We'll try loading it again later.
                favicon.width = 0
                favicon.height = 0

                onSuccess(favicon, data)
                return
            }

            favicon.width = Int(img.size.width)
            favicon.height = Int(img.size.height)

            onSuccess(favicon, data)
        }

        let onCompletedPageFavicon: SDInternalCompletionBlock = {
            (img, data, _, _, _, url) -> Void in
            guard let img = img, let url = url else {
                // If we failed to download a page-level icon, try getting the domain-level icon
                // instead before ultimately failing.
                let siteIconURL = currentURL.domainURL.appendingPathComponent("favicon.ico")
                fetch = manager.loadImage(
                    with: siteIconURL, options: options, progress: onProgress,
                    completed: onCompletedSiteFavicon)

                return
            }

            let favicon = Favicon(url: url, date: Date())
            favicon.width = Int(img.size.width)
            favicon.height = Int(img.size.height)

            onSuccess(favicon, data)
        }

        fetch = manager.loadImage(
            with: iconURL, options: options, progress: onProgress, completed: onCompletedPageFavicon
        )
        return deferred
    }
}

extension FaviconHandler: TabEventHandler {
    func tab(_ tab: Tab, didLoadPageMetadata metadata: PageMetadata) {
        tab.favicon = nil
        guard let faviconURL = metadata.faviconURL else {
            return
        }

        loadFaviconURL(faviconURL, forTab: tab).uponQueue(.main) { result in
            guard let (favicon, data) = result.successValue else { return }
            TabEvent.post(.didLoadFavicon(favicon, with: data), for: tab)
        }
    }
    func tabMetadataNotAvailable(_ tab: Tab) {
        tab.favicon = nil
    }
}
