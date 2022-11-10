// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SignInOrUpFlowPlansView: View {
    @ObservedObject var model: SignInOrUpFlowModel
    @ObservedObject var userInfo: NeevaUserInfo = NeevaUserInfo.shared
    @ObservedObject var premiumStore: PremiumStore = PremiumStore.shared

    var premiumBullets = [
        ("Browser + ad blocker + tracking prevention", ""),
        ("Unlimited ad-free, private search", ""),
        ("Unlimited devices", ""),
        ("Password manager + VPN", ""),
    ]
    var freeBullets = [
        ("Browser + ad blocker + tracking prevention", ""),
        ("Limited Ad-free, private search", "50 searches/month"),
        ("Limited devices", ""),
    ]
    var bullets: [(String, String)] {
        if model.currentPremiumPlan == nil {
            return freeBullets
        } else {
            return premiumBullets
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WelcomeFlowHeaderView(text: "Choose the right plan for you")
                .padding(.bottom)

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

                if let annualProduct = premiumStore.getProductForPlan(.annual) {
                    VStack {
                        Text("Premium\nAnnual")
                            .font(.system(size: 16, weight: .bold))
                        if let avgPricePerMonth = PremiumHelpers.annualAvgPricePerMonth(
                            annualProduct)
                        {
                            Text("\(avgPricePerMonth) /mo")
                                .font(.system(size: 14))
                        }
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

                if let monthlyProduct = premiumStore.getProductForPlan(.monthly) {
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
            .padding(.bottom)

            VStack(alignment: .leading, spacing: 0) {
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
            }
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                HStack {
                    Text(premiumStore.priceText(model.currentPremiumPlan))
                        .fontWeight(.bold)

                    if let termText = PremiumHelpers.termText(model.currentPremiumPlan),
                        termText != ""
                    {
                        Text(termText).foregroundColor(.secondaryLabel)
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)

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
            }
            .padding(.bottom)

            VStack(spacing: 0) {
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
                            model.prevScreens.append(.plans)
                            model.changeScreenTo(.signUp)
                        } else {
                            if !NeevaUserInfo.shared.hasLoginCookie() {
                                model.changeScreenTo(.signUp)
                            } else {
                                if let product = premiumStore.getProductForPlan(
                                    model.currentPremiumPlan)
                                {
                                    premiumStore.purchase(
                                        product, reloadUserInfo: true,
                                        onPending: self.onPurchasePending,
                                        onCancelled: self.onPurchaseCancelled,
                                        onError: self.onPurchaseError,
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
                .padding(.bottom, 10)

                if let subText = PremiumHelpers.primaryActionSubText(model.currentPremiumPlan),
                    subText != ""
                {
                    Text(LocalizedStringKey(subText))
                        .frame(maxWidth: .infinity)
                }

                if !NeevaUserInfo.shared.hasLoginCookie() {
                    Button(
                        action: {
                            model.logCounter(.SignInClick)
                            model.changeScreenTo(.signIn)
                            model.prevScreens.append(.plans)
                        },
                        label: {
                            Text("Already have an account? Sign in")
                                .withFont(.labelLarge)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    )
                    .buttonStyle(.neeva(.clear))
                    .padding(.top)
                }
            }
            .padding(.bottom)

            VStack(spacing: 0) {
                SafariVCLink(
                    "Subscribe and help fight climate change",
                    url: NeevaConstants.appClimatePledgeURL
                )
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)

                SignInOrUpFlowPrivacyAndTermsLinksView()
                    .frame(maxWidth: .infinity, alignment: .center)

            }
        }
        .onAppear {
            model.logCounter(.ScreenImpression)

            /*
             if this screen is showing and we have a login cookie,
             we trigger the purchase based on the users original choice
             */
            if NeevaUserInfo.shared.hasLoginCookie() {
                if let product = PremiumStore.shared.getProductForPlan(model.currentPremiumPlan) {
                    /*
                     NOTE: Only execute for users who have no subscription
                     */
                    if NeevaUserInfo.shared.subscriptionType == .basic
                        && (NeevaUserInfo.shared.subscriptionType == nil
                            || NeevaUserInfo.shared.subscriptionType == .basic
                            || NeevaUserInfo.shared.subscriptionType == .unknown)
                    {
                        premiumStore.purchase(
                            product, reloadUserInfo: true,
                            onPending: self.onPurchasePending,
                            onCancelled: self.onPurchaseCancelled,
                            onError: self.onPurchaseError,
                            onSuccess: self.onPurchaseSuccess)
                    } else {
                        model.complete()
                    }
                } else {
                    model.complete()
                }
            }
        }
    }

    func onPurchasePending() {
        model.logCounter(
            .PremiumPurchasePending,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan,
                    value: model.premiumPlanLogAttributeValue()
                )
            ])

        model.clearPreviousScreens()
        model.complete()
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

    func onPurchaseError(_ type: PremiumPurchaseErrorType) {
        model.logCounter(
            .PremiumPurchaseError,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.subscriptionPlan,
                    value: model.premiumPlanLogAttributeValue()
                )
            ])

        model.clearPreviousScreens()
        model.complete()
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

        model.clearPreviousScreens()
        model.complete()
    }
}
