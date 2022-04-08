// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

// For sharing to work, this must currently be the BrowserViewController
protocol TopBarDelegate: ToolbarDelegate {
    func urlBarReloadMenu() -> UIMenu?
    func urlBarDidPressStop()
    func urlBarDidPressReload()
    func urlBarDidEnterOverlayMode()
    func urlBarDidLeaveOverlayMode()
    func urlBar(didSubmitText text: String, isSearchQuerySuggestion: Bool)

    func perform(menuAction: OverflowMenuAction)
    func updateFeedbackImage()

    var tabContainerModel: TabContainerModel { get }
    var tabManager: TabManager { get }
    var searchQueryModel: SearchQueryModel { get }
}

struct TopBarContent: View {
    let browserModel: BrowserModel
    let suggestionModel: SuggestionModel
    let model: LocationViewModel
    let queryModel: SearchQueryModel
    let gridModel: GridModel
    let trackingStatsViewModel: TrackingStatsViewModel
    let chromeModel: TabChromeModel
    let readerModeModel: ReaderModeModel
    var web3Model: Web3Model

    let newTab: () -> Void
    let onCancel: () -> Void

    var body: some View {
        TopBarView(
            performTabToolbarAction: { chromeModel.topBarDelegate?.performTabToolbarAction($0) },
            buildTabsMenu: { chromeModel.topBarDelegate?.tabToolbarTabsMenu(sourceView: $0) },
            onReload: {
                switch chromeModel.reloadButton {
                case .reload:
                    chromeModel.topBarDelegate?.urlBarDidPressReload()
                case .stop:
                    chromeModel.topBarDelegate?.urlBarDidPressStop()
                }
            },
            onSubmit: {
                chromeModel.topBarDelegate?.urlBar(
                    didSubmitText: $0, isSearchQuerySuggestion: false)
            },
            onShare: { shareView in
                // also update in LegacyTabToolbarHelper
                ClientLogger.shared.logCounter(
                    .ClickShareButton, attributes: EnvironmentHelper.shared.getAttributes())
                guard
                    let bvc = chromeModel.topBarDelegate as? BrowserViewController,
                    let tab = bvc.tabManager.selectedTab,
                    let url = tab.url
                else { return }
                if url.isFileURL {
                    bvc.share(fileURL: url, buttonView: shareView, presentableVC: bvc)
                } else {
                    bvc.share(tab: tab, from: shareView, presentableVC: bvc)
                }
            },
            buildReloadMenu: { chromeModel.topBarDelegate?.urlBarReloadMenu() },
            onMenuAction: { chromeModel.topBarDelegate?.perform(menuAction: $0) },
            newTab: newTab,
            onCancel: onCancel,
            onOverflowMenuAction: {
                chromeModel.topBarDelegate?.perform(overflowMenuAction: $0, targetButtonView: $1)
            }
        )
        .environmentObject(browserModel)
        .environmentObject(suggestionModel)
        .environmentObject(model)
        .environmentObject(queryModel)
        .environmentObject(gridModel)
        .environmentObject(trackingStatsViewModel)
        .environmentObject(chromeModel)
        .environmentObject(readerModeModel)
        .environmentObject(web3Model)
    }
}
