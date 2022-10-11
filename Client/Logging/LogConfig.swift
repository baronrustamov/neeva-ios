// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared

public enum LogConfig {

    // MARK: - Interactions
    public enum Interaction: String {
        /// Open tracking shield
        case OpenShield
        /// Open Overflow Menu
        case OpenOverflowMenu
        /// Tap reload page
        case TapReload
        /// Tap stop reload page
        case TapStopReload

        // MARK: bottom nav
        /// Click tab button to see all available tabs
        case ShowTabTray
        /// Click done button to hide the tab tray
        case HideTabTray
        /// Click on any tabs inside the tab tray
        case SelectTab
        /// Click bookmark button to add to space
        case ClickAddToSpaceButton
        /// Click the share button
        case ClickShareButton
        /// Click turn on incognito mode button
        case TurnOnIncognitoMode
        /// Click turn off incognito mode button
        case TurnOffIncognitoMode
        /// Click back button to navigate to previous page
        case ClickBack
        /// Click forward button to navigate to next page
        case ClickForward
        /// Click close button to close current tab
        case ClickClose
        /// Tap and Hold forward button to show navigation stack
        case LongPressForward

        // MARK: tracking shield
        /// Turn on block tracking from shield
        case TurnOnBlockTracking
        /// Turn off block tracking from shield
        case TurnOffBlockTracking
        /// Turn on block tracking from settings
        case TurnOnGlobalBlockTracking
        /// Turn off block tracking from settings
        case TurnOffGlobalBlockTracking
        /// Turn on ad block tracking from settings
        case TurnOnGlobalAdBlockTracking
        /// Turn off ad block tracking from settings
        case TurnOffGlobalAdBlockTracking

        // MARK: overflow menu
        /// Click the plus new tab button
        case ClickNewTabButton
        /// Click the Find on Page Button
        case ClickFindOnPage
        /// Click the Text Size Button
        case ClickTextSize
        /// Click the Request Desktop Site button
        case ClickRequestDesktop
        /// Click the Download Page Button
        case ClickDownloadPage
        /// Click the Close All Tabs button
        case ClickCloseAllTabs
        /// Open downloads
        case OpenDownloads
        /// Open history
        case OpenHistory
        /// Open settings
        case OpenSetting
        /// Open send feedback
        case OpenSendFeedback

        // MARK: settings
        /// Click search setting/account setting
        case SettingAccountSettings
        /// Click default browser in setting
        case SettingDefaultBrowser
        /// Click theme in setting
        case SettingTheme
        /// Click app icon in setting
        case SettingAppIcon
        /// Click sign out in setting
        case SettingSignout
        /// Click to view premium subscriptions
        case SettingPremiumSubscriptions
        /// Exception thrown fetching products
        case SettingPremiumProductsFetchException
        /// No products found
        case SettingPremiumNoProductsFound
        /// Click to purchase subscription
        case SettingPremiumPurchase
        /// Click to cancel purchase
        case SettingPremiumPurchaseCanceled
        /// Purchase finalized
        case SettingPremiumPurchaseComplete
        /// Purchase pending
        case SettingPremiumPurchasePending
        /// Purchase unverified
        case SettingPremiumPurchaseUnverified
        /// Purchase error
        case SettingPremiumPurchaseError
        /// Click Data Management in setting
        case ViewDataManagement
        /// Click Tracking Protection in setting
        case ViewTrackingProtection
        /// Click Privacy Policy in setting
        case ViewPrivacyPolicy
        /// Click Show Tour in setting
        case ViewShowTour
        /// Click Help Center in setting
        case ViewHelpCenter
        /// Click Licenses in setting
        case ViewLicenses
        /// Click Terms in setting
        case ViewTerms
        /// Click link to navigate to App Settings in System Settings
        case GoToSysAppSettings
        /// dismiss the educational screen
        case DismissDefaultBrowserOnboardingScreen

        /// Click Clear Private Data in Data Management
        case ClearPrivateData
        /// Click Clear All Website Data in Data Management > Website Data
        case ClearAllWebsiteData

        // MARK: First Run
        /// Click Sign up with Apple on first run
        case FirstRunSignupWithApple
        /// Click Other sign up options on first run
        case FirstRunOtherSignUpOptions
        /// Click sign in on first run
        case FirstRunSignin
        /// Click skip to browser on first run
        case FirstRunSkipToBrowser
        /// First run screen rendered
        case FirstRunImpression
        /// Login after first run
        case LoginAfterFirstRun
        /// Page load at first run and before login
        case FirstRunPageLoad
        /// Navigation outbound, non neeva domain
        case NavigationOutbound
        /// Navigation inbound, within neeva domain
        case NavigationInbound
        /// First run search in preview mode
        case PreviewSearch
        /// Sign in from promo card
        case PromoSignin
        /// Sign up on preview promo card
        case PreviewModePromoSignup
        /// Sign in from setting
        case SettingSignin
        /// Error login view triggered by suggestion
        case SuggestionErrorLoginViewImpression
        /// Click Sign in or Join Neeva on suggestion error login page
        case SuggestionErrorSigninOrJoinNeeva
        /// Click Sign in or Join Neeva on space error login page
        case AddToSpaceErrorSigninOrJoinNeeva
        /// Click Sign in or Join Neeva on cheatsheet login page
        case CheatsheetErrorSigninOrJoinNeeva
        /// Open auth panel
        case AuthImpression
        /// Close auth panel
        case AuthClose
        /// Click sign up with Apple on auth panel
        case AuthSignUpWithApple
        /// Click other sign up options on auth panel
        case AuthOtherSignUpOptions
        /// Click sign in on auth panel
        case AuthSignin
        /// Click Sign up with Apple under other options
        case OptionSignupWithApple
        /// Click Sign up with Google under other options
        case OptionSignupWithGoogle
        /// Click Sign up with Microsoft under other options
        case OptionSignupWithMicrosoft
        /// Click Sign up with Apple on auth panel under other options
        case AuthOptionSignupWithApple
        /// Click Sign up with Google on auth panel under other options
        case AuthOptionSignupWithGoogle
        /// Click Sign up with Microsoft on auth panel under other options
        case AuthOptionSignupWithMicrosoft
        /// Click Sign up with Email on auth panel under other options
        case AuthOptionSignupWithEmail
        /// Click close on the first run under other options
        case OptionClosePanel
        /// Click close on the auth panel under other options
        case AuthOptionClosePanel
        /// Clicked a public space in zero query
        case RecommendedSpaceVisited
        /// Clicked close on preview prompt
        case PreviewPromptClose
        /// Clicked sign up with apple on preview prompt
        case PreviewPromptSignupWithApple
        /// Clicked other signup options on preview prompt
        case PreviewPromptOtherSignupOptions
        /// Clicked sign in on preview prompt
        case PreviewPromptSignIn
        /// Clicked sign up in preview mode for preferred providers
        case PreviewPreferredProviderSignIn
        /// Preview home impression
        case PreviewHomeImpression
        /// Clicked on sample query on the home page
        case PreviewSampleQueryClicked
        /// Clicked on the fake search input box on preview home page
        case PreviewTapFakeSearchInput
        /// Click sign in on preview home
        case PreviewHomeSignin
        /// Default browser interstitial impression
        case DefaultBrowserInterstitialImp
        /// Start an experiment
        case StartExperiment
        /// Tap on Get started in welcome screen
        case GetStartedInWelcome
        /// Log first navigation
        case FirstNavigation
        /// Log interstitial logging error
        case LogErrorForInterstitialEvents
        /// Log attribution token request error
        case NeevaAttributionRequestError
        /// Default browser interstitial restore imp
        case DefaultBrowserInterstitialRestoreImp
        /// Recommended space tap on preview zero query
        case SpacesRecommendedDetailUIVisited
        /// the pop over for neeva shield onboarding screen
        case ShowNeevaShieldAdBlockOnboardingScreen
        case ShowNeevaShieldCookiePopupOnboardingScreen

        // MARK: promo card
        /// Promo card is rendered on screen
        case PromoCardAppear
        /// Click set default browser from promo
        case PromoDefaultBrowser
        /// Close default browser promo card
        case CloseDefaultBrowserPromo
        /// Close preview sign up card
        case ClosePreviewSignUpPromo
        case DefaultBrowserOnboardingInterstitialSkip
        case DefaultBrowserOnboardingInterstitialContinueToNeeva
        case DefaultBrowserOnboardingInterstitialRemind
        case DefaultBrowserOnboardingInterstitialOpen
        case DefaultBrowserOnboardingInterstitialOpenAgain
        case DefaultBrowserOnboardingInterstitialContinue
        case DefaultBrowserOnboardingInterstitialVideo
        case DefaultBrowserOnboardingInterstitialScreenTime
        /// Promo card impression (without 2 second)
        case DefaultBrowserPromoCardImp
        case AdBlockPromoImp
        case AdBlockPromoClose
        case AdBlockPromoRemind
        case AdBlockPromoSetup
        case AdBlockEnabled

        // MARK: selected suggestion
        case QuerySuggestion
        case MemorizedSuggestion
        case HistorySuggestion
        case AutocompleteSuggestion
        case PersonalSuggestion
        case BangSuggestion
        case LensSuggestion
        case NoSuggestionQuery
        case NoSuggestionURL
        case FindOnPageSuggestion
        case openSuggestedSearch
        case openSuggestedSite
        case tabSuggestion
        case editCurrentURL

        // MARK: referral promo
        /// Open referral promo
        case OpenReferralPromo
        /// Close referral promo card
        case CloseReferralPromo

        // MARK: stability
        /// App Crash # With Page load #
        case AppCrashWithPageLoad
        /// App Crash # With Crash Reporter
        case AppCrashWithCrashReporter
        /// memory warning with memory footprint
        case LowMemoryWarning
        /// session start = app enter foreground
        case AppEnterForeground

        // MARK: spaces
        case SpacesUIVisited
        case SpacesDetailUIVisited
        case SpacesDetailEntityClicked
        case SpacesDetailEditButtonClicked
        case SpacesDetailShareButtonClicked
        case SpacesLoginRequired
        case OwnerSharedSpace
        case FollowerSharedSpace
        case SocialShare
        /// This is for aggregate stats collection
        case space_app_view
        case SaveToSpace
        case ViewSpacesFromSheet
        case SpaceFilterClicked
        case OpenSuggestedSpace
        case SpaceFailedToOpen

        // MARK: ratings card
        case RatingsRateExperience
        case RatingsPromptFeedback
        case RatingsPromptAppStore
        case RatingsLoveit
        case RatingsNeedsWork
        case RatingsDismissedFeedback
        case RatingsDismissedAppReview
        case RatingsSendFeedback
        case RatingsSendAppReview

        // MARK: notification
        case ShowNotificationPrompt
        case NotificationPromptEnable
        case NotificationPromptSkip
        case ShowSystemNotificationPrompt
        case AuthorizeSystemNotification
        case DenySystemNotification
        case ScheduleLocalNotification
        case OpenLocalNotification
        case OpenNotification
        /// When url is opened in default browser
        case OpenDefaultBrowserURL
        /// Click enable notification from promo
        case PromoEnableNotification
        /// Close enable notification promo card
        case CloseEnableNotificationPromo
        /// Register a push notification token
        case RegisterNotificationToken

        // MARK: Spotlight
        // when url is opened from a user activity
        case openURLFromUserActivity
        // Aggregated index activities
        case spotlightEventsForSession
        // when an indexed CSSearchablItem is opened
        case openCSSearchableItem
        case clearIndexError

        // MARK: Shortcuts
        case openURLShortcut
        case searchShortcut

        // MARK: Cheatsheet(NeevaScope)
        case CheatsheetPopoverImpression
        case CheatsheetPopoverReachedLimit
        case CheatsheetUGCIndicatorImpression
        case CheatsheetBadURLString
        case CheatsheetUGCStatsForSession
        case CheatsheetUGCHitNoRedditDataV2
        // Journey Associated
        case OpenCheatsheet
        case CloseCheatsheet
        case CheatsheetEducationImpressionOnSRP
        case CheatsheetEducationImpressionOnPage
        case AckCheatsheetEducationOnSRP
        case AckCheatsheetEducationOnPage
        case ShowCheatsheetEducationOnSRP
        case ShowCheatsheetEducationOnPage
        case ShowCheatsheetContent
        case LoadCheatsheet
        case CheatsheetUGCStatsForPage
        case CheatsheetEmpty
        case OpenLinkFromCheatsheet
        case CheatsheetQueryFallback
        case OpenCheatsheetSupport
        case CheatsheetFetchError
        // Without Journey Associated, shrinked version
        case SkOpenCheatsheet
        case SkCloseCheatsheet
        case SkCheatsheetEducationImpressionOnSRP
        case SkCheatsheetEducationImpressionOnPage
        case SkAckCheatsheetEducationOnSRP
        case SkAckCheatsheetEducationOnPage
        case SkShowCheatsheetEducationOnSRP
        case SkShowCheatsheetEducationOnPage
        case SkShowCheatsheetContent
        case SkLoadCheatsheet
        case SkCheatsheetUGCStatsForPage
        case SkCheatsheetEmpty
        case SkOpenLinkFromCheatsheet
        case SkCheatsheetQueryFallback
        case SkOpenCheatsheetSupport
        case SkCheatsheetFetchError

        // MARK: recipe cheatsheet
        case RecipeCheatsheetShowMoreRecipe

        // MARK: tab group
        case tabGroupExpanded
        case tabGroupCollapsed
        case tabGroupRenameThroughThreeDotMenu
        case tabGroupDeleteThroughThreeDotMenu
        case tabGroupLongPressMenuClicked
        case tabGroupRemaneThroughLongPressMenu
        case tabGroupDeleteThroughLongPressMenu
        case tabInTabGroupClicked
        case tabRemovedFromGroup

        // MARK: feedback
        case FeedbackFailedToSend

        // MARK: debug mode
        case SignInWithAppleSuccess
        case SignInWithAppleFailed
        case ImplicitDeleteCookie

        // MARK: Cookie Cutter
        case CookieNoticeHandled
        case ToggleTrackingProtection

        // MARK: Archived Tabs
        case clearArchivedTabs

        // MARK: Generic
        case BrowsePlanClick
        case ChoosePlanClick
        case PremiumPurchaseCancel
        case PremiumPurchasePending
        case PremiumPurchaseUnverified
        case PremiumPurchaseVerified
        case PremiumPurchaseError
        case PremiumSubscriptionFixFailed
        case PreviousScreenClick
        case ScreenImpression
        case SignInClick
        case SafariVCLinkClick
    }

    // When we add/remove a new interaction to this list make sure
    // it's updated on the server side as well
    public static let sessionIDEventWhiteList: Set =
        [
            Interaction.AppEnterForeground,
            Interaction.FirstRunImpression,
            Interaction.FirstRunPageLoad,
            Interaction.FirstNavigation,
            Interaction.OpenDefaultBrowserURL,
            Interaction.GetStartedInWelcome,
            Interaction.DefaultBrowserInterstitialImp,
            Interaction.DefaultBrowserOnboardingInterstitialOpen,
            Interaction.DefaultBrowserOnboardingInterstitialOpenAgain,
            Interaction.DefaultBrowserOnboardingInterstitialSkip,
            Interaction.DefaultBrowserOnboardingInterstitialRemind,
            Interaction.DefaultBrowserOnboardingInterstitialContinue,
            Interaction.DefaultBrowserOnboardingInterstitialVideo,
            Interaction.OpenLocalNotification,
            Interaction.AuthorizeSystemNotification,
            Interaction.DenySystemNotification,
            Interaction.AppEnterForeground,
            Interaction.PremiumPurchaseVerified,
            Interaction.StartExperiment,
            Interaction.AppCrashWithPageLoad,
            Interaction.AppCrashWithCrashReporter,
            Interaction.LowMemoryWarning,
            Interaction.FirstRunSignupWithApple,
            Interaction.FirstRunOtherSignUpOptions,
            Interaction.FirstRunSignin,
            Interaction.PreviewSearch,
            Interaction.NavigationOutbound,
            Interaction.NavigationInbound,
            Interaction.PreviewModePromoSignup,
            Interaction.DefaultBrowserInterstitialRestoreImp,
            Interaction.SpacesRecommendedDetailUIVisited,
            Interaction.PromoCardAppear,
            Interaction.PromoDefaultBrowser,
            Interaction.CloseDefaultBrowserPromo,
            Interaction.OpenNotification,
            Interaction.RegisterNotificationToken,
            Interaction.BrowsePlanClick,
            Interaction.ChoosePlanClick,
            Interaction.PremiumPurchaseCancel,
            Interaction.PremiumPurchasePending,
            Interaction.PremiumPurchaseUnverified,
            Interaction.PreviousScreenClick,
            Interaction.ScreenImpression,
            Interaction.SignInClick,
            Interaction.SpacesLoginRequired,
            Interaction.SpacesRecommendedDetailUIVisited,
            Interaction.CheatsheetUGCStatsForSession,
            Interaction.CheatsheetPopoverImpression,
            Interaction.CheatsheetUGCIndicatorImpression,
            Interaction.SkOpenCheatsheet,
            Interaction.SkCloseCheatsheet,
            Interaction.SkCheatsheetEducationImpressionOnSRP,
            Interaction.SkCheatsheetEducationImpressionOnPage,
            Interaction.SkAckCheatsheetEducationOnSRP,
            Interaction.SkAckCheatsheetEducationOnPage,
            Interaction.SkShowCheatsheetEducationOnSRP,
            Interaction.SkShowCheatsheetEducationOnPage,
            Interaction.SkShowCheatsheetContent,
            Interaction.SkLoadCheatsheet,
            Interaction.SkCheatsheetUGCStatsForPage,
            Interaction.SkCheatsheetEmpty,
            Interaction.SkOpenLinkFromCheatsheet,
            Interaction.SkCheatsheetQueryFallback,
            Interaction.SkOpenCheatsheetSupport,
            Interaction.SkCheatsheetFetchError,
        ]

    /// Specify a comma separated string with these values to
    /// enable specific logging category on the server:
    /// `ios_logging_categories.experiment.yaml`
    public enum InteractionCategory: String, CaseIterable {
        case UI = "UI"
        case OverflowMenu = "OverflowMenu"
        case Settings = "Settings"
        case Suggestions = "Suggestions"
        case ReferralPromo = "ReferralPromo"
        case Stability = "Stability"
        case FirstRun = "FirstRun"
        case PromoCard = "PromoCard"
        case Spaces = "Spaces"
        case RatingsCard = "RatingsCard"
        case Notification = "Notification"
        case Spotlight = "Spotlight"
        case Shortcuts = "Shortcuts"
        case RecipeCheatsheet = "RecipeCheatsheet"
        case Cheatsheet = "Cheatsheet"
        case TabGroup = "TabGroup"
        case Feedback = "Feedback"
        case DebugMode = "DebugMode"
        case CookieCutter = "CookieCutter"
        case ArchiveTab = "ArchiveTab"
        case Generic = "Generic"
    }

    public static var enabledLoggingCategories: Set<InteractionCategory>?

    private static var flagsObserver: AnyCancellable?

    static let alwaysEnabledCategories: Set<InteractionCategory> = [
        .FirstRun,
        .Notification,
        .Suggestions,
        .Stability,
        .DebugMode,
        .PromoCard,
        .CookieCutter,
        .UI,
        .OverflowMenu,
        .Generic,
        .Cheatsheet,
    ]
    public static func featureFlagEnabled(for category: InteractionCategory) -> Bool {
        if alwaysEnabledCategories.contains(category) {
            return true
        }

        if enabledLoggingCategories == nil {
            enabledLoggingCategories = Set<InteractionCategory>()
            flagsObserver = Defaults.publisher(NeevaFeatureFlags.stringFlagsKey)
                .combineLatest(
                    Defaults.publisher(NeevaFeatureFlags.stringFlagOverridesKey)
                ).sink { _ in
                    updateLoggingCategory()
                }
            updateLoggingCategory()
        }
        return enabledLoggingCategories?.contains(category) ?? false
    }

    private static func updateLoggingCategory() {
        enabledLoggingCategories = Set(
            NeevaFeatureFlags.latestValue(.loggingCategories)
                .components(separatedBy: ",")
                .compactMap { token in
                    InteractionCategory(
                        rawValue: token.stringByTrimmingLeadingCharactersInSet(.whitespaces)
                    )
                }
        )
    }

    public static func shouldAddSessionID(
        for path: LogConfig.Interaction
    ) -> Bool {
        return sessionIDEventWhiteList.contains(path)
    }

    // MARK: - Category
    public static func category(for interaction: Interaction) -> InteractionCategory {
        switch interaction {
        // MARK: - UI
        case .OpenShield: return .UI
        case .OpenOverflowMenu: return .UI
        case .TapReload: return .UI
        case .TapStopReload: return .UI
        case .ShowTabTray: return .UI
        case .HideTabTray: return .UI
        case .SelectTab: return .UI
        case .ClickAddToSpaceButton: return .UI
        case .ClickShareButton: return .UI
        case .TurnOnIncognitoMode: return .UI
        case .TurnOffIncognitoMode: return .UI
        case .ClickBack: return .UI
        case .ClickForward: return .UI
        case .ClickClose: return .UI
        case .LongPressForward: return .UI
        case .PreviewPreferredProviderSignIn: return .UI
        case .TurnOnBlockTracking: return .UI
        case .TurnOffBlockTracking: return .UI
        case .TurnOnGlobalBlockTracking: return .UI
        case .TurnOffGlobalBlockTracking: return .UI
        case .TurnOnGlobalAdBlockTracking: return .UI
        case .TurnOffGlobalAdBlockTracking: return .UI

        // MARK: - OverflowMenu
        case .OpenDownloads: return .OverflowMenu
        case .OpenHistory: return .OverflowMenu
        case .OpenSetting: return .OverflowMenu
        case .OpenSendFeedback: return .OverflowMenu

        case .ClickNewTabButton: return .OverflowMenu
        case .ClickFindOnPage: return .OverflowMenu
        case .ClickTextSize: return .OverflowMenu
        case .ClickRequestDesktop: return .OverflowMenu
        case .ClickDownloadPage: return .OverflowMenu
        case .ClickCloseAllTabs: return .OverflowMenu

        // MARK: - Settings
        case .SettingAccountSettings: return .Settings
        case .SettingDefaultBrowser: return .Settings
        case .SettingTheme: return .Settings
        case .SettingAppIcon: return .Settings
        case .SettingSignout: return .Settings
        case .SettingPremiumSubscriptions: return .Settings
        case .SettingPremiumProductsFetchException: return .Settings
        case .SettingPremiumNoProductsFound: return .Settings
        case .SettingPremiumPurchase: return .Settings
        case .SettingPremiumPurchaseCanceled: return .Settings
        case .SettingPremiumPurchaseComplete: return .Settings
        case .SettingPremiumPurchasePending: return .Settings
        case .SettingPremiumPurchaseUnverified: return .Settings
        case .SettingPremiumPurchaseError: return .Settings
        case .ViewDataManagement: return .Settings
        case .ViewTrackingProtection: return .Settings
        case .ViewPrivacyPolicy: return .Settings
        case .ViewShowTour: return .Settings
        case .ViewHelpCenter: return .Settings
        case .ViewLicenses: return .Settings
        case .ViewTerms: return .Settings
        case .ClearPrivateData: return .Settings
        case .ClearAllWebsiteData: return .Settings

        // MARK: - FirstRun
        case .FirstRunSignupWithApple: return .FirstRun
        case .FirstRunOtherSignUpOptions: return .FirstRun
        case .FirstRunSignin: return .FirstRun
        case .FirstRunSkipToBrowser: return .FirstRun
        case .FirstRunImpression: return .FirstRun
        case .LoginAfterFirstRun: return .FirstRun
        case .FirstRunPageLoad: return .FirstRun
        case .PromoSignin: return .FirstRun
        case .PreviewModePromoSignup: return .FirstRun
        case .SettingSignin: return .FirstRun
        case .SuggestionErrorLoginViewImpression: return .FirstRun
        case .SuggestionErrorSigninOrJoinNeeva: return .FirstRun
        case .AddToSpaceErrorSigninOrJoinNeeva: return .FirstRun
        case .CheatsheetErrorSigninOrJoinNeeva: return .FirstRun
        case .AuthImpression: return .FirstRun
        case .AuthClose: return .FirstRun
        case .AuthSignUpWithApple: return .FirstRun
        case .AuthOtherSignUpOptions: return .FirstRun
        case .AuthSignin: return .FirstRun
        case .OptionSignupWithApple: return .FirstRun
        case .OptionSignupWithGoogle: return .FirstRun
        case .OptionSignupWithMicrosoft: return .FirstRun
        case .AuthOptionSignupWithApple: return .FirstRun
        case .AuthOptionSignupWithGoogle: return .FirstRun
        case .AuthOptionSignupWithMicrosoft: return .FirstRun
        case .AuthOptionSignupWithEmail: return .FirstRun
        case .OptionClosePanel: return .FirstRun
        case .AuthOptionClosePanel: return .FirstRun
        case .RecommendedSpaceVisited: return .FirstRun
        case .PreviewPromptClose: return .FirstRun
        case .PreviewPromptSignupWithApple: return .FirstRun
        case .PreviewPromptOtherSignupOptions: return .FirstRun
        case .PreviewPromptSignIn: return .FirstRun
        case .PreviewHomeImpression: return .FirstRun
        case .PreviewSampleQueryClicked: return .FirstRun
        case .PreviewTapFakeSearchInput: return .FirstRun
        case .PreviewHomeSignin: return .FirstRun
        case .PreviewSearch: return .FirstRun
        case .NavigationOutbound: return .FirstRun
        case .NavigationInbound: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialSkip: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialContinueToNeeva: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialRemind: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialOpen: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialOpenAgain: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialContinue: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialVideo: return .FirstRun
        case .DefaultBrowserOnboardingInterstitialScreenTime: return .FirstRun
        case .DefaultBrowserInterstitialImp: return .FirstRun
        case .OpenDefaultBrowserURL: return .FirstRun
        case .StartExperiment: return .FirstRun
        case .GetStartedInWelcome: return .FirstRun
        case .FirstNavigation: return .FirstRun
        case .LogErrorForInterstitialEvents: return .FirstRun
        case .NeevaAttributionRequestError: return .FirstRun
        case .DefaultBrowserInterstitialRestoreImp: return .FirstRun
        case .SpacesRecommendedDetailUIVisited: return .FirstRun
        case .ShowNeevaShieldAdBlockOnboardingScreen: return .FirstRun
        case .ShowNeevaShieldCookiePopupOnboardingScreen: return .FirstRun

        // MARK: - PromoCard
        case .PromoCardAppear: return .PromoCard
        case .PromoDefaultBrowser: return .PromoCard
        case .CloseDefaultBrowserPromo: return .PromoCard
        case .ClosePreviewSignUpPromo: return .PromoCard
        case .GoToSysAppSettings: return .PromoCard
        case .DefaultBrowserPromoCardImp: return .PromoCard
        case .DismissDefaultBrowserOnboardingScreen: return .PromoCard
        case .AdBlockPromoImp: return .PromoCard
        case .AdBlockPromoClose: return .PromoCard
        case .AdBlockPromoRemind: return .PromoCard
        case .AdBlockPromoSetup: return .PromoCard
        case .AdBlockEnabled: return .PromoCard

        // MARK: - Suggestions
        case .QuerySuggestion: return .Suggestions
        case .MemorizedSuggestion: return .Suggestions
        case .HistorySuggestion: return .Suggestions
        case .AutocompleteSuggestion: return .Suggestions
        case .PersonalSuggestion: return .Suggestions
        case .BangSuggestion: return .Suggestions
        case .NoSuggestionURL: return .Suggestions
        case .NoSuggestionQuery: return .Suggestions
        case .LensSuggestion: return .Suggestions
        case .FindOnPageSuggestion: return .Suggestions
        case .openSuggestedSearch: return .Suggestions
        case .openSuggestedSite: return .Suggestions
        case .tabSuggestion: return .Suggestions
        case .editCurrentURL: return .Suggestions

        // MARK: - ReferralPromo
        case .OpenReferralPromo: return .ReferralPromo
        case .CloseReferralPromo: return .ReferralPromo

        // MARK: - Stability
        case .AppCrashWithPageLoad: return .Stability
        case .AppCrashWithCrashReporter: return .Stability
        case .LowMemoryWarning: return .Stability
        case .AppEnterForeground: return .Stability

        // MARK: - Spaces
        case .SpacesUIVisited: return .Spaces
        case .SpacesDetailUIVisited: return .Spaces
        case .SpacesDetailEntityClicked: return .Spaces
        case .SpacesDetailEditButtonClicked: return .Spaces
        case .SpacesDetailShareButtonClicked: return .Spaces
        case .SpacesLoginRequired: return .Spaces
        case .OwnerSharedSpace: return .Spaces
        case .FollowerSharedSpace: return .Spaces
        case .SocialShare: return .Spaces
        case .space_app_view: return .Spaces
        case .SaveToSpace: return .Spaces
        case .ViewSpacesFromSheet: return .Spaces
        case .SpaceFilterClicked: return .Spaces
        case .OpenSuggestedSpace: return .Spaces
        case .SpaceFailedToOpen: return .Spaces

        // MARK: - RatingsCard
        case .RatingsRateExperience: return .RatingsCard
        case .RatingsPromptFeedback: return .RatingsCard
        case .RatingsPromptAppStore: return .RatingsCard
        case .RatingsLoveit: return .RatingsCard
        case .RatingsNeedsWork: return .RatingsCard
        case .RatingsDismissedFeedback: return .RatingsCard
        case .RatingsDismissedAppReview: return .RatingsCard
        case .RatingsSendFeedback: return .RatingsCard
        case .RatingsSendAppReview: return .RatingsCard

        // MARK: - Notification
        case .ShowNotificationPrompt: return .Notification
        case .NotificationPromptEnable: return .Notification
        case .NotificationPromptSkip: return .Notification
        case .ShowSystemNotificationPrompt: return .Notification
        case .AuthorizeSystemNotification: return .Notification
        case .DenySystemNotification: return .Notification
        case .ScheduleLocalNotification: return .Notification
        case .OpenLocalNotification: return .Notification
        case .OpenNotification: return .Notification
        case .PromoEnableNotification: return .Notification
        case .CloseEnableNotificationPromo: return .Notification
        case .RegisterNotificationToken: return .Notification

        // MARK: - Spotlight
        case .openURLFromUserActivity: return .Spotlight
        case .spotlightEventsForSession: return .Spotlight
        case .openCSSearchableItem: return .Spotlight
        case .clearIndexError: return .Spotlight

        // MARK: - Shortcuts
        case .openURLShortcut: return .Shortcuts
        case .searchShortcut: return .Shortcuts

        // MARK: - Cheatsheet
        case .RecipeCheatsheetShowMoreRecipe: return .RecipeCheatsheet

        case .CheatsheetPopoverImpression: return .Cheatsheet
        case .CheatsheetPopoverReachedLimit: return .Cheatsheet
        case .CheatsheetUGCIndicatorImpression: return .Cheatsheet
        case .OpenCheatsheet: return .Cheatsheet
        case .CloseCheatsheet: return .Cheatsheet
        case .CheatsheetEducationImpressionOnSRP: return .Cheatsheet
        case .CheatsheetEducationImpressionOnPage: return .Cheatsheet
        case .AckCheatsheetEducationOnSRP: return .Cheatsheet
        case .AckCheatsheetEducationOnPage: return .Cheatsheet
        case .ShowCheatsheetEducationOnSRP: return .Cheatsheet
        case .ShowCheatsheetEducationOnPage: return .Cheatsheet
        case .ShowCheatsheetContent: return .Cheatsheet
        case .LoadCheatsheet: return .Cheatsheet
        case .CheatsheetEmpty: return .Cheatsheet
        case .OpenLinkFromCheatsheet: return .Cheatsheet
        case .CheatsheetQueryFallback: return .Cheatsheet
        case .OpenCheatsheetSupport: return .Cheatsheet
        case .CheatsheetBadURLString: return .Cheatsheet
        case .CheatsheetFetchError: return .Cheatsheet
        case .CheatsheetUGCStatsForPage: return .Cheatsheet
        case .CheatsheetUGCStatsForSession: return .Cheatsheet
        case .CheatsheetUGCHitNoRedditDataV2: return .Cheatsheet

        case .SkOpenCheatsheet: return .Cheatsheet
        case .SkCloseCheatsheet: return .Cheatsheet
        case .SkCheatsheetEducationImpressionOnSRP: return .Cheatsheet
        case .SkCheatsheetEducationImpressionOnPage: return .Cheatsheet
        case .SkAckCheatsheetEducationOnSRP: return .Cheatsheet
        case .SkAckCheatsheetEducationOnPage: return .Cheatsheet
        case .SkShowCheatsheetEducationOnSRP: return .Cheatsheet
        case .SkShowCheatsheetEducationOnPage: return .Cheatsheet
        case .SkShowCheatsheetContent: return .Cheatsheet
        case .SkLoadCheatsheet: return .Cheatsheet
        case .SkCheatsheetUGCStatsForPage: return .Cheatsheet
        case .SkCheatsheetEmpty: return .Cheatsheet
        case .SkOpenLinkFromCheatsheet: return .Cheatsheet
        case .SkCheatsheetQueryFallback: return .Cheatsheet
        case .SkOpenCheatsheetSupport: return .Cheatsheet
        case .SkCheatsheetFetchError: return .Cheatsheet

        // MARK: - TabGroup
        case .tabGroupExpanded: return .TabGroup
        case .tabGroupCollapsed: return .TabGroup
        case .tabGroupRenameThroughThreeDotMenu: return .TabGroup
        case .tabGroupDeleteThroughThreeDotMenu: return .TabGroup
        case .tabGroupLongPressMenuClicked: return .TabGroup
        case .tabGroupRemaneThroughLongPressMenu: return .TabGroup
        case .tabGroupDeleteThroughLongPressMenu: return .TabGroup
        case .tabInTabGroupClicked: return .TabGroup
        case .tabRemovedFromGroup: return .TabGroup

        // MARK: - Feedback
        case .FeedbackFailedToSend: return .Feedback

        // MARK: - DebugMode
        case .SignInWithAppleSuccess: return .DebugMode
        case .SignInWithAppleFailed: return .DebugMode
        case .ImplicitDeleteCookie: return .DebugMode

        // MARK: Cookie Cutter
        case .CookieNoticeHandled: return .CookieCutter
        case .ToggleTrackingProtection: return .CookieCutter

        // MARK: Archived Tabs
        case .clearArchivedTabs: return .ArchiveTab

        // MARK: Generic
        case .BrowsePlanClick: return .Generic
        case .ChoosePlanClick: return .Generic
        case .PremiumPurchaseCancel: return .Generic
        case .PremiumPurchasePending: return .Generic
        case .PremiumPurchaseUnverified: return .Generic
        case .PremiumPurchaseVerified: return .Generic
        case .PremiumPurchaseError: return .Generic
        case .PremiumSubscriptionFixFailed: return .Generic
        case .PreviousScreenClick: return .Generic
        case .ScreenImpression: return .Generic
        case .SignInClick: return .Generic
        case .SafariVCLinkClick: return .Generic
        }
    }

    public enum Attribute {
        /// Is selected tab in private mode
        public static let IsInPrivateMode = "IsInPrivateMode"
        /// Number of all tabs (normal + incognito) opened
        public static let AllTabsOpened = "AllTabsOpened"
        /// Number of normal tabs opened
        public static let NormalTabsOpened = "NormalTabsOpened"
        /// Number of incognito tabs opened
        public static let IncognitoTabsOpened = "PrivateTabsOpened"
        /// Number of archived tabs
        public static let NumberOfArchivedTabsTotal = "NumberOfArchivedTabsTotal"
        /// Number of zombie tabs opened
        public static let NumberOfZombieTabs = "NumberOfZombieTabs"
        /// Number of tab groups in total
        public static let numTabGroupsTotal = "NumTabGroupsTotal"
        /// Number of tabs inside all the tab groups
        public static let numChildTabsTotal = "NumChildTabsTotal"
        /// User theme setting, i.e dark, light
        public static let UserInterfaceStyle = "UserInterfaceStyle"
        /// Device orientation, i.e. portrait, landscape
        public static let DeviceOrientation = "DeviceOrientation"
        /// Device screen size width x height
        public static let DeviceScreenSize = "DeviceScreenSize"
        /// Is user signed in
        public static let isUserSignedIn = "IsUserSignedIn"
        /// Device name
        public static let DeviceName = "DeviceName"
        /// Device OS
        public static let DeviceOS = "DeviceOS"
        /// Session UUID
        public static let SessionUUID = "SessionUUID"
        /// First run search path and query
        public static let FirstRunSearchPathQuery = "FirstRunSearchPathQuery"
        /// First run path, option user clicked on first run screen
        public static let FirstRunPath = "FirstRunPath"
        /// First session uuid when user open the app
        public static let FirstSessionUUID = "FirstSessionUUID"
        /// Preview mode query count
        public static let PreviewModeQueryCount = "PreviewModeQueryCount"
        /// Session UUID v2
        public static let SessionUUIDv2 = "SessionUUIDv2"
        /// Attribution Token Error Message
        public static let AttributionTokenErrorToken = "AttributionTokenErrorToken"
        /// Attribution Token Error Type
        public static let AttributionTokenErrorType = "AttributionTokenErrorType"

        /// First Run Logging Error
        public static let FirstRunLogErrorMessage = "FirstRunLogErrorMessage"

        public static let InterstitialTimeSpent = "InterstitialTimeSpent"

        public static let pushNotificationToken = "PushNotificationToken"

        public static let pushNotificationTokenEnvironment = "PushNotificationTokenEnvironment"

        /// Generic attributes
        public static let screenName = "ScreenName"
        public static let source = "Source"
        public static let safariVCLinkURL = "SafariVCLinkURL"

        /// Premium attributes
        public static let subscriptionPlan = "SubscriptionPlan"
    }

    public enum CookieCutterAttribute {
        public static let adBlockEnabled = "adBlockEnabled"
        public static let cookieCutterToggleState = "cookieCutterToggleState"
        public static let trackingProtectionDomain = "trackingProtectionDomain"

        /// The name of the Cookie Cutter provider that was used.
        public static let CookieCutterProviderUsed = "CookieCutterProviderUsed"
    }

    public enum UIInteractionAttribute {
        /// View from which an UI Interaction is triggered
        public static let fromActionType = "fromActionType"
        public static let openSysSettingSourceView = "openSysSettingSourceView"
        public static let openSysSettingTriggerFrom = "openSysSettingTriggerFrom"
    }

    public enum SuggestionAttribute {
        /// suggestion position
        public static let suggestionPosition = "suggestionPosition"
        /// number of characters typed in url bar
        public static let urlBarNumOfCharsTyped = "urlBarNumOfCharsTyped"
        /// suggestion impression position index
        public static let suggestionTypePosition = "SuggestionTypeAtPosition"
        /// annotation type at position
        public static let annotationTypeAtPosition = "AnnotationTypeAtPosition"
        public static let numberOfMemorizedSuggestions = "NumberOfMemorizedSuggestions"
        public static let numberOfHistorySuggestions = "NumberOfHistorySuggestions"
        public static let numberOfPersonalSuggestions = "NumberOfPersonalSuggestions"
        public static let numberOfCalculatorAnnotations = "NumberOfCalculatorAnnotations"
        public static let numberOfWikiAnnotations = "NumberOfWikiAnnotations"
        public static let numberOfStockAnnotations = "NumberOfStockAnnotations"
        public static let numberOfDictionaryAnnotations = "NumberOfDictionaryAnnotations"
        // query info
        public static let queryInputForSelectedSuggestion = "QueryInputForSelectedSuggestion"
        public static let querySuggestionPosition = "QuerySuggestionPosition"
        public static let selectedMemorizedURLSuggestion = "selectedMemorizedURLSuggestion"
        public static let selectedQuerySuggestion = "SelectedQuerySuggestion"
        // autocomplete
        public static let autocompleteSelectedFromRow = "AutocompleteSelectedFromRow"
        // searchHistory
        public static let fromSearchHistory = "FromSearchHistory"
        // latency
        public static let numberOfCanceledRequest = "NumberOfCanceledRequest"
        public static let timeToFirstScreen = "TimeToFirstScreen"
        public static let timeToSelectSuggestion = "TimeToSelectSuggestion"
    }

    public enum SpacesAttribute {
        public static let spaceID = "space_id"
        public static let spaceEntityID = "SpaceEntityID"
        public static let isShared = "isShared"
        public static let isPublic = "isPublic"
        public static let numberOfSpaceEntities = "NumberOfSpaceEntities"
        public static let socialShareApp = "ShareAppName"
    }

    public enum PromoCardAttribute {
        public static let promoCardType = "promoCardType"
        public static let defaultBrowserInterstitialTrigger = "defaultBrowserInterstitialTrigger"
    }

    public enum ExperimentAttribute {
        public static let experiment = "Experiment"
        public static let experimentArm = "ExperimentArm"
    }

    // MARK: - CheatsheetAttribute
    public enum CheatsheetAttribute {
        public static let currentCheatsheetQuery = "currentCheatsheetQuery"
        public static let currentPageURL = "currentCheatsheetPageURL"
        public static let cheatsheetQuerySource = "cheatsheetQuerySource"
        public static let openLinkSource = "openLinkSource"
        public static let api = "api"
        public static let journeyID = "journeyID"
        public static let tabID = "tabID"
        public static let completedOnboarding = "completedOnboarding"

        public enum QuerySource: String {
            case uToQ
            case fastTapQuery
            case typedQuery
            case pageURL
        }

        public enum API: String {
            case getInfo
            case search
        }

        public enum UGCStat: String {
            case filterHealth
            case ugcTest
            case ugcTestNoResult
            case ugcHit
            case ugcClear
            case ugcCanonicalError
            case hasUGCData
            case isEnabled
        }
    }

    public enum TabsAttribute {
        public static let selectedTabSection = "SelectedTabSection"
        public static let selectedTabIndex = "SelectedTabIndex"
        public static let selectedTabRow = "SelectedTabRow"
    }

    public enum NotificationAttribute {
        public static let notificationPromptCallSite = "NotificationPromptCallSite"
        public static let notificationAuthorizationCallSite = "notificationAuthorizationCallSite"

        public static let localNotificationTapAction = "LocalNotificationTapAction"
        public static let localNotificationScheduleCallSite = "localNotificationScheduledCallSite"
        public static let localNotificationPromoId = "localNotificationPromoId"
        public static let notificationCampaignId = "NotificationCampaignId"
    }

    public enum SpotlightAttribute {
        public static let urlPayload = "urlPayload"
        public static let spaceIdPayload = "spaceIdPayload"
        public static let addActivityToSpotlight = "addActivityToSpotlight"
        public static let thumbnailSource = "thumbnailSource"

        public static let itemType = "itemType"
        public static let indexCount = "indexCount"

        public static let error = "error"

        public enum CountForEvent: String {
            case createUserActivity
            case addThumbnailToUserActivity
            case willIndex
            case didIndex
        }

        public enum ThumbnailSource: String {
            case none
            case fallback
            case favicon
        }

        public enum ItemType: String {
            case space
            case spaceEntity
            case all
        }
    }

    public enum PerformanceAttribute {
        public static let memoryUsage = "MemoryUsage"
    }

    public enum TabGroupAttribute {
        public static let numTabsInTabGroup = "NumTabsInTabGroup"
        public static let TabGroupRowIndex = "SelectedTabGroupRowIndex"
        public static let isExpanded = "IsExpanded"
        public static let selectedChildTabIndex = "SelectedChildTabIndex"
    }

    public enum DeeplinkAttribute {
        public static let searchRedirect = "SearchRedirect"
    }

    public enum TrackingProtectionAttribute {
        public static let toggleProtectionForURL = "ToggleProtectionForURL"
    }

    public enum WelcomeFlowAttribute {
        public static let welcomeFlowTrigger = "welcomeFlowTrigger"
    }
}
