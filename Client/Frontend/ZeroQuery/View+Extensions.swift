// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

#if XYZ
    import WalletCore
#endif

extension View {
    @ViewBuilder
    func foregroundColorOrGradient(_ color: Color) -> some View {
        #if XYZ
            self.gradientForeground()
        #else
            self.foregroundColor(color)
        #endif
    }

    @ViewBuilder
    func backgroundColorOrGradient(_ color: Color? = nil) -> some View {
        #if XYZ
            self.background(WalletTheme.gradient.opacity(0.1))
        #else
            if let color = color {
                self.background(color)
            } else {
                self
            }
        #endif
    }

    @ViewBuilder
    func defaultBackgroundOrTheme(_ currentTheme: String?) -> some View {
        #if XYZ
            self.background(Web3Theme(with: currentTheme).backgroundColor.ignoresSafeArea())
        #else
            self.background(Color.DefaultBackground.ignoresSafeArea())
        #endif
    }

}

extension View {
    @ViewBuilder
    public func hexagonClip() -> some View {
        ZStack {
            Image("hexagon")
                .resizable()
                .scaledToFit()
            self
                .clipShape(Hexagon().rotation(.degrees(30)))
                .blendMode(.multiply)
        }
    }
}
struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        // hypotenuse (we make it fit inside the available rect
        let height = Double(min(rect.size.width, rect.size.height)) / 2.0
        // center
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        for i in 0..<6 {
            let angle = (Double(i) * (360.0 / Double(6))) * Double.pi / 180
            // Calculate vertex position
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle) * height),
                y: center.y + CGFloat(sin(angle) * height))
            if i == 0 {
                path.move(to: pt)  // move to first vertex
            } else {
                path.addLine(to: pt)  // draw line to next vertex
            }
        }
        path.closeSubpath()
        return path
    }
}
