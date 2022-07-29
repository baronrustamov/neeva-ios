// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

private struct CollapsedCardStripTabGroupCardView: View {
    @ObservedObject var groupDetails: TabGroupCardDetails

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var cardStripModel: CardStripModel
    @Environment(\.sizeCategory) private var sizeCategory

    @State private var width: CGFloat = 120

    var title: String {
        groupDetails.title + " & \(groupDetails.allDetails.count - 1) more"
    }

    var shouldUseCompactUI: Bool {
        width <= CardStripUX.CardMinimumContentWidthRequirement
            || (cardStripModel.shouldEmbedInScrollView && !groupDetails.isSelected)
    }

    private let squareSize = CardUX.FaviconSize + 1
    private var preferredWidth: CGFloat {
        return
            title.size(withAttributes: [
                .font: FontStyle.labelMedium.uiFont(for: sizeCategory)
            ]).width + CardUX.CloseButtonSize + CardUX.FaviconSize + 45  // miscellaneous padding
    }

    var content: some View {
        HStack {
            if shouldUseCompactUI {
                Spacer()
            }

            ZStack {
                // An array of the first three favicons, enumerated and reversed.
                ForEach(
                    Array(
                        groupDetails.allDetails.prefix(3).compactMap { $0.favicon }.enumerated()
                            .reversed()), id: \.0
                ) { index, favicon in
                    favicon
                        .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                        .cornerRadius(CardUX.FaviconCornerRadius)
                        .padding(.leading, index * 12)
                        .padding(5)
                        .padding(.vertical, 6)
                        .opacity(calculateFaviconOpacity(index: index))
                }
            }

            if !shouldUseCompactUI {
                Text(title)
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .padding(.trailing, 5)
                    .padding(.vertical, 4)
            }

            Spacer()
        }
    }

    var body: some View {
        Button {
            browserModel.tabManager.select(groupDetails.allDetails[0].tab)
        } label: {
            content
        }
        .padding(.horizontal)
        .background(Color.groupedBackground)
        .onWidthOfViewChanged { width in
            self.width = width
        }
    }

    func calculateFaviconOpacity(index: Int) -> Double {
        return 1 - (Double(index) / Double(3))
    }
}

struct CardStripTabGroupCardView: View {
    @ObservedObject var groupDetails: TabGroupCardDetails

    var divider: some View {
        Rectangle()
            .frame(width: 5)
            .foregroundColor(.secondarySystemFill)
    }

    var body: some View {
        if groupDetails.isSelected {
            divider

            ForEach(groupDetails.allDetails) { details in
                CardStripCard(details: details)
            }

            divider
        } else {
            CollapsedCardStripTabGroupCardView(groupDetails: groupDetails)
        }
    }
}
