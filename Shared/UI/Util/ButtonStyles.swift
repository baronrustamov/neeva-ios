// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// A button style that sets its background color to gray when highlighted, matching a table view cell
public struct TableCellButtonStyle: ButtonStyle {
    let padding: EdgeInsets

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .background(
                Color.selectedCell
                    .opacity(configuration.isPressed ? 1 : 0)
                    .padding(padding)
                    .ignoresSafeArea(.container)
            )
    }
}

extension ButtonStyle where Self == TableCellButtonStyle {
    public static var tableCell: Self { .init(padding: EdgeInsets()) }

    public static func tableCell(padding: EdgeInsets) -> Self {
        .init(padding: padding)
    }
    public static func tableCell(padding: CGFloat) -> Self {
        .init(
            padding: EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding))
    }
    public static func tableCell(padding edges: Edge.Set, _ padding: CGFloat) -> Self {
        .init(padding: EdgeInsets(edges: edges, amount: padding))
    }

}

/// A button style that prevents the button’s label from dimming when the user presses down on it
public struct HighlightlessButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == HighlightlessButtonStyle {
    public static var highlightless: Self { .init() }
}

public struct NeevaButtonStyle: ButtonStyle {
    public enum VisualSpec {
        case primary
        case secondary
        case clear
    }

    let visualSpec: VisualSpec
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(visualSpec == VisualSpec.primary ? .white : .label)
            .padding(.vertical, 8)
            .frame(height: 48)
            .background(
                Capsule()
                    .fill(
                        visualSpec == .primary
                            ? (configuration.isPressed
                                ? Color.brand.variant.blue : Color.ui.adaptive.blue)
                            : visualSpec == .secondary
                                ? (configuration.isPressed
                                    ? Color.systemFill : Color.quaternarySystemFill)
                                : Color.clear
                    )
                    .opacity(isEnabled ? 1 : 0.5)
            )
    }
}

extension ButtonStyle where Self == NeevaButtonStyle {
    public static func neeva(_ visualSpec: NeevaButtonStyle.VisualSpec) -> Self {
        .init(visualSpec: visualSpec)
    }
}
