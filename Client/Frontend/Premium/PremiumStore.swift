// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import StoreKit

enum PremiumPlan: String, Equatable, Encodable, Decodable {
    /*
     NOTE: These text values are important, they map directly to
     App Store Connect product IDs.
     */
    case annual = "annual202206"
    case monthly = "monthly202206"
}

enum PremiumPurchaseSuccessType {
    case verified
    case unverified
}

@available(iOS 15.0, *)
class PremiumStore: ObservableObject {
    public static let shared = PremiumStore()
    private static let dateFormatter = ISO8601DateFormatter()

    // NOTE: currently only the U.S. but as we expand we'll maintain a list of valid country codes
    // https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
    public static let countries = ["USA"]

    @Published public var products: [Product] = []
    @Published public var loadingProducts = false
    @Published public var loadingPurchase = false
    @Published public var loadingMutation = false

    init() {
        Task {
            self.loadingProducts = true
            do {
                self.products = try await Product.products(for: [
                    PremiumPlan.monthly.rawValue, PremiumPlan.annual.rawValue,
                ])
            } catch {
                // TODO: log
                /*
                 ClientLogger.shared.logCounter(
                 .PremiumStoreFetchException,
                 attributes: EnvironmentHelper.shared.getAttributes()
                 )
                 */
            }
            self.loadingProducts = false
        }
    }

    public static func isOfferedInCountry() -> Bool {
        if let storefront = SKPaymentQueue.default().storefront {
            if PremiumStore.countries.contains(storefront.countryCode) {
                return true
            }

            return false
        }

        return false
    }

    public func getProductForPlan(_ plan: PremiumPlan?) -> Product? {
        if plan == nil {
            return nil
        }

        return self.products.first { product in
            return product.id == plan!.rawValue
        }
    }

    public func purchase(
        _ product: Product, reloadUserInfo: Bool, onPending: (@escaping () -> Void),
        onCancelled: (@escaping () -> Void),
        onSuccess: (@escaping (_ successType: PremiumPurchaseSuccessType) -> Void)
    ) {
        DispatchQueue.main.async {
            Task {
                var appleUUID = UUID()
                if let existingUUID = UUID(
                    uuidString: NeevaUserInfo.shared.subscription?.apple?.uuid ?? "")
                {
                    appleUUID = existingUUID
                }

                /*
                 NOTE: If you see the Xcode IDE warning saying "Making a purchase
                 without listening for transaction updates risks missing successful
                 purchases."... no worries, we have server side webhooks that will
                 handle these events and update the user profile. So the next time
                 user info is refreshed in app, premium entitlement will be in sync.
                 */
                self.loadingPurchase = true
                let result = try await product.purchase(options: [.appAccountToken(appleUUID)])
                self.loadingPurchase = false

                switch result {
                case .pending:
                    /*
                     NOTE: The purchase requires action from the customer. If the
                     transaction completes, it's available through Transaction.updates.
                     */
                    onPending()
                    break
                case .userCancelled:
                    // NOTE: The user canceled the purchase.
                    onCancelled()
                    break
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        self.loadingMutation = true

                        GraphQLAPI.shared.perform(
                            mutation: RegisterAppleSubscriptionMutation(
                                input: RegisterAppleSubscriptionInput(
                                    originalTransactionId: transaction.originalID.description,
                                    userUuid: appleUUID.uuidString,
                                    plan: product.id == PremiumPlan.monthly.rawValue
                                        ? AppleSubscriptionPlan.monthly
                                        : AppleSubscriptionPlan.annual,
                                    expiration: PremiumStore.dateFormatter.string(
                                        from: transaction.expirationDate ?? Date.now)
                                )
                            )
                        ) { result in
                            switch result {
                            case .failure(_):
                                // TODO: What should we do in this case? The user has paid, but our API call failed.
                                break
                            case .success(_):
                                break
                            }

                            if reloadUserInfo {
                                NeevaUserInfo.shared.reload()
                            }

                            self.loadingMutation = false

                            onSuccess(.verified)
                        }

                        await transaction.finish()
                    case .unverified(_, _):
                        /*
                         NOTE: If we got here StoreKitV2 was unable to verify the JWT
                         token, probably a very rare event.
                         */
                        // TODO: What should we do in this case?
                        onSuccess(.unverified)
                        break
                    }
                @unknown default:
                    break
                }
            }
        }
    }
}
