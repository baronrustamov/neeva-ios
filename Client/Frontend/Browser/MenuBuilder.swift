// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import SFSafeSymbols
import Shared
import Storage
import SwiftUI
import UIKit

class ContextMenuActionsBuilder {
    // MARK: - Close Tabs
    struct CloseTabAction: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Label {
                    Text("Close Tab")
                } icon: {
                    Image(systemSymbol: .xmark)
                }
            }.accessibilityLabel(Text("Close Tab"))
        }
    }

    struct CloseAllTabsAction: View {
        let tabManager: TabManager
        let action: () -> Void

        var label: some View {
            Label {
                Text("Close All \(tabManager.isIncognito ? "Incognito " : "")Tabs")
            } icon: {
                Image(systemSymbol: .trash)
            }
        }

        var confirmCloseIfNeeded: () -> Void {
            return {
                if Defaults[.confirmCloseAllTabs] {
                    action()
                } else {
                    tabManager.removeTabs(
                        tabManager.isIncognito
                            ? tabManager.incognitoTabs : tabManager.activeNormalTabs,
                        showToast: true)
                }
            }
        }

        var body: some View {
            Group {
                if #available(iOS 15.0, *) {
                    Button(role: .destructive, action: confirmCloseIfNeeded) {
                        label
                    }
                } else {
                    Button(action: confirmCloseIfNeeded) {
                        label
                    }
                }
            }.accessibilityLabel(Text("Close All Tabs"))
        }
    }

    // MARK: - Toggle Incognito State
    struct ToggleIncognitoStateAction: View {
        let tabManager: TabManager

        var body: some View {
            Button {
                tabManager.toggleIncognitoMode(
                    fromTabTray: false, clearSelectedTab: false, selectNewTab: true)
            } label: {
                Label {
                    if tabManager.isIncognito {
                        Text("Leave Incognito Mode")
                    } else {
                        Text("Open Incognito Mode")
                    }
                } icon: {
                    if tabManager.isIncognito {
                        Image("incognitoSlash")
                    } else {
                        Image("incognito")
                    }
                }
            }
        }
    }

    // MARK: - New Tab
    struct NewTabAction: View {
        let isIncognito: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Label {
                    if isIncognito {
                        Text("New Incognito Tab")
                    } else {
                        Text("New Tab")
                    }
                } icon: {
                    if isIncognito {
                        Image(systemSymbol: .plusSquareFill)
                    } else {
                        Image(systemSymbol: .plusSquare)
                    }
                }
            }
        }
    }

    // MARK: - Open in Tab
    private struct ButtonLabel: View {
        let incognito: Bool

        var body: some View {
            Label {
                if incognito {
                    Text("Open in new incognito tab")
                } else {
                    Text("Open in new tab")
                }
            } icon: {
                if incognito {
                    Image("incognito")
                        .renderingMode(.template)
                } else {
                    Symbol(decorative: .plusSquare)
                }
            }
        }
    }

    struct OpenInTabAction: View {
        enum Content {
            case url(URL)
            case tab(SavedTab)
        }

        let content: Content
        let tabManager: TabManager

        var body: some View {
            Group {
                OpenButton(incognito: false, content: content, tabManager: tabManager)
                OpenButton(incognito: true, content: content, tabManager: tabManager)
            }
        }

        private struct OpenButton: View {
            let incognito: Bool
            let content: Content
            let tabManager: TabManager

            var body: some View {
                Button {
                    switch content {
                    case .url(let url):
                        let tab = tabManager.addTabsForURLs(
                            [url], zombie: true, shouldSelectTab: false, incognito: incognito)[0]
                        ToastDefaults().showToastForSwitchToTab(
                            tab, incognito: incognito, tabManager: tabManager)
                    case .tab(let tab):
                        let tab = tabManager.restoreSavedTabs(
                            [tab], isIncognito: incognito, shouldSelectTab: false)
                        ToastDefaults().showToastForSwitchToTab(
                            tab, incognito: incognito, tabManager: tabManager)
                    }
                } label: {
                    ButtonLabel(incognito: incognito)
                }
            }
        }
    }

    // MARK: - Recently Closed Tabs
    struct RecentlyClosedTabsAction: View {
        let tabManager: TabManager
        let fromTab: Bool
        var recentlyClosedTabsFlattened: [SavedTab]

        var content: some View {
            ForEach(recentlyClosedTabsFlattened, id: \.self) { tab in
                Button {
                    _ = tabManager.restoreSavedTabs([tab], overrideSelectedTab: fromTab)
                } label: {
                    Text(tab.title ?? tab.url?.absoluteString ?? "Untitled")
                }
            }
        }

        var body: some View {
            if fromTab {
                Menu {
                    content
                } label: {
                    Label {
                        Text("Recently Closed Tabs")
                    } icon: {
                        Image(systemName: "trash.square")
                    }
                }
            } else {
                content
            }
        }
    }
}

class MenuBuilder {
    // MARK: - Close All Tabs
    public struct ConfirmCloseAllTabsConfirmationDialog: ViewModifier {
        @Binding var showMenu: Bool
        let tabManager: TabManager

        var numberOfTabs: Int {
            tabManager.getTabCountForCurrentType()
        }

        var isIncognito: Bool {
            tabManager.incognitoModel.isIncognito
        }

        func body(content: Content) -> some View {
            let buttonText = Text(
                "Close \(numberOfTabs) \(isIncognito ? "Incognito " : "")\(numberOfTabs > 1 ? "Tabs" : "Tab")"
            )

            if #available(iOS 15.0, *) {
                content.confirmationDialog(
                    "Are you sure you want to close all open \(isIncognito ? "incognito " : "")tabs?",
                    isPresented: $showMenu
                ) {
                    Button(role: .destructive) {
                        closeTabs()
                    } label: {
                        buttonText
                    }.accessibilityLabel("Confirm Close All Tabs")
                }
            } else {
                content.actionSheet(isPresented: $showMenu) {
                    ActionSheet(
                        title: Text(Strings.ClearHistoryMenuTitle),
                        buttons: [
                            .destructive(buttonText) {
                                closeTabs()
                            },
                            .cancel(),
                        ]
                    )
                }
            }
        }

        private func closeTabs() {
            tabManager.removeTabs(
                isIncognito ? tabManager.incognitoTabs : tabManager.activeNormalTabs,
                showToast: false)
        }
    }

    // MARK: - ShowTabsButton Menu
    public struct ShowTabsButtonMenu: ViewModifier {
        @EnvironmentObject var gridModel: GridModel
        @EnvironmentObject var incognitoModel: IncognitoModel

        let tabManager: TabManager

        public func body(content: Content) -> some View {
            let bvc: BrowserViewController = {
                SceneDelegate.getBVC(with: tabManager.scene)
            }()

            return content.contextMenu {
                if tabManager.recentlyClosedTabsFlattened.count > 0 {
                    ContextMenuActionsBuilder.RecentlyClosedTabsAction(
                        tabManager: tabManager, fromTab: true,
                        recentlyClosedTabsFlattened: tabManager.recentlyClosedTabsFlattened)
                }

                ContextMenuActionsBuilder.ToggleIncognitoStateAction(tabManager: tabManager)

                ContextMenuActionsBuilder.NewTabAction(isIncognito: incognitoModel.isIncognito) {
                    bvc.openLazyTab(openedFrom: .newTabButton)
                }

                ContextMenuActionsBuilder.CloseTabAction {
                    tabManager.removeTab(tabManager.selectedTab)
                }

                if gridModel.numberOfTabsForCurrentState > 1 {
                    ContextMenuActionsBuilder.CloseAllTabsAction(tabManager: tabManager) {
                        bvc.gridModel.showConfirmCloseAllTabs = true
                    }
                }
            }
        }
    }
}
