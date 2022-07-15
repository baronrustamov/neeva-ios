// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// Enable cornerRadius to apply only to specific corners.
// From https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: CornerSet = .all

    @Environment(\.layoutDirection) var layoutDirection

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners.rectCorners(for: layoutDirection),
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public struct CornerSet: OptionSet {
    public static let top: CornerSet = [.topLeading, .topTrailing]
    public static let bottom: CornerSet = [.bottomLeading, .bottomTrailing]
    public static let leading: CornerSet = [.topLeading, bottomLeading]
    public static let trailing: CornerSet = [.topTrailing, bottomTrailing]
    public static let all: CornerSet = [.top, .bottom]

    public static let topLeading = Self(rawValue: [.topLeading])
    public static let topTrailing = Self(rawValue: [.topTrailing])
    public static let bottomLeading = Self(rawValue: [.bottomLeading])
    public static let bottomTrailing = Self(rawValue: [.bottomTrailing])

    public var rawValue: Set<Value>
    public init(rawValue: Set<Value>) {
        self.rawValue = rawValue
    }
    public init() {
        self.rawValue = []
    }

    @inlinable public mutating func formUnion(_ other: __owned CornerSet) {
        rawValue.formUnion(other.rawValue)
    }
    @inlinable public mutating func formIntersection(_ other: CornerSet) {
        rawValue.formIntersection(other.rawValue)
    }
    @inlinable public mutating func formSymmetricDifference(_ other: __owned CornerSet) {
        rawValue.formSymmetricDifference(other.rawValue)
    }

    public enum Value {
        case topLeading, topTrailing
        case bottomLeading, bottomTrailing

        fileprivate func rectCorner(for direction: LayoutDirection) -> UIRectCorner {
            let isRTL = direction == .rightToLeft
            switch self {
            case .topLeading: return isRTL ? .topRight : .topLeft
            case .topTrailing: return isRTL ? .topLeft : .topRight
            case .bottomLeading: return isRTL ? .bottomRight : .bottomLeft
            case .bottomTrailing: return isRTL ? .bottomLeft : .bottomRight
            }
        }
    }

    fileprivate func rectCorners(for direction: LayoutDirection) -> UIRectCorner {
        rawValue.reduce(into: []) { partialResult, corner in
            partialResult.insert(corner.rectCorner(for: direction))
        }
    }
}

extension View {
    /// Clips the views to a rectangle with only the specified corners rounded.
    public func cornerRadius(_ radius: CGFloat, corners: CornerSet) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Applies a toggle style that turns them from green to blue
    public func applyToggleStyle() -> some View {
        toggleStyle(SwitchToggleStyle(tint: Color.ui.adaptive.blue))
    }

    /// Sizes the view to 44×44 pixels, the standard tap target size
    public func tapTargetFrame() -> some View {
        frame(width: 44, height: 44)
    }
}

// From https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder public func `if`<Content: View>(
        _ condition: @autoclosure () -> Bool, transform: (Self) -> Content
    ) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

    /// Applies the given transform if the given value is non-`nil`.
    /// - Parameters:
    ///   - value: The value to check
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the value is non-`nil`.
    @ViewBuilder public func `if`<Value, Content: View>(
        `let` value: @autoclosure () -> Value?, transform: (Value, Self) -> Content
    ) -> some View {
        if let value = value() {
            transform(value, self)
        } else {
            self
        }
    }
}

private struct ScreenSpaceOffset: ViewModifier {
    let x: CGFloat
    let y: CGFloat

    @Environment(\.layoutDirection) private var layoutDirection
    func body(content: Content) -> some View {
        content.offset(x: x * layoutDirection.xSign, y: y)
    }
}

extension View {
    /// Overrides right-to-left/left-to-right preference to always move in the standard direction
    /// Only use this if you have a good reason (such as because the offset is driven by a user gesture)
    public func translate(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        modifier(ScreenSpaceOffset(x: x, y: y))
    }
}

extension View {
    @ViewBuilder public func accesibilityFocus(shouldFocus: Bool, trigger: Bool) -> some View {
        if #available(iOS 15.0, *) {
            modifier(FocusOnAppearModifier(focus: shouldFocus, trigger: trigger))
        } else {
            self
        }
    }
}

@available(iOS 15.0, *)
private struct FocusOnAppearModifier: ViewModifier {
    let focus: Bool
    let trigger: Bool

    @AccessibilityFocusState var isFocused

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isFocused)
            .onChange(of: trigger) { trigger in
                if focus && trigger {
                    DispatchQueue.main.async {
                        isFocused = true
                    }
                }
            }
    }
}

/*
    Allows conditional View modifiers based on iOS version. https://stackoverflow.com/a/71203870
    Usage:

    Text("Hello, world!")
        .modify {
            if #available(iOS 15.0, *) {
                $0.modifier()
            } else {
                $0
            }
        }
 */
extension View {
    public func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
