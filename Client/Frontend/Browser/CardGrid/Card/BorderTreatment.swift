// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct BorderTreatment: ViewModifier {
    let isSelected: Bool
    let thumbnailDrawsHeader: Bool
    let isIncognito: Bool
    var cornerRadius: CGFloat = CardUX.CornerRadius

    func body(content: Content) -> some View {
        content
            .shadow(radius: thumbnailDrawsHeader ? 0 : CardUX.ShadowRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected
                            ? (isIncognito ? Color.label : Color.ui.adaptive.blue) : Color.clear,
                        lineWidth: 3)
            )
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
