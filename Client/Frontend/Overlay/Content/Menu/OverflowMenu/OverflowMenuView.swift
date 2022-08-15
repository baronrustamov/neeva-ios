// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

enum OverflowMenuUX {
    static let innerSectionPadding: CGFloat = 8
    static let squareButtonSize: CGFloat = 83
    static let squareButtonSpacing: CGFloat = 4
    static let squareButtonIconSize: CGFloat = 20
}

struct OverflowMenuButtonView: View {
    let label: LocalizedStringKey
    var symbol: SFSymbol? = nil
    var nicon: Nicon? = nil
    let action: () -> Void
    let longPressAction: (() -> Void)?
    var isIncognito: Bool

    @Environment(\.isEnabled) private var isEnabled

    init(
        label: LocalizedStringKey, symbol: SFSymbol,
        isIncognito: Bool = false,
        longPressAction: (() -> Void)? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.symbol = symbol
        self.action = action
        self.longPressAction = longPressAction
        self.isIncognito = isIncognito
    }

    public init(
        label: LocalizedStringKey, nicon: Nicon,
        longPressAction: (() -> Void)? = nil,
        isIncognito: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.nicon = nicon
        self.action = action
        self.longPressAction = longPressAction
        self.isIncognito = isIncognito
    }

    var body: some View {
        GroupedCellButton(
            action: action, longPressAction: longPressAction,
            backgroundColor: isIncognito
                ? Color.black
                : Color.secondaryGroupedBackgroundElevated
        ) {
            VStack(spacing: OverflowMenuUX.squareButtonSpacing) {
                if let symbol = symbol {
                    Symbol(
                        decorative: symbol, size: OverflowMenuUX.squareButtonIconSize,
                        weight: .medium)
                } else if let nicon = nicon {
                    Symbol(decorative: nicon, size: 20, weight: .medium)
                }

                Text(label).withFont(.bodyLarge)
            }.frame(height: OverflowMenuUX.squareButtonSize)
        }
        .accentColor(isIncognito ? .white : isEnabled ? .label : .quaternaryLabel)
    }
}

struct OverflowMenuView: View {
    private let menuAction: (OverflowMenuAction) -> Void
    private let changedUserAgent: Bool

    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var locationModel: LocationViewModel

    @State var height: CGFloat = .zero
    // used to show a little bit of the support option to encourage scrolling
    private static let heightPeekingOffset: CGFloat = 80

    init(
        changedUserAgent: Bool = false,
        menuAction: @escaping (OverflowMenuAction) -> Void
    ) {
        self.menuAction = menuAction
        self.changedUserAgent = changedUserAgent
    }

    var frameHeight: CGFloat {
        height + Self.heightPeekingOffset
    }

    var body: some View {
        GroupedStack {
            VStack(spacing: GroupedCellUX.spacing) {
                if !chromeModel.inlineToolbar {
                    topButtons
                }

                tabButtons
            }
            .modifier(ViewHeightKey())
            .onPreferenceChange(ViewHeightKey.self) {
                self.height = $0
            }

            appNavigationButtons
        }
        .overlaySheetMiddleHeight(height: frameHeight)
        .overlaySheetIgnoreSafeArea(edges: .bottom)
    }

    @ViewBuilder
    var topButtons: some View {
        HStack(spacing: OverflowMenuUX.innerSectionPadding) {
            OverflowMenuButtonView(
                label: "Forward",
                symbol: .arrowForward,
                longPressAction: {
                    menuAction(.longPressForward)
                },
                action: {
                    menuAction(.forward)
                }
            )
            .accessibilityIdentifier("OverflowMenu.Forward")
            .disabled(!chromeModel.canGoForward)

            OverflowMenuButtonView(
                label: chromeModel.reloadButton == .reload ? "Reload" : "Stop",
                symbol: chromeModel.reloadButton == .reload ? .arrowClockwise : .xmark
            ) {
                menuAction(.reloadStop)
            }
            .accessibilityIdentifier("OverflowMenu.Reload")
        }
    }

    @ViewBuilder
    var tabButtons: some View {
        GroupedCell.Decoration {
            VStack(spacing: 0) {
                GroupedRowButtonView(
                    label: "Find on Page",
                    symbol: .docTextMagnifyingglass
                ) {
                    menuAction(.findOnPage)
                }
                .accessibilityIdentifier("OverflowMenu.FindOnPage")

                Color.groupedBackground.frame(height: 1)

                GroupedRowButtonView(
                    label: "Text Size",
                    symbol: .textformatSize
                ) {
                    menuAction(.textSize)
                }
                .accessibilityIdentifier("OverflowMenu.TextSize")

                Color.groupedBackground.frame(height: 1)

                GroupedRowButtonView(
                    label: changedUserAgent == true
                        ? "Request Mobile Site"
                        : "Request Desktop Site",
                    symbol: changedUserAgent == true
                        ? (UIConstants.hasHomeButton ? .iphoneHomebutton : .iphone)
                        : .desktopcomputer
                ) {
                    menuAction(.desktopSite)
                }
                .accessibilityIdentifier("OverflowMenu.RequestDesktopSite")

                Color.groupedBackground.frame(height: 1)

                GroupedRowButtonView(
                    label: "Download Page",
                    symbol: .squareAndArrowDown
                ) {
                    menuAction(.downloadPage)
                }
                .accessibilityIdentifier("OverflowMenu.DownloadPage")
            }
            .accentColor(.label)
        }
    }

    @ViewBuilder
    var appNavigationButtons: some View {
        GroupedCell.Decoration {
            VStack(spacing: 0) {
                GroupedRowButtonView(
                    label: "Support",
                    symbol: .bubbleLeft
                ) {
                    menuAction(.support())
                }
                .accessibilityIdentifier("OverflowMenu.Support")
                Color.groupedBackground.frame(height: 1)

                GroupedRowButtonView(
                    label: "Settings",
                    symbol: .gear
                ) {
                    menuAction(.goToSettings)
                }
                .accessibilityIdentifier("OverflowMenu.Settings")
                Color.groupedBackground.frame(height: 1)

                GroupedRowButtonView(
                    label: "History",
                    symbol: .clock
                ) {
                    menuAction(.goToHistory)
                }
                .accessibilityIdentifier("OverflowMenu.History")
                Color.groupedBackground.frame(height: 1)

                GroupedRowButtonView(
                    label: "Downloads",
                    symbol: .squareAndArrowDown
                ) {
                    menuAction(.goToDownloads)
                }
                .accessibilityIdentifier("OverflowMenu.Downloads")
            }
        }
        .accentColor(.label)
    }
}

struct OverflowMenuView_Previews: PreviewProvider {
    static var previews: some View {
        OverflowMenuView(menuAction: { _ in }).previewDevice("iPod touch (7th generation)")
            .environment(
                \.sizeCategory, .extraExtraExtraLarge)
        OverflowMenuView(menuAction: { _ in })
    }
}
