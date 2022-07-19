// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import SwiftUI

class TabChromeModel: ObservableObject {
    enum ReloadButtonState: String {
        case reload = "Reload"
        case stop = "Stop"
    }

    /// True when the toolbar is inline with the location view
    /// (when in landscape or on iPad)
    @Published var inlineToolbar: Bool
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published private(set) var isPage: Bool
    @Published private(set) var isErrorPage: Bool = false
    @Published private(set) var urlInSpace: Bool = false
    @Published var estimatedProgress: Double?
    @Published private(set) var isEditingLocation = false
    @Published var showNeevaMenuTourPrompt = false
    @Published var keyboardShowing = false
    @Published var bottomBarHeight: CGFloat = 0

    private var appActiveRefreshSubscription: AnyCancellable? = nil
    private var navigationSubscriptions: Set<AnyCancellable> = []
    private var spaceRefreshSubscription: AnyCancellable?
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

    var reloadButton: ReloadButtonState {
        estimatedProgress == 1 || estimatedProgress == nil ? .reload : .stop
    }

    init(
        isPage: Bool = false, inlineToolbar: Bool = false, estimatedProgress: Double? = nil
    ) {
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
        SceneDelegate.getBVC(with: topBarDelegate?.tabManager.scene)
            .dismissEditingAndHideZeroQuery()
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

            self.isPage = Self.isPage(url: url)
            self.isErrorPage = Self.isErrorPage(url: url)

            self.navigationSubscriptions = []
            self.canGoBack = tab?.canGoBack ?? false
            self.canGoForward = tab?.canGoForward ?? false

            tab?.$canGoBack
                .assign(to: \.canGoBack, on: self)
                .store(in: &self.navigationSubscriptions)

            tab?.$canGoForward
                .assign(to: \.canGoForward, on: self)
                .store(in: &self.navigationSubscriptions)
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
    }

    class func isPage(url: URL?) -> Bool {
        guard let url = url?.displayURL else {
            return false
        }
        return url.isWebPage()
    }

    class func isErrorPage(url: URL?) -> Bool {
        guard let url = url,
            let internalURL = InternalURL(url)
        else {
            return false
        }
        return internalURL.isErrorPage
    }
}
