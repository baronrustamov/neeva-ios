/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI
import Defaults

extension BrowserViewController: TabToolbarDelegate, PhotonActionSheetProtocol {
    func tabToolbarDidPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        if simulateBackViewController?.goBack() ?? false {
            return
        }

        tabManager.selectedTab?.goBack()
    }

    func tabToolbarDidLongPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }

    func tabToolbarDidPressReload(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.reload()
    }

    func tabToolbarReloadMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) -> UIMenu? {
        guard let tab = tabManager.selectedTab else {
            return nil
        }
        return self.getRefreshLongPressMenu(for: tab)
    }

    func tabToolbarDidPressStop(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.stop()
    }

    func tabToolbarDidPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        if simulateForwardViewController?.goForward() ?? false {
            return
        }

        tabManager.selectedTab?.goForward()
    }

    func tabToolbarDidLongPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }

    func tabToolbarDidPressLibrary(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        if let libraryDrawerViewController = self.libraryDrawerViewController, libraryDrawerViewController.isOpen {
            libraryDrawerViewController.close()
        } else {
            showLibrary()
        }
    }
    
    func tabToolbarDidPressAddNewTab(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        tabManager.selectTab(tabManager.addTab(nil, isPrivate: isPrivate))
        focusLocationTextField(forTab: tabManager.selectedTab)
    }
    
    func tabToolbarSpacesMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard let tab = tabManager.selectedTab else { return }
        guard let url = tab.canonicalURL?.displayURL else { return }
        showAddToSpacesSheet(url: url, title: tab.title, webView: tab.webView!)
    }
    
    func tabToolbarDidPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        showTabTray()
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .tabToolbar, value: .tabView)
    }

    func getTabToolbarLongPressActionsForModeSwitching() -> [UIMenuElement] {
        guard let selectedTab = tabManager.selectedTab else { return [] }
        let count = selectedTab.isPrivate ? tabManager.normalTabs.count : tabManager.privateTabs.count

        func action() {
            _ = tabManager.switchPrivacyMode()
        }

        let icon: UIImage?
        if count <= 50 {
                    icon = UIImage(systemName: "\(count).square")
        } else {
            // ideally this would be infinity.square but there is no such icon
            let img = UIImage(systemName: "8.square")!
            icon = UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .left)
        }

        let privateBrowsingMode = UIAction(title: Strings.incognitoBrowsingModeTitle, image: icon) { _ in
            action()
        }
        let normalBrowsingMode = UIAction(title: Strings.normalBrowsingModeTitle, image: icon) { _ in
            action()
        }

        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [normalBrowsingMode] : [privateBrowsingMode]
        }
        return [privateBrowsingMode]
    }

    func showConfirmCloseAllTabs(numberOfTabs: Int) {
        let actionSheet = UIAlertController(title: nil, message: "Are you sure you want to close all open tabs?", preferredStyle: .actionSheet)
        let closeAction = UIAlertAction(title: "Close \(numberOfTabs) Tabs", style: .destructive) { _ in
            self.tabManager.removeAllTabsAndAddNormalTab()
            self.neevaHomeViewController?.homeViewModel.isPrivate = self.tabManager.selectedTab!.isPrivate
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // add all actions to alert
        actionSheet.addAction(closeAction)
        actionSheet.addAction(cancelAction)

        // show the alert
        self.present(actionSheet, animated: true, completion: nil)
    }

    func getMoreTabToolbarLongPressActions() -> [UIMenuElement] {
        let tabCount = self.tabManager.tabs.count

        let newTab = UIAction(title: Strings.NewTabTitle, image: UIImage(systemName: "plus.square")) { _ in
            self.openBlankNewTab(focusLocationField: false, isPrivate: false)
        }
        let newIncognitoTab = UIAction(title: Strings.NewIncognitoTabTitle, image: UIImage.templateImageNamed("incognito")) { _ in
            self.openBlankNewTab(focusLocationField: false, isPrivate: true)
        }
        let closeTab = UIAction(title: Strings.CloseTabTitle, image: UIImage(systemName: "xmark"), attributes: .destructive) { _ in
            if let tab = self.tabManager.selectedTab {
                self.tabManager.removeTabAndUpdateSelectedIndex(tab)
                self.neevaHomeViewController?.homeViewModel.isPrivate = self.tabManager.selectedTab!.isPrivate
            }
        }
        let closeAllTabs = UIAction(title: Strings.CloseAllTabsTitle, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            // make sure the user really wants to close all tabs
            self.showConfirmCloseAllTabs(numberOfTabs: tabCount)
        }

        var actions = [newTab]

        if let tab = self.tabManager.selectedTab {
            actions = tab.isPrivate ? [newIncognitoTab] : [newTab]
            
            if tabCount > 1 || !tab.isURLStartingPage {
                actions.append(closeTab)
            }
        }

        if tabCount > 1 {
            actions.append(closeAllTabs)
        }

        return actions
    }

    func tabToolbarTabsMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) -> UIMenu? {
        guard self.presentedViewController == nil else {
            return nil
        }
        var actions: [[UIMenuElement]] = []
        actions.append(getTabToolbarLongPressActionsForModeSwitching())
        actions.append(getMoreTabToolbarLongPressActions())

        return UIMenu(sections: actions)
    }

    func showBackForwardList() {
        if let backForwardList = tabManager.selectedTab?.webView?.backForwardList {
            let backForwardViewController = BackForwardListViewController(profile: profile, backForwardList: backForwardList)
            backForwardViewController.tabManager = tabManager
            backForwardViewController.bvc = self
            backForwardViewController.modalPresentationStyle = .overCurrentContext
            backForwardViewController.backForwardTransitionDelegate = BackForwardListAnimator()
            self.present(backForwardViewController, animated: true, completion: nil)
        }
    }

    func tabToolbarDidPressSearch(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        focusLocationTextField(forTab: tabManager.selectedTab)
    }
}
