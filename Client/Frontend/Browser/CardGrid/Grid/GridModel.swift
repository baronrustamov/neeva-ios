// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared

class GridResizeModel: ObservableObject {
    @Published var canResizeGrid = true
}

class GridScrollModel: ObservableObject {
    var scrollToCompletion: (() -> Void)?

    @Published var needsScrollToSelectedTab: Int = 0
    @Published var didVerticalScroll: Int = 0
    @Published var didHorizontalScroll: Int = 0

    // Ensure that the selected Card is visible by scrolling it into view
    // synchronously, which causes the selected Card to be generated if
    // needed. Runs `completion` once the selected Card is guaranteed to
    // be visible and responsive to other state changes.
    func scrollToSelectedTab(completion: (() -> Void)? = nil) {
        scrollToCompletion = completion
        needsScrollToSelectedTab += 1
    }
}

class GridSwitcherModel: ObservableObject {
    private let tabManager: TabManager
    private var incognitoListener: AnyCancellable?

    @Published private(set) var gridCanAnimate = false
    @Published private(set) var state: SwitcherView = .tabs
    @Published private(set) var switchModeWithoutAnimation = false

    func update(state: SwitcherView) {
        guard self.state != state else {
            return
        }

        self.enableCanAnimateForShortDuration()
        self.state = state

        if case .spaces = state {
            ClientLogger.shared.logCounter(
                .SpacesUIVisited,
                attributes: EnvironmentHelper.shared.getAttributes())
        }

        SceneDelegate.getCurrentSceneDelegate(with: tabManager.scene)?
            .setSceneUIState(to: .cardGrid(state, tabManager.isIncognito))
    }

    func update(switchModeWithoutAnimation: Bool) {
        if self.switchModeWithoutAnimation != switchModeWithoutAnimation {
            self.switchModeWithoutAnimation = switchModeWithoutAnimation
        }
    }

    private func enableCanAnimateForShortDuration() {
        self.gridCanAnimate = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gridCanAnimate = false
        }
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager

        // Turns on the grid animation when switching between incognito/normal tabs.
        incognitoListener = tabManager.incognitoModel.$isIncognito.sink { _ in
            self.enableCanAnimateForShortDuration()
        }
    }
}

class GridVisibilityModel: ObservableObject {
    @Published private(set) var showGrid: Bool = false

    func update(showGrid: Bool) {
        if self.showGrid != showGrid {
            self.showGrid = showGrid
        }
    }
}

class GridModel: ObservableObject {
    let resizeModel: GridResizeModel
    let scrollModel: GridScrollModel
    let spaceCardModel: SpaceCardModel
    let switcherModel: GridSwitcherModel
    let tabCardModel: TabCardModel
    let visibilityModel: GridVisibilityModel

    @Published private(set) var pickerHeight: CGFloat = UIConstants
        .TopToolbarHeightWithToolbarButtonsShowing

    @Published var showingDetailView = false {
        didSet {
            // Reset when going from true to false
            if oldValue && !showingDetailView {
                spaceCardModel.detailedSpace?.showingDetails = false
            }
        }
    }

    @Published var showConfirmCloseAllTabs = false
    @Published var numberOfTabsForCurrentState = 0

    private var subscriptions: Set<AnyCancellable> = []

    convenience init(tabManager: TabManager, tabCardModel: TabCardModel) {
        self.init(
            tabManager: tabManager, tabCardModel: tabCardModel,
            spaceCardModel: SpaceCardModel(
                manager: NeevaUserInfo.shared.isUserLoggedIn ? .shared : .suggested,
                scene: tabManager.scene))
    }

    init(tabManager: TabManager, tabCardModel: TabCardModel, spaceCardModel: SpaceCardModel) {
        self.resizeModel = GridResizeModel()
        self.scrollModel = GridScrollModel()
        self.spaceCardModel = spaceCardModel
        self.switcherModel = GridSwitcherModel(tabManager: tabManager)
        self.tabCardModel = tabCardModel
        self.visibilityModel = GridVisibilityModel()
        self.numberOfTabsForCurrentState = tabManager.getTabCountForCurrentType()

        tabManager.tabsUpdatedPublisher.sink { _ in
            self.numberOfTabsForCurrentState = tabManager.getTabCountForCurrentType()
        }.store(in: &subscriptions)
    }

    func switchToTabs(incognito: Bool) {
        switcherModel.update(state: .tabs)

        tabCardModel.manager.switchIncognitoMode(
            incognito: incognito, fromTabTray: true, openLazyTab: false)
        SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?
            .setSceneUIState(to: .cardGrid(switcherModel.state, tabCardModel.manager.isIncognito))
    }

    func switchToSpaces() {
        switcherModel.update(state: .spaces)
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
            switcherModel.update(state: .tabs)
        }

        SceneDelegate.getCurrentSceneDelegate(with: tabCardModel.manager.scene)?.setSceneUIState(
            to: .cardGrid(switcherModel.state, tabCardModel.manager.isIncognito))
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
