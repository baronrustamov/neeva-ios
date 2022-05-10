// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ZeroQueryHeader: View {
    let title: LocalizedStringKey
    var action: (() -> Void)?
    var label: LocalizedStringKey?
    var icon: Nicon?
    var hideToggle: Bool

    var body: some View {
        if let action = action, let label = label, let icon = icon {
            HStack {
                titleView
                Spacer()
                if !hideToggle {
                    Button(action: action) {
                        // decorative because the toggle action is expressed on the header view itself.
                        // This button is not an accessibility element.
                        Symbol(decorative: icon, size: ZeroQueryUX.ToggleIconSize, weight: .medium)
                            .frame(
                                width: ZeroQueryUX.ToggleButtonSize,
                                height: ZeroQueryUX.ToggleButtonSize,
                                alignment: .center
                            )
                            .background(Color(light: .ui.gray98, dark: .systemFill)).clipShape(
                                Circle())
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityLabel("\(Text(title)), \(Text(label))")
            .accessibilityAction(.default, action)
            .padding([.top, .horizontal], ZeroQueryUX.Padding)
        } else {
            HStack {
                titleView
                Spacer()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits([.isHeader])
            .accessibilityLabel("\(Text(title))")
            .padding([.top, .horizontal], ZeroQueryUX.Padding)
        }

    }

    private var titleView: some View {
        Text(title)
            .withFont(.headingMedium)
            .foregroundColorOrGradient(.secondaryLabel)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
    }
}
