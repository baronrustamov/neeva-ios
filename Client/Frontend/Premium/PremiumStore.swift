// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import StoreKit

enum ProductID: String, Equatable, Codable, CaseIterable {
    //NOTE: These raw values are important, they map directly to App Store Connect product IDs.
    case annual202206
    case monthly202206  // deprecated; may be removed when there are zero subscribers
    case monthly202209

    func premiumPlan() -> PremiumPlan {
        switch self {
        case .annual202206:
            return PremiumPlan.annual
        case .monthly202206:
            return PremiumPlan.monthly
        case .monthly202209:
            return PremiumPlan.monthly
        }
    }
}

enum PremiumPlan: String, Equatable, Codable {
    case annual
    case monthly

    func currentProductID() -> ProductID {
        switch self {
        case .annual:
            return .annual202206
        case .monthly:
            return .monthly202209
        }
    }
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

    var appleUUID: UUID? = nil

    init() {
        self.loadProducts()
    }

    func loadProducts() {
        Task {
            self.loadingProducts = true
            do {
                self.products = try await Product.products(
                    for: ProductID.allCases.map { $0.rawValue })

                self.checkForAndFixMissingSubscription()
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

    func getProductForPlan(_ plan: PremiumPlan?) -> Product? {
        guard let plan = plan else { return nil }

        return self.products.first { product in
            return product.id == plan.currentProductID().rawValue
        }
    }

    func priceText(_ plan: PremiumPlan?) -> String {
        guard let product = self.getProductForPlan(plan) else {
            return "FREE"
        }

        return product.displayPrice
    }

    func checkForAndFixMissingSubscription() {
        if NeevaUserInfo.shared.hasLoginCookie()
            && NeevaUserInfo.shared.subscriptionType == SubscriptionType.basic
        {
            self.products.forEach { product in
                Task {
                    let result = await product.currentEntitlement
                    switch result {
                    case .verified(let transaction):
                        /*
                         NOTE: This user has a basic subscription, but has an entitlement
                         to this product, let's try to restore their subscription.
                         */
                        let fixed = await self.fixSubscription(
                            product: product, transaction: transaction)

                        if fixed {
                            NeevaUserInfo.shared.reload()
                        } else {
                            ClientLogger.shared.logCounter(
                                .PremiumSubscriptionFixFailed, attributes: [])
                        }
                        break
                    case .unverified(_, _):
                        // NOTE: do nothing
                        break
                    case .none:
                        // NOTE: do nothing
                        break
                    }
                }
            }
        }
    }

    func primeUUID() async -> Bool {
        await withCheckedContinuation { continuation in
            if self.appleUUID != nil {
                continuation.resume(returning: true)
                return
            }

            DispatchQueue.main.async {
                self.loadingUUIDPrimer = true

                GraphQLAPI.shared.perform(
                    mutation: InitializeAppleSubscriptionMutation()
                ) { result in
                    self.loadingUUIDPrimer = false

                    switch result {
                    case .success(let data):
                        if let parsedUUID = UUID(
                            uuidString: data.initializeAppleSubscription?.appleUuid
                                ?? NeevaUserInfo.shared.subscription?.apple?.uuid
                                ?? "")
                        {
                            self.appleUUID = parsedUUID
                            continuation.resume(returning: true)
                            return
                        }
                        break
                    case .failure:
                        break
                    }

                    continuation.resume(returning: false)
                }
            }
        }
    }

    func registerSubscription(product: Product, transaction: Transaction) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let uuid = self.appleUUID else {
                continuation.resume(returning: false)
                return
            }

            DispatchQueue.main.async {
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
                        continuation.resume(returning: false)
                        break
                    case .success:
                        continuation.resume(returning: true)
                        break
                    }
                }
            }
        }
    }

    func fixSubscription(product: Product, transaction: Transaction) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let uuid = self.appleUUID else {
                continuation.resume(returning: false)
                return
            }

            DispatchQueue.main.async {
                GraphQLAPI.shared.perform(
                    mutation: RestoreAppleSubscriptionMutation(
                        input: RestoreAppleSubscriptionInput(
                            originalTransactionId: transaction.originalID.description,
                            userUuid: uuid.uuidString,
                            plan: product.id == PremiumPlan.monthly.rawValue
                                ? AppleSubscriptionPlan.monthly
                                : AppleSubscriptionPlan.annual
                        )
                    )
                ) { result in
                    switch result {
                    case .failure:
                        continuation.resume(returning: false)
                        break
                    case .success:
                        continuation.resume(returning: true)
                        break
                    }
                }
            }
        }
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
                guard let uuid = self.appleUUID else {
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

                        let registered = await self.registerSubscription(
                            product: product, transaction: transaction)

                        if !registered {
                            // TODO: log?
                        }

                        if reloadUserInfo {
                            NeevaUserInfo.shared.reload()
                        }

                        await transaction.finish()

                        self.loadingMutation = false

                        onSuccess(.verified)
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

// MARK: Helpers

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
            return ("Save 30%", "Cancel anytime")
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
