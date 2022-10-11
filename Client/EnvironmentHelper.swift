// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

class EnvironmentHelper {
    static let shared = EnvironmentHelper()

    enum Category: Int, RawRepresentable, Hashable, CaseIterable {
        case deviceName
        case deviceOrientation
        case deviceScreenSize
        case deviceTheme
        case firstRunPath
        case isUserSignedIn
        case previewQueryCount
        case tabs
        case tabGroups
        case deviceOS

        static let firstRun: Categories = [
            .isUserSignedIn,
            .deviceTheme,
            .deviceName,
            .deviceOS,
            .firstRunPath,
            .previewQueryCount,
        ]
    }
    typealias Categories = Set<Category>

    var env: ClientLogEnvironment {
        #if DEBUG
            return ClientLogEnvironment(rawValue: "Dev")!
        #else
            return ClientLogEnvironment(rawValue: "Prod")!
        #endif
    }

    var themeStyle: String {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        default:
            return "Unknown"
        }
    }

    var orientation: String {
        switch UIDevice.current.orientation {
        case .unknown:
            return "Unknown"
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "PortraitUpsideDown"
        case .landscapeLeft:
            return "LandscapeLeft"
        case .landscapeRight:
            return "LandscapeRight"
        case .faceUp:
            return "FaceUp"
        case .faceDown:
            return "FaceDown"
        default:
            return "Unknown"
        }
    }

    var screenSize: String {
        return "\(UIScreen.main.bounds.width) x \(UIScreen.main.bounds.height)"
    }

    // MARK: - Public Methods
    func getAttributes(
        for categories: Categories = [
            .tabs, .tabGroups, .deviceTheme, .deviceOrientation, .deviceScreenSize, .isUserSignedIn,
            .deviceOS,
        ]
    ) -> [ClientLogCounterAttribute] {
        categories.flatMap { getAttributes(category: $0) }
    }

    func getFirstRunAttributes() -> [ClientLogCounterAttribute] {
        getAttributes(for: Category.firstRun)
    }

    // MARK: - Private Methods
    private func getAttributes(category: Category) -> [ClientLogCounterAttribute] {
        switch category {
        case .tabs:
            return getAttributesForTabCounts()
        case .tabGroups:
            return getAttributesForTabGroups()
        case .isUserSignedIn:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.isUserSignedIn,
                    value: String(NeevaUserInfo.shared.hasLoginCookie())
                )
            ]
        case .deviceTheme:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.UserInterfaceStyle, value: self.themeStyle
                )
            ]
        case .deviceName:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.DeviceName, value: NeevaConstants.deviceNameValue
                )
            ]
        case .deviceOS:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.DeviceOS, value: UIDevice.current.systemVersion
                )
            ]
        case .deviceOrientation:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.DeviceOrientation, value: self.orientation
                )
            ]
        case .deviceScreenSize:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.DeviceScreenSize, value: self.screenSize
                )
            ]
        case .firstRunPath:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.FirstRunPath, value: Defaults[.firstRunPath]
                )
            ]
        case .previewQueryCount:
            return [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.PreviewModeQueryCount,
                    value: String(Defaults[.previewModeQueries].count)
                )
            ]
        }
    }

    private func getAttributesForTabCounts() -> [ClientLogCounterAttribute] {
        // number of normal tabs opened
        var numOfNormalTabs = 0
        // number of incognito tabs opened
        var numOfIncognitoTabs = 0
        // number of archived tabs
        var numOfArchivedTabs = 0
        TabManager.all.forEach { tabManager in
            numOfNormalTabs += tabManager.activeNormalTabs.count
            numOfIncognitoTabs += tabManager.incognitoTabs.count
            numOfArchivedTabs += tabManager.archivedTabs.count
        }

        let normalTabsOpened = ClientLogCounterAttribute(
            key: LogConfig.Attribute.NormalTabsOpened,
            value: String(numOfNormalTabs)
        )
        let incongitoTabsOpened = ClientLogCounterAttribute(
            key: LogConfig.Attribute.IncognitoTabsOpened,
            value: String(numOfIncognitoTabs)
        )
        let numArchivedTabsTotal = ClientLogCounterAttribute(
            key: LogConfig.Attribute.NumberOfArchivedTabsTotal, value: String(numOfArchivedTabs)
        )

        return [normalTabsOpened, incongitoTabsOpened, numArchivedTabsTotal]
    }

    private func getAttributesForTabGroups() -> [ClientLogCounterAttribute] {
        // number of tabs inside tab groups
        var numOfChildTabs = 0
        // number of tab groups
        var numOfTabGroups = 0
        TabManager.all.forEach { tabManager in
            // In the future, we may also want to log archived tab groups.
            numOfTabGroups += tabManager.activeTabGroups.count
            numOfChildTabs += tabManager.activeTabGroups.values.map(\.children.count).reduce(0, +)
        }

        let numTabGroupsTotal = ClientLogCounterAttribute(
            key: LogConfig.Attribute.numTabGroupsTotal,
            value: String(numOfTabGroups)
        )
        let numChildTabsTotal = ClientLogCounterAttribute(
            key: LogConfig.Attribute.numChildTabsTotal,
            value: String(numOfChildTabs)
        )

        return [numTabGroupsTotal, numChildTabsTotal]
    }
}
