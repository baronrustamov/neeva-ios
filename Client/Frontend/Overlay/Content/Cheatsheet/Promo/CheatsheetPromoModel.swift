// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

public class CheatsheetPromoModel: ObservableObject {
    enum PromoType {
        case tryCheatsheet
        case UGC
    }

    // MARK: - Static Properties
    static let bloomFilterManager = BloomFilterManager()
    private static let queue = DispatchQueue(
        label: "co.neeva.app.ios.browser.CheatsheetPromoModel",
        qos: .userInteractive,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: nil
    )
    static let ugcIndicatorDurationS: TimeInterval = 4

    // MARK: - Published Properties
    @Published var showPromo: Bool = false
    @Published var showBubble: Bool = false

    // MARK: - Private Properties
    private var promoType: PromoType?
    private var urlSubscription: AnyCancellable?
    private var ugcIndicatorDismissTimer: Timer?

    // MARK: - Public Functions
    func subscribe(to urlPublisher: AnyPublisher<URL?, Never>) {
        urlSubscription?.cancel()

        urlSubscription = Publishers.CombineLatest(
            Defaults.publisher(.showTryCheatsheetPopover),
            urlPublisher
        )
        .receive(on: Self.queue)
        .map { showPopover, url -> PromoType? in
            guard let url = url else {
                return nil
            }

            if !Defaults[.seenTryCheatsheetPopoverOnRecipe],
                DomainAllowList.isRecipeAllowed(url: url)
            {
                return .tryCheatsheet
            }

            // else show popover if seen SRP intro screen
            if showPopover.newValue,
                // cheatsheet is not used on NeevaDomain
                !NeevaConstants.isInNeevaDomain(url),
                // avoid flashing the popover when app launches
                !(url.scheme == InternalURL.scheme)
            {
                return .tryCheatsheet
            }

            // if not showing Try Cheatsheet Tooltip, check for UGC indicators
            if Defaults[.useCheatsheetBloomFilters],
                !(url.scheme == InternalURL.scheme),
                let canonicalURL = CanonicalURL(from: url)?.asString,
                Self.bloomFilterManager.contains(canonicalURL)
            {
                return .UGC
            }
            return nil
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            guard let self = self else {
                return
            }
            self.promoType = $0
            self.showPromo = $0 != nil
            self.showBubble = false
        }
    }

    func openSheet(on url: URL?) {
        Defaults[.showTryCheatsheetPopover] = false
        if let currentURL = url,
            DomainAllowList.isRecipeAllowed(url: currentURL)
        {
            Defaults[.seenTryCheatsheetPopoverOnRecipe] = true
        }
        showBubble = false
    }

    // MARK: - Popover UI Functions
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
                    .onAppear(perform: setupUGCIndicatorDismissTimer)
                    .onDisappear {
                        self.cancelUGCIndicatorDismissTimer()
                        self.showBubble = true
                    }
            }
        }
    }

    // MARK: - Private Functions
    private func setupUGCIndicatorDismissTimer() {
        cancelUGCIndicatorDismissTimer()

        ugcIndicatorDismissTimer = Timer.scheduledTimer(
            withTimeInterval: Self.ugcIndicatorDurationS,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            if let promoType = self.promoType,
                case .UGC = promoType
            {
                self.showPromo = false
            }
        }
    }

    private func cancelUGCIndicatorDismissTimer() {
        ugcIndicatorDismissTimer?.invalidate()
        ugcIndicatorDismissTimer = nil
    }
}
