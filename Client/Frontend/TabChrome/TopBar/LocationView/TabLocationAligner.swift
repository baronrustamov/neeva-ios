// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

/// SwiftUI magic that center-aligns the location label in the location view, even if
/// the leading and trailing buttons are different widths.
///
/// **Warning:** This view has not been tested with layouts where `Leading` is wider than `Trailing`.
/// If that is possible with the parameters you pass, make sure to check that it works properly.
struct TabLocationAligner<Leading: View, Label: View, LabelOverlay: View, Trailing: View>: View {
    let transitionToEditing: Bool
    let debug: Bool
    let leadingActions: () -> Leading
    let label: () -> Label
    let labelOverlay: (EdgeInsets) -> LabelOverlay
    let trailingActions: () -> Trailing

    init(
        transitionToEditing: Bool,
        debug: Bool = FeatureFlag[.debugURLBar],
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder labelOverlay: @escaping (EdgeInsets) -> LabelOverlay,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.transitionToEditing = transitionToEditing
        self.debug = debug
        self.label = label
        self.labelOverlay = labelOverlay
        self.leadingActions = leading
        self.trailingActions = trailing
    }

    // __________________________outerGeom__________________________
    //
    // _____________leadingGeom______________
    //                        ___innerGeom___
    // |   [leadingActions]   |   [label]   |   [trailingActions]   |

    var body: some View {
        /// `outerGeom` measures the available width
        GeometryReader { outerGeom in
            HStack(spacing: 0) {
                /// `leadingGeom` includes the content and leading buttons, but not the trailing buttons.
                GeometryReader { leadingGeom in
                    HStack(spacing: 0) {
                        leadingActions()
                        /// `innerGeom` takes up the middle space between the buttons.
                        GeometryReader { innerGeom in
                            let leadingPadding = leadingGeom.size.width - innerGeom.size.width
                            let trailingPadding = outerGeom.size.width - leadingGeom.size.width
                            ZStack {
                                LocationLabelAligner(
                                    alignLeading: transitionToEditing,
                                    debug: debug,
                                    label: label,
                                    leadingPadding: leadingPadding,
                                    trailingPadding: trailingPadding,
                                    centerX: outerGeom.size.width / 2,
                                    centerY: innerGeom.size.height / 2
                                )
                                labelOverlay(
                                    EdgeInsets(
                                        top: 0, leading: leadingPadding, bottom: 0,
                                        trailing: trailingPadding))
                            }
                        }  // GeometryReader: innerGeom
                    }  // HStack
                }  // GeometryReader: leadingGeom
                trailingActions()
            }  // HStack
        }  // GeometryReader: outerGeom
        .overlay(
            Group {
                if debug {
                    // This marker is the center of the available space, and should
                    // line up with the orange tick, unless the label is too wide.
                    Color.purple.frame(width: 1, height: 10)
                }
            }, alignment: .bottom)
    }
}

private struct LocationLabelAligner<Label: View>: View {
    /// Forces the label to be aligned leading when true (used by the app to smooth the transition to the `LocationTextField`)
    let alignLeading: Bool
    let debug: Bool
    let label: () -> Label
    /// The amount of space taken up by the controls on the leading edge of the location view
    let leadingPadding: CGFloat
    /// The amount of space taken up by the controls on the trailing edge of the location view
    let trailingPadding: CGFloat
    /// Half the width of the entire view (including leading and trailing actions).
    let centerX: CGFloat
    /// Half the available height
    let centerY: CGFloat

    @State private var labelWidth: CGFloat = 0

    @ViewBuilder
    func formatPX(_ label: String, _ value: CGFloat) -> some View {
        if debug {
            Text(
                "\(label): \(Measurement(value: Double(value), unit: Unit(symbol: "px")).description)"
            )
            .font(.caption2)
            .allowsHitTesting(false)
        }
    }

    var body: some View {
        /// The space between the end of the title and the trailing controls, if the title was centered inside the location view.
        ///
        /// Can be negative if the title is wide enough to collide with the trailing controls.
        let trailingGap = centerX - trailingPadding - labelWidth / 2

        /// The offset necessary (from the trailing edge of the leading controls) to center the label in the aligner.
        let labelOffset =
            alignLeading
            ? labelWidth / 2
                /// If the label would extend over the trailing controls if centered, this offset will align its trailing edge with
                /// the leading edge of the trailing controls.
            : centerX - leadingPadding - max(-trailingGap, 0)

        label()
            .background(
                GeometryReader { textGeom in
                    // This does double-duty: it both measures the width of the label and provides
                    // helpful coloring for debugging.
                    (debug ? Color.yellow.opacity(0.25) : Color.clear)
                        .useEffect(deps: textGeom.size.width) { self.labelWidth = $0 }
                        .overlay(
                            Group {
                                if debug {
                                    Color.orange.frame(width: 1, height: 10)
                                }
                            }, alignment: .top
                        )
                        .overlay(formatPX("width", labelWidth), alignment: .bottomTrailing)
                        .allowsHitTesting(false)
                }
            )
            /// `position` takes up as much space as possible, and aligns the center of the view in the top-left with the provided offset.
            .position(x: labelOffset, y: centerY)
            .overlay(formatPX("x", labelOffset).padding(.leading, 5), alignment: .topLeading)
            .background(
                Group {
                    if debug {
                        Color.green
                            .opacity(0.2)
                            .allowsHitTesting(false)
                    }
                })

    }
}

extension TabLocationAligner {
    fileprivate func previewStyle() -> some View {
        self
            .border(Color.orange)
            .frame(height: TabLocationViewUX.height)
    }
}

struct TabLocationAligner_Previews: PreviewProvider {
    @ViewBuilder
    static func contents(for title: String) -> some View {
        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: true, debug: true) {
            Text(verbatim: "editing")
        } labelOverlay: { _ in
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(decorative: .squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
        } trailing: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(decorative: .squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
            Text("")
        } trailing: {
            Text("")
        }
        .previewStyle()

    }
    static var previews: some View {
        ForEach(
            ["title", "a very very very very very long title", "a", "a long title"], id: \.self
        ) { title in
            VStack {
                contents(for: title)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
