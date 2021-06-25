// Copyright © Neeva. All rights reserved.
import SwiftUI

// Enable cornerRadius to apply only to specific corners.
// From https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension UIRectCorner {
    static let top: UIRectCorner = [.topLeft, .topRight]
    static let bottom: UIRectCorner = [.bottomLeft, .bottomRight]
    static let left: UIRectCorner = [.topLeft, .bottomLeft]
    static let right: UIRectCorner = [.topRight, .bottomRight]
}

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    public func applyToggleStyle() -> some View {
        toggleStyle(SwitchToggleStyle(tint: Color.ui.adaptive.blue))
    }
}

// From https://www.avanderlee.com/swiftui/conditional-view-modifier/
public extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
