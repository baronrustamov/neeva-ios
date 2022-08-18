// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// For sharing to work, this must currently be the BrowserViewController
protocol TopBarDelegate: ToolbarDelegate {
    func urlBarDidPressStop()
    func urlBarDidPressReload()
    func urlBarDidEnterOverlayMode()
    func urlBarDidLeaveOverlayMode()
    func urlBar(didSubmitText text: String, isSearchQuerySuggestion: Bool)

    func perform(menuAction: OverflowMenuAction)

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
    var geom: GeometryProxy

    let newTab: () -> Void
    let onCancel: () -> Void

    var body: some View {
        topBarView(
            performTabToolbarAction: {
                chromeModel.topBarDelegate?.performTabToolbarAction($0)
            },
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
            onMenuAction: { chromeModel.topBarDelegate?.perform(menuAction: $0) },
            newTab: newTab,
            onCancel: onCancel,
            onOverflowMenuAction: {
                chromeModel.topBarDelegate?.perform(
                    overflowMenuAction: $0, targetButtonView: $1)
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

    @ViewBuilder func topBarView(
        performTabToolbarAction: @escaping (ToolbarAction) -> Void,
        onReload: @escaping () -> Void,
        onSubmit: @escaping (String) -> Void,
        onShare: @escaping (UIView) -> Void,
        onMenuAction: @escaping (OverflowMenuAction) -> Void,
        newTab: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onOverflowMenuAction: @escaping (OverflowMenuAction, UIView) -> Void
    ) -> some View {
        #if XYZ
            Web3TopBarView(
                performTabToolbarAction: performTabToolbarAction,
                onReload: onReload,
                onSubmit: onSubmit,
                onShare: onShare,
                onMenuAction: onMenuAction,
                newTab: newTab,
                onCancel: onCancel,
                onOverflowMenuAction: onOverflowMenuAction,
                geom: geom
            )
        #else
            TopBarView(
                performTabToolbarAction: performTabToolbarAction,
                onReload: onReload,
                onSubmit: onSubmit,
                onShare: onShare,
                onMenuAction: onMenuAction,
                newTab: newTab,
                onCancel: onCancel,
                onOverflowMenuAction: onOverflowMenuAction,
                geom: geom
            )
        #endif
    }
}
