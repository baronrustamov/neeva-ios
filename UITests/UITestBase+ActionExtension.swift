// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit

@testable import Client

extension UITestBase {
    // MARK: - Tab & URL
    func closeAllTabs() {
        SceneDelegate.getBVC(for: nil).closeAllTabsCommand()
    }

    func openNewTab(to url: String = "example.com ") {
        if tester().viewExistsWithLabel("Done") {
            tester().tapView(withAccessibilityLabel: "Add Tab")
        } else {
            tester().waitForView(withAccessibilityLabel: "Show Tabs")
            tester().longPressView(withAccessibilityLabel: "Show Tabs", duration: 1)

            if tester().viewExistsWithLabel("New Tab") {
                tester().tapView(withAccessibilityLabel: "New Tab")
            } else {
                tester().tapView(withAccessibilityLabel: "New Incognito Tab")
            }
        }

        tester().waitForAnimationsToFinish()
        openURL(url)
    }

    func openURL(_ url: String = "example.com ", forceSkipAddressBar: Bool = false) {
        if !tester().viewExistsWithLabel("Cancel") && !forceSkipAddressBar {
            goToAddressBar()
        }

        let textField =
            tester().waitForView(withAccessibilityLabel: "Address and Search") as! UITextField
        textField.text = url
        textField.resignFirstResponder()
        _ = textField.delegate?.textFieldShouldReturn!(textField)
    }

    // MARK: - Data
    func clearPrivateData(_ clearables: [Clearable] = Clearable.allCases) {
        goToClearData()

        let clearables = Set(clearables)
        for clearable in UITestBase.AllClearables {
            tester().setOn(
                clearables.contains(clearable), forSwitchWithAccessibilityLabel: clearable.label())
        }

        tester().tapView(withAccessibilityLabel: "Clear Selected Data on This Device")
        tester().waitForView(withAccessibilityLabel: "Clear Data")
        tester().tapView(withAccessibilityLabel: "Clear Data")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Clear Data")

        closeClearPrivateData()
    }

    func clearPrivateData(excluding clearablesToExclude: [Clearable]) {
        clearPrivateData(Clearable.allCases.filter { !clearablesToExclude.contains($0) })
    }

    func closeClearPrivateData() {
        tester().tapView(withAccessibilityLabel: "Settings")
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Show Tabs")
    }

    // MARK: - History
    func clearHistoryItems(numberOfTests: Int = -1) {
        goToHistory()

        let historyTable =
            tester().waitForView(withAccessibilityIdentifier: "History List") as! UITableView

        var index = 0
        for _ in 0..<historyTable.numberOfSections {
            for _ in 0..<historyTable.numberOfRows(inSection: 0) {
                clearHistoryItemAtIndex(IndexPath(row: 0, section: 0))
                if numberOfTests > -1 {
                    index += 1
                    if index == numberOfTests {
                        return
                    }
                }
            }
        }

        closeHistory()
    }

    func clearHistoryItemAtIndex(_ index: IndexPath) {
        if let row = tester().waitForCell(
            at: index, inTableViewWithAccessibilityIdentifier: "History List")
        {
            tester().swipeView(
                withAccessibilityLabel: row.accessibilityLabel, value: row.accessibilityValue,
                in: KIFSwipeDirection.left)
            tester().tapView(withAccessibilityLabel: "Remove")
        }
    }

    func closeHistory() {
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Show Tabs")
    }
}
