// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/* First Run */
extension Strings {
    public static let FirstRunWelcomeTitle = NSLocalizedString(
        "FirstRun.Welcome.Title", tableName: "NeevaStrings", bundle: Bundle(for: BundleClass.self),
        value: "Privacy Made Easy",
        comment: "Title displayed when user opens the app the first time")

    public static let FirstRunWelcomeTitleStringExp = NSLocalizedString(
        "FirstRun.Welcome.Title.Arm1", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Neeva puts you in charge of\nyour life online.",
        comment:
            "[Experiment] Another title displayed when user opens the app the first time")

    public static let FirstRunWelcomeFirstBullet = NSLocalizedString(
        "FirstRun.Welcome.FirstBullet", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Ad-Free Search",
        comment: "First bullet in the list to promote Neeva's value on welcome screen")

    public static let FirstRunWelcomeSecondBullet = NSLocalizedString(
        "FirstRun.Welcome.SecondBullet", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Block Ads. Block Trackers",
        comment: "Second bullet in the list to promote Neeva's value on welcome screen")

    public static let FirstRunWelcomeThirdBullet = NSLocalizedString(
        "FirstRun.Welcome.ThirdBullet", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Block Cookie Pop-ups",
        comment: "Third bullet in the list to promote Neeva's value on welcome screen")

    public static let FirstRunWelcomeFirstBulletExp = NSLocalizedString(
        "FirstRun.Welcome.FirstBullet.Arm1", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Ad-free search results",
        comment:
            "[Experiment] First bullet in the list to promote Neeva's value on welcome screen"
    )

    public static let FirstRunWelcomeSecondBulletExp = NSLocalizedString(
        "FirstRun.Welcome.SecondBullet.Arm1", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Browser without ads or trackers",
        comment:
            "[Experiment] Second bullet in the list to promote Neeva's value on welcome screen"
    )

    public static let FirstRunWelcomeThirdBulletExp = NSLocalizedString(
        "FirstRun.Welcome.ThirdBullet.Arm1", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Cookie pop-up blocker",
        comment:
            "[Experiment] Third bullet in the list to promote Neeva's value on welcome screen"
    )
}

/* Config Default Browser */
extension Strings {
    public static let ConfigDefaultBrowserTitle = NSLocalizedString(
        "FirstRun.Onboarding.Title", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Make Neeva your Default Browser to",
        comment: "Title displayed on setting default browser screen")

    public static let ConfigDefaultBrowserFirstBullet = NSLocalizedString(
        "FirstRun.Onboarding.FirstBullet", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Browse the Web Ad-Free", comment: "")

    public static let ConfigDefaultBrowserSecondBullet = NSLocalizedString(
        "FirstRun.Onboarding.SecondBullet", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Block Trackers, and Pop-ups", comment: "")

    public static let ConfigDefaultBrowserFollowSteps = NSLocalizedString(
        "FirstRun.Onboarding.FollowSteps", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Follow these 2 easy steps:", comment: "")

    public static let ConfigDefaultBrowserFirstStep = NSLocalizedString(
        "FirstRun.Onboarding.FirstStep", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "1. Tap Default Browser App", comment: "")

    public static let ConfigDefaultBrowserSecondStep = NSLocalizedString(
        "FirstRun.Onboarding.SecondStep", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "2. Select Neeva", comment: "")

    public static let ConfigDefaultBrowserTitleExp = NSLocalizedString(
        "FirstRun.Onboarding.Title.Arm1", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Want to use\nNeeva for all your browsing?", comment: "")

    public static let ConfigDefaultBrowserSubtitleExp = NSLocalizedString(
        "FirstRun.Onboarding.Subtitle.Arm1", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Make Neeva your default browser.", comment: "")
}

/* General */
extension Strings {
    public static let LetsGoButton = NSLocalizedString(
        "FirstRun.Welcome.PrimaryButton", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self), value: "Let's Go",
        comment: "Button text on welcome screen")

    public static let RemindMeLaterButton = NSLocalizedString(
        "FirstRun.Onboarding.RemindMeLater", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Remind Me Later", comment: "")

    public static let OpenNeevaSettingsButton = NSLocalizedString(
        "FirstRun.Onboarding.OpenNeevaSettings", tableName: "NeevaStrings",
        bundle: Bundle(for: BundleClass.self),
        value: "Open Neeva Settings", comment: "")

    public static let ContinueToNeevaButton = NSLocalizedString(
        "ContinueToNeeva", tableName: "NeevaStrings", bundle: Bundle(for: BundleClass.self),
        value: "Continue to Neeva", comment: "")

    public static let BackToSettingsButton = NSLocalizedString(
        "BackToSettings", tableName: "NeevaStrings", bundle: Bundle(for: BundleClass.self),
        value: "Back to Settings", comment: "")
}
