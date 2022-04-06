// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

public enum OverflowMenuAction {
    case forward
    case reloadStop
    case newTab
    case findOnPage
    case textSize
    case desktopSite
    case share
    case downloadPage
    case longPressForward
    case toggleIncognitoMode
    case goToSettings
    case goToHistory
    case goToDownloads
    case closeAllTabs
    case support(screenshot: UIImage? = nil)
    case cryptoWallet
}

extension BrowserViewController {
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?) {
        overlayManager.hideCurrentOverlay()
        let overflowMenuAttribute = ClientLogCounterAttribute(
            key: LogConfig.UIInteractionAttribute.fromActionType,
            value: String(describing: OverflowMenuAction.self)
        )

        switch overflowMenuAction {
        case .forward:
            ClientLogger.shared.logCounter(
                .ClickForward,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )

            if simulateForwardModel.goForward() {
                return
            }

            tabManager.selectedTab?.goForward()
        case .reloadStop:
            if chromeModel.reloadButton == .reload {
                ClientLogger.shared.logCounter(
                    .TapReload,
                    attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
                )
                tabManager.selectedTab?.reload()
            } else {
                ClientLogger.shared.logCounter(
                    .TapStopReload,
                    attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
                )
                tabManager.selectedTab?.stop()
            }
        case .newTab:
            ClientLogger.shared.logCounter(
                .ClickNewTabButton,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            openLazyTab(openedFrom: .newTabButton)
        case .findOnPage:
            ClientLogger.shared.logCounter(
                .ClickFindOnPage,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            updateFindInPageVisibility(visible: true)
        case .textSize:
            ClientLogger.shared.logCounter(
                .ClickTextSize,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            if let webView = tabManager.selectedTab?.webView {
                UserActivityHandler.presentTextSizeView(
                    webView: webView)
            }
        case .desktopSite:
            ClientLogger.shared.logCounter(
                .ClickRequestDesktop,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            if let tab = tabManager.selectedTab,
                let url = tab.url
            {
                tab.toggleChangeUserAgent()
                Tab.ChangeUserAgent.updateDomainList(
                    forUrl: url, isChangedUA: tab.changedUserAgent,
                    isIncognito: tab.isIncognito)
            }
        case .share:
            ClientLogger.shared.logCounter(
                .ClickShareButton,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            showShareSheet(buttonView: targetButtonView ?? view)
        case .downloadPage:
            ClientLogger.shared.logCounter(
                .ClickDownloadPage,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            guard let selectedTab = tabManager.selectedTab, let url = selectedTab.url else {
                return
            }

            if !DownloadContentScript.requestBlobDownload(url: url, tab: selectedTab) {
                self.pendingDownloadWebView = selectedTab.webView
                let request = URLRequest(url: url)
                selectedTab.webView?.load(request)
            }
        case .longPressForward:
            ClientLogger.shared.logCounter(
                .LongPressForward,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            self.showBackForwardList()
        case .toggleIncognitoMode:
            self.browserModel.switcherToolbarModel.onToggleIncognito()
        case .goToSettings:
            ClientLogger.shared.logCounter(
                .OpenSetting,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )

            openSettings()
        case .goToHistory:
            ClientLogger.shared.logCounter(
                .OpenHistory,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            let historyPanel = HistoryPanel(profile: profile)
            historyPanel.delegate = self
            historyPanel.accessibilityLabel = "History Panel"

            let navigationController = UINavigationController(rootViewController: historyPanel)
            navigationController.modalPresentationStyle = .formSheet

            present(navigationController, animated: true, completion: nil)
        case .goToDownloads:
            ClientLogger.shared.logCounter(
                .OpenDownloads,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            openDownloadsFolderInFilesApp()
        case .closeAllTabs:
            ClientLogger.shared.logCounter(
                .ClickCloseAllTabs,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            TabMenu(tabManager: tabManager).showConfirmCloseAllTabs(sourceView: targetButtonView)
        case .support(let image):
            // This will log twice.
            ClientLogger.shared.logCounter(
                .OpenSendFeedback,
                attributes: EnvironmentHelper.shared.getAttributes() + [overflowMenuAttribute]
            )
            showFeedbackPanel(bvc: self, screenshot: image ?? self.feedbackImage)
        case .cryptoWallet:
            web3Model.showWalletPanel()
        }
    }
}
