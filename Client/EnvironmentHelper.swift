// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

public class EnvironmentHelper {
    public static let shared = EnvironmentHelper()

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

    public func getAttributes() -> [ClientLogCounterAttribute] {
        var numOfNormalTabs = 0
        var numOfIncognitoTabs = 0
        TabManager.all.forEach { tabManager in
            numOfNormalTabs += tabManager.normalTabs.count
            numOfIncognitoTabs += tabManager.incognitoTabs.count
        }

        var numOfChildTabs = 0
        var numOfTabGroups = 0
        TabManager.all.forEach { tabManager in
            // In the future, we may also want to log archived tab groups.
            numOfTabGroups += tabManager.activeTabGroups.count
            numOfChildTabs += tabManager.childTabs.count
        }

        // number of normal tabs opened
        let normalTabsOpened = ClientLogCounterAttribute(
            key: LogConfig.Attribute.NormalTabsOpened,
            value: String(numOfNormalTabs))

        // number of incognito tabs opened
        let incongitoTabsOpened = ClientLogCounterAttribute(
            key: LogConfig.Attribute.IncognitoTabsOpened,
            value: String(numOfIncognitoTabs))

        // number of tab groups
        let numTabGroupsTotal = ClientLogCounterAttribute(
            key: LogConfig.Attribute.numTabGroupsTotal,
            value: String(numOfTabGroups)
        )

        // number of tabs inside tab groups
        let numChildTabsTotal = ClientLogCounterAttribute(
            key: LogConfig.Attribute.numChildTabsTotal,
            value: String(numOfChildTabs)
        )

        // user theme setting
        let deviceTheme = ClientLogCounterAttribute(
            key: LogConfig.Attribute.UserInterfaceStyle, value: self.themeStyle)

        // orientation
        let deviceOrientation = ClientLogCounterAttribute(
            key: LogConfig.Attribute.DeviceOrientation, value: self.orientation)

        // screensize
        let deviceScreensSize = ClientLogCounterAttribute(
            key: LogConfig.Attribute.DeviceScreenSize, value: self.screenSize)

        // is user signed in
        let isUserSignedIn = ClientLogCounterAttribute(
            key: LogConfig.Attribute.isUserSignedIn,
            value: String(NeevaUserInfo.shared.hasLoginCookie()))

        let attributes = [
            normalTabsOpened, incongitoTabsOpened, numTabGroupsTotal, numChildTabsTotal,
            deviceTheme, deviceOrientation, deviceScreensSize,
            isUserSignedIn, getSessionUUID(),
        ]

        return attributes
    }

    public func getFirstRunAttributes() -> [ClientLogCounterAttribute] {
        // is user signed in
        let isUserSignedIn = ClientLogCounterAttribute(
            key: LogConfig.Attribute.isUserSignedIn,
            value: String(NeevaUserInfo.shared.hasLoginCookie()))

        // user theme setting
        let deviceTheme = ClientLogCounterAttribute(
            key: LogConfig.Attribute.UserInterfaceStyle, value: self.themeStyle)

        // device name
        let deviceName = ClientLogCounterAttribute(
            key: LogConfig.Attribute.DeviceName, value: NeevaConstants.deviceNameValue)

        // first run path, option user selected on first run screen
        let firstRunPath = ClientLogCounterAttribute(
            key: LogConfig.Attribute.FirstRunPath, value: Defaults[.firstRunPath])

        // count of preview mode query
        let previewQueryCount = ClientLogCounterAttribute(
            key: LogConfig.Attribute.PreviewModeQueryCount,
            value: String(Defaults[.previewModeQueries].count))

        let attributes = [
            getSessionUUID(), isUserSignedIn, deviceTheme, deviceName, firstRunPath,
            previewQueryCount,
        ]

        return attributes
    }

    public func getSessionUUID() -> ClientLogCounterAttribute {
        // Rotate session UUID every 30 mins
        if Defaults[.sessionUUIDExpirationTime].minutesFromNow() > 30 {
            Defaults[.sessionUUID] = UUID().uuidString
            Defaults[.sessionUUIDExpirationTime] = Date()
        }

        // session UUID that will rotate every 30 mins
        return ClientLogCounterAttribute(
            key: LogConfig.Attribute.SessionUUID, value: Defaults[.sessionUUID])
    }

    public func getSessionUUIDv2() -> ClientLogCounterAttribute {
        // session UUID that will rotate every 30 mins
        return ClientLogCounterAttribute(
            key: LogConfig.Attribute.SessionUUIDv2, value: Defaults[.sessionUUIDv2])
    }
}
