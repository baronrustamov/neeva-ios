// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ArchivedTabsView: View {
    var containerGeometry: CGSize
    @EnvironmentObject var tabModel: TabCardModel
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openArchivedTabsPanelView) private var openArchivedTabsPanelView

    @Default(.archivedTabsDuration) var archivedTabsDuration

    var tabsDurationText: String {
        switch archivedTabsDuration {
        case .week:
            return "for 7 days"
        case .month:
            return "for 30 days"
        case .forever:
            return "forever"
        }
    }

    var bvc: BrowserViewController {
        SceneDelegate.getBVC(with: tabModel.manager.scene)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Color.secondarySystemFill
                .frame(width: containerGeometry.width, height: 8)
                .padding(.horizontal, -CardGridUX.GridSpacing)

            Button(
                action: {
                    openArchivedTabsPanelView()
                },
                label: {
                    HStack {
                        Spacer()
                        Symbol(decorative: .clock)
                        Text("Archived Tabs")
                        Spacer()
                    }
                }
            )
            .buttonStyle(.neeva(.secondary))
            .padding(16)

            Text("Neeva is set to keep tabs \(tabsDurationText)")
                .withFont(.bodyLarge)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Button(
                action: {
                    openSettings(.archivedTabs)
                },
                label: {
                    Text("Change in settings")
                        .underline()
                })
        }
        .padding(.bottom, 27)
    }
}
