// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension Strings {
    public struct FirstRun {

        public struct Welcome {
            public static let TitleString = NSLocalizedString(
                "FirstRun.Welcome.Title", tableName: "NeevaStrings",
                value: "Privacy Made Easy", comment: "Title displayed when user opens the app the first time")

            public static let TitleStringExp = NSLocalizedString(
                "FirstRun.Welcome.Title.Arm1", tableName: "NeevaStrings",
                value: "Neeva puts you in charge of\nyour life online.", comment: "[Experiment] Another title displayed when user opens the app the first time")

            public static let PrimaryButtonString = NSLocalizedString(
                "Let's go", tableName: "NeevaStrings", value: "Let's go",
                comment: "Button text on welcome screen")

            public static let FirstBullet = NSLocalizedString(
                "FirstRun.Welcome.FirstBullet", tableName: "NeevaStrings", value: "Ad-Free Search",
                comment: "First bullet in the list to promote Neeva's value on welcome screen")

            public static let SecondBullet = NSLocalizedString(
                "FirstRun.Welcome.SecondBullet", tableName: "NeevaStrings",
                value: "Block Ads. Block Trackers", comment: "Second bullet in the list to promote Neeva's value on welcome screen")

            public static let ThirdBullet = NSLocalizedString(
                "FirstRun.Welcome.ThirdBullet", tableName: "NeevaStrings",
                value: "Block Cookie Pop-ups", comment: "Third bullet in the list to promote Neeva's value on welcome screen")

            public static let FirstBulletExp = NSLocalizedString(
                "FirstRun.Welcome.FirstBullet.Arm1", tableName: "NeevaStrings",
                value: "Ad-free search results", comment: "[Experiment] First bullet in the list to promote Neeva's value on welcome screen")

            public static let SecondBulletExp = NSLocalizedString(
                "FirstRun.Welcome.SecondBullet.Arm1", tableName: "NeevaStrings",
                value: "Browser without ads or trackers", comment: "[Experiment] Second bullet in the list to promote Neeva's value on welcome screen")

            public static let ThirdBulletExp = NSLocalizedString(
                "FirstRun.Welcome.ThirdBullet.Arm1", tableName: "NeevaStrings",
                value: "Cookie pop-up blocker", comment: "[Experiment] Third bullet in the list to promote Neeva's value on welcome screen")
        }

        public struct Onboarding {
            public static let TitleString = NSLocalizedString(
                "FirstRun.Onboarding.Title", tableName: "NeevaStrings",
                value: "Make Neeva your Default Browser to", comment: "Title displayed on setting default browser screen")

            public static let FirstBullet = NSLocalizedString(
                "FirstRun.Onboarding.FirstBullet", tableName: "NeevaStrings",
                value: "Browse the Web Ad-Free", comment: "")

            public static let SecondBullet = NSLocalizedString(
                "FirstRun.Onboarding.SecondBullet", tableName: "NeevaStrings",
                value: "Block Trackers, and Pop-ups", comment: "")

            public static let FollowSteps = NSLocalizedString(
                "FirstRun.Onboarding.FollowSteps", tableName: "NeevaStrings",
                value: "Follow these 2 easy steps:", comment: "")

            public static let FirstStep = NSLocalizedString(
                "FirstRun.Onboarding.FirstStep", tableName: "NeevaStrings",
                value: "1. Tap Default Browser App", comment: "")

            public static let SecondStep = NSLocalizedString(
                "FirstRun.Onboarding.SecondStep", tableName: "NeevaStrings",
                value: "2. Select Neeva", comment: "")

            public static let TitleStringExp = NSLocalizedString(
                "FirstRun.Onboarding.Title.Arm1", tableName: "NeevaStrings",
                value: "Want to use\nNeeva for all your browsing?", comment: "")

            public static let SubtitleStringExp = NSLocalizedString(
                "FirstRun.Onboarding.Subtitle.Arm1", tableName: "NeevaStrings",
                value: "Make Neeva your default browser.", comment: "")

            public static let RemindMeLater = NSLocalizedString(
                "Remind Me Later", tableName: "NeevaStrings",
                value: "Remind Me Later", comment: "")

            public static let OpenNeevaSettings = NSLocalizedString(
                "Open Neeva Settings", tableName: "NeevaStrings",
                value: "Open Neeva Settings", comment: "")

            public static let ContinueToNeeva = NSLocalizedString(
                "Continue to Neeva", tableName: "NeevaStrings",
                value: "Continue to Neeva", comment: "")

            public static let BackToSettings = NSLocalizedString(
                "Back to Settings", tableName: "NeevaStrings",
                value: "Back to Settings", comment: "")
        }
    }
}
