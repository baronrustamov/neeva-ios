// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
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

    public init(
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
            .disabled(!model.canGoBack && !model.canReturnToSuggestions)
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
        let action: () -> Void

        @EnvironmentObject private var incognitoModel: IncognitoModel

        var body: some View {
            TabToolbarButton(
                label: Image("neevaMenuIcon")
                    .renderingMode(incognitoModel.isIncognito ? .template : .original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconWidth)
                    .accessibilityLabel("Neeva"),
                action: action
            )
        }
    }

    #if XYZ
        struct NeevaWallet: View {
            @ObservedObject var assetStore: AssetStore
            @EnvironmentObject var model: Web3Model
            @Default(.currentTheme) var currentTheme

            var body: some View {
                TabToolbarButton(
                    label: Web3Theme(with: currentTheme).walletButton,
                    action: model.showWalletPanel
                )
            }
        }
    #endif

    #if XYZ
        struct LazyTabButton: View {
            let action: () -> Void
            @Default(.currentTheme) var currentTheme

            var body: some View {
                TabToolbarButton(
                    label: Web3Theme(with: currentTheme).lazyTabButton,
                    action: action
                )
            }
        }
    #endif

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
            .disabled(incognitoModel.isIncognito || !model.isPage)
        }
    }

    struct ShowTabs: View {
        let weight: UIImage.SymbolWeight
        let action: () -> Void
        let buildMenu: (_ sourceView: UIView) -> UIMenu?
        @Default(.currentTheme) var currentTheme

        @ViewBuilder
        var body: some View {
            #if XYZ
                SecondaryMenuButton(action: action) { button in
                    button.setImage(
                        Web3Theme(with: currentTheme).tabsImage, for: .normal)
                    button.tintColor = .label
                    button.setDynamicMenu {
                        buildMenu(button)
                    }
                    button.accessibilityLabel = "Show Tabs"
                }
            #else
                SecondaryMenuButton(action: action) { button in
                    button.setImage(
                        Symbol.uiImage(.squareOnSquare, size: 20, weight: weight), for: .normal)
                    button.setDynamicMenu {
                        buildMenu(button)
                    }
                    button.accessibilityLabel = "Show Tabs"
                }
            #endif
        }
    }

    struct ShareButton: View {
        let weight: Font.Weight
        let action: () -> Void

        var body: some View {
            TabToolbarButton(
                label: Symbol(
                    .squareAndArrowUp,
                    size: 20, weight: weight,
                    label: "share"),
                action: action
            )
        }
    }

    struct ShowPreferenceButton: View {
        let weight: Font.Weight
        let action: () -> Void

        @EnvironmentObject private var model: TabChromeModel

        var body: some View {
            if let faviconURL = model.currentCheatsheetFaviconURL {
                TabToolbarButton(
                    label: WebImage(url: faviconURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .cornerRadius(6),
                    action: action
                )
            } else if let currentURLInitial = model.currentCheatsheetURL?.baseDomain?.asURL?
                .absoluteString.first?.description
            {
                TabToolbarButton(
                    label: Circle()
                        .fill(Color.gray)
                        .overlay(
                            Text(currentURLInitial).foregroundColor(Color.brand.white).padding(
                                .bottom, 2)
                        )
                        .frame(width: 24, height: 24),
                    action: action
                )
            } else {
                TabToolbarButton(
                    label: Circle()
                        .fill(Color.gray)
                        .frame(width: 24, height: 24),
                    action: action
                )
            }
        }
    }
}
