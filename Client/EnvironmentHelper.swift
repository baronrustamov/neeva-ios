// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

public class EnvironmentHelper {
    public static let shared = EnvironmentHelper()

    public enum Category: Int, RawRepresentable, Hashable, CaseIterable {
        case deviceName
        case deviceOrientation
        case deviceScreenSize
        case deviceTheme
        case firstRunPath
        case isUserSignedIn
        case previewQueryCount
        case tabs
        case tabGroups

        static let firstRun: Categories = [
            .isUserSignedIn,
            .deviceTheme,
            .deviceName,
            .firstRunPath,
            .previewQueryCount,
        ]
    }
    public typealias Categories = Set<Category>

    public var env: ClientLogEnvironment {
        #if DEBUG
            return ClientLogEnvironment(rawValue: "Dev")!
        #else
            return ClientLogEnvironment(rawValue: "Prod")!
        #endif
    }

    public var themeStyle: String {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        default:
            return "Unknown"
        }
    }

    public var orientation: String {
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

    public var screenSize: String {
        return "\(UIScreen.main.bounds.width) x \(UIScreen.main.bounds.height)"
    }

    // MARK: - Public Methods
    public func getAttributes(
        for categories: Categories = [
            .tabs, .tabGroups, .deviceTheme, .deviceOrientation, .deviceScreenSize, .isUserSignedIn,
        ]
    ) -> [ClientLogCounterAttribute] {
        categories.flatMap { getAttributes(category: $0) } + [getSessionUUID()]
    }

    public func getFirstRunAttributes() -> [ClientLogCounterAttribute] {
        getAttributes(for: Category.firstRun)
    }

    public func getSessionUUID() -> ClientLogCounterAttribute {
        // Rotate session UUID every 30 mins
        if Defaults[.sessionUUIDExpirationTime].minutesFromNow() > 30 {
            Defaults[.sessionUUID] = UUID().uuidString
            Defaults[.sessionUUIDExpirationTime] = Date()
        }

        // session UUID that will rotate every 30 mins
        return ClientLogCounterAttribute(
            key: LogConfig.Attribute.SessionUUID, value: Defaults[.sessionUUID]
        )
    }

    public func getSessionUUIDv2() -> ClientLogCounterAttribute {
        return ClientLogCounterAttribute(
            key: LogConfig.Attribute.SessionUUIDv2, value: Defaults[.sessionUUIDv2]
        )
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
            numOfNormalTabs += tabManager.normalTabs.count
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
            numOfChildTabs += tabManager.childTabs.count
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
