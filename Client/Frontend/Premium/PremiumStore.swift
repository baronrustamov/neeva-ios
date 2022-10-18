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

class PremiumStore: ObservableObject {
    static let shared = PremiumStore()
    private static let dateFormatter = ISO8601DateFormatter()

    // NOTE: languages premium is offered to
    // https://developer.apple.com/documentation/foundation/nslocale/1643026-languagecode
    // https://www.loc.gov/standards/iso639-2/php/English_list.php
    static let languages = ["en", "eng", "fr", "fre", "de", "ger"]

    @Published var products: [Product] = []
    @Published var loadingProducts = false
    @Published var loadingPurchase = false
    @Published var loadingMutation = false
    @Published var loadingUUIDPrimer = false

    var appleUUID: UUID? = nil

    init() {
        Task {
            self.loadingProducts = true
            do {
                let products = try await Product.products(for: [
                    PremiumPlan.monthly.rawValue, PremiumPlan.annual.rawValue,
                ])

                await MainActor.run {
                    self.products = products
                    self.checkForAndFixMissingSubscription()
                }
            } catch {
                // TODO: log?
            }

            await MainActor.run {
                self.loadingProducts = false
            }
        }
    }

    static func isOfferedInLanguage() -> Bool {
        let preferredLanguages = Locale.preferredLanguages

        if preferredLanguages.count <= 0 {
            // we want to track how frequent this case happens
            ClientLogger.shared.logCounter(.NoPreferredLanguage)
            return false
        } else {
            // preferredLanguage returns in format en, de-US...
            for language in preferredLanguages {
                let components = language.components(separatedBy: "-")
                if components.count > 0 && PremiumStore.languages.contains(components[0]) {
                    return true
                }
            }
        }

        return false
    }

    func getProductForPlan(_ plan: PremiumPlan?) -> Product? {
        guard let plan = plan else { return nil }

        return self.products.first { product in
            return product.id == plan.rawValue
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
                            // Logger needs to be called on main
                            await MainActor.run {
                                ClientLogger.shared.logCounter(
                                    .PremiumSubscriptionFixFailed,
                                    attributes: []
                                )
                            }
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

class PremiumHelpers {
    static func primaryActionText(_ plan: PremiumPlan?, subscribed: Bool = false) -> String {
        switch plan {
        case .annual:
            return subscribed ? "Manage Yearly" : "Try it Free"
        case .monthly:
            return subscribed ? "Manage Monthly" : "Try it Free"
        default:
            return "Get FREE"
        }
    }

    static func primaryActionSubText(_ plan: PremiumPlan?, subscribed: Bool = false) -> String {
        switch plan {
        case .annual:
            return "7 Day Free Trial"
        case .monthly:
            return "7 Day Free Trial"
        default:
            return ""
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

    static func annualAvgPricePerMonth(_ product: Product) -> String {
        let pricePerMonth = product.price / 12
        var output = ""

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""  // removes currency symbols

        if let fmtPrice = formatter.string(from: product.price as NSNumber),
            let fmtPricePerMonth = formatter.string(from: pricePerMonth as NSNumber)
        {
            // in some languages `NumberFormatter` will append whitespace to currency formatting, so we trim it off
            let trmPrice = fmtPrice.trimmingCharacters(in: .whitespacesAndNewlines)
            let trmPricePerMonth = fmtPricePerMonth.trimmingCharacters(in: .whitespacesAndNewlines)

            output = product.displayPrice.replacingOccurrences(of: trmPrice, with: trmPricePerMonth)
        }

        return output
    }
}
