// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct FindInCardGridView: View {
    @State var searchQuery: String = ""

    let tabCardModel: TabCardModel
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            SingleLineTextField(
                icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                placeholder: "Search Tabs",
                text: $searchQuery,
                focusTextField: true
            ).accessibilityIdentifier("FindInCardGrid_TextField")

            Button {
                onDismiss()
                tabCardModel.isSearchingForTabs = false
            } label: {
                Text("Done")
            }.accessibilityIdentifier("FindInCardGrid_Done")
        }.onChange(of: searchQuery) { newValue in
            tabCardModel.tabSearchFilter = newValue
        }.padding(.top, 4)
    }
}
