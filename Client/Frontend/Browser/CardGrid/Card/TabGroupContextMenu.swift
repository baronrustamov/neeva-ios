// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct TabGroupContextMenu: View {
    @ObservedObject var groupDetails: TabGroupCardDetails

    var body: some View {
        if let title = groupDetails.customTitle {
            Text("\(groupDetails.allDetails.count) tabs from “\(title)”")
        } else {
            Text("\(groupDetails.allDetails.count) Tabs")
        }

        Button {
            ClientLogger.shared.logCounter(.tabGroupRenameThroughThreeDotMenu)
            groupDetails.renaming = true
        } label: {
            Label("Rename", systemSymbol: .pencil)
        }

        Button {
            ClientLogger.shared.logCounter(.tabGroupSaveToSpacesThroughThreeDotMenu)
            if let tabGroup = groupDetails.manager.getTabGroup(for: groupDetails.id) {
                SceneDelegate.getBVC(with: groupDetails.manager.scene).showAddToSpacesSheetForGroup(
                    tabGroup: tabGroup)
            }
        } label: {
            Label("Save All to Spaces", systemSymbol: .bookmark)
        }

        Button(
            role: .destructive,
            action: {
                ClientLogger.shared.logCounter(.tabGroupDeleteThroughThreeDotMenu)
                groupDetails.deleting = true
            }
        ) {
            Label("Close All", systemSymbol: .trash)
        }
    }
}
