/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SDWebImage
import Shared
import Storage
import WebKit
import XCGLogger

private let log = Logger.browser

private func fixUpMetadata(_ dict: [String: Any]?, for tab: Tab) -> [String: Any]? {
    // Workaround for Issue #678: The favicon for a non-HTML document (e.g., PDF) can
    // only be the site favicon.
    // See https://github.com/mozilla/page-metadata-parser/issues/120 for the better fix.
    if tab.temporaryDocument != nil {
        var copy = dict
        if let pageURLString = copy?[MetadataKeys.pageURL.rawValue] as? String,
            let pageURL = URL(string: pageURLString)
        {
            copy?[MetadataKeys.favicon.rawValue] =
                pageURL.domainURL.appendingPathComponent("favicon.ico").absoluteString
        }
        return copy
    } else {
        return dict
    }
}

class MetadataParserHelper: TabEventHandler {
    init() {
        register(self, forTabEvents: .didChangeURL)
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        // Get the metadata out of the page-metadata-parser, and into a type safe struct as soon
        // as possible.
        guard let webView = tab.webView,
            let url = webView.url, url.isWebPage(includeDataURIs: false),
            !InternalURL.isValid(url: url)
        else {
            TabEvent.post(.pageMetadataNotAvailable, for: tab)
            tab.pageMetadata = nil
            return
        }
        webView.evaluateJavascriptInDefaultContentWorld(
            "__firefox__.metadata && __firefox__.metadata.getMetadata()"
        ) { result, error in
            guard error == nil else {
                TabEvent.post(.pageMetadataNotAvailable, for: tab)
                tab.pageMetadata = nil
                return
            }

            guard let dict = fixUpMetadata(result as? [String: Any], for: tab),
                let pageURL = tab.url?.displayURL,
                let pageMetadata = PageMetadata.fromDictionary(dict)
            else {
                log.debug("Page contains no metadata!")
                TabEvent.post(.pageMetadataNotAvailable, for: tab)
                tab.pageMetadata = nil
                return
            }

            tab.pageMetadata = pageMetadata
            TabEvent.post(.didLoadPageMetadata(pageMetadata), for: tab)

            let userInfo: [String: Any] = [
                "isPrivate": tab.isIncognito,
                "pageMetadata": pageMetadata,
                "tabURL": pageURL,
            ]
            NotificationCenter.default.post(
                name: .OnPageMetadataFetched, object: nil, userInfo: userInfo)
        }
    }
}

class MediaImageLoader: TabEventHandler {
    init() {
        register(self, forTabEvents: .didLoadPageMetadata)
    }

    func tab(_ tab: Tab, didLoadPageMetadata metadata: PageMetadata) {
        if let urlString = metadata.mediaURL,
            let mediaURL = URL(string: urlString)
        {
            prepareCache(mediaURL)
        }
    }

    fileprivate func prepareCache(_ url: URL) {
        let manager = SDWebImageManager.shared
        if manager.cacheKey(for: url) == nil {
            self.downloadAndCache(fromURL: url)
        }
    }

    fileprivate func downloadAndCache(fromURL webUrl: URL) {
        let manager = SDWebImageManager.shared
        manager.loadImage(with: webUrl, options: .continueInBackground, progress: nil) {
            (image, _, _, _, _, _) in
            if let image = image {
                self.cache(image: image, forURL: webUrl)
            }
        }
    }

    fileprivate func cache(image: UIImage, forURL url: URL) {
        SDImageCache.shared.storeImageData(toDisk: image.sd_imageData(), forKey: url.absoluteString)
    }
}
