// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

extension URL {
    public func isNeevaURL() -> Bool {
        return
            (self.scheme == NeevaConstants.appHomeURL.scheme
            && self.host == NeevaConstants.appHomeURL.host) || self.host == "login.neeva.com"
    }

    /// Checks if the current URL is for the Neeva Search Results Page
    public func isNeevaSearchResultsPageURL() -> Bool {
        return isNeevaURL() && path == "/search"
    }
}
