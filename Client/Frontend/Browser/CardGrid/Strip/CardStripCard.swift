// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CardStripCard<Details>: View where Details: TabCardDetails {
    @ObservedObject var details: Details

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var cardStripModel: CardStripModel
    @EnvironmentObject var incognitoModel: IncognitoModel
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    @State private var width: CGFloat = 0

    var shouldUseCompactUI: Bool {
        width <= CardStripUX.CardMinimumContentWidthRequirement
            || (cardStripModel.shouldEmbedInScrollView && !details.isSelected)
    }

    private let squareSize = CardUX.FaviconSize + 1
    private var preferredWidth: CGFloat {
        return
            details.title.size(withAttributes: [
                .font: FontStyle.labelMedium.uiFont(for: sizeCategory)
            ]).width + CardUX.CloseButtonSize + CardUX.FaviconSize + 45  // miscellaneous padding
    }

    @ViewBuilder
    var buttonContent: some View {
        HStack {
            if shouldUseCompactUI {
                Spacer()
            }

            HStack {
                if let favicon = details.favicon {
                    favicon
                        .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                        .cornerRadius(CardUX.FaviconCornerRadius)
                        .padding(5)
                        .padding(.vertical, 6)
                }

                if !shouldUseCompactUI {
                    Text(details.title)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .padding(.trailing, 5)
                        .padding(.vertical, 4)
                }
            }

            Spacer()

            if let image = details.closeButtonImage,
                width > CardStripUX.CardMinimumContentWidthRequirement - 15
            {
                Button(action: details.onClose) {
                    Image(uiImage: image)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.secondaryLabel)
                        .padding(8)
                        .frame(width: CardUX.CloseButtonSize, height: CardUX.CloseButtonSize)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                        .accessibilityLabel("Close \(details.title)")
                        .hoverEffect(.lift)
                }
            }
        }.animation(nil)
    }

    var card: some View {
        Button {
            details.onSelect()
        } label: {
            if details.isPinned {
                buttonContent
                    .frame(width: CardUX.FaviconSize + 12)
            } else {
                buttonContent
                    .frame(minWidth: details.isSelected ? preferredWidth : CardUX.FaviconSize + 12)
            }
        }
        .padding(.horizontal)
        .onWidthOfViewChanged { width in
            self.width = width
        }
    }

    var body: some View {
        card
            .transition(.identity)
            .animation(CardTransitionUX.animation)
            .contextMenu(menuItems: details.contextMenu)
            .background(
                details.isSelected ? Color.DefaultBackground : Color.groupedBackground
            )
            .if(!details.isPinned) { view in
                view
                    .onDrop(of: ["public.url", "public.text"], delegate: details)
                    .modifier(CardDragAndDropModifier(tabCardDetail: details))
            }
    }
}
