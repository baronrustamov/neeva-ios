// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct TextSizeStepper: View {
    var roundedCorners: CornerSet = .all
    @ObservedObject var model: TextSizeModel

    var body: some View {
        GroupedCell(
            content: {
                HStack {
                    OverlayStepperButton(
                        action: model.zoomOut,
                        symbol: Symbol(decorative: .minus, style: .bodyLarge),
                        foregroundColor: model.canZoomOut ? .label : .tertiaryLabel
                    )
                    .disabled(!model.canZoomOut)

                    Spacer()

                    Button(action: model.resetZoom) {
                        Symbol(decorative: .textformatSize, style: .headingLarge)
                            .foregroundColor(.label)
                    }

                    Spacer()

                    OverlayStepperButton(
                        action: model.zoomIn,
                        symbol: Symbol(decorative: .plus, style: .bodyLarge),
                        foregroundColor: model.canZoomIn ? .label : .tertiaryLabel
                    )
                    .disabled(!model.canZoomIn)
                }.padding(.horizontal, -GroupedCellUX.padding)
            }, roundedCorners: roundedCorners
        )
        .buttonStyle(.tableCell)
        .accessibilityElement(children: .ignore)
        .modifier(
            OverlayStepperAccessibilityModifier(
                accessibilityLabel: "Page Zoom",
                accessibilityValue: model.label,
                increment: model.zoomIn,
                decrement: model.zoomOut))
    }
}
