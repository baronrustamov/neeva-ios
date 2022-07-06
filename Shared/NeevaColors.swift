// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import UIKit

extension UIColor {
    public enum brand {
        public static let blue = UIColor(
            named: "Brand/Blue", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let seafoam = UIColor(
            named: "Brand/Seafoam", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let polar = UIColor(
            named: "Brand/Polar", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let pistachio = UIColor(
            named: "Brand/Pistachio", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let offwhite = UIColor(
            named: "Brand/Offwhite", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let red = UIColor(
            named: "Brand/Red", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let orange = UIColor(
            named: "Brand/Orange", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let peach = UIColor(
            named: "Brand/Peach", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let yellow = UIColor(
            named: "Brand/Yellow", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let pink = UIColor(
            named: "Brand/Pink", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let green = UIColor(
            named: "Brand/Green", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let mint = UIColor(
            named: "Brand/Mint", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let maya = UIColor(
            named: "Brand/Maya", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gold = UIColor(
            named: "Brand/Gold", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let purple = UIColor(
            named: "Brand/Purple", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

        public static let charcoal = UIColor(
            named: "Brand/Charcoal", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let white = UIColor(
            named: "Brand/White", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let beige = UIColor(
            named: "Brand/Beige", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

        public enum variant {
            public static let blue = UIColor(
                named: "Brand/Blue Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let seafoam = UIColor(
                named: "Brand/Seafoam Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil
            )!
            public static let polar = UIColor(
                named: "Brand/Polar Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let pistachio = UIColor(
                named: "Brand/Pistachio Variant", in: NeevaConstants.sharedBundle,
                compatibleWith: nil)!
            public static let offwhite = UIColor(
                named: "Brand/Offwhite Variant", in: NeevaConstants.sharedBundle,
                compatibleWith: nil)!
            public static let red = UIColor(
                named: "Brand/Red Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let orange = UIColor(
                named: "Brand/Orange Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let peach = UIColor(
                named: "Brand/Peach Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let yellow = UIColor(
                named: "Brand/Yellow Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let pink = UIColor(
                named: "Brand/Pink Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let green = UIColor(
                named: "Brand/Green Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let mint = UIColor(
                named: "Brand/Mint Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let maya = UIColor(
                named: "Brand/Maya Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gold = UIColor(
                named: "Brand/Gold Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let purple = UIColor(
                named: "Brand/Purple Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        }

        public enum adaptive {
            public static let maya = UIColor(light: .brand.maya, dark: .brand.variant.maya)
            public static let polar = UIColor(light: .brand.polar, dark: .brand.variant.polar)
            public static let pistachio = UIColor(
                light: .brand.pistachio, dark: .brand.variant.pistachio)
            public static let orange = UIColor(light: .brand.variant.orange, dark: .brand.orange)
        }

        public enum candidate {
            public static let pistachio = UIColor(
                named: "Brand/Pistachio Candidate", in: NeevaConstants.sharedBundle,
                compatibleWith: nil)!
            public static let blueUI = UIColor(
                named: "Brand/Blue UI Candidate", in: NeevaConstants.sharedBundle,
                compatibleWith: nil)!
        }
    }

    public enum ui {
        public static let aqua = UIColor(
            named: "UI/Aqua", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let backdrop = UIColor(
            named: "UI/Backdrop", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray10 = UIColor(
            named: "UI/Gray 10", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray20 = UIColor(
            named: "UI/Gray 20", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray30 = UIColor(
            named: "UI/Gray 30", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray40 = UIColor(
            named: "UI/Gray 40", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray50 = UIColor(
            named: "UI/Gray 50", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray60 = UIColor(
            named: "UI/Gray 60", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray70 = UIColor(
            named: "UI/Gray 70", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray80 = UIColor(
            named: "UI/Gray 80", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray91 = UIColor(
            named: "UI/Gray 91", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray96 = UIColor(
            named: "UI/Gray 96", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray97 = UIColor(
            named: "UI/Gray 97", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray98 = UIColor(
            named: "UI/Gray 98", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let gray99 = UIColor(
            named: "UI/Gray 99", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let quarternary = UIColor(
            named: "UI/Quarternary", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

        public enum adaptive {
            public static let blue = UIColor(
                named: "UI/Blue", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let separator = UIColor(
                named: "UI/Separator", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        }

        public enum variant {
            public static let aqua = UIColor(
                named: "UI/Aqua Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        }
    }

    public static let DefaultBackground = UIColor(
        named: "Background", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let DefaultTextAndTint = UIColor(
        named: "TextAndTint", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let ElevatedDarkBackground = UIColor(
        named: "DarkElevated", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let SelectedCell = UIColor(
        named: "SelectedCell", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let TrayBackground = UIColor(
        named: "TrayBackground", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let TextSelectionHighlight = UIColor(
        named: "TextSelectionHighlight", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let PreviewHomeBackground = UIColor(
        named: "PreviewHomeBackground", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    public static let SpaceIconBackground = UIColor.brand.variant.polar
}

extension Color {
    public enum brand {
        public static let blue = Color(UIColor.brand.blue)
        public static let seafoam = Color(UIColor.brand.seafoam)
        public static let polar = Color(UIColor.brand.polar)
        public static let pistachio = Color(UIColor.brand.pistachio)
        public static let offwhite = Color(UIColor.brand.offwhite)
        public static let red = Color(UIColor.brand.red)
        public static let orange = Color(UIColor.brand.orange)
        public static let peach = Color(UIColor.brand.peach)
        public static let yellow = Color(UIColor.brand.yellow)
        public static let pink = Color(UIColor.brand.pink)
        public static let green = Color(UIColor.brand.green)
        public static let mint = Color(UIColor.brand.mint)
        public static let maya = Color(UIColor.brand.maya)
        public static let gold = Color(UIColor.brand.gold)
        public static let purple = Color(UIColor.brand.purple)

        public enum variant {
            public static let blue = Color(UIColor.brand.variant.blue)
            public static let seafoam = Color(UIColor.brand.variant.seafoam)
            public static let polar = Color(UIColor.brand.variant.polar)
            public static let pistachio = Color(UIColor.brand.variant.pistachio)
            public static let offwhite = Color(UIColor.brand.variant.offwhite)
            public static let red = Color(UIColor.brand.variant.red)
            public static let orange = Color(UIColor.brand.variant.orange)
            public static let peach = Color(UIColor.brand.variant.peach)
            public static let yellow = Color(UIColor.brand.variant.yellow)
            public static let pink = Color(UIColor.brand.variant.pink)
            public static let green = Color(UIColor.brand.variant.green)
            public static let mint = Color(UIColor.brand.variant.mint)
            public static let maya = Color(UIColor.brand.variant.maya)
            public static let gold = Color(UIColor.brand.variant.gold)
            public static let purple = Color(UIColor.brand.variant.purple)

            public enum adaptive {
                public static let polar = Color(
                    light: Color(UIColor.brand.variant.polar),
                    dark: Color(hex: 0x415AFF)
                )

                public static let shadow = Color(
                    light: Color(hex: 0x4D88E8, opacity: 0.1),
                    dark: Color(hex: 0x1C3BC7, opacity: 0.1)
                )
            }
        }

        public static let charcoal = Color(UIColor.brand.charcoal)
        public static let white = Color(UIColor.brand.white)
        public static let beige = Color(UIColor.brand.beige)

        public enum adaptive {
            public static let maya = Color(UIColor.brand.adaptive.maya)
            public static let polar = Color(UIColor.brand.adaptive.polar)
            public static let pistachio = Color(UIColor.brand.adaptive.pistachio)
            public static let orange = Color(UIColor.brand.adaptive.orange)
        }

        public enum candidate {
            public static let pistachio = Color(UIColor.brand.candidate.pistachio)
            public static let blueUI = Color(UIColor.brand.candidate.blueUI)
        }
    }

    public enum ui {
        public static let aqua = Color(UIColor.ui.aqua)
        public static let backdrop = Color(UIColor.ui.backdrop)
        public static let gray10 = Color(UIColor.ui.gray10)
        public static let gray20 = Color(UIColor.ui.gray20)
        public static let gray30 = Color(UIColor.ui.gray30)
        public static let gray40 = Color(UIColor.ui.gray40)
        public static let gray50 = Color(UIColor.ui.gray50)
        public static let gray60 = Color(UIColor.ui.gray60)
        public static let gray70 = Color(UIColor.ui.gray70)
        public static let gray80 = Color(UIColor.ui.gray80)
        public static let gray91 = Color(UIColor.ui.gray91)
        public static let gray96 = Color(UIColor.ui.gray96)
        public static let gray97 = Color(UIColor.ui.gray97)
        public static let gray98 = Color(UIColor.ui.gray98)
        public static let gray99 = Color(UIColor.ui.gray99)
        public static let quarternary = Color(UIColor.ui.quarternary)

        public enum adaptive {
            public static let blue = Color(UIColor.ui.adaptive.blue)
            public static let separator = Color(UIColor.ui.adaptive.separator)
        }

        public enum variant {
            public static let aqua = Color(UIColor.ui.variant.aqua)
        }
    }

    public static let DefaultBackground = Color(UIColor.DefaultBackground)
    public static let TrayBackground = Color(UIColor.TrayBackground)
    public static let elevatedDarkBackground = Color(UIColor.ElevatedDarkBackground)
    public static let textSelectionHighlight = Color(UIColor.TextSelectionHighlight)
    public static let selectedCell = Color(UIColor.SelectedCell)

    public static let spaceIconBackground = Color(UIColor.SpaceIconBackground)

    public static let PreviewHomeBackground = Color(UIColor.PreviewHomeBackground)
}
