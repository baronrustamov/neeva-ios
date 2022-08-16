/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import CoreSpotlight
import Defaults
import Foundation
import SDWebImage
import Shared
import Storage
import WebKit

private let searchableIndex = CSSearchableIndex(name: "neeva")

class UserActivityHandler {
    static let browsingActivityType: String = "co.neeva.app.ios.browser.browsing"

    init() {
        register(
            self,
            forTabEvents: .didClose, .didLoseFocus, .didGainFocus, .didChangeURL,
            .didLoadPageMetadata, .pageMetadataNotAvailable
        )  // .didLoadFavicon, // TODO: Bug 1390294
    }

    class func clearSearchIndex(completionHandler: ((Error?) -> Void)? = nil) {
        searchableIndex.deleteAllSearchableItems(completionHandler: completionHandler)
    }

    class func clearIndexedItems(completionHandler: @escaping (() -> Void) = {}) {
        NSUserActivity.deleteAllSavedUserActivities(completionHandler: completionHandler)
    }

    fileprivate func setUserActivityForTab(_ tab: Tab) {
        guard Defaults[.createUserActivities],
            let url = tab.pageMetadata?.siteURL ?? tab.webView?.url,
            !tab.isIncognito,
            url.isWebPage(includeDataURIs: false),
            !InternalURL.isValid(url: url)
        else {
            tab.userActivity?.resignCurrent()
            tab.userActivity = nil
            return
        }

        tab.userActivity?.invalidate()

        // Create user activity for browsing a webpage
        let userActivity = NSUserActivity(activityType: Self.browsingActivityType)
        userActivity.title = tab.title
        // Indicate activity should be added to spotlight index
        userActivity.isEligibleForSearch = Defaults[.makeActivityAvailForSearch]
        // Carry url payload instead of using webpageURL in case neeva app is not DB
        userActivity.requiredUserInfoKeys = ["url"]
        userActivity.userInfo = ["url": url.absoluteString]
        // we can set userActivity.keywords = [String] to specify additional queries with which this item can be found in spotlight

        // create rich attributes for spotlight card in place of NSUserActivity properties
        let attributes = CSSearchableItemAttributeSet(contentType: .item)
        attributes.title = tab.pageMetadata?.title ?? tab.title
        attributes.contentDescription = tab.pageMetadata?.description
        attributes.weakRelatedUniqueIdentifier = url.absoluteString

        // Fetch favicon
        if #unavailable(iOS 15),
            Defaults[.addThumbnailToActivities]
        {
            if let faviconURLString = tab.pageMetadata?.faviconURL,
                let faviconURL = URL(string: faviconURLString)
            {
                // we get this data now in case it changes later
                let favicon = tab.favicon
                // Give FaviconHandler time to fetch so we can hopefully hit cache here
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    // isIncognito must be false from the guard statement at the top
                    UserActivityHandler.getFavicon(
                        for: url, faviconURL: faviconURL, isIncognito: false
                    ) { image in
                        let resolvedImage =
                            image
                            ?? UserActivityHandler.getFallbackFavicon(for: url, favicon: favicon)

                        attributes.thumbnailData = resolvedImage.pngData()
                        userActivity.contentAttributeSet = attributes
                        userActivity.needsSave = true

                        Defaults[.numOfThumbnailsForUserActivity] += 1
                    }
                }
            } else {
                attributes.thumbnailData = UserActivityHandler.getFallbackFavicon(
                    for: url, favicon: nil
                ).pngData()

                Defaults[.numOfThumbnailsForUserActivity] += 1
            }
        }

        userActivity.contentAttributeSet = attributes
        userActivity.needsSave = true

        // Set activity as active and makes it available for indexing (if isEligibleForSearch)
        userActivity.becomeCurrent()
        if Defaults[.makeActivityAvailForSearch] {
            Defaults[.numOfIndexedUserActivities] += 1
        }

        tab.userActivity = userActivity
    }

    class func presentTextSizeView(tab: Tab) {
        let bvc = SceneDelegate.getBVC(for: tab.webView)
        bvc.showAsModalOverlaySheet(style: .grouped) {
            TextSizeView(
                model: TextSizeModel(tab: tab)
            ) {
                bvc.overlayManager.hideCurrentOverlay(ofPriority: .modal)
            }
        } onDismiss: {
        }
    }
}

extension UserActivityHandler {
    class func getFavicon(
        for siteURL: URL, faviconURL: URL, isIncognito: Bool,
        completion: @escaping (UIImage?) -> Void
    ) {
        let manager = SDWebImageManager.shared
        let options: SDWebImageOptions =
            isIncognito
            ? [SDWebImageOptions.lowPriority, SDWebImageOptions.fromCacheOnly]
            : SDWebImageOptions.lowPriority

        let onCompletedPageFavicon: SDInternalCompletionBlock = {
            (img, _, _, _, _, _) -> Void in
            if let img = img {
                completion(img)
            } else {
                let siteIconURL = siteURL.domainURL.appendingPathComponent("favicon.ico")
                manager.loadImage(
                    with: siteIconURL,
                    options: options,
                    progress: nil
                ) { (img, _, _, _, _, _) -> Void in
                    completion(img)
                }
            }
            return
        }

        manager.loadImage(
            with: faviconURL,
            options: options,
            progress: nil,
            completed: onCompletedPageFavicon
        )
    }

    class func getFallbackFavicon(for siteURL: URL, favicon: Favicon?) -> UIImage {
        let site = Site(url: siteURL)
        site.icon = favicon
        let resolver = FaviconResolver(site: site)
        return resolver.fallbackContent.image
    }
}

extension UserActivityHandler: TabEventHandler {
    func tabDidGainFocus(_ tab: Tab) {
        tab.userActivity?.becomeCurrent()
    }

    func tabDidLoseFocus(_ tab: Tab) {
        tab.userActivity?.resignCurrent()
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        // We do not need to register user activity here
        // MetadataParserHelper observes didChangeURL and fires pageMetadataNotAvailable or didLoadPageMetadata
    }

    func tab(_ tab: Tab, didLoadPageMetadata metadata: PageMetadata) {
        setUserActivityForTab(tab)
    }

    func tabMetadataNotAvailable(_ tab: Tab) {
        setUserActivityForTab(tab)
    }

    func tabDidClose(_ tab: Tab) {
        guard let userActivity = tab.userActivity else {
            return
        }
        tab.userActivity = nil
        userActivity.invalidate()
    }
}
