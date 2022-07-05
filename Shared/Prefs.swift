// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI

public enum AppearanceThemeOption: String, Equatable, Encodable, Decodable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    public var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

public enum AppearanceIconOption: String, Equatable, Encodable, Decodable, CaseIterable {
    // these strings map directly to definitions in `/Client/Info.plist`
    case system = "System"
    case black = "Black"

    public var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

// If you add a setting here, make sure it’s either exposed through
// user-visible settings or in InternalSettingsView
//
// TODO(Issue #1209): Migrate all pref names to use "_" in place of "." to
// support Defaults.publisher.
//
extension Defaults.Keys {
    // MARK: - automatically recorded
    public static let searchInputPromptDismissed = Defaults.BoolKey(
        "profile.SearchInputPromptDismissed")
    public static let introSeen = Defaults.BoolKey("profile.IntroViewControllerSeen")
    public static let didFirstNavigation = Defaults.BoolKey("profile_didFirstNavigation")
    public static let lastVersionNumber = Defaults.Key<String?>("profile.KeyLastVersionNumber")
    public static let lastVersionActiveOn = Defaults.Key<String?>("profile.KeyLastVersionActiveOn")
    public static let didDismissReferralPromoCard =
        Defaults.BoolKey("profile.didDismissReferralPromoCard")
    public static let firstRunSeenAndNotSignedIn = Defaults.BoolKey(
        "firstRunSeenAndNotSignedIn")
    public static let signedInOnce = Defaults.BoolKey("signedInOnce")
    public static let firstRunPath = Defaults.Key<String>(
        "firstRunPath", default: "none")
    public static let firstRunImpressionLogged = Defaults.BoolKey(
        "firstRunImpressionLogged")
    public static let sessionUUID = Defaults.Key<String>(
        "sessionUUID", default: "")
    public static let firstSessionUUID = Defaults.Key<String>(
        "firstSessionUUID", default: "")
    public static let sessionUUIDv2 = Defaults.Key<String>(
        "sessionUUIDv2", default: "")
    public static let sessionUUIDExpirationTime = Defaults.Key<Date>(
        "sessionUUIDExpirationTime", default: Date(timeIntervalSince1970: 0))
    public static let lastSessionPrivate = Defaults.BoolKey("wasLastSessionPrivate")

    // MARK: - explicit/implicit settings
    public static let contextMenuShowLinkPreviews = Defaults.Key(
        "profile.ContextMenuShowLinkPreviews", default: true)
    public static let deletedSuggestedSites = Defaults.Key<[String]>(
        "profile.topSites.deletedSuggestedSites", default: [])
    public static let showSearchSuggestions = Defaults.Key(
        "profile.search.suggestions.show", default: true)
    public static let blockPopups = Defaults.Key("profile.blockPopups", default: true)
    public static let closeIncognitoTabs = Defaults.BoolKey("profile.settings.closePrivateTabs")
    public static let recentlyClosedTabs = Defaults.Key<Data?>("profile.recentlyClosedTabs")
    public static let saveLogins = Defaults.BoolKey("profile.saveLogins")
    public static let upgradeAllToHttps = Defaults.BoolKey(
        "profile.tracking_protection.upgradeAllToHttps")
    public static let blockThirdPartyTrackingCookies = Defaults.Key(
        "profile.tracking_protection.blockThirdPartyTrackingCookies", default: true)
    public static let blockThirdPartyTrackingRequests = Defaults.Key(
        "profile.tracking_protection.blockThirdPartyTrackingRequests", default: true)
    public static let unblockedDomains = Defaults.Key<Set<String>>(
        "profile.tracking_protection.unblockedDomains", default: [])
    public static let customSearchEngine = Defaults.Key<String?>("profile_customSearchEngine")
    public static let confirmCloseAllTabs = Defaults.Key(
        "profile.confirmCloseAllTabs", default: true)
    public static let contentBlockingStrength =
        Defaults.Key<String>("contentBlockingStrength", default: "easyPrivacyStrict")
    public static let adBlockEnabled =
        Defaults.Key("adBlockEnabled", default: false)

    // MARK: - appearance app settings
    public static let customizeTheme = Defaults.Key<AppearanceThemeOption?>(
        "appearance_theme", default: .system)
    public static let customizeIcon = Defaults.Key<AppearanceIconOption?>(
        "appearance_icon", default: .system)

    // MARK: - debug settings
    public static let enableAuthLogging = Defaults.BoolKey("profile_enableAuthLogging")
    public static let enableBrowserLogging = Defaults.BoolKey("profile_enableBrowserLogging")
    public static let enableWebKitConsoleLogging = Defaults.BoolKey(
        "profile_enableWebKitConsoleLogging")
    public static let enableNetworkLogging = Defaults.BoolKey("profile_enableNetworkLogging")
    public static let enableStorageLogging = Defaults.BoolKey("profile_enableStorageLogging")
    public static let enableLogToConsole = Defaults.BoolKey("profile_enableLogToConsole")
    public static let enableLogToFile = Defaults.BoolKey("profile_enableLogToFile")
    public static let enableGeigerCounter = Defaults.BoolKey("profile.enableGeigerCounter")

    // MARK: - caches
    public static let topSitesCacheIsValid = Defaults.BoolKey("profile.topSitesCacheIsValid")
    public static let topSitesCacheSize = Defaults.Key<Int32?>("profile.topSitesCacheSize")
    public static let neevaUserInfo = Defaults.Key<[String: String]>("UserInfo", default: [:])

    // MARK: - telemetry
    @available(*, deprecated)  // 2022-05-18
    public static let appExtensionTelemetryOpenUrl = Defaults.Key<Bool?>(
        "profile.AppExtensionTelemetryOpenUrl",
        suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)

    // MARK: - widgets
    public static let widgetKitSimpleTabKey = Defaults.Key<Data?>(
        "WidgetKitSimpleTabKey", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)
    public static let widgetKitSimpleTopTab = Defaults.Key<Data?>(
        "WidgetKitSimpleTopTab", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)

    // MARK: - performance
    public static let applicationCleanlyBackgrounded = Defaults.Key<Bool>(
        "ApplicationCrashedLastTime", default: true)
    public static let pageLoadedCounter = Defaults.Key<Int32>("PageLoadedCounter", default: 0)

    public static let loginLastWeekTimeStamp = Defaults.Key<[Date]>(
        "LoginLastWeekTimeStamp", default: [])
    public static let numberOfAppForeground = Defaults.Key<Int32>(
        "NumberOfAppForeground", default: 0)

    // MARK: - app review
    public static let ratingsCardHidden = Defaults.BoolKey("RatingsCardHidden")
    public static let didTriggerSystemReviewDialog = Defaults.BoolKey(
        "didTriggerSystemReviewDialog")

    public static let notificationToken = Defaults.Key<String?>("notificationToken")

    // MARK: - spaces
    public static let seenSpacesIntro = Defaults.BoolKey("spacesIntroSeen")
    public static let seenSpacesShareIntro = Defaults.BoolKey("spacesShareIntroSeen")
    public static let showDescriptions = Defaults.BoolKey("showSpaceEntityDescription")

    // MARK: - cheatsheet
    public static let seenCheatsheetIntro = Defaults.BoolKey("cheatsheetIntroSeen")
    public static let showTryCheatsheetPopover = Defaults.BoolKey("showTryCheatsheetPopover")
    public static let seenTryCheatsheetPopoverOnRecipe = Defaults.BoolKey(
        "seenTryCheatsheetPopoverOnRecipe")
    public static let cheatsheetDebugQuery = Defaults.BoolKey("cheatsheetDebugQuery")
    public static let showNeevaMenuWillMove = Defaults.BoolKey(
        "showNeevaMenuWillMove", default: true)
    public static let useCheatsheetBloomFilters = Defaults.BoolKey(
        "useCheatsheetBloomFilters", default: true
    )

    // MARK: - notification
    public static let lastScheduledNeevaPromoID = Defaults.Key<String?>("lastScheduledNeevaPromoID")
    public static let lastNeevaPromoScheduledTimeInterval = Defaults.Key<Int?>(
        "lastNeevaPromoScheduledTimeInterval")
    public static let didRegisterNotificationTokenOnServer = Defaults.BoolKey(
        "didRegisterNotificationTokenOnServer")
    public static let productSearchPromoTimeInterval = Defaults.Key<Int>(
        "productSearchPromoTimeInterval", default: 259200)
    public static let newsProviderPromoTimeInterval = Defaults.Key<Int>(
        "newsProviderPromoTimeInterval", default: 86400)
    public static let fastTapPromoTimeInterval = Defaults.Key<Int>(
        "fastTapPromoTimeInterval", default: 432000)
    public static let defaultBrowserPromoTimeInterval = Defaults.Key<Int>(
        "defaultBrowserPromoTimeInterval", default: 259200)
    /// 0: Undecided, 1: Accepted, 2: Denied
    public static let notificationPermissionState = Defaults.Key<Int>(
        "notificationPermissionState", default: 0)
    public static let seenNotificationPermissionPromo = Defaults.BoolKey(
        "seenNotificationPermissionPromo")
    public static let debugNotificationTitle = Defaults.Key<String?>(
        "debugNotificationTitle", default: "Neeva Space")
    public static let debugNotificationBody = Defaults.Key<String?>(
        "debugNotificationBody", default: "Check out our recommended space: Cookie Monster Space")
    public static let debugNotificationDeeplink = Defaults.Key<String?>(
        "debugNotificationDeeplink",
        default: "neeva://space?id=B-ZzfqeytWS-n3YHKRi77h6Ore1kQ7EuojJIm4b7")
    public static let debugNotificationTimeInterval = Defaults.Key<Int>(
        "debugNotificationTimeInterval", default: 10)

    // MARK: - tab groups
    public static let tabGroupNames = Defaults.Key<[String: String]>("tabGroupNames", default: [:])
    public static let tabGroupExpanded = Defaults.Key<Set<String>>("tabGroupExpanded", default: [])

    // MARK: - Feedback
    public static let feedbackBeingSent = Defaults.BoolKey("feedbackBeingSent")

    // MARK: - preview mode
    public static let previewModeQueries = Defaults.Key<Set<String>>(
        "previewModeQueries", default: [])
    public static let signupPromptInterval = Defaults.Key<Int>("signupPromptInterval", default: 5)
    public static let maxQueryLimit = Defaults.Key<Int>("maxQueryLimit", default: 25)

    // crypto wallet
    public static let cryptoPublicKey = Defaults.Key<String>("cryptoPublicKey", default: "")
    public static let cryptoTransactionHashStore = Defaults.Key<Set<String>>(
        "cryptoTransactionHashStore", default: [])
    public static let sessionsPeerIDs = Defaults.Key<Set<String>>(
        "web3SessionsPeerIDs", default: [])
    public static let tickerResponse = Defaults.Key<Data?>("tickerResponse", default: nil)
    public static let walletIntroSeen = Defaults.BoolKey("seenWalletIntro")
    public static let walletOnboardingDone = Defaults.BoolKey("walletOnboardingDone")
    public static let currentTheme = Defaults.Key<String>("currentTheme", default: "")
    public static let showGasFeeInToolbar = Defaults.Key<Bool>("gasFeeToolbar", default: false)
    public static let walletProfilePictureAssetId = Defaults.Key<Int?>(
        "walletProfilePictureAssetId", default: nil)

    // MARK: - default browser
    public static let didDismissDefaultBrowserCard = Defaults.BoolKey(
        "profile.didDismissDefaultBrowserCard")
    public static let didDismissPreviewSignUpCard = Defaults.BoolKey(
        "profile.didDismissPreviewSignUpCard")
    public static let introSeenDate = Defaults.Key<Date?>(
        "introSeenDate")

    public static let didShowDefaultBrowserInterstitial = Defaults.BoolKey(
        "didShowDefaultBrowserInterstitial")
    // keeping interstitial shown state separately for skip to browser case so we can
    // show the default browser interstitial in the future for user who sign in later
    public static let didShowDefaultBrowserInterstitialFromSkipToBrowser = Defaults.BoolKey(
        "didShowDefaultBrowserInterstitialFromSkipToBrowser")
    public static let didSetDefaultBrowser = Defaults.BoolKey(
        "didSetDefaultBrowser")

    public static let loggedDefaultBrowserExperiment = Defaults.BoolKey(
        "loggedDefaultBrowserExperiment", default: false)
    public static let lastDefaultBrowserPromptInteraction = Defaults.Key<String?>(
        "lastDefaultBrowserPromptInteraction")

    public static let lastDefaultBrowserInterstitialChoice = Defaults.Key<Int>(
        "lastDefaultBrowserInterstitialChoice", default: 0)

    public static let didDismissDefaultBrowserInterstitial = Defaults.Key<Bool?>(
        "didDismissDefaultBrowserInterstitial")

    public static let didShowAdBlockerPromo = Defaults.BoolKey(
        "didShowAdBlockerPromo")

    // MARK: - Spotlight Search
    public static let createUserActivities = Defaults.BoolKey("createUserActivities", default: true)
    public static let makeActivityAvailForSearch = Defaults.BoolKey(
        "makeActivityAvailForSearch", default: true)
    public static let addThumbnailToActivities = Defaults.BoolKey(
        "addThumbnailToActivities", default: true)
    public static let addSpacesToCS = Defaults.BoolKey("addSpacesToCS", default: true)
    public static let addSpaceURLsToCS = Defaults.BoolKey("addSpaceURLsToCS", default: true)
    public static let overwriteSpotlightDefaults = Defaults.BoolKey(
        "overwriteSpotlightDefaults", default: true)
    public static let numOfIndexedUserActivities = Defaults.Key<Int>(
        "numOfIndexedUserActivities", default: 0)
    public static let numOfThumbnailsForUserActivity = Defaults.Key<Int>(
        "numOfThumbnailsForUserActivity", default: 0
    )
    public static let numOfWillIndexEvents = Defaults.Key<Int>("numOfWillIndexEvents", default: 0)
    public static let numOfDidIndexEvents = Defaults.Key<Int>("numOfDidIndexEvents", default: 0)

    public static let numOfDailyZeroQueryImpression = Defaults.Key<Int>(
        "numOfDailyZeroQueryImpression", default: 0)
    public static let lastZeroQueryImpUpdatedTimestamp = Defaults.Key<Date?>(
        "lastZeroQueryImpUpdatedTimestamp")

    public static let forceProdGraphQLLogger = Defaults.BoolKey(
        "forceProdGraphQLLogger", default: false)

    public static let lastReportedConversionEvent = Defaults.Key<Int>(
        "lastReportedConversionEvent", default: -1)

    public static let hasLogErrorFromFirstRunEvent = Defaults.Key<Bool>(
        "hasLogErrorFromFirstRunEvent", default: false)
    public static let lastFirstRunEventLogError = Defaults.Key<String>(
        "lastFirstRunEventLogError", default: "")
}

// MARK: - Defaults Extension
extension Defaults {
    static func BoolKey(
        _ key: String,
        default defaultValue: Bool = false,
        suite: UserDefaults = .standard
    ) -> Key<Bool> {
        Key<Bool>(key, default: defaultValue, suite: suite)
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    public func clearProfilePrefs() {
        for key in dictionaryRepresentation().keys {
            if key.hasPrefix("profile") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
