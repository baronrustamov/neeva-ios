// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

// This is the root model for the browser and is available via @EnvironmentObject to
// any View. It explicitly does not have any @Published vars. This way it is safe to
// access via @EnvironmentObject without worry about that causing unwanted updates to
// the View graph. However as this provides a means to access just about any model
// from anywhere, it can be all too easy for this to open the door to spaghetti code.
// All of these models are also available in the environment as well, so you can use
// them directly as needed and preserve more modular code design.
class BrowserModel: ObservableObject {
    private var subscription: AnyCancellable?

    let cardStripModel: CardStripModel
    let cardTransitionModel: CardTransitionModel
    let contentVisibilityModel: ContentVisibilityModel
    let cookieCutterModel = CookieCutterModel()
    let gridModel: GridModel
    let incognitoModel: IncognitoModel
    let overlayManager: OverlayManager
    let scrollingControlModel: ScrollingControlModel
    let switcherToolbarModel: SwitcherToolbarModel
    let tabManager: TabManager
    let toastViewManager: ToastViewManager

    func showGridWithAnimation() {
        print(">>> showGridWithAnimation")
        gridModel.switcherModel.update(state: .tabs)
        gridModel.switcherAnimationModel.update(switchWithAnimation: false)
        gridModel.tabCardModel.updateIfNeeded()

        if tabManager.selectedTab?.isIncognito != incognitoModel.isIncognito {
            showGridWithNoAnimation()
        } else {
            overlayManager.hideCurrentOverlay(ofPriority: .modal)
            gridModel.scrollModel.scrollToSelectedTab { [self] in
                print(">>> did scrollToSelectedTab")
                cardTransitionModel.update(to: .visibleForTrayShow)
                contentVisibilityModel.update(showContent: false)
                updateSpaces()
            }
        }
    }

    func showGridWithNoAnimation() {
        gridModel.scrollModel.scrollToSelectedTab()
        cardTransitionModel.update(to: .hidden)
        contentVisibilityModel.update(showContent: false)
        overlayManager.hideCurrentOverlay(ofPriority: .modal)

        gridModel.visibilityModel.update(showGrid: true)

        updateSpaces()
    }

    func showSpaces(forceUpdate: Bool = true) {
        showGridWithNoAnimation()
        gridModel.switcherModel.update(state: .spaces)

        if forceUpdate {
            updateSpaces()
        }
    }

    func hideGridWithAnimation(tabToBeSelected: Tab? = nil) {
        print(">>> hideGridWithAnimation")
        assert(!gridModel.tabCardModel.allDetails.isEmpty)

        let tabToBeSelected = tabToBeSelected ?? tabManager.selectedTab
        tabToBeSelected?.shouldPerformHeavyUpdatesUponSelect = false

        if let tabToBeSelected = tabToBeSelected {
            gridModel.switcherAnimationModel.update(switchWithAnimation: false)
            incognitoModel.update(isIncognito: tabToBeSelected.isIncognito)
        }

        overlayManager.hideCurrentOverlay(ofPriority: .modal)
        gridModel.scrollModel.scrollToSelectedTab { [self] in
            print(">>> did scrollToSelectedTab")
            cardTransitionModel.update(to: .visibleForTrayHidden)
            gridModel.closeDetailView()
        }
    }

    func hideGridWithNoAnimation() {
        gridModel.scrollModel.scrollToSelectedTab()
        cardTransitionModel.update(to: .hidden)

        gridModel.visibilityModel.update(showGrid: false)

        overlayManager.hideCurrentOverlay(ofPriority: .modal)
        contentVisibilityModel.update(showContent: true)

        gridModel.switcherModel.update(state: .tabs)
        gridModel.closeDetailView()

        tabManager.updateSelectedTabDataPostAnimation()

        SceneDelegate.getCurrentSceneDelegate(with: tabManager.scene)?.setSceneUIState(to: .tab)
        gridModel.switcherAnimationModel.update(switchWithAnimation: true)
        gridModel.tabCardModel.isSearchingForTabs = false
    }

    func onCompletedCardTransition() {
        print(">>> onCompletedCardTransition")
        // Prevents a bug where a tab wouldn't open upon select,
        // since the previous animation wasn't finished yet.
        if gridModel.visibilityModel.showGrid, cardTransitionModel.state == .visibleForTrayShow {
            cardTransitionModel.update(to: .hidden)
            gridModel.switcherAnimationModel.update(switchWithAnimation: true)

            SceneDelegate.getCurrentSceneDelegate(with: tabManager.scene)?.setSceneUIState(
                to: .cardGrid(gridModel.switcherModel.state, tabManager.isIncognito))
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

    func openSpace(spaceId: String) {
        let existingSpace = gridModel.spaceCardModel.allDetails.first(where: { $0.id == spaceId })
        DispatchQueue.main.async { [self] in
            if incognitoModel.isIncognito {
                tabManager.toggleIncognitoMode()
            }

            if let existingSpace = existingSpace {
                openSpace(spaceID: existingSpace.id)
                existingSpace.refresh { wasSuccessful in
                    if !wasSuccessful {
                        self.gridModel.spaceFailedToOpen()
                    }
                }

                return
            }

            gridModel.openSpaceInDetailView(spaceId)
        }
    }

    func openSpace(spaceID: String?) {
        withAnimation(nil) {
            showSpaces(forceUpdate: false)
        }

        if let spaceID = spaceID,
            let detail = gridModel.spaceCardModel.allDetails.first(where: { $0.id == spaceID })
        {
            gridModel.openSpaceInDetailView(detail)
        }
    }

    func openSpaceDigest(bvc: BrowserViewController) {
        bvc.showTabTray()
        gridModel.switcherModel.update(state: .spaces)

        openSpace(spaceId: SpaceStore.dailyDigestID)
    }

    init(
        gridModel: GridModel, tabManager: TabManager, chromeModel: TabChromeModel,
        incognitoModel: IncognitoModel, switcherToolbarModel: SwitcherToolbarModel,
        toastViewManager: ToastViewManager, overlayManager: OverlayManager
    ) {
        self.cardStripModel = CardStripModel(
            incognitoModel: incognitoModel,
            tabCardModel: gridModel.tabCardModel,
            tabChromeModel: chromeModel
        )
        self.cardTransitionModel = CardTransitionModel()
        self.contentVisibilityModel = ContentVisibilityModel()
        self.gridModel = gridModel
        self.incognitoModel = incognitoModel
        self.scrollingControlModel = ScrollingControlModel(
            tabManager: tabManager, chromeModel: chromeModel)
        self.switcherToolbarModel = switcherToolbarModel
        self.tabManager = tabManager

        self.overlayManager = overlayManager
        self.toastViewManager = toastViewManager

        subscription = self.gridModel.visibilityModel.$showGrid.sink { [weak self] showGrid in
            if showGrid {
                // Ensures toolbars are visible when user closes from the CardGrid.
                // Expand when set to true, so ready when user returns.
                self?.scrollingControlModel.showToolbars(animated: true, completion: nil)
            }
        }
    }
}
