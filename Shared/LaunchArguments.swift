/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public struct LaunchArguments {
    public static let Test = "NEEVA_TEST"
    public static let PerformanceTest = "NEEVA_PERFORMANCE_TEST"
    public static let SkipIntro = "NEEVA_SKIP_INTRO"
    public static let ReactivateIntro = "REACTIVATE_INTRO"
    public static let SkipWhatsNew = "NEEVA_SKIP_WHATS_NEW"
    public static let SkipETPCoverSheet = "NEEVA_SKIP_ETP_COVER_SHEET"
    public static let ClearProfile = "NEEVA_CLEAR_PROFILE"
    public static let DeviceName = "DEVICE_NAME"
    public static let ServerPort = "GCDWEBSERVER_PORT:"
    public static let SetSignInOnce = "SIGN_IN_ONCE"
    public static let SetDidFirstNavigation = "DID_FIRST_NAVIGATION"
    public static let ForceExperimentControlArm = "FORCE_EXPERIMENT_CONTROL_ARM"
    public static let SkipAdBlockOnboarding = "SKIP_AD_BLOCK_ONBOARDING"

    // After the colon, put the name of the file to load from test bundle
    public static let LoadDatabasePrefix = "NEEVA_LOAD_DB_NAMED:"
    public static let LoadTabsStateArchive = "LOAD_TABS_STATE_ARCHIVE_NAMED:"

    public static let SetLoginCookie = "SET_LOGIN_COOKIE:"
    public static let EnableFeatureFlags = "ENABLE_FEATURE_FLAGS:"
    public static let EnableNeevaFeatureBoolFlags = "ENABLE_NEEV_FEATURE_BOOL_FLAGS:"

    public static let EnableMockAppHost = "ENABLE_MOCK_APP_HOST"
    public static let EnableMockUserInfo = "ENABLE_MOCK_USER_INFO"
    public static let EnableMockSpaces = "ENABLE_MOCK_SPACES"

    public static let DontAddTabOnLaunch = "DONT_ADD_TAB_ON_LAUNCH"

    public static let DisableCheatsheetBloomFilters = "DISABLE_CHEATSHEET_BLOOM_FILTERS"
}
