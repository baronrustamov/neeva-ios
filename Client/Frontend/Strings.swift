/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public struct Strings {}

class BundleClass {}

func MZLocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String)
    -> String
{
    let bundle = Bundle(for: BundleClass.self)
    return NSLocalizedString(
        key, tableName: tableName, bundle: bundle, value: value, comment: comment)
}

extension Strings {
    public static let OKString = MZLocalizedString("OK", comment: "OK button")
    public static let CancelString = MZLocalizedString("Cancel", comment: "Label for Cancel button")
    public static let OpenSettingsString = MZLocalizedString(
        "Open Settings", comment: "See http://mzl.la/1G7uHo7")
}

// Activities on Share Sheet.
extension Strings {
    public static let PinToTopSitesTitleActivity = MZLocalizedString(
        "Pin to Top Sites", comment: "Pin to Top Sites no Share activity title")
    public static let UnpinFromTopSitesTitleActivity = MZLocalizedString(
        "Unpin from Top Sites", comment: "Unpin from Top Sites Share activity title")
}

// Error pages.
extension Strings {
    public static let ErrorPagesAdvancedButton = MZLocalizedString(
        "ErrorPages.Advanced.Button", value: "Advanced",
        comment: "Label for button to perform advanced actions on the error page")
    public static let ErrorPagesAdvancedWarning1 = MZLocalizedString(
        "ErrorPages.AdvancedWarning1.Text",
        value: "Warning: we can’t confirm your connection to this website is secure.",
        comment: "Warning text when clicking the Advanced button on error pages")
    public static let ErrorPagesAdvancedWarning2 = MZLocalizedString(
        "ErrorPages.AdvancedWarning2.Text",
        value:
            "It may be a misconfiguration or tampering by an attacker. Proceed if you accept the potential risk.",
        comment: "Additional warning text when clicking the Advanced button on error pages")
    public static let ErrorPagesCertWarningDescription = MZLocalizedString(
        "ErrorPages.CertWarning.Description",
        value:
            "Your private information could be stolen from %@. To protect your safety, Neeva has not connected to this website.",
        comment: "Warning text on the certificate error page")
    public static let ErrorPagesCertWarningTitle = MZLocalizedString(
        "ErrorPages.CertWarning.Title", value: "This connection is not trusted",
        comment: "Title on the certificate error page")
    public static let ErrorPagesGoBackButton = MZLocalizedString(
        "ErrorPages.GoBack.Button", value: "Go Back",
        comment: "Label for button to go back from the error page")
    public static let ErrorPagesVisitOnceButton = MZLocalizedString(
        "ErrorPages.VisitOnce.Button", value: "Visit site anyway",
        comment: "Button label to temporarily continue to the site from the certificate error page")
}

// Clear recent history action menu
extension Strings {
    public static let ClearHistoryMenuTitle = MZLocalizedString(
        "HistoryPanel.ClearHistoryMenuTitle",
        value: "Clearing Recent History will remove history, cookies, and other browser data.",
        comment: "Title for popup action menu to clear recent history.")
}

// Neeva Logins
extension Strings {
    // Prompts
    public static let SaveLoginUsernamePrompt = MZLocalizedString(
        "LoginsHelper.PromptSaveLogin.Title", value: "Save login %@ for %@?",
        comment:
            "Prompt for saving a login. The first parameter is the username being saved. The second parameter is the hostname of the site."
    )
    public static let SaveLoginPrompt = MZLocalizedString(
        "LoginsHelper.PromptSavePassword.Title", value: "Save password for %@?",
        comment:
            "Prompt for saving a password with no username. The parameter is the hostname of the site."
    )
    public static let UpdateLoginUsernamePrompt = MZLocalizedString(
        "LoginsHelper.PromptUpdateLogin.Title.TwoArg", value: "Update login %@ for %@?",
        comment:
            "Prompt for updating a login. The first parameter is the username for which the password will be updated for. The second parameter is the hostname of the site."
    )
    public static let UpdateLoginPrompt = MZLocalizedString(
        "LoginsHelper.PromptUpdateLogin.Title.OneArg", value: "Update login for %@?",
        comment:
            "Prompt for updating a login. The first parameter is the hostname for which the password will be updated for."
    )
}

//Hotkey Titles
extension Strings {
    public static let ReloadPageTitle = MZLocalizedString(
        "Hotkeys.Reload.DiscoveryTitle", value: "Reload Page",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let BackTitle = MZLocalizedString(
        "Hotkeys.Back.DiscoveryTitle", value: "Back",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let ForwardTitle = MZLocalizedString(
        "Hotkeys.Forward.DiscoveryTitle", value: "Forward",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")

    public static let FindTitle = MZLocalizedString(
        "Hotkeys.Find.DiscoveryTitle", value: "Find",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let SelectLocationBarTitle = MZLocalizedString(
        "Hotkeys.SelectLocationBar.DiscoveryTitle", value: "Select Location Bar",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let NewTabTitle = MZLocalizedString(
        "Hotkeys.NewTab.DiscoveryTitle", value: "New Tab",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let NewIncognitoTabTitle = MZLocalizedString(
        "Hotkeys.NewIncognitoTab.DiscoveryTitle", value: "New Incognito Tab",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let CloseTabTitle = MZLocalizedString(
        "Hotkeys.CloseTab.DiscoveryTitle", value: "Close Tab",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let CloseAllTabsTitle = MZLocalizedString(
        "Hotkeys.CloseAllTabs.DiscoveryTitle", value: "Close All Tabs",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let RestoreLastClosedTabsTitle = MZLocalizedString(
        "Hotkeys.RestoreLastClosedTabs.DiscoveryTitle", value: "Restore Last Closed Tabs",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let ShowNextTabTitle = MZLocalizedString(
        "Hotkeys.ShowNextTab.DiscoveryTitle", value: "Show Next Tab",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let ShowPreviousTabTitle = MZLocalizedString(
        "Hotkeys.ShowPreviousTab.DiscoveryTitle", value: "Show Previous Tab",
        comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
}

//Clipboard Toast
extension Strings {
    public static let GoToCopiedLink = MZLocalizedString(
        "ClipboardToast.GoToCopiedLink.Title", value: "Go to copied link?",
        comment: "Message displayed when the user has a copied link on the clipboard")
}

//// errors
extension Strings {
    public static let UnableToAddPassErrorTitle = MZLocalizedString(
        "AddPass.Error.Title", value: "Failed to Add Pass",
        comment:
            "Title of the 'Add Pass Failed' alert. See https://support.apple.com/HT204003 for context on Wallet."
    )
    public static let UnableToAddPassErrorMessage = MZLocalizedString(
        "AddPass.Error.Message",
        value: "An error occured while adding the pass to Wallet. Please try again later.",
        comment:
            "Text of the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet."
    )
    public static let UnableToAddPassErrorDismiss = MZLocalizedString(
        "AddPass.Error.Dismiss", value: "OK",
        comment:
            "Button to dismiss the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet."
    )
}

// Page context menu items (i.e. links and images).
extension Strings {
    public static let ContextMenuOpenInNewTab = MZLocalizedString(
        "ContextMenu.OpenInNewTabButtonTitle", value: "Open in New Tab",
        comment: "Context menu item for opening a link in a new tab")
    public static let ContextMenuOpenInNewIncognitoTab = MZLocalizedString(
        "ContextMenu.OpenInNewIncognitoTabButtonTitle", tableName: "PrivateBrowsing",
        value: "Open in New Incognito Tab",
        comment: "Context menu option for opening a link in a new Incognito Tab")
    public static let ContextMenuDownloadLink = MZLocalizedString(
        "ContextMenu.DownloadLinkButtonTitle", value: "Download Link",
        comment: "Context menu item for downloading a link URL")
    public static let ContextMenuCopyLink = MZLocalizedString(
        "ContextMenu.CopyLinkButtonTitle", value: "Copy Link",
        comment: "Context menu item for copying a link URL to the clipboard")
    public static let ContextMenuShareLink = MZLocalizedString(
        "ContextMenu.ShareLinkButtonTitle", value: "Share Link",
        comment: "Context menu item for sharing a link URL")
    public static let ContextMenuSaveImage = MZLocalizedString(
        "ContextMenu.SaveImageButtonTitle", value: "Save Image",
        comment: "Context menu item for saving an image")
    public static let ContextMenuCopyImage = MZLocalizedString(
        "ContextMenu.CopyImageButtonTitle", value: "Copy Image",
        comment: "Context menu item for copying an image to the clipboard")
    public static let ContextMenuCopyImageLink = MZLocalizedString(
        "ContextMenu.CopyImageLinkButtonTitle", value: "Copy Image Link",
        comment: "Context menu item for copying an image URL to the clipboard")
}

// Photo Library access.
extension Strings {
    public static let PhotoLibraryNeevaWouldLikeAccessTitle = MZLocalizedString(
        "PhotoLibrary.NeevaWouldLikeAccessTitle", value: "Neeva would like to access your Photos",
        comment: "See http://mzl.la/1G7uHo7")
    public static let PhotoLibraryNeevaWouldLikeAccessMessage = MZLocalizedString(
        "PhotoLibrary.NeevaWouldLikeAccessMessage",
        value: "This allows you to save the image to your Camera Roll.",
        comment: "See http://mzl.la/1G7uHo7")
}

// Keyboard short cuts
extension Strings {
    public static let ShowTabTrayFromTabKeyCodeTitle = MZLocalizedString(
        "Tab.ShowTabTray.KeyCodeTitle", value: "Show All Tabs",
        comment:
            "Hardware shortcut to open the tab tray from a tab. Shown in the Discoverability overlay when the hardware Command Key is held down."
    )
}

// Share extension
extension Strings {
    public static let SendToErrorOKButton = MZLocalizedString(
        "SendTo.Error.OK.Button", value: "OK", comment: "OK button to dismiss the error prompt.")
    public static let SendToErrorTitle = MZLocalizedString(
        "SendTo.Error.Title", value: "The link you are trying to share cannot be shared.",
        comment: "Title of error prompt displayed when an invalid URL is shared.")
    public static let SendToErrorMessage = MZLocalizedString(
        "SendTo.Error.Message", value: "Only HTTP and HTTPS links can be shared.",
        comment: "Message in error prompt explaining why the URL is invalid.")
}

//Today Widget Strings - [New Search - Private Search]
extension String {
    // Widget - Shared

    public static let QuickActionsGalleryTitle = MZLocalizedString(
        "TodayWidget.QuickActionsGalleryTitle", tableName: "Today", value: "Quick Actions",
        comment: "Quick Actions title when widget enters edit mode")
    public static let QuickActionsGalleryTitlev2 = MZLocalizedString(
        "TodayWidget.QuickActionsGalleryTitleV2", tableName: "Today", value: "Neeva Shortcuts",
        comment:
            "Neeva shortcuts title when widget enters edit mode. Do not translate the word Neeva.")

    // Quick Action - Medium Size Quick Action
    public static let GoToCopiedLinkLabelV2 = MZLocalizedString(
        "TodayWidget.GoToCopiedLinkLabelV2", tableName: "Today", value: "Go to\nCopied Link",
        comment: "Go to copied link")
    public static let GoToCopiedLinkLabelV3 = MZLocalizedString(
        "TodayWidget.GoToCopiedLinkLabelV3", tableName: "Today", value: "Go to Copied Link",
        comment:
            "Go To Copied Link text pasted on the clipboard but this string doesn't have new line character"
    )

    // Quick Action - Medium Size - Gallery View
    public static let NeevaShortcutGalleryDescription = MZLocalizedString(
        "TodayWidget.ShortcutGalleryDescription", tableName: "Today",
        value: "Add Neeva shortcuts to your Home screen.",
        comment: "Description for medium size widget to add Neeva Shortcut to home screen")

    // Quick Action - Small Size Widget
    public static let SearchInNeevaTitle = NSLocalizedString(
        "TodayWidget.SearchInNeevaTitle", tableName: "Today", value: "Search in Neeva",
        comment:
            "Title for small size widget which allows users to search in Neeva. Do not translate the word Neeva."
    )
    public static let SearchInIncognitoTabLabelV2 = MZLocalizedString(
        "TodayWidget.SearchInIncognitoTabLabelV2", tableName: "Today",
        value: "Search in\nIncognito Tab", comment: "Search in Incognito Tab")
    public static let SearchInNeevaV2 = NSLocalizedString(
        "TodayWidget.SearchInNeevaV2", tableName: "Today", value: "Search in\nNeeva",
        comment: "Search in Neeva. Do not translate the word Neeva")
    public static let CloseIncognitoTabsLabelV2 = MZLocalizedString(
        "TodayWidget.CloseIncognitoTabsLabelV2", tableName: "Today", value: "Close\nIncognito Tabs",
        comment: "Close Incognito Tabs")

    // Quick Action - Small Size Widget - Edit Mode
    public static let QuickActionDescription = MZLocalizedString(
        "TodayWidget.QuickActionDescription", tableName: "Today",
        value: "Select a Neeva shortcut to add to your Home screen.",
        comment: "Quick action description when widget enters edit mode")

    // Top Sites - Medium Size - Gallery View
    public static let TopSitesGalleryTitle = MZLocalizedString(
        "TodayWidget.TopSitesGalleryTitle", tableName: "Today", value: "Top Sites",
        comment: "Title for top sites widget to add Neeva top sites shotcuts to home screen")
    public static let TopSitesGalleryDescription = MZLocalizedString(
        "TodayWidget.TopSitesGalleryDescription", tableName: "Today",
        value: "Add shortcuts to frequently and recently visited sites.",
        comment: "Description for top sites widget to add Neeva top sites shotcuts to home screen")
}

// Default Browser
extension String {
    public static let DefaultBrowserMenuItem = MZLocalizedString(
        "Settings.DefaultBrowserMenuItem", tableName: "Default Browser",
        value: "Set as Default Browser",
        comment: "Menu option for setting Neeva as default browser.")
}

// BrowserViewController
extension String {
    public static let WebViewAccessibilityLabel = MZLocalizedString(
        "Web content", comment: "Accessibility label for the main web content view")
}

// Tab Location View
extension String {
    public static let TabLocationURLPlaceholder = MZLocalizedString(
        "Search or enter address", comment: "The text shown in the URL bar on about:home")
}

// Tab Toolbar
extension String {
    public static let TabToolbarBackAccessibilityLabel = MZLocalizedString(
        "Back", comment: "Accessibility label for the Back button in the tab toolbar.")
    public static let TabToolbarForwardAccessibilityLabel = MZLocalizedString(
        "Forward", comment: "Accessibility Label for the tab toolbar Forward button")
    public static let TabToolbarMoreAccessibilityLabel = MZLocalizedString(
        "More", comment: "Accessibility Label for the tab toolbar More button")
}

// Incognito
extension String {
    public static let IncognitoOnTitle = MZLocalizedString(
        "You are incognito", tableName: "Incognito",
        comment: "Title displayed for when there are no open tabs while in incognito mode")
    public static let IncognitoDescriptionParagraph1 = MZLocalizedString(
        "Neeva *won't save* any of your personal activity like searches, clicks or browsing.",
        tableName: "Incognito",
        comment: "Description text displayed when there are no open tabs while in private mode")
    public static let IncognitoDescriptionParagraph2 = MZLocalizedString(
        "Search privately, knowing that other people who use this device won't see your activity if you close your incognito tabs.",
        tableName: "Incognito",
        comment: "Description text displayed when there are no open tabs while in private mode")
    public static let IncognitoDescriptionParagraph3 = MZLocalizedString(
        "Your activity *might still be visible* to your internet service provider, your school or employer.",
        tableName: "Incognito",
        comment: "Description text displayed when there are no open tabs while in private mode")
}

// URL Bar
extension String {
    public static let URLBarLocationAccessibilityLabel = MZLocalizedString(
        "Address and Search",
        comment:
            "Accessibility label for address and search field, both words (Address, Search) are therefore nouns."
    )
}

// Error Pages
extension String {
    public static let ErrorPageTryAgain = MZLocalizedString(
        "Reload", tableName: "ErrorPages",
        comment: "Shown in error pages on a button that will try to load the page again")
    public static let ErrorPageOpenInSafari = MZLocalizedString(
        "Open in Safari", tableName: "ErrorPages",
        comment: "Shown in error pages for files that can't be shown and need to be downloaded.")
}

// Reader Mode Handler
extension String {
    public static let ReaderModeHandlerLoadingContent = MZLocalizedString(
        "Loading content…",
        comment:
            "Message displayed when the reader mode page is loading. This message will appear only when sharing to Neeva reader mode from another app."
    )
    public static let ReaderModeHandlerPageCantDisplay = MZLocalizedString(
        "The page could not be displayed in Reader View.",
        comment:
            "Message displayed when the reader mode page could not be loaded. This message will appear only when sharing to Neeva reader mode from another app."
    )
    public static let ReaderModeHandlerLoadOriginalPage = MZLocalizedString(
        "Load original page",
        comment:
            "Link for going to the non-reader page when the reader view could not be loaded. This message will appear only when sharing to Neeva reader mode from another app."
    )
    public static let ReaderModeHandlerError = MZLocalizedString(
        "There was an error converting the page",
        comment: "Error displayed when reader mode cannot be enabled")
}

// MenuHelper
extension String {
    public static let MenuHelperPasteAndGo = MZLocalizedString(
        "UIMenuItem.PasteGo", value: "Paste & Go",
        comment:
            "The menu item that pastes the current contents of the clipboard into the URL bar and navigates to the page"
    )
    public static let MenuHelperReveal = MZLocalizedString(
        "Reveal", tableName: "LoginManager", comment: "Reveal password text selection menu item")
    public static let MenuHelperHide = MZLocalizedString(
        "Hide", tableName: "LoginManager", comment: "Hide password text selection menu item")
    public static let MenuHelperCopy = MZLocalizedString(
        "Copy", tableName: "LoginManager", comment: "Copy password text selection menu item")
    public static let MenuHelperOpenAndFill = MZLocalizedString(
        "Open & Fill", tableName: "LoginManager",
        comment: "Open and Fill website text selection menu item")
    public static let MenuHelperFindInPage = MZLocalizedString(
        "Find in Page", tableName: "FindInPage", comment: "Text selection menu item")
    public static let MenuHelperAddToSpace = MZLocalizedString(
        "UIMenuItem.AddToSpace", value: "Add to Space",
        comment: "Add the selected text to a Space selection menu item")
}

// TimeConstants
extension String {
    public static let TimeConstantMoreThanAMonth = MZLocalizedString(
        "more than a month ago",
        comment: "Relative date for dates older than a month and less than two months.")
    public static let TimeConstantMoreThanAWeek = MZLocalizedString(
        "more than a week ago",
        comment: "Description for a date more than a week ago, but less than a month ago.")
    public static let TimeConstantYesterday = MZLocalizedString(
        "yesterday", comment: "Relative date for yesterday.")
    public static let TimeConstantThisWeek = MZLocalizedString(
        "this week", comment: "Relative date for date in past week.")
    public static let TimeConstantRelativeToday = MZLocalizedString(
        "today at %@", comment: "Relative date for date older than a minute.")
    public static let TimeConstantJustNow = MZLocalizedString(
        "just now", comment: "Relative time for a tab that was visited within the last few moments."
    )
}
