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
    @Published private(set) var switcherState: SwitcherView = .tabs {
        didSet {
            if case .spaces = switcherState {
                ClientLogger.shared.logCounter(
                    .SpacesUIVisited,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }

            SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?
                .setSceneUIState(to: .cardGrid(switcherState, tabCardModel.manager.isIncognito))
        }
    }
    @Published var gridCanAnimate = false
    @Published var switchModeWithoutAnimation = false
    @Published var showingDetailView = false {
        didSet {
            // Reset when going from true to false
            if oldValue && !showingDetailView {
                spaceCardModel.detailedSpace?.showingDetails = false
            }
        }
    }
    @Published var needsScrollToSelectedTab: Int = 0
    var scrollToCompletion: (() -> Void)?
    @Published var didVerticalScroll: Int = 0
    @Published var didHorizontalScroll: Int = 0
    @Published var canResizeGrid = true
    @Published var showConfirmCloseAllTabs = false
    @Published var numberOfTabsForCurrentState = 0

    private var subscriptions: Set<AnyCancellable> = []

    init(tabManager: TabManager, tabCardModel: TabCardModel) {
        self.tabCardModel = tabCardModel
        self.spaceCardModel = SpaceCardModel(
            manager: NeevaUserInfo.shared.isUserLoggedIn ? .shared : .suggested,
            scene: tabManager.scene)
        self.numberOfTabsForCurrentState = tabManager.getTabCountForCurrentType()

        tabManager.tabsUpdatedPublisher.sink { _ in
            self.numberOfTabsForCurrentState = tabManager.getTabCountForCurrentType()
        }.store(in: &subscriptions)
    }

    // Ensure that the selected Card is visible by scrolling it into view
    // synchronously, which causes the selected Card to be generated if
    // needed. Runs `completion` once the selected Card is guaranteed to
    // be visible and responsive to other state changes.
    func scrollToSelectedTab(completion: (() -> Void)? = nil) {
        scrollToCompletion = completion
        needsScrollToSelectedTab += 1
    }

    public func setSwitcherState(to state: SwitcherView) {
        gridCanAnimate = true

        if state != switcherState {
            switcherState = state
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gridCanAnimate = false
        }
    }

    func switchToTabs(incognito: Bool) {
        setSwitcherState(to: .tabs)

        tabCardModel.manager.switchIncognitoMode(
            incognito: incognito, fromTabTray: true, openLazyTab: false)
        SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?
            .setSceneUIState(to: .cardGrid(switcherState, tabCardModel.manager.isIncognito))
    }

    func switchToSpaces() {
        setSwitcherState(to: .spaces)
    }

    func openSpaceInDetailView(_ space: SpaceCardDetails?) {
        if let id = space?.item?.id.id {
            SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?
                .setSceneUIState(to: .spaceDetailView(id))
        }

        DispatchQueue.main.async { [self] in
            spaceCardModel.detailedSpace = space
            showingDetailView = true
        }
    }

    func openSpaceInDetailView(_ id: String?) {
        guard let id = id else { return }

        SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?.setSceneUIState(
            to: .spaceDetailView(id))

        DispatchQueue.main.async { [self] in
            // Prevents duplicate calls to spaceFailedToOpen
            var didFailToOpen = false

            spaceCardModel.detailedSpace = SpaceCardDetails(id: id, manager: SpaceStore.shared)
            showingDetailView = true
            spaceCardModel.detailedSpace?.refresh { wasSuccessful in
                if !wasSuccessful && !didFailToOpen {
                    didFailToOpen = true
                    self.spaceFailedToOpen()
                }
            }
        }
    }

    func closeDetailView(switchToTabs: Bool = false) {
        guard showingDetailView else {
            return
        }

        spaceCardModel.detailedSpace?.showingDetails = false
        showingDetailView = false
        spaceCardModel.detailedSpace = nil

        if switchToTabs {
            setSwitcherState(to: .tabs)
        }

        SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?.setSceneUIState(
            to: .cardGrid(switcherState, tabCardModel.manager.isIncognito))
    }

    func spaceFailedToOpen() {
        closeDetailView()

        let toastViewManager = SceneDelegate.getBVC(with: tabCardModel.manager.scene)
            .toastViewManager
        ToastDefaults().showToast(
            with:
                "Unable to open Space. Check that the Space is shared with you and the link is correct.",
            toastViewManager: toastViewManager)

        ClientLogger.shared.logCounter(.SpaceFailedToOpen, attributes: [])
    }
}
