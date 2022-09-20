// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

/// Methods in this struct are not thread safe
private struct PromoStateStorage {
    struct State {
        var showPromo: Bool
        var showBubble: Bool

        static let missed: Self = .init(showPromo: false, showBubble: false)
        static let hit: Self = .init(showPromo: true, showBubble: false)
    }

    enum Transition {
        case dismissPromo
        case dismissBubble
    }

    private let bloomFilterManager: BloomFilterManager = .shared
    private var cache: [URL: State] = [:]

    // MARK: - Getters
    func getState(for url: URL) -> State? {
        return cache[url]
    }

    // MARK: - Setters
    /// Perform initial bloom filter hit test for an input url and initialize state entry in cache
    mutating func provision(url: URL) {
        guard cache[url] == nil else {
            return
        }

        var counters: [CheatsheetIntAttribute] = []
        defer {
            CheatsheetLogger.shared.increment(counters)
        }

        counters.append(.numOfUGCTests)

        // if cannot construct canonical url, consider as miss
        guard let canonicalURL = CanonicalURL(from: url, stripMobile: true, relaxed: true)?.asString
        else {
            counters.append(.numOfUGCCanonicalError)
            cache[url] = .missed
            return
        }

        // leave value as unintialized if bloom filter manager is not ready to produce a result
        guard let result = bloomFilterManager.contains(canonicalURL)
        else {
            counters.append(.numOfUGCNoResult)
            return
        }

        cache[url] = result ? .hit : .missed
        if result {
            counters.append(.numOfUGCHits)
        }
    }

    mutating func performTransition(on url: URL, transition: Transition) {
        assert(Thread.isMainThread)
        guard var state = cache[url] else {
            return
        }

        switch transition {
        case .dismissPromo:
            if state.showPromo {
                state.showBubble = true
            }
            state.showPromo = false
        case .dismissBubble:
            state.showPromo = false
            state.showBubble = false
            CheatsheetLogger.shared.increment([.numOfUGCClears])
        }

        cache[url] = state
    }
}

class CheatsheetPromoModel: ObservableObject {
    enum PromoType {
        case tryCheatsheet
        case UGC
    }

    private enum UIUpdate {
        case clearPromo
        case setTryPromo
        case syncUGCState(state: PromoStateStorage.State, url: URL)
    }

    // MARK: - Static Properties
    private static let queue = DispatchQueue(
        label: "co.neeva.app.ios.browser.CheatsheetPromoModel",
        qos: .userInteractive,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: nil
    )
    static let ugcIndicatorDurationS: TimeInterval = 4
    // wait for bottom tool bar to show up completely before presenting promo
    static let showPromoDelay: DispatchTimeInterval = .milliseconds(200)

    // MARK: - Published Properties
    @Published var showPromo: Bool = false
    @Published var showBubble: Bool = false
    var popoverDimBackground: Bool { !(promoType == .UGC) }
    var popoverUseAlternativeShadow: Bool { promoType == .UGC }

    // MARK: - Private Properties
    private var stateStorage: PromoStateStorage!
    private var promoType: PromoType?
    private var selectedURLSubscription: AnyCancellable?
    private var tabEventSubcription: AnyCancellable?
    private var tabSelectionSubscription: AnyCancellable?
    private var ugcIndicatorDismissTimer: Timer?

    private var currentURL: URL?
    private let uiUpdatePublisher = PassthroughSubject<UIUpdate, Never>()
    private var uiUpdateSubscription: AnyCancellable?

    init() {
        if Defaults[.useCheatsheetBloomFilters] {
            stateStorage = PromoStateStorage()
        }
    }

    // MARK: - Subscription Methods
    func subscribe(
        to visibilityManager: ContentVisibilityModel,
        overlayManager: OverlayManager
    ) {
        // we wait until the browser has finished animating and the
        // webcontent and tool bar is fully visible
        uiUpdateSubscription?.cancel()
        let isOverlayShowingPublisher = Publishers.CombineLatest(
            overlayManager.$currentOverlay,
            overlayManager.$animationCompleted
        ).map { currentOverlay, animationCompleted in
            return currentOverlay != nil || animationCompleted != nil
        }.removeDuplicates()
        uiUpdateSubscription = Publishers.CombineLatest3(
            uiUpdatePublisher,
            visibilityManager.$showContent.removeDuplicates(),
            isOverlayShowingPublisher
        )
        .compactMap { update, visible, isOverlayShowing -> UIUpdate? in
            guard visible, !isOverlayShowing else {
                return nil
            }
            return update
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] update in
            self?.perform(uiUpdate: update)
        }
    }

    /// Subscribe to tabManager's selectedTabPublisher
    func subscribe(to tabManager: TabManager) {
        if Defaults[.useCheatsheetBloomFilters] {
            selectedURLSubscription = tabManager.selectedTabURLPublisher
                .removeDuplicates()
                .compactMap { url -> URL? in
                    // check isInNeevaDomain on Main
                    precondition(Thread.isMainThread)
                    guard let url = url,
                        !(url.scheme == InternalURL.scheme),
                        !NeevaConstants.isInNeevaDomain(url)
                    else {
                        return nil
                    }
                    return url
                }
                .receive(on: Self.queue)
                .sink { [weak self] url in
                    self?.stateStorage.provision(url: url)
                }
        }

        tabSelectionSubscription = tabManager.selectedTabPublisher
            .removeDuplicates()
            .sink { [weak self] tab in
                self?.tabEventSubcription?.cancel()
                self?.scheduleClearDisplayedStates()
                if let tab = tab {
                    self?.subscribe(to: tab)
                }
            }
    }

    private func subscribe(to tab: Tab) {
        precondition(Thread.isMainThread)
        self.tabEventSubcription = Publishers.CombineLatest3(
            Defaults.publisher(.showTryCheatsheetPopover),
            tab.$url,
            tab.$isLoading
        )
        .filter { _, _, isLoading in
            return !isLoading
        }
        .sink { [weak self] showPopover, url, _ in
            // check isInNeevaDomain on Main
            precondition(Thread.isMainThread)
            self?.currentURL = url
            guard let url = url,
                // avoid flashing the popover when app launches
                !(url.scheme == InternalURL.scheme),
                // cheatsheet is not used on NeevaDomain
                !NeevaConstants.isInNeevaDomain(url),
                // Do not show promo when page is not valid
                TabChromeModel.isPage(url: url),
                !TabChromeModel.isErrorPage(url: url)
            else {
                self?.scheduleClearDisplayedStates()
                return
            }

            if showPopover.newValue {
                if Defaults[.tryCheatsheetPopoverCount] > 0 {
                    self?.scheduleSetDisplayedStateForTryCheatsheet()
                } else {
                    ClientLogger.shared.logCounter(
                        .CheatsheetPopoverReachedLimit,
                        attributes: EnvironmentHelper.shared.getAttributes(for: [
                            .isUserSignedIn
                        ])
                    )
                }
            } else if Defaults[.useCheatsheetBloomFilters] {
                Self.queue.async {
                    self?.updateDisplayedStateFromUGCStorage(for: url)
                }
            }
        }
    }

    // MARK: - State Management Methods
    private func perform(uiUpdate: UIUpdate) {
        switch uiUpdate {
        case .clearPromo:
            showPromo = false
            showBubble = false
            promoType = nil
        case .setTryPromo:
            showPromo = true
            showBubble = false
            promoType = .tryCheatsheet
        case .syncUGCState(let state, let url):
            guard currentURL == url else {
                return
            }
            promoType = .UGC
            showPromo = state.showPromo
            showBubble = state.showBubble
            if showPromo {
                setupUGCIndicatorDismissTimer(targetURL: url)
            }
        }
        objectWillChange.send()
    }

    private func scheduleClearDisplayedStates() {
        uiUpdatePublisher.send(.clearPromo)
    }

    private func scheduleSetDisplayedStateForTryCheatsheet() {
        uiUpdatePublisher.send(.setTryPromo)
    }

    private func updateDisplayedStateFromUGCStorage(for url: URL) {
        dispatchPrecondition(condition: .onQueue(Self.queue))
        guard Defaults[.useCheatsheetBloomFilters],
            let cachedState = stateStorage.getState(for: url)
        else {
            scheduleClearDisplayedStates()
            return
        }

        // Since this function schedules ui update on a background thread,
        // the page's url could have changed by the time the update is executed
        // need to make sure that the url is still the one for which
        // we acquired the state
        uiUpdatePublisher.send(.syncUGCState(state: cachedState, url: url))
    }

    // MARK: - Interaction Methods
    func openSheet(on url: URL?) {
        precondition(Thread.isMainThread)
        switch promoType {
        case .tryCheatsheet:
            // If try cheatsheet promo is shown on a page on which UGC also hits
            // need to dismiss UGC promo state before sending `showTryCheatsheetPopover` change
            if Defaults[.useCheatsheetBloomFilters],
                let url = url
            {
                self.stateStorage?.performTransition(on: url, transition: .dismissPromo)
            }
            Defaults[.showTryCheatsheetPopover] = false
            scheduleClearDisplayedStates()
        case .UGC:
            // transition straight to dismiss bubble
            if let url = url {
                dismissBubble(on: url)
            } else {
                assertionFailure("Inconsistence state for bubble")
                scheduleClearDisplayedStates()
            }
        case .none:
            break
        }
    }

    private func dismissBubble(on url: URL) {
        Self.queue.async {
            DispatchQueue.main.sync {
                self.stateStorage.performTransition(on: url, transition: .dismissBubble)
            }
            self.updateDisplayedStateFromUGCStorage(for: url)
        }
    }

    // MARK: - Timer Methods
    private func setupUGCIndicatorDismissTimer(targetURL: URL) {
        cancelUGCIndicatorDismissTimer()

        ugcIndicatorDismissTimer = Timer.scheduledTimer(
            withTimeInterval: Self.ugcIndicatorDurationS,
            repeats: false
        ) { [weak self] _ in
            self?.onUGCTimerFired(on: targetURL)
        }
    }

    private func cancelUGCIndicatorDismissTimer() {
        precondition(
            Thread.isMainThread,
            "Timer must be invalidated from the same thread on which it was installed."
        )
        ugcIndicatorDismissTimer?.invalidate()
        ugcIndicatorDismissTimer = nil
    }

    private func onUGCTimerFired(on url: URL) {
        cancelUGCIndicatorDismissTimer()
        Self.queue.async {
            DispatchQueue.main.sync {
                self.stateStorage.performTransition(on: url, transition: .dismissPromo)
            }
            self.updateDisplayedStateFromUGCStorage(for: url)
        }
    }
}

// MARK: - Popover UI Functions
extension CheatsheetPromoModel {
    func getPopoverBackgroundColor() -> UIColor {
        switch promoType {
        case .none:
            return .systemBackground
        case .some(let promo):
            switch promo {
            case .tryCheatsheet:
                return UIColor { (trait: UITraitCollection) -> UIColor in
                    (trait.userInterfaceStyle == .dark) ? .brand.variant.polar : .brand.blue
                }
            case .UGC:
                return .systemBackground
            }
        }
    }

    @ViewBuilder
    func getPopoverContent() -> some View {
        switch promoType {
        case .none:
            EmptyView()
        case .some(let promo):
            switch promo {
            case .tryCheatsheet:
                CheatsheetTooltipPopoverView()
                    .onAppear {
                        Defaults[.tryCheatsheetPopoverCount] -= 1
                    }
            case .UGC:
                CheatsheetUGCIndicatorView()
                    .onTapGesture {
                        self.ugcIndicatorDismissTimer?.fire()
                    }
                    .onDisappear {
                        self.ugcIndicatorDismissTimer?.fire()
                    }
            }
        }
    }
}
