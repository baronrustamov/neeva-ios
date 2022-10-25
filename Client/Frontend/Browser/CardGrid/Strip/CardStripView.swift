// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CardStripUX {
    static let Height: CGFloat = 40
    static let CardMinimumContentWidthRequirement: CGFloat = 115
}

struct CardStripView: View {
    @EnvironmentObject private var gridScrollModel: GridScrollModel
    @EnvironmentObject private var gridVisibilityModel: GridVisibilityModel
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
        if let row = tabCardModel.getRows(for: .all, incognito: incognitoModel.isIncognito).first(
            where: {
                row in
                row.cells.contains(where: \.isSelected)
            })
        {
            return row.id
        }

        return nil
    }

    @ViewBuilder
    var content: some View {
        HStack(spacing: 0) {
            ForEach(model.cells) { cell in
                Group {
                    switch cell {
                    case .tabGroupInline(let groupDetails):
                        CardStripTabGroupCardView(groupDetails: groupDetails)
                            .id(cell.id)
                    case .tabGroupGridRow(let groupDetails, _):
                        CardStripTabGroupCardView(groupDetails: groupDetails)
                            .id(cell.id)
                    case .tab(let tabDetails):
                        CardStripCard(details: tabDetails)
                    default:
                        EmptyView()
                    }
                }.id(cell.id)
            }

            if !model.todayTabsExists {
                Spacer()
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
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    content.useEffect(deps: gridScrollModel.cardStripNeedScrollToSelectedTab) { _ in
                        if let selected = model.cells.first(where: \.isSelected) {
                            scrollProxy.scrollTo(selected.id, anchor: .center)
                        }
                    }
                }
            }
        } else {
            content
        }
    }
}
