// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Storage

class Web3SuggestedSitesViewModel: SuggestedSitesViewModel {
    public init() {
        let opensea = Site(url: "https://opensea.io", title: "Open Sea", id: 900)
        opensea.icon = Favicon(url: "https://opensea.io/static/images/favicon/180x180.png")
        let foundation = Site(url: "https://foundation.app", title: "Foundation", id: 901)
        foundation.icon = Favicon(url: "https://foundation.app/apple-touch-icon.png")
        let superrare = Site(url: "https://superrare.com", title: "Super Rare", id: 902)
        superrare.icon = Favicon(url: "https://superrare.com/favicon.png")
        let zora = Site(url: "https://zora.co", title: "Zora", id: 903)
        zora.icon = Favicon(url: "https://zora.co/assets/apple-touch-icon.png")
        super.init(sites: [opensea, foundation, superrare, zora])
    }
}
