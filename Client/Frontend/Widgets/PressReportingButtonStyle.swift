// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// This button style updates a binding to reflect its pressed state.
/// You are responsible for making the pressed state visible since the button will no longer change its appearance.
struct PressReportingButtonStyle: ButtonStyle {
    @Binding fileprivate var isPressed: Bool
    fileprivate let animation: Animation?

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed) { value in
                withAnimation(animation) {
                    isPressed = value
                }
            }
    }
}

extension ButtonStyle where Self == PressReportingButtonStyle {
    static func reportsPresses(
        to isPressed: Binding<Bool>, using animation: Animation? = .interactiveSpring()
    ) -> Self {
        .init(isPressed: isPressed, animation: animation)
    }
}

struct PressReportingButtonStyle_Previews: PreviewProvider {
    struct Preview: View {
        @State var isPressed = false

        var body: some View {
            VStack(spacing: 30) {
                Label(String("Pressed?"), systemSymbol: isPressed ? .checkmarkSquare : .square)

                Button(String("Press Here!")) {}
                    .padding()
                    .background(Capsule().fill(Color.systemFill))
                    .buttonStyle(.reportsPresses(to: $isPressed))
            }
            .padding()
        }
    }
    static var previews: some View {
        Preview()
            .previewLayout(.sizeThatFits)
    }
}
