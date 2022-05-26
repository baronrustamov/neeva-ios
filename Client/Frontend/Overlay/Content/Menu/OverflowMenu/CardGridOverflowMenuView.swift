// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

public struct CardGridOverflowMenuView: View {
    private let menuAction: (OverflowMenuAction) -> Void
    private let changedUserAgent: Bool

    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var locationModel: LocationViewModel

    public init(
        changedUserAgent: Bool = false,
        menuAction: @escaping (OverflowMenuAction) -> Void
    ) {
        self.menuAction = menuAction
        self.changedUserAgent = changedUserAgent
    }

    public var body: some View {
        GroupedStack {
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    GroupedRowButtonView(label: "Close All Tabs", symbol: .trash) {
                        menuAction(.closeAllTabs)
                    }
                    .accentColor(.red)
                    .disabled(
                        chromeModel.topBarDelegate?.tabManager.getTabCountForCurrentType() == 0
                    )
                    .accessibilityIdentifier("CardGridOverflowMenu.CloseAllTabs")

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(label: "Search Tabs", symbol: .magnifyingglass) {
                        menuAction(.findTab)
                    }
                    .accentColor(.label)
                    .accessibilityIdentifier("CardGridOverflowMenu.FindTab")
                }
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    GroupedRowButtonView(label: "Support", symbol: .bubbleLeft) {
                        menuAction(.support())
                    }.accessibilityIdentifier("CardGridOverflowMenu.Feedback")

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(label: "Settings", symbol: .gear) {
                        menuAction(.goToSettings)
                    }.accessibilityIdentifier("CardGridOverflowMenu.Settings")

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(label: "History", symbol: .clock) {
                        menuAction(.goToHistory)
                    }.disabled(
                        chromeModel.topBarDelegate?.tabManager.incognitoModel.isIncognito ?? false
                    ).accessibilityIdentifier("CardGridOverflowMenu.History")

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(label: "Downloads", symbol: .squareAndArrowDown) {
                        menuAction(.goToDownloads)
                    }.accessibilityIdentifier("CardGridOverflowMenu.Downloads")
                }.accentColor(.label)
            }
        }
    }
}

struct CardGridOverflowMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CardGridOverflowMenuView(menuAction: { _ in })
    }
}
