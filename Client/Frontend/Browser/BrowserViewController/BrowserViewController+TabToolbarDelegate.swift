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
    case share
    case showZeroQuery
}

extension BrowserViewController: ToolbarDelegate {
    var performTabToolbarAction: (ToolbarAction) -> Void {
        { [weak self] action in
            guard let self = self else { return }
            let toolbarActionAttribute = ClientLogCounterAttribute(
                key: LogConfig.UIInteractionAttribute.fromActionType,
                value: String(describing: ToolbarAction.self)
            )
            switch action {
            case .back:
                ClientLogger.shared.logCounter(
                    .ClickBack,
                    attributes: EnvironmentHelper.shared.getAttributes() + [toolbarActionAttribute]
                )
                if self.simulatedSwipeModel.goBack() {
                    return
                }

                self.tabManager.selectedTab?.goBack()
            case .forward:
                ClientLogger.shared.logCounter(
                    .ClickForward,
                    attributes: EnvironmentHelper.shared.getAttributes() + [toolbarActionAttribute]
                )
                if self.simulateForwardModel.goForward() {
                    return
                }

                self.tabManager.selectedTab?.goForward()
            case .reloadStop:
                if self.chromeModel.reloadButton == .reload {
                    ClientLogger.shared.logCounter(
                        .TapReload,
                        attributes: EnvironmentHelper.shared.getAttributes() + [
                            toolbarActionAttribute
                        ]
                    )
                    self.tabManager.selectedTab?.reload()
                } else {
                    ClientLogger.shared.logCounter(
                        .TapStopReload,
                        attributes: EnvironmentHelper.shared.getAttributes() + [
                            toolbarActionAttribute
                        ]
                    )
                    self.tabManager.selectedTab?.stop()
                }
            case .overflow:
                ClientLogger.shared.logCounter(
                    .OpenOverflowMenu,
                    attributes: EnvironmentHelper.shared.getAttributes() + [toolbarActionAttribute]
                )
                self.updateFeedbackImage()
                self.showModal(style: .nonScrollableMenu) {
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
                ClientLogger.shared.logCounter(
                    .LongPressForward,
                    attributes: EnvironmentHelper.shared.getAttributes() + [toolbarActionAttribute]
                )
                self.showBackForwardList()
            case .addToSpace:
                guard let tab = self.tabManager.selectedTab else { return }
                tab.showAddToSpacesSheet()

                ClientLogger.shared.logCounter(
                    .ClickAddToSpaceButton,
                    attributes: EnvironmentHelper.shared.getAttributes() + [toolbarActionAttribute]
                )

            case .showTabs:
                self.showTabTray()
            case .share:
                self.showShareSheet(buttonView: self.view)
            case .showZeroQuery:
                self.showZeroQuery()
            }
            if action != .showZeroQuery,
                self.tabContainerModel.currentContentUI == .zeroQuery
                    || self.tabContainerModel.currentContentUI == .suggestions
            {
                self.hideZeroQuery()
            }
        }
    }

    func tabToolbarTabsMenu(sourceView: UIView) -> UIMenu? {
        guard self.presentedViewController == nil else {
            return nil
        }

        let switchPrivacyMode = { [self] (_: UIAction) in
            tabManager.toggleIncognitoMode(
                fromTabTray: false, clearSelectedTab: false, selectNewTab: true)
        }

        var switchModeTitle = Strings.openIncognitoModeTitle
        var switchModeImage: UIImage? = UIImage(named: "incognito")?.withTintColor(
            .label, renderingMode: .alwaysOriginal)

        var newTabTitle = Strings.NewTabTitle
        var newTabImage = UIImage(systemSymbol: .plusSquare)
        var newTabAccessibilityLabel = "New Tab"

        if incognitoModel.isIncognito {
            switchModeTitle = Strings.leaveIncognitoModeTitle
            switchModeImage = UIImage(named: "incognitoSlash")?.withTintColor(
                .label, renderingMode: .alwaysOriginal)

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

        var actions: [UIMenuElement] = [newTabAction, switchModeAction]

        let tabCount =
            incognitoModel.isIncognito
            ? tabManager.incognitoTabs.count : tabManager.normalTabs.count

        if self.tabManager.selectedTab != nil && tabCount > 0 {
            let closeTabAction = UIAction(
                title: Strings.CloseTabTitle, image: UIImage(systemSymbol: .xmark)
            ) { _ in
                if let tab = self.tabManager.selectedTab {
                    self.tabManager.removeTab(tab, showToast: false)
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

        let recentlyClosedTabsMenu = gridModel.buildRecentlyClosedTabsMenu()
        actions.append(
            UIMenu(
                title: "Recently Closed Tabs",
                image: UIImage(systemName: "trash.square"),
                children: recentlyClosedTabsMenu.children
            ))

        Haptics.longPress()

        return UIMenu(children: actions)
    }
}
