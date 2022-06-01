// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct EmptyCardGrid: View {
    let isIncognito: Bool
    let isTopBar: Bool

    var body: some View {
        VStack {
            Image(decorative: isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
            Text(isIncognito ? "Create and manage incognito tabs" : "Create and manage tabs")
                .withFont(.headingXLarge)
            Text("Tap + \(isTopBar ? "above" : "below") to create a new tab")
                .withFont(.bodyMedium)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
        .accessibilityLabel(Text(isIncognito ? "Empty Card Grid (Incognito)" : "Empty Card Grid"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyCardGrid_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmptyCardGrid(isIncognito: false, isTopBar: false)
            EmptyCardGrid(isIncognito: true, isTopBar: true)
        }
    }
}
