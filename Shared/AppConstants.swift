/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public enum AppBuildChannel: String {
    case release
    case beta
    case developer
}

public struct AppConstants {
    public static let IsRunningTest =
        NSClassFromString("XCTestCase") != nil
        || ProcessInfo.processInfo.arguments.contains(LaunchArguments.Test)

    public static let IsRunningPerfTest =
        NSClassFromString("XCTestCase") != nil
        || ProcessInfo.processInfo.arguments.contains(LaunchArguments.PerformanceTest)

    /// Build Channel.
    public static let BuildChannel: AppBuildChannel = {
        #if NEEVA_CHANNEL_RELEASE
            return .release
        #elseif NEEVA_CHANNEL_BETA
            return .beta
        #elseif NEEVA_CHANNEL_DEV
            return .developer
        #endif
    }()

    /// Enables support for International Domain Names (IDN)
    /// Disabled because of https://bugzilla.mozilla.org/show_bug.cgi?id=1312294
    public static let MOZ_PUNYCODE: Bool = {
        #if NEEVA_CHANNEL_RELEASE
            return false
        #elseif NEEVA_CHANNEL_BETA
            return false
        #elseif NEEVA_CHANNEL_DEV
            return false
        #else
            return true
        #endif
    }()
}
