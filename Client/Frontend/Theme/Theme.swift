/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation
import Shared

protocol IncognitoModeUI {
    func applyUIMode(isIncognito: Bool)
}

extension UIColor {
    enum legacyTheme {
        enum tableView {
            static let rowBackground = UIColor(light: .Photon.White100, dark: .Photon.Grey70)
            static let rowText = UIColor(light: .Photon.Grey90, dark: .Photon.Grey90)
            static let disabledRowText = UIColor.Photon.Grey40
            static let separator = UIColor(light: .Photon.Grey30, dark: .Photon.Grey60)
            static let headerBackground = UIColor(light: .white, dark: .Photon.Grey80)
            // Used for table headers in home panel tables
            static let headerTextDark = UIColor(light: .Photon.Grey90, dark: .Photon.Grey30)
        }
    }
<<<<<<< HEAD
=======

    var readerModeButtonSelected: UIColor { return UIColor.Photon.Blue40 }
    var readerModeButtonUnselected: UIColor { return UIColor.Photon.Grey50 }
    var pageOptionsSelected: UIColor { return readerModeButtonSelected }
    var pageOptionsUnselected: UIColor { return UIColor.theme.browser.tint }
}

class BrowserColor {
    var background: UIColor { return defaultBackground }
    var urlBarDivider: UIColor { return UIColor.Photon.Grey90A10 }
    var tint: UIColor { return defaultTextAndTint }
}

// The back/forward/refresh/menu button (bottom toolbar)
class ToolbarButtonColor {
    var selectedTint: UIColor { return UIColor.Photon.Blue40 }
    var disabledTint: UIColor { return UIColor.Photon.Grey30 }
}

class LoadingBarColor {
    func start(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.Photon.Blue40A30 : UIColor.Photon.Magenta60A30
    }

    func end(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.Photon.Teal60 : UIColor.Photon.Purple60
    }
}

class TabTrayColor {
    var tabTitleText: UIColor { return UIColor.black }
    var tabTitleBlur: UIBlurEffect.Style { return UIBlurEffect.Style.extraLight }
    var background: UIColor { return UIColor.Photon.Grey80 }
    var cellBackground: UIColor { return defaultBackground }
    var toolbar: UIColor { return defaultBackground }
    var toolbarButtonTint: UIColor { return defaultTextAndTint }
    var privateModeLearnMore: UIColor { return UIColor.Photon.Purple60 }
    var privateModePurple: UIColor { return UIColor.Photon.Purple60 }
    var privateModeButtonOffTint: UIColor { return toolbarButtonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Photon.Grey10 }
    var cellCloseButton: UIColor { return UIColor.Photon.Grey50 }
    var cellTitleBackground: UIColor { return UIColor.clear }
    var faviconTint: UIColor { return UIColor.black }
    var searchBackground: UIColor { return UIColor.Photon.Grey30 }
}

class TopTabsColor {
    var background: UIColor { return UIColor.Photon.Grey80 }
    var tabBackgroundSelected: UIColor { return UIColor.Photon.Grey10 }
    var tabBackgroundUnselected: UIColor { return UIColor.Photon.Grey80 }
    var tabForegroundSelected: UIColor { return UIColor.Photon.Grey90 }
    var tabForegroundUnselected: UIColor { return UIColor.Photon.Grey40 }
    func tabSelectedIndicatorBar(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.Photon.Blue40 : UIColor.Photon.Purple60
    }
    var buttonTint: UIColor { return UIColor.Photon.Grey40 }
    var privateModeButtonOffTint: UIColor { return buttonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Photon.Grey10 }
    var closeButtonSelectedTab: UIColor { return tabBackgroundUnselected }
    var closeButtonUnselectedTab: UIColor { return tabBackgroundSelected }
    var separator: UIColor { return UIColor.Photon.Grey70 }
}

class TextFieldColor {
    var background: UIColor { return UIColor.Photon.Grey25 }
    var backgroundInOverlay: UIColor { return UIColor.Photon.Grey25 }
    var textAndTint: UIColor { return defaultTextAndTint }
    var separator: UIColor { return .white }
}

class HomePanelColor {
    var toolbarBackground: UIColor { return defaultBackground }
    var toolbarHighlight: UIColor { return UIColor.Photon.Blue40 }
    var toolbarTint: UIColor { return UIColor.Photon.Grey50 }

    var panelBackground: UIColor { return UIColor.Photon.White100 }

    var separator: UIColor { return defaultSeparator }
    var border: UIColor { return UIColor.Photon.Grey60 }
    var buttonContainerBorder: UIColor { return separator }
    
    var welcomeScreenText: UIColor { return UIColor.Photon.Grey50 }
    
    var siteTableHeaderBorder: UIColor { return UIColor.Photon.Grey30.withAlphaComponent(0.8) }

    var topSiteDomain: UIColor { return UIColor.black }
    var topSitesGradientStart: UIColor { return UIColor.white }
    var topSitesGradientEnd: UIColor { return UIColor(rgb: 0xf8f8f8) }
    var topSitesBackground: UIColor { return UIColor.white }

    var activityStreamHeaderText: UIColor { return UIColor.Photon.Grey50 }
    var activityStreamCellTitle: UIColor { return UIColor.black }
    var activityStreamCellDescription: UIColor { return UIColor.Photon.Grey60 }

    var readingListActive: UIColor { return defaultTextAndTint }
    var readingListDimmed: UIColor { return UIColor.Photon.Grey40 }
    
    var downloadedFileIcon: UIColor { return UIColor.Photon.Grey60 }
    
    var historyHeaderIconsBackground: UIColor { return UIColor.Photon.White100 }

    var searchSuggestionPillBackground: UIColor { return UIColor.Photon.White100 }
    var searchSuggestionPillForeground: UIColor { return UIColor.Photon.Blue40 }
}

class SnackBarColor {
    var highlight: UIColor { return UIColor.Defaults.iOSTextHighlightBlue.withAlphaComponent(0.9) }
    var highlightText: UIColor { return UIColor.Photon.Blue40 }
    var border: UIColor { return UIColor.Photon.Grey30 }
    var title: UIColor { return UIColor.Photon.Blue40 }
}

class GeneralColor {
    var faviconBackground: UIColor { return UIColor.clear }
    var passcodeDot: UIColor { return UIColor.Photon.Grey60 }
    var highlightBlue: UIColor { return UIColor.Photon.Blue40 }
    var destructiveRed: UIColor { return UIColor.Photon.Red50 }
    var separator: UIColor { return defaultSeparator }
    var settingsTextPlaceholder: UIColor { return UIColor.Photon.Grey40 }
    var controlTint: UIColor { return UIColor.Photon.Blue40 }
    var switchToggle: UIColor { return UIColor.Photon.Grey90A40 }
}

class DefaultBrowserCardColor {
    var backgroundColor: UIColor { return UIColor.Photon.Grey30 }
    var textColor: UIColor { return UIColor.black }
    var closeButtonBackground: UIColor { return UIColor.Photon.Grey20 }
    var closeButton: UIColor { return UIColor.Photon.Grey80 }
}

protocol Theme {
    var name: String { get }
    var tableView: TableViewColor { get }
    var urlbar: URLBarColor { get }
    var browser: BrowserColor { get }
    var toolbarButton: ToolbarButtonColor { get }
    var loadingBar: LoadingBarColor { get }
    var tabTray: TabTrayColor { get }
    var topTabs: TopTabsColor { get }
    var textField: TextFieldColor { get }
    var homePanel: HomePanelColor { get }
    var snackbar: SnackBarColor { get }
    var general: GeneralColor { get }
    var actionMenu: ActionMenuColor { get }
    var switchToggleTheme: GeneralColor { get }
    var defaultBrowserCard: DefaultBrowserCardColor { get }
}

class NormalTheme: Theme {
    var name: String { return BuiltinThemeName.normal.rawValue }
    var tableView: TableViewColor { return TableViewColor() }
    var urlbar: URLBarColor { return URLBarColor() }
    var browser: BrowserColor { return BrowserColor() }
    var toolbarButton: ToolbarButtonColor { return ToolbarButtonColor() }
    var loadingBar: LoadingBarColor { return LoadingBarColor() }
    var tabTray: TabTrayColor { return TabTrayColor() }
    var topTabs: TopTabsColor { return TopTabsColor() }
    var textField: TextFieldColor { return TextFieldColor() }
    var homePanel: HomePanelColor { return HomePanelColor() }
    var snackbar: SnackBarColor { return SnackBarColor() }
    var general: GeneralColor { return GeneralColor() }
    var actionMenu: ActionMenuColor { return ActionMenuColor() }
    var switchToggleTheme: GeneralColor { return GeneralColor() }
    var defaultBrowserCard: DefaultBrowserCardColor { return DefaultBrowserCardColor() }
>>>>>>> parent of 4e81b3f2d (Remove search engine switching, Neeva branding and Search Engine view modifications)
}
