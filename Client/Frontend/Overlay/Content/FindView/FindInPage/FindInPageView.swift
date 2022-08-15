// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct FindInPageViewUX {
    static let height: CGFloat = 80
}

struct FindInPageView: View {
    @ObservedObject var model: FindInPageModel
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            SingleLineTextField(
                icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                placeholder: "Search Page",
                text: $model.searchValue,
                alwaysShowClearButton: false,
                detailText: model.matchIndex,
                focusTextField: true
            ).accessibilityIdentifier("FindInPage_TextField")

            HStack {
                OverlayStepperButton(
                    action: model.previous,
                    symbol: Symbol(.chevronUp, style: .headingMedium, label: "Previous"),
                    foregroundColor: .ui.adaptive.blue
                )
                .accessibilityIdentifier("FindInPage_Previous")

                OverlayStepperButton(
                    action: model.next,
                    symbol: Symbol(.chevronDown, style: .headingMedium, label: "Next"),
                    foregroundColor: .ui.adaptive.blue
                )
                .accessibilityIdentifier("FindInPage_Next")
            }

            Button(action: onDismiss) {
                Text("Done")
            }
            .textButtonPointerEffect()
            .accessibilityIdentifier("FindInPage_Done")
            .accessibilityLabel(Text("Done"))
        }
    }
}

struct FindInPageView_Previews: PreviewProvider {
    static var previews: some View {
        FindInPageView(model: FindInPageModel(tab: nil), onDismiss: {})
    }
}
