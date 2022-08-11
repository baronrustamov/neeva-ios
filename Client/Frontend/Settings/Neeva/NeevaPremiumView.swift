// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import StoreKit
import SwiftUI

@available(iOS 15.0, *)
struct NeevaPremiumView: View {
    @ObservedObject var userInfo: NeevaUserInfo

    let dateFormatter = ISO8601DateFormatter()

    @State private var products = [Product]()
    @State private var loadingProducts = false
    @State private var loadingPurchase = false
    @State private var loadingMutation = false

    var body: some View {
        ScrollView {
            VStack {
                Group {
                    if !loadingProducts && products.count == 0 {
                        Text("Subscription products not found.")
                    } else {
                        Text("Choose Your Plan")
                            .font(.system(size: 28, weight: .bold))
                    }
                }
                .padding(.top)

                productList

                Spacer()
            }
            .navigationTitle("Premium")
            .task {
                ClientLogger.shared.logCounter(
                    .SettingPremiumSubscriptions,
                    attributes: EnvironmentHelper.shared.getAttributes()
                )

                loadingProducts = true
                do {
                    products = try await Product.products(for: [
                        PremiumPlan.monthly.rawValue, PremiumPlan.annual.rawValue,
                    ])
                } catch {
                    ClientLogger.shared.logCounter(
                        .SettingPremiumProductsFetchException,
                        attributes: EnvironmentHelper.shared.getAttributes()
                    )
                }
                loadingProducts = false

                if products.count == 0 {
                    ClientLogger.shared.logCounter(
                        .SettingPremiumNoProductsFound,
                        attributes: EnvironmentHelper.shared.getAttributes()
                    )
                }
            }
        }
    }

    private var productList: some View {
        VStack {
            ForEach(products) { product in
                Merchandise(
                    product: product, isSubscribed: isSubscribedToPlan(product.id),
                    loading: loadingPurchase || loadingMutation,
                    plan: planFor(product: product.id)
                ) {
                    purchase(product, reloadUserInfo: !isSubscribedToPlan(product.id))
                }
                .padding(.bottom)
            }
        }
        .padding()
    }

    // NOTE: this assumes we only have two products
    private func planFor(product id: String) -> SubscriptionPlan {
        if id == PremiumPlan.annual.rawValue {
            return .annual
        }

        return .monthly
    }

    private func isSubscribedToPlan(_ productID: String) -> Bool {
        return
            (userInfo.subscription?.plan == .monthly
            && productID == PremiumPlan.monthly.rawValue)
            || (userInfo.subscription?.plan == .annual
                && productID == PremiumPlan.annual.rawValue)
    }

    private func purchase(_ product: Product, reloadUserInfo: Bool) {
        Task {
            /*
             NOTE: If you see the Xcode IDE warning saying "Making a purchase
             without listening for transaction updates risks missing successful
             purchases."... no worries, we have server side webhooks that will
             handle these events and update the user profile. So the next time
             user info is refreshed in app, premium entitlement will be in sync.
             */

            var appleUUID = UUID()
            if let existingUUID = UUID(uuidString: userInfo.subscription?.apple?.uuid ?? "") {
                appleUUID = existingUUID
            }

            loadingPurchase = true
            let result = try await product.purchase(options: [.appAccountToken(appleUUID)])
            loadingPurchase = false

            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    loadingMutation = true
                    // TODO: Refactor this out to a `SubscriptionStore/Model`.
                    let mutation = RegisterAppleSubscriptionMutation(
                        input: RegisterAppleSubscriptionInput(
                            originalTransactionId: transaction.originalID.description,
                            userUuid: appleUUID.uuidString,
                            plan: product.id == PremiumPlan.monthly.rawValue
                                ? AppleSubscriptionPlan.monthly
                                : AppleSubscriptionPlan.annual,
                            expiration: dateFormatter.string(
                                from: transaction.expirationDate ?? Date.now)
                        )
                    )
                    GraphQLAPI.shared.perform(mutation: mutation) { result in
                        switch result {
                        case .failure(_):
                            // TODO: What should we do in this case? The user has paid, but our API call failed.
                            break
                        case .success(_):
                            break
                        }

                        if reloadUserInfo {
                            userInfo.reload()
                        }

                        loadingMutation = false
                    }

                    await transaction.finish()

                    var attributes = EnvironmentHelper.shared.getAttributes()
                    attributes.append(
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.subscriptionPlan,
                            value: product.id
                        )
                    )
                    ClientLogger.shared.logCounter(
                        .SettingPremiumPurchaseComplete,
                        attributes: attributes
                    )
                case .unverified(_, _):
                    // If we got here StoreKitV2 was unable to verify the JWT token, probably a very rare event.
                    // TODO: What should we do in this case? Maybe the answer is nothing.
                    var attributes = EnvironmentHelper.shared.getAttributes()
                    attributes.append(
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.subscriptionPlan,
                            value: product.id
                        )
                    )
                    ClientLogger.shared.logCounter(
                        .SettingPremiumPurchaseUnverified,
                        attributes: attributes
                    )
                    break
                }
            case .pending:
                // The purchase requires action from the customer.
                // If the transaction completes, it's available through Transaction.updates.
                // TODO: What should we do in this case? Maybe the answer is nothing.
                var attributes = EnvironmentHelper.shared.getAttributes()
                attributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.Attribute.subscriptionPlan,
                        value: product.id
                    )
                )
                ClientLogger.shared.logCounter(
                    .SettingPremiumPurchasePending,
                    attributes: attributes
                )
                break
            case .userCancelled:
                // The user canceled the purchase.
                var attributes = EnvironmentHelper.shared.getAttributes()
                attributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.Attribute.subscriptionPlan,
                        value: product.id
                    )
                )
                ClientLogger.shared.logCounter(
                    .SettingPremiumPurchaseCanceled,
                    attributes: attributes
                )
                break
            @unknown default:
                break
            }
        }
    }
}

@available(iOS 15.0, *)
private struct Merchandise: View {
    var product: Product
    var isSubscribed: Bool
    var loading: Bool
    var plan: SubscriptionPlan
    var action: () -> Void

    var body: some View {
        VStack {
            Text(plan == .monthly ? "Premium Monthly Plan" : "Premium Annual Plan")
                .font(.system(size: 20, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.25))
                )

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.blue)
                        .padding(.top, 2)
                    Text("Browser + ad blocker")
                }
                .padding(.bottom, 5)
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.blue)
                        .padding(.top, 2)
                    Text("Tracking prevention")
                }
                .padding(.bottom, 5)
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.blue)
                        .padding(.top, 2)
                    Text("Unlimited ad-free, private search")
                }
                .padding(.bottom, 5)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .padding()

            HStack {
                Button(action: action) {
                    Text(
                        buttonText(
                            isSubscribed: isSubscribed, plan: plan, price: product.displayPrice)
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                }
                .disabled(loading)
                .padding()
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)

            if isSubscribed {
                Text("This is your current plan.")
                    .foregroundColor(Color.secondary)
                    .font(.system(size: 14))
                    .padding(.top, 5)
            }
        }
        .padding(8)
        .padding(.bottom, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.25))
        )
    }

    private func buttonText(isSubscribed: Bool, plan: SubscriptionPlan, price: String) -> String {
        return
            "\(isSubscribed ? "Manage" : "Get") \(plan == .monthly ? "Monthly" : "Annual") / \(price)"
    }
}
