// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

extension View {
    @ViewBuilder
    public func hexagonClip(with size: CGFloat) -> some View {
        self
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Hexagon())
    }
}

struct HexagonParameters {
    struct Segment {
        let line: CGPoint
        let curve: CGPoint
        let control: CGPoint
    }

    static let segments = [
        Segment(
            line: CGPoint(x: 0.60, y: 0.05),
            curve: CGPoint(x: 0.40, y: 0.05),
            control: CGPoint(x: 0.50, y: 0.00)
        ),
        Segment(
            line: CGPoint(x: 0.10, y: 0.25),
            curve: CGPoint(x: 0.05, y: 0.35),
            control: CGPoint(x: 0.05, y: 0.30)
        ),
        Segment(
            line: CGPoint(x: 0.05, y: 0.65),
            curve: CGPoint(x: 0.10, y: 0.75),
            control: CGPoint(x: 0.05, y: 0.70)
        ),
        Segment(
            line: CGPoint(x: 0.40, y: 0.95),
            curve: CGPoint(x: 0.60, y: 0.95),
            control: CGPoint(x: 0.50, y: 1.00)
        ),
        Segment(
            line: CGPoint(x: 0.90, y: 0.75),
            curve: CGPoint(x: 0.95, y: 0.65),
            control: CGPoint(x: 0.95, y: 0.70)
        ),
        Segment(
            line: CGPoint(x: 0.95, y: 0.35),
            curve: CGPoint(x: 0.90, y: 0.25),
            control: CGPoint(x: 0.95, y: 0.30)
        ),
    ]
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width: CGFloat = min(rect.width, rect.height)
        let height = width
        path.move(
            to: CGPoint(
                x: width * 0.90,
                y: height * (0.25)
            )
        )

        HexagonParameters.segments.forEach { segment in
            path.addLine(
                to: CGPoint(
                    x: width * segment.line.x,
                    y: height * segment.line.y
                )
            )

            path.addQuadCurve(
                to: CGPoint(
                    x: width * segment.curve.x,
                    y: height * segment.curve.y
                ),
                control: CGPoint(
                    x: width * segment.control.x,
                    y: height * segment.control.y
                )
            )
        }
        return path
    }
}
