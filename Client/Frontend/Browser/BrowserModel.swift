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

    func show() {
        if gridModel.switcherState != .tabs {
            gridModel.switcherState = .tabs
        }
        if gridModel.tabCardModel.allDetails.isEmpty {
            showWithNoAnimation()
        } else {
            if FeatureFlag[.enableTimeBasedSwitcher] {
                gridModel.tabCardModel.contentVisibilityPublisher.send()
            }
            gridModel.scrollToSelectedTab { [self] in
                cardTransitionModel.update(to: .visibleForTrayShow)
                contentVisibilityModel.update(showContent: false)
                updateSpaces()
            }
        }
    }

    func showWithNoAnimation() {
        if FeatureFlag[.enableTimeBasedSwitcher] {
            gridModel.tabCardModel.contentVisibilityPublisher.send()
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

    func hideWithAnimation() {
        assert(!gridModel.tabCardModel.allDetails.isEmpty)
        gridModel.scrollToSelectedTab { [self] in
            cardTransitionModel.update(to: .visibleForTrayHidden)
            gridModel.closeDetailView()
        }
    }

    func hideWithNoAnimation() {
        gridModel.scrollToSelectedTab()
        cardTransitionModel.update(to: .hidden)

        if showGrid {
            showGrid = false
        }

        contentVisibilityModel.update(showContent: true)

        gridModel.switcherState = .tabs
        gridModel.closeDetailView()
    }

    func onCompletedCardTransition() {
        if showGrid {
            cardTransitionModel.update(to: .hidden)
        } else {
            hideWithNoAnimation()
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
                gridModel.refreshDetailedSpace()
                return
            }

            gridModel.isLoading = true
            SpaceStore.openSpaceWithNoFollow(spaceId: spaceId) { [self] result in
                guard let result = result else {
                    gridModel.isLoading = false
                    return
                }
                switch result {
                case .success(let model):
                    let spaceCardDetails = SpaceCardDetails(
                        space: model, manager: SpaceStore.shared)
                    openSpace(detail: spaceCardDetails)
                    gridModel.isLoading = false
                    completion()
                case .failure:
                    gridModel.isLoading = false
                    ToastDefaults().showToast(
                        with: "Unable to find Space",
                        toastViewManager: toastViewManager
                    )
                }
            }
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

    func openSpace(detail: SpaceCardDetails) {
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
