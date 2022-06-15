/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SwiftUI

extension UIColor {
    // These are defaults from http://design.firefox.com/photon/visuals/color.html
    struct Defaults {
        static let LightBeige = UIColor(rgb: 0xf0e6dc)
    }
}

extension Color {
    public enum Tour {
        public static let Background = Color(UIColor.Tour.Background)
        public static let Title = Color(UIColor.Tour.Title)
        public static let Description = Color(UIColor.Tour.Description)
        public static let ButtonBackground = Color(UIColor.Tour.ButtonBackground)
        public static let ButtonText = Color(UIColor.Tour.ButtonText)
    }
}

public struct UIConstants {
    static let TextFieldHeight: CGFloat = 42

    // Landscape and tablet mode:
    static let TopToolbarHeightWithToolbarButtonsShowing: CGFloat = TextFieldHeight + 8

    // Bottom bar when in portrait mode on a phone:
    static var ToolbarHeight: CGFloat = 55
    static let PortraitToolbarHeight: CGFloat = 50
    static var BottomToolbarHeight: CGFloat {
        return ToolbarHeight + safeArea.bottom
    }

    // ArchivedTab View
    static let ArchivedTabsViewHeight: CGFloat = 80

    /// JPEG compression quality for persisted screenshots. Must be between 0-1.
    static let ScreenshotQuality: Float = 0.3
    static let ActiveScreenshotQuality: CGFloat = 0.5

    static var safeArea: UIEdgeInsets {
        let keyWindow = SceneDelegate.getKeyWindow(for: nil)
        return keyWindow.safeAreaInsets
    }

    static var hasHomeButton: Bool {
        Self.safeArea.bottom == 0
    }

    static var enableBottomURLBar: Bool {
        FeatureFlag[.bottomURLBar] && UIDevice.current.userInterfaceIdiom != .pad
    }
}

extension UIColor {
    public struct HomePanel {
        public static let topSitesBackground = UIColor.systemBackground
        public static let welcomeScreenText = UIColor.secondaryLabel
    }
}

extension UIColor {
    public enum Tour {
        public static let Background = UIColor(named: "Tour-Background")!
        public static let Title = UIColor(named: "Tour-Title")!
        public static let Description = UIColor(named: "Tour-Description")!
        public static let ButtonBackground = UIColor(named: "Tour-Button-Background")!
        public static let ButtonText = UIColor(named: "Tour-Button-Text")!
    }
}
