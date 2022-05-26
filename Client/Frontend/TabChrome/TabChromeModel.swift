// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import SwiftUI

class TabChromeModel: ObservableObject {
    @Published var canGoBack: Bool
    @Published var canGoForward: Bool
    var canReturnToSuggestions: Bool {
        guard let selectedTab = topBarDelegate?.tabManager.selectedTab,
            let currentItem = selectedTab.webView?.backForwardList.currentItem
        else {
            return false
        }

        guard let query = selectedTab.queryForNavigation.findQueryFor(navigation: currentItem)
        else {
            return false
        }
        return query.location == .suggestion
    }

    /// True when the toolbar is inline with the location view
    /// (when in landscape or on iPad)
    @Published var inlineToolbar: Bool

    @Published private(set) var isPage: Bool
    @Published private(set) var isErrorPage: Bool = false
    @Published private(set) var urlInSpace: Bool = false
    private var spaceRefreshSubscription: AnyCancellable?

    var showTopCardStrip: Bool {
        FeatureFlag[.cardStrip] && FeatureFlag[.topCardStrip] && inlineToolbar
            && !isEditingLocation
    }

    var appActiveRefreshSubscription: AnyCancellable? = nil
    private var subscriptions: Set<AnyCancellable> = []

    private var urlSubscription: AnyCancellable?
    weak var topBarDelegate: TopBarDelegate? {
        didSet {
            $isEditingLocation
                .withPrevious()
                .sink { [weak topBarDelegate] change in
                    switch change {
                    case (false, true):
                        topBarDelegate?.urlBarDidEnterOverlayMode()
                    case (true, false):
                        topBarDelegate?.urlBarDidLeaveOverlayMode()
                    default: break
                    }
                }
                .store(in: &subscriptions)
            $isEditingLocation
                .combineLatest(topBarDelegate!.searchQueryModel.$value)
                .withPrevious()
                .sink { [weak topBarDelegate] (prev, current) in
                    let (prevEditing, _) = prev
                    let (isEditing, query) = current
                    if let delegate = topBarDelegate, (prevEditing, isEditing) == (true, true) {
                        if query.isEmpty {
                            delegate.tabContainerModel.updateContent(.hideSuggestions)
                        } else {
                            delegate.tabContainerModel.updateContent(.showSuggestions)
                        }
                    }
                }
                .store(in: &subscriptions)
            setupURLObserver()
        }
    }
    weak var toolbarDelegate: ToolbarDelegate?

    enum ReloadButtonState: String {
        case reload = "Reload"
        case stop = "Stop"
    }
    var reloadButton: ReloadButtonState {
        estimatedProgress == 1 || estimatedProgress == nil ? .reload : .stop
    }
    @Published var estimatedProgress: Double?

    @Published private(set) var isEditingLocation = false

    @Published var showNeevaMenuTourPrompt = false

    private var inlineToolbarHeight: CGFloat {
        return UIConstants.TopToolbarHeightWithToolbarButtonsShowing
            + (showTopCardStrip ? CardControllerUX.Height : 0)
    }

    private var portraitHeight: CGFloat {
        return UIConstants.PortraitToolbarHeight
            + (showTopCardStrip ? CardControllerUX.Height : 0)
    }

    var topBarHeight: CGFloat {
        return inlineToolbar ? inlineToolbarHeight : portraitHeight
    }

    @Published var keyboardShowing = false
    @Published var bottomBarHeight: CGFloat = 0

    init(
        canGoBack: Bool = false, canGoForward: Bool = false, isPage: Bool = false,
        inlineToolbar: Bool = false, estimatedProgress: Double? = nil
    ) {
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.isPage = isPage
        self.inlineToolbar = inlineToolbar
        self.estimatedProgress = estimatedProgress
    }

    /// Calls the address bar to be selected and enter editing mode
    func triggerOverlay() {
        isEditingLocation = true
    }

    func setEditingLocation(to value: Bool) {
        withAnimation(TabLocationViewUX.animation) {
            isEditingLocation = value
        }
    }

    func hideZeroQuery() {
        SceneDelegate.getBVC(with: topBarDelegate?.tabManager.scene).hideZeroQuery()
    }

    private func setupURLObserver() {
        urlSubscription?.cancel()
        spaceRefreshSubscription?.cancel()

        guard let tabManager = topBarDelegate?.tabManager else {
            return
        }

        urlSubscription = Publishers.CombineLatest(
            tabManager.selectedTabPublisher,
            tabManager.selectedTabURLPublisher
        ).sink { [weak self] tab, url in
            guard let self = self else {
                return
            }

            self.isPage = url?.displayURL?.isWebPage() ?? false
            self.isErrorPage = InternalURL(url)?.isErrorPage ?? false
        }

        spaceRefreshSubscription = Publishers.CombineLatest(
            SpaceStore.shared.$state,
            tabManager.selectedTabURLPublisher
        )
        .map { state, url -> Bool? in
            guard case .ready = state else {
                return nil
            }
            guard let url = url else {
                return false
            }
            return SpaceStore.shared.urlInASpace(url)
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            if let result = result {
                self?.urlInSpace = result
            }
        }

        CheatsheetMenuViewModel.promoModel.subscribe(
            to: tabManager.selectedTabURLPublisher.eraseToAnyPublisher()
        )
    }
}
