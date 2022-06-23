//
//  URLExtensions.swift
//  Client
//
//  Created by Burak Üstün on 31.03.2022.
//  Copyright © 2022 Neeva. All rights reserved.
//

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

    public var isImage: Bool {
        return pathExtension == "jpeg"
            || pathExtension == "jpg"
            || pathExtension == "png"
            || pathExtension == "gif"
    }
}
