// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

/// Methods in this class are not thread safe
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

        // if cannot construct canonical url, consider as miss
        guard let canonicalURL = CanonicalURL(from: url)?.asString
        else {
            cache[url] = .missed
            return
        }

        // leave value as unintialized if bloom filter manager is not ready to produce a result
        guard let result = bloomFilterManager.contains(canonicalURL)
        else {
            return
        }

        cache[url] = result ? .hit : .missed
    }

    mutating func performTransition(on url: URL, transition: Transition) {
        guard var state = cache[url] else {
            return
        }

        switch transition {
        case .dismissPromo:
            state.showPromo = false
            state.showBubble = true
        case .dismissBubble:
            state.showBubble = false
        }

        cache[url] = state
    }
}

public class CheatsheetPromoModel: ObservableObject {
    enum PromoType {
        case tryCheatsheet
        case UGC
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

    // MARK: - Private Properties
    private var stateStorage: PromoStateStorage!
    private var promoType: PromoType?
    private var selectedURLSubscription: AnyCancellable?
    private var tabEventSubcription: AnyCancellable?
    private var tabSelectionSubscription: AnyCancellable?
    private var ugcIndicatorDismissTimer: Timer?

    init() {
        if Defaults[.useCheatsheetBloomFilters] {
            stateStorage = PromoStateStorage()
        }
    }

    // MARK: - Subscription Methods
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
                self?.clearDisplayedStates()
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
            guard let url = url,
                // avoid flashing the popover when app launches
                !(url.scheme == InternalURL.scheme),
                // cheatsheet is not used on NeevaDomain
                !NeevaConstants.isInNeevaDomain(url)
            else {
                self?.clearDisplayedStates()
                return
            }

            var showIntroPopover: Bool = showPopover.newValue
            // Show intro on recipe pages for the first time
            if !Defaults[.seenTryCheatsheetPopoverOnRecipe],
                DomainAllowList.isRecipeAllowed(url: url)
            {
                showIntroPopover = true
            }

            if showIntroPopover {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.showPromoDelay) {
                    self?.setDisplayedStateForTryCheatsheet()
                }
            } else if Defaults[.useCheatsheetBloomFilters] {
                Self.queue.async {
                    self?.updateDisplayedStateFromUGCStorage(for: url)
                }
            }
        }
    }

    // MARK: - State Management Methods
    private func clearDisplayedStates() {
        precondition(Thread.isMainThread)
        self.showPromo = false
        self.showBubble = false
        self.promoType = nil
        self.objectWillChange.send()
    }

    private func setDisplayedStateForTryCheatsheet() {
        precondition(Thread.isMainThread)
        self.showPromo = true
        self.showBubble = false
        self.promoType = .tryCheatsheet
        self.objectWillChange.send()
    }

    private func updateDisplayedStateFromUGCStorage(for url: URL) {
        dispatchPrecondition(condition: .onQueue(Self.queue))
        guard Defaults[.useCheatsheetBloomFilters],
            let cachedState = stateStorage.getState(for: url)
        else {
            DispatchQueue.main.async { [weak self] in
                self?.clearDisplayedStates()
            }
            return
        }

        if cachedState.showPromo {
            // Sometimes popover can be presented when the tab selection animation has not finished yet
            // that would cause the popover to dismiss itself immediately and clears the flag
            // 200ms delays seems to be sufficient
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.showPromoDelay) { [weak self] in
                guard let self = self else {
                    return
                }

                self.promoType = .UGC
                self.showPromo = true
                self.showBubble = false
                self.setupUGCIndicatorDismissTimer(targetURL: url)
                self.objectWillChange.send()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.promoType = nil
                self.showPromo = false
                self.showBubble = cachedState.showBubble
                self.objectWillChange.send()
            }
        }
    }

    //MARK: - Interaction Methods
    func openSheet(on url: URL?) {
        precondition(Thread.isMainThread)
        if promoType == .UGC,
            showBubble
        {
            if let url = url {
                dismissBubble(on: url)
            } else {
                assertionFailure("Inconsistence state for bubble")
                clearDisplayedStates()
            }
        } else {
            dismissPromo(on: url)
        }
    }

    private func dismissPromo(on url: URL?) {
        if promoType == .tryCheatsheet {
            // If try cheatsheet promo is shown on a page on which UGC also hits
            // need to dismiss UGC promo state before sending `showTryCheatsheetPopover` change
            if let url = url {
                self.stateStorage.performTransition(on: url, transition: .dismissPromo)
            }
            Defaults[.showTryCheatsheetPopover] = false
            if let currentURL = url,
                DomainAllowList.isRecipeAllowed(url: currentURL)
            {
                Defaults[.seenTryCheatsheetPopoverOnRecipe] = true
            }
            clearDisplayedStates()
        } else if promoType == .UGC {
            if let url = url {
                onDissmissUGCPromo(on: url)
            } else {
                assertionFailure("Inconsistence state for UGC promo")
                clearDisplayedStates()
            }
        }
    }

    private func dismissBubble(on url: URL) {
        Self.queue.async {
            self.stateStorage.performTransition(on: url, transition: .dismissBubble)
            self.updateDisplayedStateFromUGCStorage(for: url)
        }
    }

    private func onDissmissUGCPromo(on url: URL) {
        cancelUGCIndicatorDismissTimer()
        Self.queue.async {
            self.stateStorage.performTransition(on: url, transition: .dismissPromo)
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
            self?.onDissmissUGCPromo(on: targetURL)
        }
    }

    private func cancelUGCIndicatorDismissTimer() {
        precondition(
            Thread.isMainThread,
            "Timer must be invalidated from the same thread on which it was installed.")
        ugcIndicatorDismissTimer?.invalidate()
        ugcIndicatorDismissTimer = nil
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
            case .UGC:
                CheatsheetUGCIndicatorView()
                    .onDisappear {
                        self.ugcIndicatorDismissTimer?.fire()
                    }
            }
        }
    }
}
