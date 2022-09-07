/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

// Naming functions: use the suffix 'KeyCommand' for an additional level of namespacing (bug 1415830)
extension BrowserViewController {
    @objc func reloadTabKeyCommand() {
        if let tab = tabManager.selectedTab {
            tab.reload()
        }
    }

    @objc func goBackKeyCommand() {
        if let tab = tabManager.selectedTab, tab.canGoBack {
            tab.goBack()
        }
    }

    @objc func goForwardKeyCommand() {
        if let tab = tabManager.selectedTab, tab.canGoForward {
            tab.goForward()
        }
    }

    @objc func findInPageKeyCommand() {
        if let tab = tabManager.selectedTab {
            self.tab(tab, didSelectFindInPageForSelection: "")
        }
    }

    @objc func selectLocationBarKeyCommand() {
        browserModel.scrollingControlModel.showToolbars(animated: true)
        chromeModel.triggerOverlay()
        zeroQueryModel.targetTab = .currentTab
    }

    @objc func newTabKeyCommand() {
        openLazyTab(
            openedFrom: browserModel.contentVisibilityModel.showContent
                ? .openTab(tabManager.selectedTab) : .tabTray)
    }

    @objc func newIncognitoTabKeyCommand() {
        if !(incognitoModel.isIncognito) {
            tabManager.toggleIncognitoMode(openLazyTab: false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            openLazyTab(
                openedFrom: browserModel.contentVisibilityModel.showContent
                    ? .openTab(nil) : .tabTray)
        }
    }

    @objc func closeTabKeyCommand() {
        guard let currentTab = tabManager.selectedTab else {
            return
        }

        tabManager.removeTab(currentTab, showToast: true)
    }

    @objc func nextTabKeyCommand() {
        guard let currentTab = tabManager.selectedTab else {
            return
        }

        let tabs =
            incognitoModel.isIncognito ? tabManager.incognitoTabs : tabManager.activeNormalTabs
        if let index = tabs.firstIndex(of: currentTab), index + 1 < tabs.count {
            tabManager.selectTab(tabs[index + 1], notify: true)
        } else if let firstTab = tabs.first {
            tabManager.selectTab(firstTab, notify: true)
        }
    }

    @objc func previousTabKeyCommand() {
        guard let currentTab = tabManager.selectedTab else {
            return
        }

        let tabs =
            incognitoModel.isIncognito ? tabManager.incognitoTabs : tabManager.activeNormalTabs
        if let index = tabs.firstIndex(of: currentTab), index - 1 < tabs.count && index != 0 {
            tabManager.selectTab(tabs[index - 1], notify: true)
        } else if let lastTab = tabs.last {
            tabManager.selectTab(lastTab, notify: true)
        }
    }

    @objc func restoreTabKeyCommand() {
        if tabManager.recentlyClosedTabs.count > 0 {
            tabManager.restoreSavedTabs(tabManager.recentlyClosedTabs[0])
        }
    }

    @objc func closeAllTabsCommand() {
        if incognitoModel.isIncognito {
            tabManager.toggleIncognitoMode()

            // Wait for tabManager to switch to normal mode before closing private tabs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                tabManager.removeTabs(
                    tabManager.incognitoTabs, showToast: false)
            }
        } else {
            tabManager.removeTabs(tabManager.todaysTabs, showToast: true)
        }
    }

    @objc func showTabTrayKeyCommand() {
        showTabTray()
    }

    @objc func moveURLCompletionKeyCommand(sender: UIKeyCommand) {
        if let input = sender.input {
            suggestionModel.handleKeyboardShortcut(input: input)
        }
    }

    var keyboardShortcuts: [UIKeyCommand] {
        let searchLocationCommands = [
            UIKeyCommand(
                input: UIKeyCommand.inputUpArrow, modifierFlags: [],
                action: #selector(moveURLCompletionKeyCommand(sender:))),
            UIKeyCommand(
                input: UIKeyCommand.inputDownArrow, modifierFlags: [],
                action: #selector(moveURLCompletionKeyCommand(sender:))),
            UIKeyCommand(
                input: "\r", modifierFlags: [],
                action: #selector(moveURLCompletionKeyCommand(sender:))),
        ]

        if #available(iOS 15.0, *) {
            for command in searchLocationCommands {
                // Fixes a bug where Up/Down key commands weren't called
                command.wantsPriorityOverSystemBehavior = true
            }
        }

        let overidesTextEditing = [
            UIKeyCommand(
                input: UIKeyCommand.inputRightArrow, modifierFlags: [.command, .shift],
                action: #selector(nextTabKeyCommand)),
            UIKeyCommand(
                input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command, .shift],
                action: #selector(previousTabKeyCommand)),
            UIKeyCommand(
                input: UIKeyCommand.inputLeftArrow, modifierFlags: .command,
                action: #selector(goBackKeyCommand)),
            UIKeyCommand(
                input: UIKeyCommand.inputRightArrow, modifierFlags: .command,
                action: #selector(goForwardKeyCommand)),
        ]
        let tabNavigation = [
            UIKeyCommand(
                title: Strings.ReloadPageTitle, action: #selector(reloadTabKeyCommand), input: "r",
                modifierFlags: .command),
            UIKeyCommand(
                title: Strings.BackTitle, action: #selector(goBackKeyCommand), input: "[",
                modifierFlags: .command),
            UIKeyCommand(
                title: Strings.ForwardTitle, action: #selector(goForwardKeyCommand), input: "]",
                modifierFlags: .command),

            UIKeyCommand(
                title: Strings.FindTitle, action: #selector(findInPageKeyCommand), input: "f",
                modifierFlags: .command),
            UIKeyCommand(
                title: Strings.SelectLocationBarTitle,
                action: #selector(selectLocationBarKeyCommand), input: "l", modifierFlags: .command),
            UIKeyCommand(
                title: Strings.NewTabTitle, action: #selector(newTabKeyCommand), input: "t",
                modifierFlags: .command),
            UIKeyCommand(
                title: Strings.NewIncognitoTabTitle, action: #selector(newIncognitoTabKeyCommand),
                input: "p", modifierFlags: [.command]),
            UIKeyCommand(
                title: Strings.CloseTabTitle, action: #selector(closeTabKeyCommand), input: "w",
                modifierFlags: .command),
            UIKeyCommand(
                title: Strings.ShowNextTabTitle, action: #selector(nextTabKeyCommand), input: "\t",
                modifierFlags: .control),
            UIKeyCommand(
                title: Strings.ShowPreviousTabTitle, action: #selector(previousTabKeyCommand),
                input: "\t", modifierFlags: [.control, .shift]),

            UIKeyCommand(
                title: Strings.RestoreLastClosedTabsTitle, action: #selector(restoreTabKeyCommand),
                input: "t", modifierFlags: [.shift, .command]),
            UIKeyCommand(
                title: Strings.CloseAllTabsTitle, action: #selector(closeAllTabsCommand),
                input: "w", modifierFlags: [.shift, .command]),

            // Switch tab to match Safari on iOS.
            UIKeyCommand(
                input: "]", modifierFlags: [.command, .shift], action: #selector(nextTabKeyCommand)),
            UIKeyCommand(
                input: "[", modifierFlags: [.command, .shift],
                action: #selector(previousTabKeyCommand)),

            UIKeyCommand(
                input: "\\", modifierFlags: [.command, .shift],
                action: #selector(showTabTrayKeyCommand)),  // Safari on macOS
            UIKeyCommand(
                title: Strings.ShowTabTrayFromTabKeyCodeTitle,
                action: #selector(showTabTrayKeyCommand), input: "\t",
                modifierFlags: [.command, .alternate]),
        ]

        let isEditingText = tabManager.selectedTab?.isEditing ?? false

        if chromeModel.isEditingLocation {
            return tabNavigation + searchLocationCommands
        } else if !isEditingText {
            return tabNavigation + overidesTextEditing
        }

        return tabNavigation
    }

    override var keyCommands: [UIKeyCommand]? {
        return keyboardShortcuts
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension BrowserViewController {
    static var isCommandKeyPressed = false

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }

            if key.characters == "" && key.modifierFlags == .command {
                BrowserViewController.isCommandKeyPressed = true
            } else {
                BrowserViewController.isCommandKeyPressed = false
            }
        }

        super.pressesBegan(presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }

            if key.modifierFlags == .command {
                BrowserViewController.isCommandKeyPressed = false
            }
        }

        super.pressesEnded(presses, with: event)
    }
}
