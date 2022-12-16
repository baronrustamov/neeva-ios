// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum PromoCardValues {
    static let LARGE_DISPLAY_WIDTH: CGFloat = 500
}

enum PromoCardViewType: String {
    case defaultBrowser
    case premium
}

struct PromoCardView: View {
    @ObservedObject var zqModel: ZeroQueryModel
    let viewWidth: CGFloat

    var body: some View {
        switch zqModel.promoCardType {
        case .defaultBrowser:
            PromoCardDefaultBrowserView(zqModel: zqModel, viewWidth: viewWidth)
        case .premium:
            PromoCardPremiumView(zqModel: zqModel, viewWidth: viewWidth)
        default:
            EmptyView()
        }
    }
}

struct PromoCardDefaultBrowserView: View {
    var zqModel: ZeroQueryModel
    let viewWidth: CGFloat

    var body: some View {
        PromoCardContainer {
            PromoCardHeading("Get the most out of Neeva’s private search and browsing.") {
                zqModel.logPromoCardInteraction(.CloseDefaultBrowserPromo)
                zqModel.dismissPromoCardView()
            }
            HStack {
                PromoCardButton("Set as Default Browser") {
                    zqModel.logPromoCardInteraction(.PromoDefaultBrowser)
                    zqModel.bvc.presentDBOnboardingViewController(
                        triggerFrom: .defaultBrowserPromoCard)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                    .frame(
                        maxWidth: viewWidth >= PromoCardValues.LARGE_DISPLAY_WIDTH ? .infinity : 0)
            }
        }
        .onAppear {
            zqModel.logPromoCardImpression()
        }
    }
}

struct PromoCardPremiumView: View {
    var zqModel: ZeroQueryModel
    let viewWidth: CGFloat

    var body: some View {
        PromoCardContainer {
            PromoCardHeading("Get Premium for unlimited access & top-tier privacy") {
                zqModel.logPromoCardInteraction(.ClosePremiumPromo)
                zqModel.dismissPromoCardView()
            }
            .padding(.bottom, 3)
            if viewWidth >= PromoCardValues.LARGE_DISPLAY_WIDTH {
                HStack {
                    bullets().frame(maxWidth: .infinity, alignment: .leading)
                    button().frame(maxWidth: .infinity)
                }
            } else {
                bullets()
                button()
            }
        }
        .onAppear {
            zqModel.logPromoCardImpression()
        }
    }

    func bullets() -> PromoCardBullets {
        PromoCardBullets([
            "Unlimited ad-free searches",
            "Unlimited devices",
            "Premium Password Manager+VPN",
        ])
    }

    func button() -> PromoCardButton {
        PromoCardButton("Try it Free") {
            zqModel.logPromoCardInteraction(.PromoPremium)
            zqModel.bvc.presentSignInOrUpFlow()
        }
    }
}

struct PromoCardHeading: View {
    let copy: String
    let dismissAction: (() -> Void)?

    init(_ copy: String, dismissAction: (() -> Void)? = nil) {
        self.copy = copy
        self.dismissAction = dismissAction
    }

    var body: some View {
        HStack(alignment: .top) {
            Text(LocalizedStringKey(copy))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.roobert(.medium, size: 20))

            if let dismissAction = self.dismissAction {
                Button(action: dismissAction) {
                    Symbol(.xmark, weight: .semibold, label: "Dismiss")
                        .foregroundColor(Color.secondary)
                }
            }
        }
    }
}

struct PromoCardBullets: View {
    let items: [String]

    init(_ items: [String]) {
        self.items = items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items, id: \.self) { copy in
                HStack(alignment: .top) {
                    Symbol(decorative: .checkmark, size: 16)
                        .foregroundColor(Color.brand.variant.green)
                    Text(LocalizedStringKey(copy)).font(.system(size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PromoCardButton: View {
    let copy: String
    let action: (() -> Void)

    init(_ copy: String, action: @escaping (() -> Void)) {
        self.copy = copy
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image("neevaMenuIcon")
                    .renderingMode(.template)
                    .frame(width: 18, height: 16)
                    .foregroundColor(.white)
                    .padding(.trailing, 3)
                Text(LocalizedStringKey(copy))
                Spacer()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(height: 48)
            .background(Capsule().fill(Color.brand.blue))
        }
    }
}

struct PromoCardContainer<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    @ViewBuilder
    var background: some View {
        // Reference: https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
        let shape = RoundedRectangle(cornerRadius: 12)
        let innerShadowAmount: CGFloat = 1.25

        shape
            .fill(
                LinearGradient(
                    gradient: Gradient(
                        colors: colorScheme == .dark
                            ? [.hex(0x1E2C4D), .hex(0x2B384E), .hex(0x1F2D4D)]
                            : [.hex(0xD8EEFE), .hex(0xEBFCFF), .hex(0xDAE9FF)]),
                    startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .background(
                shape
                    .fill(Color.black.opacity(0.03))
                    .blur(radius: 0.5)
                    .offset(y: -0.5)
            )
            .overlay(
                shape
                    .inset(by: -innerShadowAmount)
                    .stroke(Color.black.opacity(0.2), lineWidth: innerShadowAmount * 2)
                    .blur(radius: 0.5)
                    .offset(y: -innerShadowAmount)
                    .mask(shape)
            )
    }

    var body: some View {
        VStack(content: content)
            .accessibilityIdentifier("promoCardContainer")
            .padding()
            .frame(maxWidth: .infinity)
            .background(background)
            .padding()
    }
}
