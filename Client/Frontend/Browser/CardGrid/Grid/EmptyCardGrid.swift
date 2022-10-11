// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct EmptyCardGrid: View {
    let isIncognito: Bool
    let showArchivedTabsView: Bool

    @EnvironmentObject var chromeModel: TabChromeModel
    @State var containerGeom: CGSize = CGSize.zero

    var isTopBar: Bool {
        chromeModel.inlineToolbar
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image(decorative: isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
                Text(
                    isIncognito
                        ? LocalizedStringKey("Create and manage incognito tabs")
                        : LocalizedStringKey("Create and manage tabs")
                )
                .withFont(.headingXLarge)
                Text("Tap + \(isTopBar ? "above" : "below") to create a new tab")
                    .withFont(.bodyMedium)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
            .accessibilityLabel(
                Text(isIncognito ? "Empty Card Grid (Incognito)" : "Empty Card Grid"))

            if showArchivedTabsView {
                OpenArchivedTabsPanelButton(containerGeometry: containerGeom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyCardGrid_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmptyCardGrid(isIncognito: false, showArchivedTabsView: false)
                .environmentObject(TabChromeModel())
            EmptyCardGrid(isIncognito: true, showArchivedTabsView: false)
                .environmentObject(TabChromeModel())
        }
    }
}
