// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import SwiftUI

struct TopBarNeevaButton: View {
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var chromeModel: TabChromeModel

    // TODO: sync this state variable with TabToolbarView somehow
    @State private var presenting = false
    @State private var action: OverflowMenuAction?

    let onMenuAction: (OverflowMenuAction) -> Void

    static private let neevaIconWidth: CGFloat = 24

    var body: some View {
        // button to open cheatsheet
        neevaButton
    }

    @ViewBuilder
    private var neevaButton: some View {
        TabToolbarButtons.Neeva(iconWidth: Self.neevaIconWidth) {
            ClientLogger.shared.logCounter(
                .OpenCheatsheet,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
            chromeModel.clearCheatsheetPopoverFlags()
            if let bvc = chromeModel.topBarDelegate as? BrowserViewController {
                bvc.showCheatSheetOverlay()
            }
        }
        .tapTargetFrame()
        .presentAsPopover(
            isPresented: $chromeModel.showTryCheatsheetPopover,
            backgroundColor: CheatsheetTooltipPopoverView.backgroundColor,
            dismissOnTransition: true
        ) {
            CheatsheetTooltipPopoverView()
                .frame(maxWidth: 270)
        }
        .disabled(!chromeModel.isPage || chromeModel.isErrorPage)
    }
}

struct TopBarOverflowMenuButton: View {
    let changedUserAgent: Bool?
    let onOverflowMenuAction: (OverflowMenuAction, UIView) -> Void
    let location: OverflowMenuLocation

    @EnvironmentObject var incognitoModel: IncognitoModel

    // TODO: sync this state variable with TabToolbarView somehow
    @State private var presenting = false
    @State private var action: OverflowMenuAction?
    @State private var targetButtonView: UIView!

    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var locationModel: LocationViewModel

    @ViewBuilder
    var content: some View {
        ScrollView {
            if location == .tab {
                OverflowMenuView(
                    changedUserAgent: changedUserAgent ?? false,
                    menuAction: {
                        action = $0
                        presenting = false
                    }
                )
            } else {
                CardGridOverflowMenuView(
                    changedUserAgent: changedUserAgent ?? false,
                    menuAction: {
                        action = $0
                        presenting = false
                    }
                )
            }
        }.padding(.vertical, 24)
    }

    var body: some View {
        TabToolbarButtons.OverflowMenu(
            weight: .regular,
            action: {
                // Refesh feedback screenshot before presenting overflow menu
                if let tabManager = chromeModel.topBarDelegate?.tabManager {
                    SceneDelegate.getBVC(with: tabManager.scene).updateFeedbackImage()
                }
                presenting = true
                chromeModel.hideZeroQuery()
            },
            identifier: "TopBarOverflowButton"
        )
        .uiViewRef($targetButtonView)
        .tapTargetFrame()
        .presentAsPopover(
            isPresented: $presenting,
            arrowDirections: .up,
            dismissOnTransition: true,
            onDismiss: {
                if let action = action {
                    onOverflowMenuAction(action, targetButtonView)
                    self.action = nil
                }
            }
        ) {
            content
                .environmentObject(chromeModel)
                .environmentObject(incognitoModel)
                .environmentObject(locationModel)
                .topBarPopoverPadding(removeBottomPadding: false)
                .frame(minWidth: 340, minHeight: 350)
        }
    }
}

struct TopBarSpaceFilterButton: View {
    @EnvironmentObject var spaceCardModel: SpaceCardModel
    @State private var presenting = false

    var body: some View {
        TabToolbarButtons.SpaceFilter(weight: .regular) {
            presenting = true
        }
        .tapTargetFrame()
        .presentAsPopover(
            isPresented: $presenting,
            arrowDirections: .up,
            dismissOnTransition: true,
            onDismiss: {
                presenting = false
            }
        ) {
            VerticalScrollViewIfNeeded {
                SpacesFilterView()
                    .topBarPopoverPadding()
                    .environmentObject(spaceCardModel)
            }.frame(minWidth: 325, minHeight: 128)
        }
    }
}

/// see also `LocationViewShareButton`
struct TopBarShareButton: View {
    let url: URL?
    let onTap: (UIView) -> Void

    @State private var shareTargetView: UIView!
    @EnvironmentObject private var chromeModel: TabChromeModel

    var body: some View {
        TabToolbarButton(
            label: Symbol(.squareAndArrowUp, size: 20, label: "Share"),
            action: {
                onTap(shareTargetView)
            }
        )
        .uiViewRef($shareTargetView)
        .disabled(url == nil || !chromeModel.isPage)
    }
}

struct TopBarShareButton_Previews: PreviewProvider {
    static var previews: some View {
        TopBarShareButton(url: nil, onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))
        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: false))

        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))

        TopBarNeevaButton(onMenuAction: { _ in })
            .environmentObject(TabChromeModel())
    }
}

extension View {
    func topBarPopoverPadding(
        removeBottomPadding: Bool = true, removeHorizontalPadding: Bool = true
    ) -> some View {
        self
            .padding(.horizontal, removeHorizontalPadding ? -4 : 4)
            .padding(.top, 8)
            .padding(.bottom, removeBottomPadding ? -8 : 0)
    }
}
