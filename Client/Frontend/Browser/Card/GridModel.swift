// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI

class GridModel: ObservableObject {
    let tabCardModel: TabCardModel
    let spaceCardModel: SpaceCardModel

    @Published private(set) var pickerHeight: CGFloat = UIConstants
        .TopToolbarHeightWithToolbarButtonsShowing
    @Published var switcherState: SwitcherViews = .tabs {
        willSet {
            gridCanAnimate = true
        }

        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.gridCanAnimate = false
            }

            if case .spaces = switcherState {
                ClientLogger.shared.logCounter(
                    .SpacesUIVisited,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        }
    }
    @Published var gridCanAnimate = false
    @Published var showingDetailView = false {
        didSet {
            // Reset when going from true to false
            if oldValue && !showingDetailView {
                spaceCardModel.detailedSpace?.showingDetails = false
            }
        }
    }
    @Published var needsScrollToSelectedTab: Int = 0

    // Spaces
    @Published var isLoading = false
    @Published private(set) var refreshDetailedSpaceSubscription: AnyCancellable? = nil

    private var subscriptions: Set<AnyCancellable> = []
    private let tabMenu: TabMenu

    init(tabManager: TabManager, tabCardModel: TabCardModel) {
        self.tabCardModel = tabCardModel
        self.spaceCardModel = SpaceCardModel()

        self.tabMenu = TabMenu(tabManager: tabManager)
    }

    var isShowingEmpty: Bool {
        let tabManager = tabCardModel.manager
        if tabManager.incognitoModel.isIncognito {
            return tabManager.incognitoTabs.isEmpty
        }
        return tabManager.normalTabs.isEmpty
    }

    func scrollToSelectedTab() {
        needsScrollToSelectedTab += 1
    }

    func refreshDetailedSpace() {
        guard let detailedSpace = spaceCardModel.detailedSpace,
            !(detailedSpace.space?.isDigest ?? false)
        else {
            return
        }

        refreshDetailedSpaceSubscription = detailedSpace.manager.$state.sink { state in
            if case .ready = state {
                if detailedSpace.manager.updatedSpacesFromLastRefresh.first?.id.id ?? ""
                    == detailedSpace.id
                {
                    detailedSpace.updateDetails()
                }

                withAnimation(.easeOut) {
                    self.refreshDetailedSpaceSubscription = nil
                }
            }
        }

        detailedSpace.manager.refreshSpace(spaceID: detailedSpace.id)
    }

    func switchToTabs(incognito: Bool) {
        switcherState = .tabs

        tabCardModel.manager.switchIncognitoMode(
            incognito: incognito, fromTabTray: true, openLazyTab: false)
    }

    func switchToSpaces() {
        switcherState = .spaces
    }

    func buildCloseAllTabsMenu(sourceView: UIView) -> UIMenu {
        if switcherState == .tabs {
            return UIMenu(sections: [[tabMenu.createCloseAllTabsAction(sourceView: sourceView)]])
        } else {
            return UIMenu()
        }
    }

    func buildRecentlyClosedTabsMenu() -> UIMenu {
        tabMenu.createRecentlyClosedTabsMenu()
    }

    func openSpaceInDetailView(_ space: SpaceCardDetails) {
        DispatchQueue.main.async { [self] in
            showingDetailView = true
            spaceCardModel.detailedSpace = space
        }
    }

    func closeDetailView() {
        guard showingDetailView else {
            return
        }

        spaceCardModel.detailedSpace?.showingDetails = false
        showingDetailView = false
    }
}
