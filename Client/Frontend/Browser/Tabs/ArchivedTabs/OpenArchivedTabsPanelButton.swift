// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct OpenArchivedTabsPanelButton: View {
    var containerGeometry: CGSize
    @EnvironmentObject var tabModel: TabCardModel
    @Environment(\.openArchivedTabsPanelView) private var openArchivedTabsPanelView

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Color.secondarySystemFill
                .frame(width: containerGeometry.width, height: 8)
                .padding(.horizontal, -CardGridUX.GridSpacing)

            Button {
                openArchivedTabsPanelView()
            } label: {
                HStack {
                    Spacer()
                    Label("Archived Tabs", systemSymbol: .clock)
                    Spacer()
                }
            }
            .buttonStyle(.neeva(.secondary))
            .padding(16)
        }
    }
}
