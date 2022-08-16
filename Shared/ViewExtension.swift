// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

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

extension EnvironmentValues {
    private struct HideOverlayKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }

    public var hideOverlay: () -> Void {
        get { self[HideOverlayKey.self] }
        set { self[HideOverlayKey.self] = newValue }
    }
}
