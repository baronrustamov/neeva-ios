// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import SwiftUI

// This file provides conveniences for using Neeva Icons (aka Nicons).

public enum NiconFont: String {
    case regular = "nicons-400"
    case medium = "nicons-500"
    case semibold = "nicons-600"
}

public enum Nicon: Character {
    /// 􀄩
    case arrowDown = "\u{100129}"
    /// 􀄰
    case arrowDownLeft = "\u{100130}"
    /// 􀄱
    case arrowDownRight = "\u{100131}"
    /// 􀅋
    case arrowDownRightAndArrowTopLeft = "\u{10014B}"
    /// 􀄪
    case arrowLeft = "\u{10012A}"
    /// 􀄫
    case arrowRight = "\u{10012B}"
    /// 􀄭
    case arrowRightArrowLeft = "\u{10012D}"

    case arrowTopRightOnSquare = "\u{101000}"
    /// 􀄨
    case arrowUp = "\u{100128}"
    /// 􀄬
    case arrowUpArrowDown = "\u{10012C}"
    /// 􀄮
    case arrowUpLeft = "\u{10012E}"
    /// 􀅊
    case arrowUpLeftAndArrowDownRight = "\u{10014A}"
    /// 􀄯
    case arrowUpRight = "\u{10012F}"
    /// 􀙟
    case arrowUpRightDiamondFill = "\u{10065F}"
    /// 􀉞
    case bookmark = "\u{10025E}"
    /// 􀉟
    case bookmarkFill = "\u{10025F}"

    case bookmarkOnBookmark = "\u{101010}"
    /// 􀌪
    case bubbleLeft = "\u{10032A}"
    /// 􀆈
    case chevronDown = "\u{100188}"
    /// 􀆇
    case chevronUp = "\u{100187}"

    case doubleChevronDown = "\u{101006}"
    /// 􀍟
    case gear = "\u{10035F}"
    /// 􀎞
    case house = "\u{10039E}"
    /// 🅯
    case ccBy = "\u{101013}"

    case ellipsis = "\u{100360}"

    case incognito = "\u{101004}"

    case incognitoSlash = "\u{101018}"
}

/// A wrapper for displaying either Neeva-specific or standard (SF Symbols) icons.
///
/// Usage note: If a `Symbol` will be used on its own to represent something (such as a button that conatins only an icon),
/// you **must** provide a `label` so screen reader users will be able to access the button. If you do not provide a label,
/// the symbol will be hidden from screen readers.
public struct Symbol: View {
    private enum Icon {
        case neeva(Nicon, Font)
        case sfSymbol(SFSymbol, SystemFont)
    }
    private enum SystemFont {
        case system(CGFloat, Font.Weight)
        case custom(FontStyle)
    }

    private let icon: Icon
    private let label: String?

    public static let defaultSize: CGFloat = 16

    // since this comes first, Neeva custom icons take priority over SF Symbols with the same name
    /// This produces a decorative icon, which is only suitable when combined with text. It will be invisible to users of accessibility technologies
    public init(
        decorative nicon: Nicon, size: CGFloat = Symbol.defaultSize, weight: NiconFont = .regular,
        relativeTo: Font.TextStyle = .body
    ) {
        self.icon = .neeva(nicon, Font.custom(weight.rawValue, size: size, relativeTo: relativeTo))
        self.label = nil
    }

    /// This produces a decorative icon, which is only suitable when combined with text. It will be invisible to users of accessibility technologies
    @_disfavoredOverload
    public init(
        decorative symbol: SFSymbol, size: CGFloat = Symbol.defaultSize,
        weight: Font.Weight = .medium
    ) {
        self.icon = .sfSymbol(symbol, .system(size, weight))
        self.label = nil
    }

    // since this comes first, Neeva custom icons take priority over SF Symbols with the same name
    public init(
        _ nicon: Nicon, size: CGFloat = Symbol.defaultSize, weight: NiconFont = .regular,
        relativeTo: Font.TextStyle? = .body, label: String
    ) {
        var font: Font
        if let relativeTo = relativeTo {
            font = Font.custom(weight.rawValue, size: size, relativeTo: relativeTo)
        } else {
            font = Font.custom(weight.rawValue, fixedSize: size)
        }
        self.icon = .neeva(nicon, font)
        self.label = label
    }

    @_disfavoredOverload
    public init(
        _ symbol: SFSymbol, size: CGFloat = Symbol.defaultSize, weight: Font.Weight = .medium,
        label: String
    ) {
        self.icon = .sfSymbol(symbol, .system(size, weight))
        self.label = label
    }

    public init(_ symbol: SFSymbol, style: FontStyle, label: String) {
        self.icon = .sfSymbol(symbol, .custom(style))
        self.label = label
    }

    public init(decorative symbol: SFSymbol, style: FontStyle) {
        self.icon = .sfSymbol(symbol, .custom(style))
        self.label = nil
    }

    @ViewBuilder private var content: some View {
        switch icon {
        case let .neeva(nicon, font):
            Text(String(nicon.rawValue))
                .font(font)
        case let .sfSymbol(symbol, .system(size, weight)):
            Image(systemSymbol: symbol)
                .renderingMode(.template)
                .font(.system(size: size, weight: weight))
        case let .sfSymbol(symbol, .custom(style)):
            Image(systemSymbol: symbol)
                .renderingMode(.template)
                .withFont(style)
        }
    }

    public var body: some View {
        if let label = label {
            content.accessibilityLabel(label)
        } else {
            content.accessibilityHidden(true)
        }
    }
}

extension Symbol {
    public static func uiImage(
        _ symbol: SFSymbol, size: CGFloat = Symbol.defaultSize,
        weight: UIImage.SymbolWeight = .medium
    ) -> UIImage {
        UIImage(
            systemSymbol: symbol,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: size, weight: weight, scale: .medium))
    }
}
