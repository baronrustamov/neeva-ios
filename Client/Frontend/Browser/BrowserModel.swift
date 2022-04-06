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

    func show() {
        if gridModel.switcherState != .tabs {
            gridModel.switcherState = .tabs
        }
        if gridModel.tabCardModel.allDetails.isEmpty {
            showWithNoAnimation()
        } else {
            cardTransitionModel.update(to: .visibleForTrayShow)
            contentVisibilityModel.update(showContent: false)
            updateSpaces()
        }
    }

    func showWithNoAnimation() {
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
        cardTransitionModel.update(to: .visibleForTrayHidden)

        gridModel.closeDetailView()
    }

    func hideWithNoAnimation() {
        cardTransitionModel.update(to: .hidden)

        if showGrid {
            showGrid = false
        }

        contentVisibilityModel.update(showContent: true)

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
        guard NeevaUserInfo.shared.hasLoginCookie() else {
            var spaceURL = NeevaConstants.appSpacesURL
            spaceURL.appendPathComponent(spaceId)
            bvc.switchToTabForURLOrOpen(spaceURL, isIncognito: isIncognito)
            return
        }

        let existingSpace = gridModel.spaceCardModel.allDetails.first(where: { $0.id == spaceId })
        DispatchQueue.main.async { [self] in
            if incognitoModel.isIncognito {
                tabManager.toggleIncognitoMode()
            }

            if let existingSpace = existingSpace {
                openSpace(spaceID: existingSpace.id)
                gridModel.refreshDetailedSpace()
            } else {
                bvc.showTabTray()
                gridModel.switcherState = .spaces
                gridModel.isLoading = true
            }

            guard existingSpace == nil else {
                return
            }

            SpaceStore.openSpace(spaceId: spaceId) { [self] error in
                if error != nil {
                    gridModel.isLoading = false

                    ToastDefaults().showToast(
                        with: "Unable to find Space",
                        toastViewManager: SceneDelegate.getCurrentSceneDelegate(for: bvc.view)
                            .toastViewManager
                    )

                    return
                }

                let spaceCardModel = bvc.gridModel.spaceCardModel
                if let _ = spaceCardModel.allDetails.first(where: { $0.id == spaceId }) {
                    gridModel.isLoading = false
                    openSpace(spaceID: spaceId, animate: false)
                    completion()
                } else {
                    followPublicSpaceSubscription = spaceCardModel.objectWillChange.sink {
                        [self] in  // OK to hold a strong ref as this should terminate.
                        if let _ = spaceCardModel.allDetails.first(where: { $0.id == spaceId }) {
                            openSpace(
                                spaceID: spaceId, animate: false)
                            completion()
                            followPublicSpaceSubscription = nil
                        }

                        gridModel.isLoading = false
                    }
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

    func openSpaceDigest(bvc: BrowserViewController) {
        bvc.showTabTray()
        gridModel.switcherState = .spaces

        openSpace(spaceId: SpaceStore.dailyDigestID, bvc: bvc) {}
    }

    init(
        gridModel: GridModel, tabManager: TabManager, chromeModel: TabChromeModel,
        incognitoModel: IncognitoModel, switcherToolbarModel: SwitcherToolbarModel
    ) {
        self.gridModel = gridModel
        self.tabManager = tabManager
        self.incognitoModel = incognitoModel
        self.cardTransitionModel = CardTransitionModel()
        self.contentVisibilityModel = ContentVisibilityModel()
        self.scrollingControlModel = ScrollingControlModel(
            tabManager: tabManager, chromeModel: chromeModel)
        self.switcherToolbarModel = switcherToolbarModel
    }
}
