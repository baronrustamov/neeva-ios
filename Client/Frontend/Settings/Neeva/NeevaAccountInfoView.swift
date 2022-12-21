// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import StoreKit
import SwiftUI
import XCGLogger

private let log = Logger.browser

struct NeevaAccountInfoView: View {
    @EnvironmentObject var browserModel: BrowserModel
    @Environment(\.onOpenURL) var openURL

    @State var signingOut = false
    @Binding var isPresented: Bool
    @ObservedObject var userInfo: NeevaUserInfo
    @State var showingPremium = false

    var body: some View {
        List {
            Section(header: Text("Signed in to Neeva with")) {
                HStack {
                    (userInfo.authProvider?.icon ?? Image("placeholder-avatar"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 14)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(userInfo.authProvider?.displayName ?? "Unknown")
                        Text(userInfo.email ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                    }
                    .padding(.vertical, 5)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "\(Text(userInfo.authProvider?.displayName ?? "Unknown")), \(userInfo.email ?? "")"
                )
            }.accessibilityElement(children: .combine)

            Section(header: Text("Membership Status"), footer: membershipStatusFooterText) {
                membershipStatusBody

                /*
                 NOTE: Only show for users who are not Lifetime and have
                 not paid through another source.
                 */
                if userInfo.subscriptionType != .lifetime
                    && (userInfo.subscription?.source == SubscriptionSource.none
                        || userInfo.subscription?.source == SubscriptionSource.apple)
                {
                    NavigationLink(
                        destination: NeevaPremiumView(userInfo: userInfo),
                        isActive: $showingPremium
                    ) {
                        HStack {
                            Text("Your Subscription")
                            Spacer()
                            Text("\(currentPlan)")
                        }
                    }
                    .onAppear {
                        PremiumStore.shared.checkForAndFixMissingSubscription()
                    }
                }
            }

            DecorativeSection {
                Button("Sign Out") { signingOut = true }
                    .actionSheet(isPresented: $signingOut) {
                        ActionSheet(
                            title: Text("Sign out of Neeva?"),
                            buttons: [
                                .destructive(Text("Sign Out")) {
                                    ClientLogger.shared.logCounter(
                                        .SettingSignout,
                                        attributes: EnvironmentHelper.shared.getAttributes())

                                    if userInfo.hasLoginCookie() {
                                        NotificationPermissionHelper.shared
                                            .deleteDeviceTokenFromServer()

                                        userInfo.clearCache()
                                        userInfo.deleteLoginCookie()
                                        userInfo.didLogOut()
                                        browserModel.tabManager.clearNeevaTabs()

                                        isPresented = false
                                    }
                                },
                                .cancel(),
                            ])
                    }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(userInfo.displayName ?? "Neeva Account")
    }

    // TODO: Refactor this out to a `SubscriptionStore/Model`.
    func premiumOfferedInCountry() -> Bool {
        if let storefront = SKPaymentQueue.default().storefront {
            // NOTE: currently only the U.S. but as we expand we'll maintain a list of valid country codes
            // https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3

            log.info(
                "Storefront country code: \(storefront.countryCode), subscriptionType: \(String(describing: userInfo.subscriptionType)), subscriptionSource: \(String(describing: userInfo.subscription?.source))"
            )
            if storefront.countryCode == "USA" {
                return true
            }

            return false
        } else {
            log.info("No Storefront, PaymentQueue default: \(SKPaymentQueue.default())")
        }

        return false
    }

    private var currentPlan: String {
        switch userInfo.subscription?.plan {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Annual"
        default:
            return "None"
        }
    }

    @ViewBuilder
    private var membershipStatusFooterText: some View {
        switch userInfo.subscriptionType {
        case .basic:
            EmptyView()
        case .lifetime:
            EmptyView()
        case .premium, .unlimited:
            // TODO: When we support Google Pay for Android, we should be more precise with this messaging.
            if userInfo.subscription?.source != .apple {
                Text("Please sign in to Neeva from your computer to manage your subscription.")
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var membershipStatusBody: some View {
        switch userInfo.subscriptionType {
        case .basic:
            VStack(alignment: .leading) {
                Text(SubscriptionType.basic.displayName)
                    .withFont(.headingMedium)
                    .padding(4)
                    .padding(.horizontal, 4)
                    .foregroundColor(.brand.charcoal)
                    .background(SubscriptionType.basic.color)
                    .cornerRadius(4)

                Text(
                    "Neeva’s Free Basic membership gives you access to all Neeva search and personalization features."
                )
                .withFont(.bodyLarge)
                .fixedSize(horizontal: false, vertical: true)
            }
        case .premium, .lifetime:
            VStack(alignment: .leading) {
                Text(SubscriptionType.premium.displayName)
                    .withFont(.headingMedium)
                    .padding(4)
                    .padding(.horizontal, 4)
                    .foregroundColor(.brand.charcoal)
                    .background(SubscriptionType.premium.color)
                    .cornerRadius(4)

                if userInfo.subscriptionType == .lifetime {
                    // This should only apply to US as we didn't have referral competition in other countries
                    Text(
                        verbatim:
                            "As a winner in Neeva's referral competition, you are a lifetime Premium member of Neeva."
                    )
                    .withFont(.bodyLarge)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Text(
                    "If you have any questions or need assistance with your Premium membership, please reach out to premium@neeva.co."
                )
                .withFont(.bodyLarge)
                .fixedSize(horizontal: false, vertical: true)
            }

            NavigationLinkButton("View Benefits") {
                openURL(NeevaConstants.appMembershipURL)
            }
        case .unlimited:
            VStack(alignment: .leading) {
                Text(SubscriptionType.unlimited.displayName)
                    .withFont(.headingMedium)
                    .padding(4)
                    .padding(.horizontal, 4)
                    .foregroundColor(.brand.charcoal)
                    .background(SubscriptionType.unlimited.color)
                    .cornerRadius(4)

                Text(
                    "If you have any questions or need assistance with your Unlimited membership, please reach out to premium@neeva.co."
                )
                .withFont(.bodyLarge)
                .fixedSize(horizontal: false, vertical: true)
            }

            NavigationLinkButton("View Benefits") {
                openURL(NeevaConstants.appMembershipURL)
            }
        default:
            VStack {
                Button("Learn More on the Neeva Website") {
                    openURL(NeevaConstants.appMembershipURL)
                }
            }
        }
    }
}

struct NeevaAccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(SSOProvider.allCases, id: \.self) { authProvider in
            NeevaAccountInfoView(
                isPresented: .constant(true),
                userInfo: NeevaUserInfo(
                    previewDisplayName: "First Last", email: "name@example.com",
                    pictureUrl:
                        "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg",
                    authProvider: authProvider))
        }.previewLayout(.fixed(width: 375, height: 150))
    }
}
