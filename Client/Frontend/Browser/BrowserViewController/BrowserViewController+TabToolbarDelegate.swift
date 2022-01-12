/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Shared
import SwiftUI

enum ToolbarAction {
    case back
    case forward
    case reloadStop
    case overflow
    case longPressBackForward
    case addToSpace
    case showTabs
    case showPreference
    case share
}

extension BrowserViewController: ToolbarDelegate {
    var performTabToolbarAction: (ToolbarAction) -> Void {
        { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .back:
                if self.simulateBackViewController?.goBack() ?? false {
                    return
                }

                self.tabManager.selectedTab?.goBack()
            case .forward:
                if self.simulateBackViewController?.goForward() ?? false {
                    return
                }

                self.tabManager.selectedTab?.goForward()
            case .reloadStop:
                if self.chromeModel.reloadButton == .reload {
                    self.tabManager.selectedTab?.reload()
                } else {
                    self.tabManager.selectedTab?.stop()
                }
            case .overflow:
                self.showModal(style: .grouped) {
                    OverflowMenuOverlayContent(
                        menuAction: { action in
                            self.perform(overflowMenuAction: action, targetButtonView: nil)
                        },
                        changedUserAgent: self.tabManager.selectedTab?.showRequestDesktop,
                        chromeModel: self.chromeModel,
                        locationModel: self.locationModel,
                        location: .tab
                    )
                }

                self.dismissVC()
            case .longPressBackForward:
                self.showBackForwardList()
            case .addToSpace:
                guard let tab = self.tabManager.selectedTab else { return }
                guard let url = tab.canonicalURL?.displayURL else { return }

                if FeatureFlag[.spacify],
                    let domain = SpaceImportDomain(rawValue: tab.url?.baseDomain ?? "")
                {
                    tab.webView?.evaluateJavaScript(domain.script) {
                        [weak self] (result, error) in
                        guard let self = self else { return }
                        guard let linkData = result as? [[String]] else {
                            self.showAddToSpacesSheet(
                                url: url, title: tab.title, webView: tab.webView!)
                            return
                        }

                        let importData = SpaceImportHandler(
                            title: tab.url!.path.remove("/").capitalized, data: linkData)
                        self.showAddToSpacesSheet(
                            url: url, title: tab.title,
                            webView: tab.webView!,
                            importData: importData
                        )
                    }
                } else {
                    self.showAddToSpacesSheet(url: url, title: tab.title, webView: tab.webView!)
                }
                ClientLogger.shared.logCounter(
                    .ClickAddToSpaceButton, attributes: EnvironmentHelper.shared.getAttributes())

            case .showTabs:
                self.showTabTray()
            case .showPreference:
                if let tabUUID = self.tabManager.selectedTab?.tabUUID,
                    let url = self.tabManager.selectedTab?.url?.absoluteString
                {
                    RecipeCheatsheetLogManager.shared.logInteraction(
                        logType: .clickPreferredProvider, tabUUIDAndURL: tabUUID + url)
                }
                // Set up preferred provider list
                let providerList = ProviderList.shared
                if !providerList.isLoading {
                    providerList.fetchProviderList()
                }

                guard let toastViewManager = self.getSceneDelegate()?.toastViewManager else {
                    return
                }
                self.showModal(style: .spaces) {
                    SetPreferredProviderContent(
                        chromeModel: self.chromeModel,
                        toastViewManager: toastViewManager,
                        tabUUID: self.tabManager.selectedTab?.tabUUID
                    )
                }
                break
            case .share:
                self.showShareSheet(buttonView: self.topBar.view)
            }

            self.hideZeroQuery()
        }
    }

    func tabToolbarTabsMenu(sourceView: UIView) -> UIMenu? {
        guard self.presentedViewController == nil else {
            return nil
        }

        let switchPrivacyMode = { [self] (_: UIAction) in
            tabManager.toggleIncognitoMode(fromTabTray: false)
        }

        var switchModeTitle = Strings.openIncognitoModeTitle
        var switchModeImage: UIImage? = UIImage(named: "incognito")

        var newTabTitle = Strings.NewTabTitle
        var newTabImage = UIImage(systemSymbol: .plusSquare)
        var newTabAccessibilityLabel = "New Tab"

        if tabManager.isIncognito {
            switchModeTitle = Strings.leaveIncognitoModeTitle
            switchModeImage = nil

            newTabTitle = Strings.NewIncognitoTabTitle
            newTabImage = UIImage(systemSymbol: .plusSquareFill)
            newTabAccessibilityLabel = "New Incognito Tab"
        }

        let switchModeAction = UIAction(
            title: switchModeTitle,
            image: switchModeImage,
            handler: switchPrivacyMode)
        let newTabAction = UIAction(title: newTabTitle, image: newTabImage) { _ in
            DispatchQueue.main.async {
                self.openLazyTab(openedFrom: .newTabButton)
            }
        }
        newTabAction.accessibilityLabel = newTabAccessibilityLabel

        var actions = [newTabAction, switchModeAction]

        let tabCount =
            tabManager.isIncognito
            ? tabManager.privateTabs.count : tabManager.normalTabs.count

        if self.tabManager.selectedTab != nil && tabCount > 0 {
            let closeTabAction = UIAction(
                title: Strings.CloseTabTitle, image: UIImage(systemSymbol: .xmark)
            ) { _ in
                if let tab = self.tabManager.selectedTab {
                    self.tabManager.removeTabAndUpdateSelectedTab(tab)
                }
            }
            closeTabAction.accessibilityIdentifier = "Close Tab Action"
            actions.insert(closeTabAction, at: 0)
        }

        if tabCount > 1 {
            actions.insert(
                TabMenu(tabManager: tabManager).createCloseAllTabsAction(sourceView: sourceView),
                at: 0)
        }

        Haptics.longPress()

        return UIMenu(sections: [actions])
    }
}
