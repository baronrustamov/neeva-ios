// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CheatsheetOverlayHostView: View {
    @Environment(\.hideOverlay) private var hideOverlay
    @EnvironmentObject private var tabChromeModel: TabChromeModel

    @ObservedObject private var model: CheatsheetMenuViewModel

    private var showAsPopover: Bool { tabChromeModel.inlineToolbar }

    private let dismiss: () -> Void
    private let openSupport: (UIImage?) -> Void
    private let openURL: (URL) -> Void

    init(openSupport: @escaping (UIImage?) -> Void, dismiss: @escaping ()-> Void, tabManager: TabManager) {
        self.model = tabManager.selectedTab?.cheatsheetModel ?? CheatsheetMenuViewModel(tab: nil)

        self.dismiss = dismiss
        self.openSupport = openSupport
        self.openURL = { url in
            tabManager.createOrSwitchToTab(for: url)
        }
    }

    var body: some View {
        EmptyView()
    }

    @ViewBuilder
    func makePopover<Content: View>(content: Content) -> some View {
        PopoverView(style: .cheatsheet, onDismiss: dismiss, headerButton: nil) {
            content
        }
    }

    @ViewBuilder
    var content: some View {
        CheatsheetMenuView(support: openSupport)
            .environmentObject(model)
            .environment(\.onOpenURLForCheatsheet) { url, source in
                hideOverlay()
                ClientLogger.shared.logCounter(
                    .OpenLinkFromCheatsheet,
                    attributes:
                        EnvironmentHelper.shared.getAttributes()
                        + model.loggerAttributes
                        + [
                            ClientLogCounterAttribute(
                                key: LogConfig.CheatsheetAttribute.openLinkSource,
                                value: source
                            ),
                            ClientLogCounterAttribute(key: "url", value: url.absoluteString),
                        ]
                )
                self.openURL(url)
            }
    }
}

struct CheatsheetOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    private let menuAction: (OverflowMenuAction) -> Void
    private let model: CheatsheetMenuViewModel
    private let isIncognito: Bool
    private let tabManager: TabManager

    init(menuAction: @escaping (OverflowMenuAction) -> Void, tabManager: TabManager) {
        self.menuAction = menuAction
        self.model = tabManager.selectedTab?.cheatsheetModel ?? CheatsheetMenuViewModel(tab: nil)
        self.isIncognito = tabManager.incognitoModel.isIncognito
        self.tabManager = tabManager
    }

    var body: some View {
        CheatsheetMenuView { feedbackImage in
            menuAction(.support(screenshot: feedbackImage))
        }
        .background(Color.DefaultBackground)
        .overlayIsFixedHeight(isFixedHeight: false)
        .environmentObject(model)
        .environment(\.onOpenURLForCheatsheet) { url, source in
            hideOverlay()
            ClientLogger.shared.logCounter(
                .OpenLinkFromCheatsheet,
                attributes:
                    EnvironmentHelper.shared.getAttributes()
                    + model.loggerAttributes
                    + [
                        ClientLogCounterAttribute(
                            key: LogConfig.CheatsheetAttribute.openLinkSource,
                            value: source
                        ),
                        ClientLogCounterAttribute(key: "url", value: url.absoluteString),
                    ]
            )
            self.tabManager.createOrSwitchToTab(for: url)
        }
    }
}
