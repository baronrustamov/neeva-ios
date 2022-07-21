// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct EmptyCardGrid: View {
    let isIncognito: Bool
    let isTopBar: Bool
    let showArchivedTabsView: Bool

    @State var containerGeom: CGSize = CGSize.zero

    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image(decorative: isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
                Text(
                    isIncognito
                        ? Strings.IncognitoTabSwitcherEmptyTabTitle
                        : Strings.TabSwitcherEmptyTabTitle
                )
                .withFont(.headingXLarge)
                Text("Tap + \(isTopBar ? Strings.Above : Strings.Below) to create a new tab")
                    .withFont(.bodyMedium)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
            .accessibilityLabel(
                Text(isIncognito ? "Empty Card Grid (Incognito)" : "Empty Card Grid"))
            if showArchivedTabsView {
                ArchivedTabsView(containerGeometry: containerGeom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyCardGrid_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmptyCardGrid(isIncognito: false, isTopBar: false, showArchivedTabsView: false)
            EmptyCardGrid(isIncognito: true, isTopBar: true, showArchivedTabsView: false)
        }
    }
}
