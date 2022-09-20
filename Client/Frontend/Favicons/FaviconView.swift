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

    @Published var image: UIImage?
    @Published var backgroundColor = UIColor.clear

    init(with resolver: FaviconResolver) {
        self.resolver = resolver
        self.subscription = self.resolver.$faviconUrl.sink { [weak self] in
            if let url = $0 {
                self?.load(url: url)
            }
        }
    }

    static func updateCache(for url: URL, with image: UIImage) {
        cache[url] = image
    }

    private func load(url: URL) {
        if let image = Self.cache[url] {
            update(image: image, backgroundColor: .clear)
        } else {
            // Fetch the image
            SDWebImageManager.shared.loadImage(with: url, options: .init(), progress: nil) {
                (image, _, _, _, _, _) in
                // completed
                if let image = image {
                    Self.cache[url] = image
                    self.update(image: image, backgroundColor: .clear)
                }
            }

            let fallbackContent = resolver.fallbackContent
            update(image: fallbackContent.image, backgroundColor: fallbackContent.color)
        }
    }

    private func update(image: UIImage, backgroundColor: UIColor) {
        self.image = image
        self.backgroundColor = backgroundColor
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
        if let image = fetcher.image {
            Image(uiImage: image)
                .resizable()
                .background(Color(fetcher.backgroundColor))
                .transition(.opacity)
                .scaledToFit()
        } else {
            Color.blue
        }
    }
}
