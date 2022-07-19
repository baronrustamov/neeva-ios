// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import StoreKit
import SwiftUI

// TODO: move to a better location during next refactor
private enum PremiumPlan: String, Equatable, Encodable, Decodable {
    /*
     NOTE: These text values are important, they map directly to
     App Store Connect product IDs.
     */
    case annual = "annual202206"
    case monthly = "monthly202206"
}

@available(iOS 15.0, *)
struct NeevaPremiumView: View {
    @ObservedObject var userInfo: NeevaUserInfo

    let dateFormatter = ISO8601DateFormatter()

    @State private var products = [Product]()
    @State private var loadingProducts = false
    @State private var loadingPurchase = false
    @State private var loadingMutation = false

    var body: some View {
        VStack {
            if !loadingProducts && products.count == 0 {
                Text("Subscription products not found.")
            }

            productList
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

    private var productList: some View {
        List(products) { product in
            Button(action: { purchase(product, reloadUserInfo: !isSubscribedToPlan(product.id)) }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(product.displayName)
                        if isSubscribedToPlan(product.id) {
                            Text("This is your current plan.")
                                .foregroundColor(Color.secondary)
                                .font(.system(size: 14))
                        }
                    }
                    Spacer()
                    Text(product.displayPrice)
                }
            }
        }
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
                    RegisterAppleSubscriptionMutation(
                        input: RegisterAppleSubscriptionInput(
                            originalTransactionId: transaction.originalID.description,
                            userUuid: appleUUID.uuidString,
                            plan: product.id == PremiumPlan.monthly.rawValue
                                ? AppleSubscriptionPlan.monthly
                                : AppleSubscriptionPlan.annual,
                            expiration: dateFormatter.string(
                                from: transaction.expirationDate ?? Date.now)
                        )
                    ).perform(resultHandler: { result in
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
                    })

                    await transaction.finish()

                    var attributes = EnvironmentHelper.shared.getAttributes()
                    attributes.append(
                        ClientLogCounterAttribute(
                            key: LogConfig.Attribute.SubscriptionPlan,
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
                            key: LogConfig.Attribute.SubscriptionPlan,
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
                        key: LogConfig.Attribute.SubscriptionPlan,
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
                        key: LogConfig.Attribute.SubscriptionPlan,
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
