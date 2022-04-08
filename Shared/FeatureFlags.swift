// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation

/// Usage: add a `case` to this enum, then reference `FeatureFlag[.myFeature]` to check for that feature’s status.
public enum FeatureFlag: String, CaseIterable, RawRepresentable {
    // IMPORTANT: when adding a new feature flag, make sure to keep this list
    // in alphabetical order to reduce merge conflicts.

    case bottomURLBar = "Bottom URL Bar"
    case cardStrip = "Carousel of cards instead of tab strip"
    case topCardStrip = "Top Card Strip"
    case debugURLBar = "URL Bar Debug Mode"
    case dragAndDropTabs = "Drag and drop tabs in tab switcher"
    case inlineAccountSettings = "Inline Account Settings"
    case newTrackingProtectionSettings = "New Tracking Protection Settings"
    case pinToTopSites = "Pin to Top Sites"
    case recommendedSpaces = "Recommended Spaces"
    case reverseChronologicalOrdering = "Sort tabs based on reverse chronological ordering"
    case spaceComments = "Comments from space on pages"
    case spacify = "Enable button to turn a page into a Space"
    case swipePlusPlus = "Additional forward and back swipe gestures"
    case enableSuggestedSpaces = "Show Spaces from Neeva Community"
    case showNFTsInWallet = "Show NFTs in Wallet"
    case customSearchEngine = "Custom Search Engine"
    case swipeToCloseTabs = "Swipe to close tabs"
    case cookieCutter = "Cookie Cutter"
    case swiftUIHistory = "SwiftUI History"

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
