// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

class BrowserModel: ObservableObject {
    @Published var showGrid = false {
        didSet {
            if showGrid {
                // Ensures toolbars are visible when user closes from the CardGrid.
                // Expand when set to true, so ready when user returns.
                scrollingControlModel.showToolbars(animated: true, completion: nil)

                // Ensure that the switcher is reset in case a previous drag was not
                // properly completed.
                switcherToolbarModel.dragOffset = nil
            }
        }
    }

    let gridModel: GridModel
    let incognitoModel: IncognitoModel
    let tabManager: TabManager

    var cardTransitionModel: CardTransitionModel
    var contentVisibilityModel: ContentVisibilityModel
    var scrollingControlModel: ScrollingControlModel
    let switcherToolbarModel: SwitcherToolbarModel
    let cookieCutterModel = CookieCutterModel()

    var toastViewManager: ToastViewManager
    var notificationViewManager: NotificationViewManager

    func showGridWithAnimation() {
        gridModel.switchModeWithoutAnimation = true

        if gridModel.switcherState != .tabs {
            gridModel.switcherState = .tabs
        }

        if !gridModel.tabCardModel.getAllDetails(matchingIncognitoState: incognitoModel.isIncognito)
            .contains(where: \.isSelected)
        {
            showGridWithNoAnimation()
        } else {
            if FeatureFlag[.enableTimeBasedSwitcher] {
                gridModel.tabCardModel.updateRowsIfNeeded()
            }

            gridModel.scrollToSelectedTab { [self] in
                cardTransitionModel.update(to: .visibleForTrayShow)
                contentVisibilityModel.update(showContent: false)
                updateSpaces()
            }
        }
    }

    func showGridWithNoAnimation() {
        if FeatureFlag[.enableTimeBasedSwitcher] {
            gridModel.tabCardModel.updateRowsIfNeeded()
        }

        gridModel.scrollToSelectedTab()
        cardTransitionModel.update(to: .hidden)
        contentVisibilityModel.update(showContent: false)

        if !showGrid {
            showGrid = true
        }

        updateSpaces()
    }

    func showSpaces(forceUpdate: Bool = true) {
        cardTransitionModel.update(to: .hidden)
        contentVisibilityModel.update(showContent: false)
        showGrid = true
        gridModel.switcherState = .spaces

        if forceUpdate {
            updateSpaces()
        }
    }

    func hideGridWithAnimation(tabToBeSelected: Tab? = nil) {
        assert(!gridModel.tabCardModel.allDetails.isEmpty)

        let tabToBeSelected = tabToBeSelected ?? tabManager.selectedTab
        tabToBeSelected?.shouldCreateWebViewUponSelect = false

        if let tabToBeSelected = tabToBeSelected {
            gridModel.switchModeWithoutAnimation = true
            incognitoModel.update(isIncognito: tabToBeSelected.isIncognito)
        }

        gridModel.scrollToSelectedTab { [self] in
            cardTransitionModel.update(to: .visibleForTrayHidden)
            gridModel.closeDetailView()
        }
    }

    func hideGridWithNoAnimation() {
        gridModel.scrollToSelectedTab()
        cardTransitionModel.update(to: .hidden)

        if showGrid {
            showGrid = false
        }

        contentVisibilityModel.update(showContent: true)

        gridModel.switcherState = .tabs
        gridModel.closeDetailView()

        tabManager.updateWebViewForSelectedTab(notify: true)
        gridModel.switchModeWithoutAnimation = false
    }

    func onCompletedCardTransition() {
        // Prevents a bug where a tab wouldn't open upon select,
        // since the previous animation wasn't finished yet.
        if showGrid, cardTransitionModel.state == .visibleForTrayShow {
            cardTransitionModel.update(to: .hidden)
            gridModel.switchModeWithoutAnimation = false
        } else {
            hideGridWithNoAnimation()
        }
    }

    private func updateSpaces() {
        // In preparation for the CardGrid being shown soon, refresh spaces.
        DispatchQueue.main.async {
            SpaceStore.shared.refresh()
        }
    }

    private var followPublicSpaceSubscription: AnyCancellable?

    func openSpace(
        spaceId: String, bvc: BrowserViewController, isIncognito: Bool = false,
        completion: @escaping () -> Void
    ) {

        let existingSpace = gridModel.spaceCardModel.allDetails.first(where: { $0.id == spaceId })
        DispatchQueue.main.async { [self] in
            if incognitoModel.isIncognito {
                tabManager.toggleIncognitoMode()
            }

            if let existingSpace = existingSpace {
                openSpace(spaceID: existingSpace.id)
                existingSpace.refresh()
                return
            }

            gridModel.openSpaceInDetailView(spaceId)
        }
    }

    func openSpace(spaceID: String?, animate: Bool = true) {
        withAnimation(nil) {
            showSpaces(forceUpdate: false)
        }

        guard let spaceID = spaceID,
            let detail = gridModel.spaceCardModel.allDetails.first(where: { $0.id == spaceID })
        else {
            return
        }

        gridModel.openSpaceInDetailView(detail)
    }

    func openSpaceDigest(bvc: BrowserViewController) {
        bvc.showTabTray()
        gridModel.switcherState = .spaces

        openSpace(spaceId: SpaceStore.dailyDigestID, bvc: bvc) {}
    }

    init(
        gridModel: GridModel, tabManager: TabManager, chromeModel: TabChromeModel,
        incognitoModel: IncognitoModel, switcherToolbarModel: SwitcherToolbarModel,
        toastViewManager: ToastViewManager, notificationViewManager: NotificationViewManager
    ) {
        self.gridModel = gridModel
        self.tabManager = tabManager
        self.incognitoModel = incognitoModel
        self.cardTransitionModel = CardTransitionModel()
        self.contentVisibilityModel = ContentVisibilityModel()
        self.scrollingControlModel = ScrollingControlModel(
            tabManager: tabManager, chromeModel: chromeModel)
        self.switcherToolbarModel = switcherToolbarModel

        self.toastViewManager = toastViewManager
        self.notificationViewManager = notificationViewManager
    }
}
