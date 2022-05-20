/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Shared
import WebKit

extension Defaults.Keys {
    // TODO: migrate to a new naming without dot so publisher/observer work
    static let contentBlockingEnabled = Defaults.Key<Bool>(
        "profile.prefkey.trackingprotection.normalbrowsing", default: true)
}

enum BlockingStrength: String, Codable, CaseIterable, Identifiable {
    case easyPrivacy
    case easyPrivacyStrict

    var id: String { self.rawValue }

    var name: String {
        switch self {
        case .easyPrivacy:
            return "Standard"
        case .easyPrivacyStrict:
            return "Strict"
        }
    }

    var description: String {
        switch self {
        case .easyPrivacy:
            return "Blocks many trackers. Minimizes disruption to ads and other funtionality."
        case .easyPrivacyStrict:
            return "Blocks more trackers. May break ads and other functionlity on some sites."
        }
    }
}

/// Neeva-specific implementation of tab content blocking.
class NeevaTabContentBlocker: TabContentBlocker, TabContentScript {
    class func name() -> String {
        return "TrackingProtectionStats"
    }

    // A cache of page stats used to support showing stats for pages loaded
    // out of WebKit's page cache. Note, this cache is stored on a per-Tab
    // object rather than globally so that it will be naturally pruned as
    // tabs are closed. And there is no need to persist this cache.
    var pageStatsCache: [URL: TPPageStats] = [:]

    override var isEnabled: Bool {
        Defaults[.contentBlockingEnabled] && Defaults[.cookieCutterEnabled]
    }

    override init(tab: ContentBlockerTab) {
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        var strength: BlockingStrength = .easyPrivacy
        if NeevaConstants.currentTarget == .xyz {
            strength = .easyPrivacyStrict
        } else {
            if let strEnum = BlockingStrength(rawValue: Defaults[.contentBlockingStrength]) {
                strength = strEnum
            }
        }

        let rules = BlocklistFileName.listsForMode(strength: strength)
        ContentBlocker.shared.setupTrackingProtection(
            forTab: tab, isEnabled: isEnabled, rules: rules)
    }

    @objc override func notifiedTabSetupRequired() {
        setupForTab()

        if let tab = tab as? Tab {
            TabEvent.post(.didChangeContentBlocking, for: tab)
        }
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension NeevaTabContentBlocker {
    static func isTrackingProtectionEnabled() -> Bool {
        Defaults[.contentBlockingEnabled]
    }
}
