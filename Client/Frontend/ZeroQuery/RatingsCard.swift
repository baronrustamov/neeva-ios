// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum RatingsCardState {
    case rateExperience
    case sendFeedback
    case appStoreReview
}

enum AppRatingPromoCardRule {
    static let numOfAppForegroundLastWeek = 3
}

enum AppRatingSystemDialogRule {
    static let numOfAppForeground = 6
}

struct RatingsCard: View {
    @State var state = RatingsCardState.rateExperience

    let onClose: () -> Void
    let onFeedback: () -> Void
    var viewWidth: CGFloat

    // this number is from the Figma mock
    let minimumButtonWidth: CGFloat = 250

    var secondButtonProminent: Bool {
        switch state {
        case .rateExperience: return false
        default: return true
        }
    }

    var color: Color {
        return Color(light: .hex(0xFFFDF5), dark: .hex(0x191919))
    }

    func leftButtonFunction() {
        switch state {
        case .rateExperience:
            state = .sendFeedback
            ClientLogger.shared.logCounter(.RatingsNeedsWork)
            ClientLogger.shared.logCounter(.RatingsPromptFeedback)
        case .sendFeedback:
            onClose()
            ClientLogger.shared.logCounter(.RatingsDismissedFeedback)
        case .appStoreReview:
            onClose()
            ClientLogger.shared.logCounter(.RatingsDismissedAppReview)
        }
    }

    func rightButtonFunction() {
        switch state {
        case .rateExperience:
            state = .appStoreReview
            ClientLogger.shared.logCounter(.RatingsLoveit)
            ClientLogger.shared.logCounter(.RatingsPromptAppStore)
        case .sendFeedback:
            onFeedback()
            onClose()
            ClientLogger.shared.logCounter(.RatingsSendFeedback)
        case .appStoreReview:
            // Not using SKStoreReviewController due to its flakiness and feedbacks we've received from users
            UIApplication.shared.open(
                "https://apps.apple.com/us/app/neeva-browser-search-engine/id1543288638?action=write-review",
                options: [:], completionHandler: nil)
            onClose()
            ClientLogger.shared.logCounter(.RatingsSendAppReview)
        }
    }

    @ViewBuilder
    var leftButtonContent: some View {
        HStack {
            if state == RatingsCardState.rateExperience { Text("😕").withFont(.bodyLarge) }
            Spacer(minLength: 0)
            if state == RatingsCardState.rateExperience {
                Text("Needs work").withFont(.bodyLarge)
            } else {
                Text("Maybe later").withFont(.bodyLarge)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 12.5)
        .padding(.trailing, 16)
    }

    @ViewBuilder
    var rightButtonContent: some View {
        HStack {
            if state == RatingsCardState.rateExperience { Text("😍").withFont(.bodyLarge) }
            Spacer(minLength: 0)
            if state == RatingsCardState.rateExperience {
                Text("Loving it!").withFont(.bodyLarge)
            } else {
                Text("Let's do it!")
                    .bold()
                    .withFont(.bodyLarge)
            }
            Spacer(minLength: 0)

        }
        .padding(.leading, 12.5)
        .padding(.trailing, 16)
    }

    @ViewBuilder
    var title: some View {
        switch state {
        case .rateExperience:
            Text("How's your Neeva experience?")
                .withFont(.bodyLarge)
                .multilineTextAlignment(.center)
        case .sendFeedback:
            Text("✍️").font(.system(size: 32))
            Text("We hear you. Send feedback to help us make Neeva better for you!")
                .withFont(.bodyLarge)
                .multilineTextAlignment(isHorizontal ? .leading : .center)
        case .appStoreReview:
            Text("😍").font(.system(size: 32))
            Text("Spread the cheer on the App Store? Your review will help Neeva grow.")
                .withFont(.bodyLarge)
                .multilineTextAlignment(isHorizontal ? .leading : .center)
        }
    }

    @ViewBuilder
    var buttons: some View {
        HStack(spacing: 10) {
            Button(action: self.leftButtonFunction) {
                leftButtonContent
            }
            .buttonStyle(.neeva(.secondary))
            .frame(width: 148)
            Button(action: self.rightButtonFunction) {
                rightButtonContent
            }
            .buttonStyle(.neeva(secondButtonProminent ? .primary : .secondary))
            .frame(width: 148)
        }

    }

    @ViewBuilder
    var label: some View {
        let size: CGFloat = 24
        let lineSpacing = 32 - size

        title
            .font(.roobert(.regular, size: size))
            .lineSpacing(lineSpacing)
            .foregroundColor(.label)
            .padding(.vertical, 0)
    }

    var background: some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        let innerShadowAmount: CGFloat = 1.25
        return
            shape
            .fill(color)
            .background(
                shape
                    .fill(Color.black.opacity(0.03))
                    .blur(radius: 0.5)
                    .offset(y: -0.5)
            )
            .overlay(
                // Reference: https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
                shape
                    .inset(by: -innerShadowAmount)
                    .stroke(Color.black.opacity(0.2), lineWidth: innerShadowAmount * 2)
                    .blur(radius: 0.5)
                    .offset(y: -innerShadowAmount)
                    .mask(shape)
            )

    }

    var isHorizontal: Bool {
        // button takes up roughly 1/2.5 of the view width
        return viewWidth / 2.5 > minimumButtonWidth
    }

    var body: some View {
        Group {
            if isHorizontal {
                HStack(spacing: 16) {
                    label
                    Spacer()
                    buttons
                }
            } else {
                VStack(spacing: 16) {
                    label
                        .fixedSize(
                            horizontal: false,
                            vertical: true)
                    buttons
                }
            }
        }

        .padding(25)
        .background(background)
        .frame(maxWidth: viewWidth)
        .padding()
    }

}

struct RatingsCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            GeometryReader { geom in
                RatingsCard(
                    state: RatingsCardState.rateExperience,
                    onClose: {}, onFeedback: {},
                    viewWidth: geom.size.width)
            }
            GeometryReader { geom in
                RatingsCard(
                    state: RatingsCardState.sendFeedback,
                    onClose: {}, onFeedback: {},
                    viewWidth: geom.size.width)
            }
            GeometryReader { geom in
                RatingsCard(
                    state: RatingsCardState.appStoreReview,
                    onClose: {}, onFeedback: {},
                    viewWidth: geom.size.width)
            }
        }
    }
}
