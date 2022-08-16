// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SFSafeSymbols
import Shared
import SwiftUI

#if XYZ
    import WalletCore
#endif

struct TabToolbarButton<Content: View>: View {
    let label: Content
    let action: () -> Void
    let longPressAction: (() -> Void)?

    @Environment(\.isEnabled) private var isEnabled

    init(
        label: Content,
        action: @escaping () -> Void,
        longPressAction: (() -> Void)? = nil
    ) {
        self.label = label
        self.action = action
        self.longPressAction = longPressAction
    }

    var body: some View {
        LongPressButton(action: action, longPressAction: longPressAction) {
            Spacer(minLength: 0)
            label.tapTargetFrame()
            Spacer(minLength: 0)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

enum TabToolbarButtons {
    struct BackButton: View {
        let weight: Font.Weight
        let onBack: () -> Void
        let onLongPress: () -> Void

        @EnvironmentObject private var model: TabChromeModel
        @Default(.currentTheme) var currentTheme

        var body: some View {
            TabToolbarButton(
                label: label,
                action: onBack,
                longPressAction: onLongPress
            )
            .disabled(!model.canGoBack)
            .accessibilityAction(named: "Show Recent Pages", onLongPress)
        }

        @ViewBuilder private var label: some View {
            #if XYZ
                Web3Theme(with: currentTheme).backButton
            #else
                Symbol(
                    .arrowBackward,
                    size: 20,
                    weight: weight,
                    label: .TabToolbarBackAccessibilityLabel)
            #endif
        }
    }

    struct ForwardButton: View {
        let weight: Font.Weight
        let onForward: () -> Void
        let onLongPress: () -> Void

        @EnvironmentObject private var model: TabChromeModel

        var body: some View {
            Group {
                TabToolbarButton(
                    label: Symbol(
                        .arrowForward, size: 20, weight: weight,
                        label: .TabToolbarForwardAccessibilityLabel),
                    action: onForward,
                    longPressAction: onLongPress
                )
                .disabled(!model.canGoForward)
                .accessibilityAction(named: "Show Recent Pages", onLongPress)
            }
        }
    }

    struct ReloadStopButton: View {
        let weight: Font.Weight
        let onTap: () -> Void

        @EnvironmentObject private var model: TabChromeModel

        var body: some View {
            Group {
                TabToolbarButton(
                    label: Symbol(
                        model.reloadButton == .reload ? .arrowClockwise : .xmark, size: 20,
                        weight: weight,
                        label: model.reloadButton == .reload ? "Reload" : "Stop"),
                    action: onTap
                )
            }
        }
    }

    struct SpaceFilter: View {
        let weight: Font.Weight
        let action: () -> Void

        var body: some View {
            TabToolbarButton(
                label: Symbol(
                    .lineHorizontal3DecreaseCircle,
                    size: 20, weight: weight,
                    label: "Space Filter"),
                action: action
            )
        }
    }

    struct OverflowMenu: View {
        let weight: Font.Weight
        let action: () -> Void
        let identifier: String
        @Default(.currentTheme) var currentTheme

        init(weight: Font.Weight, action: @escaping () -> Void, identifier: String = "") {
            self.weight = weight
            self.action = action
            self.identifier = identifier
        }

        var body: some View {
            TabToolbarButton(
                label: label,
                action: action
            )
            .accessibilityIdentifier(identifier)
        }

        @ViewBuilder private var label: some View {
            #if XYZ
                Web3Theme(with: currentTheme).overflowButton
            #else
                Symbol(
                    .ellipsisCircle,
                    size: 20,
                    weight: weight,
                    label: .TabToolbarMoreAccessibilityLabel)
            #endif
        }
    }

    struct Neeva: View {
        let iconWidth: CGFloat

        @EnvironmentObject private var chromeModel: TabChromeModel
        @EnvironmentObject private var promoModel: CheatsheetPromoModel
        @EnvironmentObject private var incognitoModel: IncognitoModel
        @Environment(\.isEnabled) private var isEnabled

        var renderAsTemplate: Bool {
            incognitoModel.isIncognito || !isEnabled
        }

        var body: some View {
            TabToolbarButton(
                label: icon,
                action: {
                    promoModel.openSheet(
                        on: chromeModel.topBarDelegate?.tabManager.selectedTab?.url
                    )
                    if let bvc = chromeModel.topBarDelegate as? BrowserViewController {
                        bvc.showCheatSheetOverlay()
                    }
                }
            )
            .presentAsPopover(
                isPresented: $promoModel.showPromo,
                backgroundColor: promoModel.getPopoverBackgroundColor(),
                useDimmingBackground: promoModel.popoverDimBackground,
                useAlternativeShadow: promoModel.popoverUseAlternativeShadow,
                dismissOnTransition: true
            ) {
                promoModel.getPopoverContent()
                    .frame(maxWidth: 270)
            }
        }

        @ViewBuilder
        var icon: some View {
            ZStack(alignment: .center) {
                Image("neevaMenuIcon")
                    .renderingMode(renderAsTemplate ? .template : .original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconWidth)
                    .accessibilityLabel("Neeva")
                HStack {
                    Spacer()
                    VStack {
                        bubble
                        Spacer()
                    }
                }
                .padding(7)
            }
        }

        @ViewBuilder
        var bubble: some View {
            if promoModel.showBubble {
                Circle()
                    .fill(Color.ui.adaptive.blue)
                    .frame(width: 6, height: 6)
            }
        }
    }

    #if XYZ
        struct NeevaWallet: View {
            @ObservedObject var assetStore: AssetStore
            @EnvironmentObject var model: Web3Model
            @Default(.currentTheme) var currentTheme
            @ObservedObject var gasFeeModel: GasFeeModel

            var body: some View {
                TabToolbarButton(
                    label: Web3Theme(with: currentTheme).walletButton(
                        with: gasFeeModel.gasFeeState.tintColor),
                    action: model.showWalletPanel
                )
            }
        }
    #endif

    #if XYZ
        struct HomeButton: View {
            let action: () -> Void
            @Default(.currentTheme) var currentTheme

            var body: some View {
                TabToolbarButton(
                    label: Web3Theme(with: currentTheme).homeButton,
                    action: action
                )
            }
        }
    #endif

    struct CloseTab: View {
        let action: () -> Void

        @EnvironmentObject private var model: TabChromeModel

        var body: some View {
            TabToolbarButton(
                label: Symbol(
                    .trash,
                    size: 20, weight: .medium, label: "Close Tab Shortcut"),
                action: action
            )
            .disabled(!model.isPage || model.isErrorPage)
        }
    }

    struct AddToSpace: View {
        let weight: NiconFont
        let action: () -> Void

        @EnvironmentObject private var incognitoModel: IncognitoModel
        @EnvironmentObject private var model: TabChromeModel

        var body: some View {
            TabToolbarButton(
                label: Symbol(
                    model.urlInSpace ? .bookmarkFill : .bookmark,
                    size: 20, weight: weight, label: "Add To Space"),
                action: action
            )
            .accessibilityValue(model.urlInSpace ? "Page is in a Space" : "")
            .disabled(incognitoModel.isIncognito || !model.isPage || model.isErrorPage)
        }
    }

    struct ShowTabs: View {
        let weight: Font.Weight
        let action: () -> Void
        @Default(.currentTheme) var currentTheme

        @EnvironmentObject var browserModel: BrowserModel
        @EnvironmentObject var gridModel: GridModel

        var button: some View {
            #if XYZ
                TabToolbarButton(
                    label: Web3Theme(with: currentTheme).tabsImage,
                    action: action
                )
            #else
                TabToolbarButton(
                    label: Symbol(
                        .squareOnSquare, size: 20, weight: weight, label: "Show Tabs"),
                    action: action
                )
            #endif
        }

        @ViewBuilder
        var body: some View {
            button
                .modifier(MenuBuilder.ShowTabsButtonMenu(tabManager: browserModel.tabManager))
                .modifier(
                    MenuBuilder.ConfirmCloseAllTabsConfirmationDialog(
                        showMenu: $gridModel.showConfirmCloseAllTabs,
                        tabManager: browserModel.tabManager)
                )
                .accessibilityLabel(Text("Show Tabs"))
        }
    }
}
