// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation

/// Usage: add a `case` to this enum, then reference `FeatureFlag[.myFeature]` to check for that feature’s status.
public enum FeatureFlag: String, CaseIterable, RawRepresentable {
    // IMPORTANT: when adding a new feature flag, make sure to keep this list
    // in alphabetical order to reduce merge conflicts and keep the settings screen
    // simple to scan.
    case cardStrip = "Card Strip"
    case cookieCutterRemindMeLater = "Cookie Cutter Remind Me Later"
    case customSearchEngine = "Custom Search Engine"
    case debugURLBar = "URL Bar Debug Mode"
    case enableSuggestedSpaces = "Show Spaces from Neeva Community"
    case hoverEffects = "Enable Hover Effects"
    case incognitoQuickClose = "Incognito Quick Close"
    case inlineAccountSettings = "Inline Account Settings"
    case interactiveScrollView = "Interactive Scroll View"
    case newWeb3Features = "New Web3 Features"
    case oldDBFirstRun = "Old Default Browser Interstitial"
    case openZeroQueryAfterLongDuration = "Open Zero Query After Inactive Duration"
    case pinnedTabImprovments = "Pin Tab Improvments"
    case pinnnedTabSection = "Pinned Tab Section"
    case pinToTopSites = "Pin to Top Sites"
    case qrCodeSignIn = "Sign in with QR Code"
    case recommendedSpaces = "Recommended Spaces"
    case spaceComments = "Comments from space on pages"
    case spacify = "Enable button to turn a page into a Space"
    case swipePlusPlus = "Additional forward and back swipe gestures"
    case swipeToCloseTabs = "Swipe to close tabs"

    public init?(caseName: String) {
        for value in FeatureFlag.allCases where "\(value)" == caseName {
            self = value
            return
        }

        return nil
    }
}

extension FeatureFlag {
    public static let defaultsKey = Defaults.Key<Set<String>>(
        "neevaFeatureFlags", default: [], suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)

    public static var enabledFlags: Set<FeatureFlag> = {
        let names = Defaults[Self.defaultsKey]
        let flags = names.compactMap(FeatureFlag.init(rawValue:))
        Defaults[Self.defaultsKey] = Set(flags.map(\.rawValue))
        return Set(flags)
    }()

    public static subscript(flag: FeatureFlag) -> Bool {
        Self.enabledFlags.contains(flag)
    }
}
