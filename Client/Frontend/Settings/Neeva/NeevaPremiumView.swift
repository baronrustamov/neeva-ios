// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import StoreKit
import SwiftUI

@available(iOS 15.0, *)
struct NeevaPremiumView: View {
    @ObservedObject var userInfo: NeevaUserInfo
    // NOTE: we listen for changes on the store incase products are loading
    @ObservedObject var premiumStore: PremiumStore

    @State var currentPremiumPlan: PremiumPlan? = .annual

    init(userInfo: NeevaUserInfo) {
        self.userInfo = userInfo

        if let currentPlan = userInfo.subscription?.plan {
            if currentPlan == SubscriptionPlan.annual {
                self.currentPremiumPlan = PremiumPlan.annual
            } else if currentPlan == SubscriptionPlan.monthly {
                self.currentPremiumPlan = PremiumPlan.monthly
            }
        }

        premiumStore = PremiumStore.shared
    }

    var premiumBullets = [
        ("Browser + ad blocker", ""),
        ("Tracking prevention", ""),
        ("Unlimited ad-free, private search", ""),
        ("Premium password manager + VPN", ""),
    ]
    var freeBullets = [
        ("Browser + ad blocker", ""),
        ("Tracking prevention", ""),
        ("Ad-free, private search", "50 searches/week"),
    ]
    var bullets: [(String, String)] {
        if currentPremiumPlan == nil {
            return freeBullets
        } else {
            return premiumBullets
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            WelcomeFlowHeaderView(text: "Get Premium for maximum privacy")
                .padding(.bottom, 20)

            HStack(spacing: 0) {
                VStack {
                    Text("FREE")
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding(8)
                .if(currentPremiumPlan == nil) { view in
                    view
                        .foregroundColor(.blue)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.blue, lineWidth: 3)
                        )
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.logCounter(.BrowsePlanClick)
                    currentPremiumPlan = nil
                }

                if let annualProduct = PremiumStore.shared.getProductForPlan(.annual) {
                    VStack {
                        Text("Premium\nAnnual")
                            .font(.system(size: 16, weight: .bold))
                        Text("\(PremiumHelpers.priceString(from: annualProduct.price / 12)) /mo")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .if(currentPremiumPlan == .annual) { view in
                        view
                            .foregroundColor(.blue)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(.blue, lineWidth: 3)
                            )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.logCounter(.BrowsePlanClick)
                        currentPremiumPlan = .annual
                    }
                }

                if let monthlyProduct = PremiumStore.shared.getProductForPlan(.monthly) {
                    VStack {
                        Text("Premium\nMonthly")
                            .font(.system(size: 16, weight: .bold))
                        Text("\(monthlyProduct.displayPrice) /mo")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .if(currentPremiumPlan == .monthly) { view in
                        view
                            .foregroundColor(.blue)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(.blue, lineWidth: 3)
                            )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.logCounter(.BrowsePlanClick)
                        currentPremiumPlan = .monthly
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondaryLabel).opacity(0.25)).cornerRadius(8)

            Spacer()

            ForEach(bullets, id: \.self.0) { (primary, secondary) in
                HStack(alignment: .top) {
                    Symbol(decorative: .checkmark, size: 18)
                        .foregroundColor(Color.ui.adaptive.blue)
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey(primary)).font(.system(size: 16, weight: .bold))
                        if secondary != "" {
                            Text(LocalizedStringKey(secondary)).font(.system(size: 12))
                        }
                    }
                }
                .padding(.bottom, 10)
            }

            Group {
                Spacer()

                HStack {
                    Text(PremiumStore.shared.priceText(currentPremiumPlan)).fontWeight(.bold)
                    if let termText = PremiumHelpers.termText(currentPremiumPlan), termText != "" {
                        Text(LocalizedStringKey(termText)).foregroundColor(.secondaryLabel)
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

                if let subText = PremiumHelpers.priceSubText(currentPremiumPlan) {
                    HStack {
                        if subText.0 != "" {
                            Text(LocalizedStringKey(subText.0))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("·").foregroundColor(.secondaryLabel)
                            Text(LocalizedStringKey(subText.1)).foregroundColor(.secondaryLabel)
                        } else {
                            Text(LocalizedStringKey(subText.1)).foregroundColor(.secondaryLabel)
                        }
                    }
                    .withFont(unkerned: .bodySmall)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }

                Spacer()
            }

            if currentPremiumPlan != nil {
                Button(
                    action: {
                        self.logCounter(.ChoosePlanClick)

                        if let product = PremiumStore.shared.getProductForPlan(currentPremiumPlan) {
                            PremiumStore.shared.purchase(
                                product, reloadUserInfo: true,
                                onPending: self.onPurchasePending,
                                onCancelled: self.onPurchaseCancelled,
                                onSuccess: self.onPurchaseSuccess)
                        }
                    },
                    label: {
                        Text(
                            LocalizedStringKey(
                                PremiumHelpers.primaryActionText(
                                    currentPremiumPlan, subscribed: isSubscribedToPlan()))
                        )
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(.neeva(.primary))
            }

            if isSubscribedToPlan() {
                Text("This is your current plan.")
                    .foregroundColor(.secondaryLabel)
                    .withFont(.bodySmall)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 25)
    }

    func onPurchasePending() {
        // TODO: what should we do here for the UX?

        self.logCounter(.SettingPremiumPurchasePending)
    }

    func onPurchaseCancelled() {
        self.logCounter(.SettingPremiumPurchaseCanceled)
    }

    func onPurchaseSuccess(_ type: PremiumPurchaseSuccessType) {
        self.logCounter(.SettingPremiumPurchaseComplete)
    }

    private func isSubscribedToPlan() -> Bool {
        return
            (userInfo.subscription?.plan == .monthly
            && currentPremiumPlan == .monthly)
            || (userInfo.subscription?.plan == .annual
                && currentPremiumPlan == .annual)
    }

    private func logCounter(_ interaction: LogConfig.Interaction) {
        var attributes = EnvironmentHelper.shared.getAttributes()

        // source attribute
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.source, value: "Settings"
            )
        )

        // plan attribute
        if let currentPlan = currentPremiumPlan {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan,
                    value: currentPlan == .annual ? "Annual" : "Monthly"
                )
            )
        } else {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan, value: "Free"
                )
            )
        }

        ClientLogger.shared.logCounter(
            interaction,
            attributes: attributes
        )
    }
}
