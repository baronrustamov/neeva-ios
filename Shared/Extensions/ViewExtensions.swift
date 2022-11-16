// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SwiftUI

// MARK: - Corner Radius
// Enable cornerRadius to apply only to specific corners.
// From https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: CornerSet = .all

    let layoutDirection: LayoutDirection

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners.rectCorners(for: layoutDirection),
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

/// RoundedCornerModifier to apply clipShape with `RoundedCorner`
///
/// This wrapper helps silence the runtime warning.
/// ```[SwiftUI] Accessing Environment<LayoutDirection>'s value outside of being installed on a View. This will always read the default value and will not update.```
/// It appears that accessing the Environment value in a ViewModifier is allowed
private struct RoundedCornerModifier: ViewModifier {
    @Environment(\.layoutDirection) var layoutDirection

    let radius: CGFloat
    let corners: CornerSet

    func body(content: Content) -> some View {
        content
            .clipShape(
                RoundedCorner(radius: radius, corners: corners, layoutDirection: layoutDirection)
            )
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
        modifier(RoundedCornerModifier(radius: radius, corners: corners))
    }
}

// MARK: - Toggle Style
extension View {
    /// Applies a toggle style that turns them from green to blue
    public func applyToggleStyle() -> some View {
        toggleStyle(SwitchToggleStyle(tint: Color.ui.adaptive.blue))
    }

    /// Sizes the view to 44×44 pixels, the standard tap target size
    public func tapTargetFrame() -> some View {
        frame(width: 44, height: 44)
    }
}

// MARK: - if
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

// MARK: - Screen Space Offset
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

// MARK: - FocusOnAppear
public struct FocusOnAppearModifier: ViewModifier {
    let focus: Bool
    let trigger: Bool

    @AccessibilityFocusState var isFocused

    public func body(content: Content) -> some View {
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

    public init(focus: Bool, trigger: Bool) {
        self.focus = focus
        self.trigger = trigger
    }
}

// MARK: - React Style Hooks
private struct Pair<T0: Equatable, T1: Equatable>: Equatable {
    let zero: T0, one: T1
}

private struct Tuple<T0: Equatable, T1: Equatable, T2: Equatable>: Equatable {
    let zero: T0, one: T1, two: T2
}

extension View {
    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    public func useEffect<T: Equatable>(deps: T, perform updater: @escaping (T) -> Void)
        -> some View
    {
        self.onChange(of: deps, perform: updater)
            .onAppear { updater(deps) }
    }

    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    public func useEffect<T0: Equatable, T1: Equatable>(
        deps zero: T0, _ one: T1, perform updater: @escaping (T0, T1) -> Void
    ) -> some View {
        self.onChange(of: Pair(zero: zero, one: one)) { updater($0.zero, $0.one) }
            .onAppear { updater(zero, one) }
    }

    public func useEffect<T0: Equatable, T1: Equatable, T2: Equatable>(
        deps zero: T0, _ one: T1, _ two: T2, perform updater: @escaping (T0, T1, T2) -> Void
    ) -> some View {
        self.onChange(of: Tuple(zero: zero, one: one, two: two)) {
            updater($0.zero, $0.one, $0.two)
        }
        .onAppear { updater(zero, one, two) }
    }

    // Publisher variants. Useful when you just want to observe a particular published
    // var of a model and not the entire model. Runs updater task asynchronously from
    // onReceive to simulate the behavior of onChange and to ensure that the published
    // var being updated has been updated by the time updater runs.
    public func useEffect<P>(_ p1: P, perform updater: @escaping () -> Void) -> some View
    where P: Publisher, P.Failure == Never {
        self.onReceive(p1) { _ in DispatchQueue.main.async(execute: updater) }
            .onAppear { updater() }
    }

    public func useEffect<P>(_ p1: P, _ p2: P, perform updater: @escaping () -> Void) -> some View
    where P: Publisher, P.Failure == Never {
        self.onReceive(p1) { _ in DispatchQueue.main.async(execute: updater) }
            .onReceive(p2) { _ in DispatchQueue.main.async(execute: updater) }
            .onAppear { updater() }
    }
}

// MARK: - Rounded Outer Border
/// Wraps a border around the content to which it is applied, resulting in
/// the content being `2 * lineWidth` larger in width and height.
struct RoundedOuterBorder: ViewModifier {
    let cornerRadius: CGFloat
    let color: Color
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .cornerRadius(cornerRadius)
            .padding(lineWidth)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius + lineWidth)
                    .strokeBorder(color, lineWidth: lineWidth)
            )
    }
}

extension View {
    public func roundedOuterBorder(cornerRadius: CGFloat, color: Color, lineWidth: CGFloat = 1)
        -> some View
    {
        self.modifier(
            RoundedOuterBorder(cornerRadius: cornerRadius, color: color, lineWidth: lineWidth))
    }
}

// MARK: - Overlay
extension EnvironmentValues {
    private struct HideOverlayKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }

    public var hideOverlay: () -> Void {
        get { self[HideOverlayKey.self] }
        set { self[HideOverlayKey.self] = newValue }
    }
}

// MARK: - On Size of View Changed
extension View {
    public func onHeightOfViewChanged(perform updater: @escaping (CGFloat) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.size.height) { height in
                            updater(height)
                        }
                }
            )
    }

    public func onWidthOfViewChanged(perform updater: @escaping (CGFloat) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.size.width) { width in
                            updater(width)
                        }
                }
            )
    }

    public func onSizeOfViewChanged(perform updater: @escaping (CGSize) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.size) { size in
                            updater(size)
                        }
                }
            )
    }

    public func safeAreaChanged(perform updater: @escaping (EdgeInsets) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.safeAreaInsets) { insets in
                            updater(insets)
                        }
                }
            )
    }
}
