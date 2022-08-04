/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Defaults

extension ContentBlocker {
    // Get the safelist domain array as a JSON fragment that can be inserted at the end of a blocklist.
    func safelistAsJSON() -> String {
        if Defaults[.unblockedDomains].isEmpty {
            return ""
        }
        // Note that * is added to the front of domains, so foo.com becomes *foo.com
        let list = "'*" + Defaults[.unblockedDomains].joined(separator: "','*") + "'"
        return ", {'action': { 'type': 'ignore-previous-rules' }, 'trigger': { 'url-filter': '.*', 'if-domain': [\(list)] }}".replacingOccurrences(of: "'", with: "\"")
    }

    func clearSafelist(completion: (() -> Void)?) {
        Defaults[.unblockedDomains] = Set<String>()
        completion?()
    }

    // Ensure domains used for safelisting are standardized by using this function.
    func safelistableDomain(fromUrl url: URL) -> String? {
        guard let domain = url.host, !domain.isEmpty else {
            return nil
        }
        return domain
    }

    func isSafelisted(url: URL) -> Bool {
        guard let domain = safelistableDomain(fromUrl: url) else {
            return false
        }

        return TrackingPreventionConfig.trackersAllowedFor(domain)
    }
}
