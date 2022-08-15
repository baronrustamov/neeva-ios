/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit

// A small structure to encapsulate all the possible data that we can get
// from an application sharing a web page or a URL.
public struct ShareItem {
    public var url: String
    public var title: String?
    public var description: String?
    public var favicon: Favicon?

    public init(url: String, title: String?, description: String? = nil, favicon: Favicon?) {
        self.url = url
        self.title = title
        self.favicon = favicon
        self.description = description
    }
}
