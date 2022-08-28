// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct GroupedDataPanelView<Model: GroupedDataPanelModel, NavigationButton: View>: View {
    let model: Model
    let navigationButton: NavigationButton

    var optionSections: some View {
        VStack {
            Color.groupedBackground.frame(height: 8)

            navigationButton
                .foregroundColor(.label).padding(16)

            Color.groupedBackground.frame(height: 1)

            Button {

            } label: {
                HStack {
                    Text("Clear Browsing Data")

                    Spacer()
                }
            }.foregroundColor(.red).padding(16)

            Color.groupedBackground.frame(height: 8)
        }
    }

    var body: some View {
        VStack {
            optionSections
        }
        .animation(.interactiveSpring())
        .transition(.identity)
    }

    init(model: Model, @ViewBuilder navigationButton: () -> NavigationButton) {
        self.model = model
        self.navigationButton = navigationButton()
    }
}
