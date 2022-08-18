/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI

// Enum file that holds the different cases for the Quick Actions small widget with their configurations (string, backgrounds, images) as selected by the user in edit mode. It maps the values of IntentQuickLink enum in the QuickLinkSelectionIntent to the designated values of each case.

enum QuickLink: Int {
    case search = 1
    case copiedLink
    case incognitoSearch
    case closeIncognitoTabs

    var imageName: String {
        switch self {
        case .search:
            return "faviconNeeva"
        case .incognitoSearch:
            return "incognito"
        case .copiedLink:
            return "copiedLinkIcon"
        case .closeIncognitoTabs:
            return "delete"
        }
    }

    var label: String {
        switch self {
        case .search:
            return String.SearchInNeevaV2
        case .incognitoSearch:
            return String.SearchInIncognitoTabLabelV2
        case .copiedLink:
            return String.GoToCopiedLinkLabelV2
        case .closeIncognitoTabs:
            return String.CloseIncognitoTabsLabelV2
        }
    }

    var url: URL {
        switch self {
        case .search:
            return linkToContainingApp("?private=false", query: "open-url")
        case .incognitoSearch:
            return linkToContainingApp("?private=true", query: "open-url")
        case .copiedLink:
            return linkToContainingApp(query: "open-copied")
        case .closeIncognitoTabs:
            return linkToContainingApp(query: "close-private-tabs")
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .search:
            return [Color("searchButtonColorTwo"), Color("searchButtonColorOne")]
        case .incognitoSearch:
            return [
                Color("privateGradientThree"), Color("privateGradientTwo"),
                Color("privateGradientOne"),
            ]
        case .copiedLink:
            return [Color("goToCopiedLinkSolid")]
        case .closeIncognitoTabs:
            return [
                Color("privateGradientThree"), Color("privateGradientTwo"),
                Color("privateGradientOne"),
            ]
        }
    }

    static func from(_ configuration: QuickLinkSelectionIntent) -> Self {
        switch configuration.quickLink {
        case .search:
            return .search
        case .incongitoSearch:
            return .incognitoSearch
        case .closeIncognitoTabs:
            return .closeIncognitoTabs
        case .copiedLink:
            return .copiedLink
        default:
            return .search
        }
    }
}
