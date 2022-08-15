// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct WelcomeFlowPlansView: View {
    @ObservedObject var model: WelcomeFlowModel

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
        if model.currentPremiumPlan == nil {
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
                .if(model.currentPremiumPlan == nil) { view in
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
                    model.logCounter(
                        .BrowsePlanClick,
                        attributes: [
                            ClientLogCounterAttribute(
                                key: LogConfig.Attribute.subscriptionPlan, value: "Free"
                            )
                        ]
                    )
                    model.currentPremiumPlan = nil
                }

                if #available(iOS 15.0, *),
                    let annualProduct = PremiumStore.shared.getProductForPlan(.annual)
                {
                    VStack {
                        Text("Premium\nAnnual")
                            .font(.system(size: 16, weight: .bold))
                        Text("\(PremiumHelpers.priceString(from: annualProduct.price / 12)) /mo")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .if(model.currentPremiumPlan == .annual) { view in
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
                        model.logCounter(
                            .BrowsePlanClick,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Attribute.subscriptionPlan, value: "Annual"
                                )
                            ]
                        )
                        model.currentPremiumPlan = .annual
                    }
                }

                if #available(iOS 15.0, *),
                    let monthlyProduct = PremiumStore.shared.getProductForPlan(.monthly)
                {
                    VStack {
                        Text("Premium\nMonthly")
                            .font(.system(size: 16, weight: .bold))
                        Text("\(monthlyProduct.displayPrice) /mo")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .if(model.currentPremiumPlan == .monthly) { view in
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
                        model.logCounter(
                            .BrowsePlanClick,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Attribute.subscriptionPlan, value: "Monthly"
                                )
                            ]
                        )
                        model.currentPremiumPlan = .monthly
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
                    if #available(iOS 15.0, *) {
                        Text(PremiumStore.shared.priceText(model.currentPremiumPlan)).fontWeight(
                            .bold)
                    }
                    if let termText = PremiumHelpers.termText(model.currentPremiumPlan),
                        termText != ""
                    {
                        Text(termText).foregroundColor(.secondaryLabel)
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

                if let subText = PremiumHelpers.priceSubText(model.currentPremiumPlan) {
                    HStack {
                        if subText.0 != "" {
                            Text(subText.0)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("·").foregroundColor(.secondaryLabel)
                            Text(subText.1).foregroundColor(.secondaryLabel)
                        } else {
                            Text(subText.1).foregroundColor(.secondaryLabel)
                        }
                    }
                    .withFont(unkerned: .bodySmall)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }

                Spacer()
            }

            Group {
                Button(
                    action: {
                        model.logCounter(
                            .ChoosePlanClick,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Attribute.subscriptionPlan,
                                    value: model.premiumPlanLogAttributeValue()
                                )
                            ]
                        )

                        if model.currentPremiumPlan == nil {
                            model.prevScreen = .plans
                            model.changeScreenTo(.defaultBrowser)
                        } else {
                            if !NeevaUserInfo.shared.hasLoginCookie() {
                                model.changeScreenTo(.signUp)
                            } else {
                                if #available(iOS 15.0, *),
                                    let product = PremiumStore.shared.getProductForPlan(
                                        model.currentPremiumPlan)
                                {
                                    PremiumStore.shared.purchase(
                                        product, reloadUserInfo: true,
                                        onPending: self.onPurchasePending,
                                        onCancelled: self.onPurchaseCancelled,
                                        onSuccess: self.onPurchaseSuccess)
                                }
                            }
                        }
                    },
                    label: {
                        Text(PremiumHelpers.primaryActionText(model.currentPremiumPlan))
                            .withFont(.labelLarge)
                            .foregroundColor(.brand.white)
                            .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(.neeva(.primary))

                if !NeevaUserInfo.shared.hasLoginCookie() {
                    Button(
                        action: {
                            model.logCounter(.SignInClick)
                            model.changeScreenTo(.signIn)
                            model.prevScreen = .plans
                        },
                        label: {
                            Text("Already have an account? Sign in")
                                .withFont(.labelLarge)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    )
                    .buttonStyle(.neeva(.clear))
                }
            }

            Spacer()

            WelcomeFlowPrivacyAndTermsLinksView()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .onAppear {
            model.logCounter(.ScreenImpression)

            /*
             if this screen is showing and we have a login cookie,
             we trigger the purchase based on the users original choice
             */
            if NeevaUserInfo.shared.hasLoginCookie() {
                if #available(iOS 15.0, *),
                    let product = PremiumStore.shared.getProductForPlan(model.currentPremiumPlan)
                {
                    PremiumStore.shared.purchase(
                        product, reloadUserInfo: true,
                        onPending: self.onPurchasePending,
                        onCancelled: self.onPurchaseCancelled,
                        onSuccess: self.onPurchaseSuccess)
                }
            }

            // flush logging based on preference
            if Defaults[.shouldCollectUsageStats] == true {
                ClientLogger.shared.flushLoggingQueue()
            }
        }
    }

    func onPurchasePending() {
        // TODO: what should we do here for the UX?
        model.logCounter(
            .PremiumPurchasePending,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan,
                    value: model.premiumPlanLogAttributeValue()
                )
            ])
    }

    func onPurchaseCancelled() {
        model.logCounter(
            .PremiumPurchaseCancel,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan,
                    value: model.premiumPlanLogAttributeValue()
                )
            ])
    }

    func onPurchaseSuccess(_ type: PremiumPurchaseSuccessType) {
        model.logCounter(
            type == .verified ? .PremiumPurchaseVerified : .PremiumPurchaseUnverified,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan,
                    value: model.premiumPlanLogAttributeValue()
                )
            ])

        model.prevScreen = nil
        model.changeScreenTo(.defaultBrowser)
    }
}
