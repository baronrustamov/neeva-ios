/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

private struct Color {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
}

extension UIColor {
    public convenience init(light: UIColor, dark: UIColor) {
        self.init { traits in
            switch traits.userInterfaceStyle {
            case .dark: return dark
            default: return light
            }
        }
    }

    /// Initializes and returns a color object for the given RGB hex integer.
    public convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((rgb & 0x0000FF) >> 0) / 255.0,
            alpha: 1)
    }

    public convenience init(rgba: UInt32) {
        self.init(
            red: CGFloat((rgba & 0xFF00_0000) >> 24) / 255.0,
            green: CGFloat((rgba & 0x00FF_0000) >> 16) / 255.0,
            blue: CGFloat((rgba & 0x0000_FF00) >> 8) / 255.0,
            alpha: CGFloat((rgba & 0x0000_00FF) >> 0) / 255.0
        )
    }

    public convenience init(colorString: String) {
        var colorInt: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&colorInt)
        self.init(rgb: (Int)(colorInt))
    }

    public var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)),
            lroundf(Float(b * 255)))
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }

        return color
    }

    public var swappedForStyle: UIColor {
        return UIColor { traits in
            let style: UIUserInterfaceStyle = traits.userInterfaceStyle == .dark ? .light : .dark
            return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        }
    }

    public var lightVariant: UIColor {
        return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
    }

    public var darkVariant: UIColor {
        return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    }

    public var elevated: UIColor {
        UIColor { traits in
            self.resolvedColor(
                with: UITraitCollection(traitsFrom: [traits, .init(userInterfaceLevel: .elevated)]))
        }
    }
}
