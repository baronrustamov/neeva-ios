// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum CardUX {
    static let DefaultCardSize: CGFloat = 160
    static let ShadowRadius: CGFloat = 2
    static let CornerRadius: CGFloat = 16
    static let CompactCornerRadius: CGFloat = 8
    static let FaviconCornerRadius: CGFloat = 4
    static let ButtonSize: CGFloat = 28
    static let FaviconSize: CGFloat = 18
    static let CloseButtonSize: CGFloat = 24
    static let HeaderSize: CGFloat = ButtonSize + 1
    static let DefaultTabCardRatio: CGFloat = 200 / 164
}

extension EnvironmentValues {
    private struct CardSizeKey: EnvironmentKey {
        static var defaultValue: CGFloat = CardUX.DefaultCardSize
    }

    public var cardSize: CGFloat {
        get { self[CardSizeKey.self] }
        set { self[CardSizeKey.self] = newValue }
    }

    private struct AspectRatioKey: EnvironmentKey {
        static var defaultValue: CGFloat = 1
    }

    public var aspectRatio: CGFloat {
        get { self[AspectRatioKey.self] }
        set { self[AspectRatioKey.self] = newValue }
    }

    private struct SelectionCompletionKey: EnvironmentKey {
        static var defaultValue: () -> Void = {}
    }
    public var selectionCompletion: () -> Void {
        get { self[SelectionCompletionKey.self] }
        set { self[SelectionCompletionKey.self] = newValue }
    }
}

struct CardThumbnail<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    let geom: GeometryProxy

    var body: some View {
        details.thumbnail
            .frame(
                width: max(0, geom.size.width),
                height: max(
                    0,
                    geom.size.height
                        - (details.thumbnailDrawsHeader ? 0 : CardUX.HeaderSize)),
                alignment: .top
            )
            .clipped()
    }
}

struct CardAccessibilityFocusModifier<Details>: ViewModifier where Details: CardDetails {
    @ObservedObject var details: Details
    @EnvironmentObject var cardTransitionModel: CardTransitionModel

    func body(content: Content) -> some View {
        content
            .modifier(
                FocusOnAppearModifier(
                    focus: details.isSelected,
                    trigger: cardTransitionModel.state == .hidden
                )
            )
    }
}

/// A flexible card that takes up as much space as it is allotted.
struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    var dragToClose = false
    var animate = false
    var showGrid = true

    var tabCardDetail: TabCardDetails? {
        details as? TabCardDetails
    }

    @Environment(\.selectionCompletion) private var selectionCompletion
    @Environment(\.cardSize) private var cardSize
    @EnvironmentObject private var incognitoModel: IncognitoModel
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geom in
            VStack(alignment: .center, spacing: 0) {
                Button {
                    selectionCompletion()
                    details.onSelect()
                } label: {
                    CardThumbnail(details: details, geom: geom)
                        .onDrop(of: ["public.url", "public.text"], delegate: details)
                        .if(let: tabCardDetail) { tabCardDetail, view in
                            view.modifier(CardDragAndDropModifier(tabCardDetail: tabCardDetail))
                        }
                }
                .buttonStyle(.reportsPresses(to: $isPressed))
                .cornerRadius(animate && !showGrid ? 0 : CardUX.CornerRadius)
                .modifier(
                    BorderTreatment(
                        isSelected: showGrid && details.isSelected,
                        thumbnailDrawsHeader: details.thumbnailDrawsHeader,
                        isIncognito: incognitoModel.isIncognito)
                )
                .modifier(CardModifier(details: details, animate: animate))

                if !details.thumbnailDrawsHeader {
                    HStack(spacing: 0) {
                        details.favicon
                            .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                            .cornerRadius(CardUX.FaviconCornerRadius)
                            .padding(5)
                        Text(details.title)
                            .withFont(.labelMedium)
                            .frame(alignment: .center)
                            .padding(.trailing, 5).padding(.vertical, 4).lineLimit(1)
                    }
                    // Avoid re-layout as the geometry of the card changes during card transition
                    // animation. `geom.size.width` should never get smaller than `cardSize`.
                    .frame(width: cardSize, height: CardUX.ButtonSize)
                    .background(Color.clear)
                    .opacity(animate && !showGrid ? 0 : 1)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(details.accessibilityLabel)
        .modifier(ActionsModifier(close: details.closeButtonImage == nil ? nil : details.onClose))
        .modifier(
            CloseButtonModifier(
                details: details, animate: animate, showGrid: showGrid,
                dragToClose: dragToClose)
        )
        .accessibilityAddTraits(.isButton)
        .modifier(CardAccessibilityFocusModifier(details: details))
        .if(!animate) { view in
            view
                .scaleEffect(isPressed ? 0.95 : 1)
                .animation(CardTransitionUX.animation, value: isPressed)
        }
    }

    private struct ActionsModifier: ViewModifier {
        let close: (() -> Void)?

        func body(content: Content) -> some View {
            if let close = close {
                content.accessibilityAction(named: "Close", close)
            } else {
                content
            }
        }
    }

    private struct CardModifier: ViewModifier {
        let details: Details
        let animate: Bool

        @ViewBuilder
        func body(content: Content) -> some View {
            if let tabDetails = details as? TabCardDetails {
                content
                    .modifier(TabCardModifier(details: tabDetails, animate: animate))
            } else if let spaceDetails = details as? SpaceCardDetails {
                content
                    .modifier(SpaceCardModifier(details: spaceDetails, animate: animate))
            } else {
                content
            }
        }
    }

    private struct SpaceCardModifier: ViewModifier {
        @ObservedObject var details: SpaceCardDetails
        let animate: Bool
        @State var showingRemoveSpaceWarning: Bool = false

        // These two buttons (removeButton, pinButton) are broken
        // out into computed properties in order to make things
        // easier for the compiler.
        @ViewBuilder
        var removeButton: some View {
            Button {
                guard !details.isFollowing else {
                    showingRemoveSpaceWarning = true
                    return
                }

                if let spaceId = details.item?.id.id {
                    SpaceStore.shared.followSpace(spaceId: spaceId)
                }

            } label: {
                if details.isFollowing {
                    Label(
                        details.item?.ACL == .owner ? "Delete Space" : "Unfollow",
                        systemSymbol: .trash)
                } else {
                    Label("Follow", systemSymbol: .plus)
                }
            }
        }

        // `isPinnable` is used to disable the pin option, for example,
        // in the "Verified Creators" Profile UI.
        @ViewBuilder
        var pinButton: some View {
            if details.isPinnable {
                Button {
                    details.pinSpace()
                } label: {
                    if let isPinned = details.item?.isPinned {
                        Label(
                            isPinned ? "Unpin" : "Pin",
                            systemSymbol: (isPinned ? .pinSlash : .pin))
                    }
                }
            }
        }

        @ViewBuilder
        func body(content: Content) -> some View {
            content
                .if(!animate) { view in
                    view
                        .padding(1.5)
                        .contextMenu {
                            if !(details.item?.isDefaultSpace ?? false) {
                                removeButton
                            }
                            pinButton
                        }
                        .actionSheet(isPresented: $showingRemoveSpaceWarning) {
                            ActionSheet(
                                // Compilation fails if we don't concat separate Text views for title
                                title: Text(
                                    "Are you sure you want to \(details.item?.ACL == .owner ? "delete" : "unfollow") this space?"
                                ),
                                buttons: [
                                    .destructive(
                                        Text(
                                            details.item?.ACL == .owner
                                                ? "Delete Space" : "Unfollow Space"),
                                        action: {
                                            details.item?.ACL == .owner
                                                ? details.deleteSpace()
                                                : details.unfollowSpace()
                                        }),
                                    .cancel(),
                                ]
                            )
                        }
                        .padding(-1.5)
                }
        }

    }

    private struct TabCardModifier: ViewModifier {
        @ObservedObject var details: TabCardDetails
        let animate: Bool

        @ViewBuilder
        func body(content: Content) -> some View {
            content
                .if(!animate) { view in
                    view
                        // add padding to all tab grids
                        .padding(1.5)
                        // remove padding of unselected tab grid to eliminate edge when open contextMenu
                        .padding(details.isSelected ? 0 : -1.5)
                        .contextMenu(menuItems: details.contextMenu)
                        // remove padding of selected tab
                        .padding(details.isSelected ? -1.5 : 0)
                }
        }
    }

    private struct CloseButtonModifier<Details>: ViewModifier where Details: CardDetails {
        @ObservedObject var details: Details
        let animate: Bool
        let showGrid: Bool
        let dragToClose: Bool

        private var closeButton: some View {
            HoverEffectButton(effect: .lift, action: details.onClose) {
                Image(uiImage: details.closeButtonImage!)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(.secondaryLabel)
                    .padding(6)
                    .frame(width: CardUX.CloseButtonSize, height: CardUX.CloseButtonSize)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
                    .padding(6)
                    .opacity(animate && !showGrid ? 0 : 1)
                    .transition(.identity.combined(with: .opacity))
                    .animation(animate ? CardTransitionUX.animation : nil)
            }.accessibilityHidden(true)
        }

        func body(content: Content) -> some View {
            if details.closeButtonImage != nil {
                content
                    .overlay(closeButton, alignment: .topTrailing)
                    .if(dragToClose) { view in
                        view.modifier(DragToCloseInteraction(action: details.onClose))
                    }
            } else {
                content
            }
        }
    }
}
