// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import WalletCore

struct Web3Toolbar: View {
    private let opacity: CGFloat
    private let onBack: () -> Void
    private let onLongPress: () -> Void
    private let overFlowMenuAction: () -> Void
    private let showTabsAction: () -> Void
    private let zeroQueryAction: () -> Void
    @EnvironmentObject var model: Web3Model

    init(
        opacity: CGFloat,
        onBack: @escaping () -> Void,
        onLongPress: @escaping () -> Void,
        overFlowMenuAction: @escaping () -> Void,
        showTabsAction: @escaping () -> Void,
        zeroQueryAction: @escaping () -> Void
    ) {
        self.opacity = opacity
        self.onBack = onBack
        self.onLongPress = onLongPress
        self.overFlowMenuAction = overFlowMenuAction
        self.showTabsAction = showTabsAction
        self.zeroQueryAction = zeroQueryAction
    }

    var body: some View {
        HStack(spacing: 0) {
            TabToolbarButtons.BackButton(
                weight: .medium,
                onBack: onBack,
                onLongPress: onLongPress
            )
            TabToolbarButtons.OverflowMenu(
                weight: .medium,
                action: overFlowMenuAction,
                identifier: "TabOverflowButton"
            )
            TabToolbarButtons.NeevaWallet(
                assetStore: AssetStore.shared, gasFeeModel: model.gasFeeModel
            )
            TabToolbarButtons.HomeButton(
                action: zeroQueryAction
            )
            TabToolbarButtons.ShowTabs(
                weight: .medium,
                action: showTabsAction
            ).frame(height: 44)
        }
        .padding(.top, 2)
        .opacity(opacity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TabToolbar")
        .accessibilityLabel("Toolbar")
    }
}
