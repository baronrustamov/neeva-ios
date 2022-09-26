// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import StoreKit

enum PremiumPlan: String, Equatable, Codable {
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

enum PremiumPurchaseErrorType {
    case uuid
    case unknown
}

@available(iOS 15.0, *)
class PremiumStore: ObservableObject {
    static let shared = PremiumStore()
    private static let dateFormatter = ISO8601DateFormatter()

    // NOTE: currently only the U.S. but as we expand we'll maintain a list of valid country codes
    // https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
    static let countries = ["USA"]

    @Published var products: [Product] = []
    @Published var loadingProducts = false
    @Published var loadingPurchase = false
    @Published var loadingMutation = false
    @Published var loadingUUIDPrimer = false

    var appleUUID: String? = nil

    init() {
        Task {
            self.loadingProducts = true
            do {
                self.products = try await Product.products(for: [
                    PremiumPlan.monthly.rawValue, PremiumPlan.annual.rawValue,
                ])
            } catch {
                // TODO: log?
            }
            self.loadingProducts = false
        }
    }

    static func isOfferedInCountry() -> Bool {
        if let storefront = SKPaymentQueue.default().storefront {
            if PremiumStore.countries.contains(storefront.countryCode) {
                return true
            }
        } else {
            ClientLogger.shared.logCounter(
                .StorefrontWasNil,
                attributes: [
                    ClientLogCounterAttribute(
                        key: LogConfig.Attribute.locale, value: Locale.current.identifier
                    )
                ]
            )
        }

        return false
    }

    func primeUUID() async -> String? {
        await withCheckedContinuation { continuation in
            if self.appleUUID != nil {
                continuation.resume(returning: self.appleUUID)
                return
            }

            self.loadingUUIDPrimer = true

            DispatchQueue.main.async {
                GraphQLAPI.shared.perform(
                    mutation: InitializeAppleSubscriptionMutation()
                ) { result in
                    switch result {
                    case .success(let data):
                        self.appleUUID = data.initializeAppleSubscription?.appleUuid
                        break
                    case .failure:
                        break
                    }

                    self.loadingUUIDPrimer = false

                    continuation.resume(returning: self.appleUUID)
                }
            }
        }

    }

    func getProductForPlan(_ plan: PremiumPlan?) -> Product? {
        if plan == nil {
            return nil
        }

        return self.products.first { product in
            return product.id == plan!.rawValue
        }
    }

    func priceText(_ plan: PremiumPlan?) -> String {
        guard let product = self.getProductForPlan(plan) else {
            return "FREE"
        }

        return product.displayPrice
    }

    func purchase(
        _ product: Product, reloadUserInfo: Bool, onPending: (@escaping () -> Void),
        onCancelled: (@escaping () -> Void),
        onError: (@escaping (_ successType: PremiumPurchaseErrorType) -> Void),
        onSuccess: (@escaping (_ successType: PremiumPurchaseSuccessType) -> Void)
    ) {
        DispatchQueue.main.async {
            Task {
                _ = await self.primeUUID()

                /*
                 NOTE: We won't use this value, if we can't initialize
                 the UUID given by the server, we bail early.
                 */
                var uuid = UUID()
                if let appleUUID = UUID(
                    uuidString: self.appleUUID ?? NeevaUserInfo.shared.subscription?.apple?.uuid
                        ?? "")
                {
                    uuid = appleUUID
                } else {
                    onError(PremiumPurchaseErrorType.uuid)
                    return
                }

                /*
                 NOTE: If you see the Xcode IDE warning saying "Making a purchase
                 without listening for transaction updates risks missing successful
                 purchases."... no worries, we have server side webhooks that will
                 handle these events and update the user profile. So the next time
                 user info is refreshed in app, premium entitlement will be in sync.
                 */
                self.loadingPurchase = true
                let result = try await product.purchase(options: [.appAccountToken(uuid)])
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
                                    userUuid: uuid.uuidString,
                                    plan: product.id == PremiumPlan.monthly.rawValue
                                        ? AppleSubscriptionPlan.monthly
                                        : AppleSubscriptionPlan.annual,
                                    expiration: PremiumStore.dateFormatter.string(
                                        from: transaction.expirationDate ?? Date.now)
                                )
                            )
                        ) { result in
                            switch result {
                            case .failure:
                                // TODO: What should we do in this case? The user has paid, but our API call failed.
                                break
                            case .success:
                                break
                            }

                            if reloadUserInfo {
                                NeevaUserInfo.shared.reload()
                            }

                            self.loadingMutation = false

                            onSuccess(.verified)
                        }

                        await transaction.finish()
                    case .unverified:
                        /*
                         NOTE: If we got here StoreKitV2 was unable to verify the JWT
                         token, probably a very rare event.
                         */
                        // TODO: What should we do in this case?
                        onSuccess(.unverified)
                        break
                    }
                @unknown default:
                    onError(PremiumPurchaseErrorType.unknown)
                    break
                }
            }
        }
    }
}

class PremiumHelpers {
    static func primaryActionText(_ plan: PremiumPlan?, subscribed: Bool = false) -> String {
        switch plan {
        case .annual:
            return subscribed ? "Manage Yearly" : "Subscribe Yearly"
        case .monthly:
            return subscribed ? "Manage Monthly" : "Subscribe Monthly"
        default:
            return "Get FREE"
        }
    }

    static func priceSubText(_ plan: PremiumPlan?) -> (String, String) {
        switch plan {
        case .annual:
            return ("Save 16%", "Cancel anytime")
        case .monthly:
            return ("", "Cancel anytime")
        default:
            return ("", "")
        }
    }

    static func termText(_ plan: PremiumPlan?) -> String {
        switch plan {
        case .annual:
            return "/year"
        case .monthly:
            return "/month"
        default:
            return ""
        }
    }

    static func priceString(from input: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: input as NSNumber) ?? "\(input)"
    }
}
