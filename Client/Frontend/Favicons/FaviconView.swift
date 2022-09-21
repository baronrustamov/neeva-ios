// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SDWebImage
import Shared
import Storage
import SwiftUI

class FaviconFetcher: ObservableObject {
    private static let cacheSize = 32  // Tuned for the card grid
    private static let cache: MRUCache<URL, UIImage> = .init(maxEntries: cacheSize)

    private let resolver: FaviconResolver
    private var subscription: AnyCancellable?

    @Published var image: UIImage = FaviconSupport.defaultFavicon
    @Published var backgroundColor = UIColor.clear

    init(with resolver: FaviconResolver) {
        self.resolver = resolver
        self.subscription = self.resolver.$faviconUrl.sink { [weak self] in self?.load(url: $0) }
    }

    static func updateCache(for url: URL, with image: UIImage) {
        cache[url] = image
    }

    private func load(url: URL?) {
        // The url will be null while waiting on the resolver.
        if let url = url {
            if let image = Self.cache[url] {
                self.update(with: (image, .clear))
                return
            }
            // Fetch the image and use fallback content while waiting for it to load.
            SDWebImageManager.shared.loadImage(with: url, options: .init(), progress: nil) {
                (image, _, _, _, _, _) in
                // completed
                if let image = image {
                    Self.cache[url] = image
                    self.update(with: (image, .clear))
                }
            }
        }
        update(with: resolver.fallbackContent)
    }

    private func update(with content: (image: UIImage, color: UIColor)) {
        self.image = content.image
        self.backgroundColor = content.color
    }
}

struct FaviconView: View {
    @ObservedObject private var fetcher: FaviconFetcher

    /// If `site.icon` is not provided, then the `Favicon` to use will be resolved by looking in
    /// the history database for the `Favicon` associated with the `site.url`. If that is not
    /// found, then a fallback favicon will be used.
    init(forSite site: Site) {
        self.init(with: FaviconResolver(site: site))
    }

    // For use when only the `url` of a website is available.
    init(forSiteUrl url: URL) {
        self.init(forSite: Site(url: url))
    }

    // For use when only the `url` of the favicon is available.
    init(forFavicon favicon: Favicon) {
        self.init(with: FaviconResolver(favicon: favicon))
    }

    init(with resolver: FaviconResolver) {
        self.fetcher = FaviconFetcher(with: resolver)
    }

    var body: some View {
        Image(uiImage: fetcher.image)
            .resizable()
            .background(Color(fetcher.backgroundColor))
            .transition(.opacity)
            .scaledToFit()
    }
}
