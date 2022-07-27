// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

class SwitcherToolbarModel: ObservableObject {
    let tabManager: TabManager
    let openLazyTab: () -> Void
    let createNewSpace: () -> Void
    private let onMenuAction: (OverflowMenuAction) -> Void
    @Published var dragOffset: CGFloat? = nil

    init(
        tabManager: TabManager,
        openLazyTab: @escaping () -> Void,
        createNewSpace: @escaping () -> Void,
        onMenuAction: @escaping (OverflowMenuAction) -> Void
    ) {
        self.tabManager = tabManager
        self.openLazyTab = openLazyTab
        self.createNewSpace = createNewSpace
        self.onMenuAction = onMenuAction
    }

    func onToggleIncognito() {
        tabManager.toggleIncognitoMode(clearSelectedTab: false)
    }
}

/// The toolbar for the card grid/tab switcher
struct SwitcherToolbarView: View {
    let top: Bool

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    @State var presentingMenu: Bool = false
    @State private var action: OverflowMenuAction? = nil

    @Default(.currentTheme) var currentTheme

    var bvc: BrowserViewController {
        SceneDelegate.getBVC(with: toolbarModel.tabManager.scene)
    }

    var body: some View {
        let divider = Color.ui.adaptive.separator.frame(height: 1).ignoresSafeArea()
        VStack(spacing: 0) {
            if !top { divider }

            HStack(spacing: 0) {
                if top {
                    GridPicker(isInToolbar: true).fixedSize()
                    Spacer()
                }

                if top {
                    if gridModel.switcherState == .spaces {
                        TopBarSpaceFilterButton()
                            .tapTargetFrame()
                            .environmentObject(gridModel.spaceCardModel)
                    } else {
                        TopBarOverflowMenuButton(
                            changedUserAgent: bvc.tabManager.selectedTab?.showRequestDesktop,
                            onOverflowMenuAction: { action, view in
                                bvc.perform(overflowMenuAction: action, targetButtonView: view)
                            },
                            location: .cardGrid
                        )
                        .tapTargetFrame()
                        .environmentObject(bvc.chromeModel)
                        .environmentObject(bvc.locationModel)
                    }
                } else {
                    if gridModel.switcherState == .spaces {
                        TabToolbarButtons.SpaceFilter(weight: .medium) {
                            bvc.showModal(style: .grouped) {
                                SpacesFilterView()
                                    .environmentObject(gridModel.spaceCardModel)
                            }
                        }.tapTargetFrame()
                    } else {
                        TabToolbarButtons.OverflowMenu(
                            weight: .medium,
                            action: {
                                ClientLogger.shared.logCounter(
                                    .OpenOverflowMenu,
                                    attributes: EnvironmentHelper.shared.getAttributes()
                                )
                                // Refesh feedback screenshot before presenting overflow menu
                                bvc.updateFeedbackImage()
                                bvc.showModal(style: .nonScrollableMenu) {
                                    OverflowMenuOverlayContent(
                                        menuAction: { action in
                                            bvc.perform(
                                                overflowMenuAction: action,
                                                targetButtonView: nil)
                                        },
                                        changedUserAgent: bvc.tabManager.selectedTab?
                                            .showRequestDesktop,
                                        chromeModel: bvc.chromeModel,
                                        locationModel: bvc.locationModel,
                                        location: .cardGrid
                                    )
                                }
                            },
                            identifier: "SwitcherOverflowButton"
                        ).tapTargetFrame()
                    }
                }

                if !top {
                    Spacer()
                }

                Button {
                    switch gridModel.switcherState {
                    case .tabs:
                        toolbarModel.openLazyTab()
                        browserModel.hideGridWithNoAnimation()
                    case .spaces:
                        toolbarModel.createNewSpace()
                    }
                } label: {
                    Symbol(.plus, size: 20, weight: .medium, label: "Add Tab")
                }
                .tapTargetFrame()
                .contextMenu {
                    if bvc.tabManager.recentlyClosedTabsFlattened.count > 0 {
                        ContextMenuActionsBuilder.RecentlyClosedTabsAction(
                            tabManager: bvc.tabManager, fromTab: false)
                    }
                }
                .disabled(gridModel.switcherState != .tabs && !NeevaUserInfo.shared.isUserLoggedIn)
                .accentColor(.label)

                if !top {
                    Spacer()
                }

                Button {
                    switch gridModel.switcherState {
                    case .tabs:
                        browserModel.hideGridWithAnimation()
                    case .spaces:
                        browserModel.hideGridWithNoAnimation()
                    }
                } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                }
                .tapTargetFrame()
                .accentColor(tabModel.manager.selectedTab == nil ? .secondaryLabel : .label)
                .disabled(tabModel.manager.selectedTab == nil)
                .accessibilityIdentifier("TabTrayController.doneButton")
                .accessibilityValue(
                    Text(tabModel.manager.selectedTab == nil ? "Disabled" : "Enabled")
                )
                .padding(.horizontal, 10)  // a) Padding for contextMenu
                .contextMenu {
                    ContextMenuActionsBuilder.CloseAllTabsAction(tabManager: bvc.tabManager) {
                        gridModel.showConfirmCloseAllTabs = true
                    }
                }
                .padding(.horizontal, -10)  // Remove extra padding added in `a`
                .modifier(
                    MenuBuilder.ConfirmCloseAllTabsConfirmationDialog(
                        showMenu: $gridModel.showConfirmCloseAllTabs,
                        tabManager: browserModel.tabManager)
                )
                .allowsHitTesting(tabModel.manager.selectedTab != nil)
            }
            .padding(.horizontal, 16)
            .frame(
                height: top ? UIConstants.TopToolbarHeightWithToolbarButtonsShowing - 1 : nil)

            if top {
                divider
            } else {
                Spacer()
            }
        }
        .defaultBackgroundOrTheme(currentTheme)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Toolbar")
        .accessibilityHidden(gridModel.showingDetailView)
    }
}
