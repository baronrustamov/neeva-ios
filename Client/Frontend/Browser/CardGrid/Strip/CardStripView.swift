// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import Storage
import SwiftUI

struct CardStripUX {
    static let Height: CGFloat = 40
    static let CardMinimumContentWidthRequirement: CGFloat = 115
}

struct CardStripView: View {
    @EnvironmentObject private var gridModel: GridModel
    @EnvironmentObject private var incognitoModel: IncognitoModel
    @EnvironmentObject private var model: CardStripModel
    @EnvironmentObject private var scrollingControlModel: ScrollingControlModel
    @EnvironmentObject private var tabCardModel: TabCardModel

    @State var width: CGFloat = 0

    let containerGeometry: CGSize
    var pinnedDetails: [TabCardDetails] {
        return tabCardModel.allDetails.filter { $0.isPinned }
    }

    var selectedRowId: TabCardModel.Row.ID? {
        if let row = tabCardModel.getRows(incognito: incognitoModel.isIncognito).first(where: {
            row in
            row.cells.contains(where: \.isSelected)
        }) {
            return row.id
        }

        return nil
    }

    @ViewBuilder
    var content: some View {
        HStack(spacing: 0) {
            ForEach(model.rows) { row in
                ForEach(Array(row.cells.enumerated()), id: \.0) { index, details in
                    switch details {
                    case .tabGroupInline(let groupDetails):
                        CardStripTabGroupCardView(groupDetails: groupDetails)
                    case .tabGroupGridRow(let groupDetails, _):
                        CardStripTabGroupCardView(groupDetails: groupDetails)
                    case .tab(let tabDetails):
                        CardStripCard(details: tabDetails)
                    default:
                        EmptyView()
                    }
                }.id(row.id)
            }
        }
        .opacity(scrollingControlModel.controlOpacity)
        .frame(height: CardStripUX.Height)
        .background(Color.DefaultBackground)
        .useEffect(deps: containerGeometry) { containerGeometry in
            model.shouldEmbedInScrollView = containerGeometry.width < width
        }.onWidthOfViewChanged { width in
            self.width = width
            model.shouldEmbedInScrollView = containerGeometry.width < width
        }
    }

    var body: some View {
        if model.shouldEmbedInScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                content.useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
                    model.shouldEmbedInScrollView = false
                }
            }
        } else {
            content
        }
    }
}
