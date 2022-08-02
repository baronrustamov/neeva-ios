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

struct TabToolbarView: View {
    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var scrollingControlModel: ScrollingControlModel
    @EnvironmentObject private var incognitoModel: IncognitoModel
    @Default(.currentTheme) var currentTheme

    let performAction: (ToolbarAction) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Color.ui.adaptive.separator
                .frame(height: 0.5)
                .ignoresSafeArea()

            #if XYZ
                Web3Toolbar(
                    opacity: scrollingControlModel.controlOpacity,
                    onBack: { performAction(.back) },
                    onLongPress: { performAction(.longPressBackForward) },
                    overFlowMenuAction: { performAction(.overflow) },
                    showTabsAction: { performAction(.showTabs) },
                    zeroQueryAction: { performAction(.showZeroQuery) }
                )
            #else
                normalTabToolbar
            #endif
            Spacer()
        }
        .defaultBackgroundOrTheme(currentTheme)
        .accentColor(.label)
        .offset(y: scrollingControlModel.footerBottomOffset)
    }

    @ViewBuilder
    var normalTabToolbar: some View {
        HStack(spacing: 0) {
            TabToolbarButtons.BackButton(
                weight: .medium,
                onBack: { performAction(.back) },
                onLongPress: { performAction(.longPressBackForward) }
            )
            TabToolbarButtons.OverflowMenu(
                weight: .medium,
                action: {
                    performAction(.overflow)
                },
                identifier: "TabOverflowButton"
            )
            neevaButton
            if incognitoModel.isIncognito && FeatureFlag[.incognitoQuickClose] {
                TabToolbarButtons.CloseTab(
                    action: { performAction(.closeTab) })
            } else {
                TabToolbarButtons.AddToSpace(
                    weight: .medium, action: { performAction(.addToSpace) })
            }
            TabToolbarButtons.ShowTabs(
                weight: .medium,
                action: { performAction(.showTabs) }
            ).frame(height: 44)
        }
        .padding(.top, 2)
        .opacity(scrollingControlModel.controlOpacity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TabToolbar")
        .accessibilityLabel("Toolbar")
    }

    @ViewBuilder
    private var neevaButton: some View {
        TabToolbarButtons.Neeva(iconWidth: 22)
            .disabled(!chromeModel.isPage || chromeModel.isErrorPage)
    }
}

struct TabToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        let make = { (model: TabChromeModel) in
            TabToolbarView(
                performAction: { _ in }
            )
            .environmentObject(model)
        }
        VStack {
            Spacer()
            make(TabChromeModel())
        }
        VStack {
            Spacer()
            make(TabChromeModel())
        }.preferredColorScheme(.dark)
        VStack {
            Spacer()
            make(TabChromeModel())
                .environmentObject(IncognitoModel(isIncognito: true))
        }
        VStack {
            Spacer()
            make(TabChromeModel())
                .environmentObject(IncognitoModel(isIncognito: true))
        }.preferredColorScheme(.dark)
    }
}
