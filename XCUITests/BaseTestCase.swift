/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let serverPort = Int.random(in: 1025..<65000)

func path(forTestPage page: String) -> String {
    return "http://localhost:\(serverPort)/test-fixture/\(page)"
}

// see also `skipTest` in ClientTests, StorageTests, and UITests
func skipTest(issue: Int, _ message: String) throws {
    throw XCTSkip("#\(issue): \(message)")
}

class BaseTestCase: XCTestCase {
    let app = XCUIApplication()

    // leave empty for non-specific tests
    var specificForPlatform: UIUserInterfaceIdiom?

    // These are used during setUp(). Change them prior to setUp() for the app to launch with different args,
    // or, use restart() to re-launch with custom args.
    var launchArguments = [
        LaunchArguments.ClearProfile, LaunchArguments.SkipIntro, LaunchArguments.SetSignInOnce,
        LaunchArguments.SetDidFirstNavigation,
        LaunchArguments.SkipETPCoverSheet, LaunchArguments.DeviceName,
        "\(LaunchArguments.ServerPort)\(serverPort)", LaunchArguments.DisableCheatsheetBloomFilters,
    ]

    var testName: String {
        // Test name looks like: "[Class testFunc]", parse out the function name
        return String(name.split(separator: " ")[1].dropLast())
    }

    func setUpApp() {
        if !launchArguments.contains("NEEVA_PERFORMANCE_TEST") {
            app.launchArguments = [LaunchArguments.Test] + launchArguments
        } else {
            app.launchArguments = [LaunchArguments.PerformanceTest] + launchArguments
        }

        app.launch()
    }

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        if !skipPlatform {
            setUpApp()
        }
    }

    override func tearDown() {
        // Reset the previous UI state to create a standard testing environment.
        UserDefaults.standard.set("tab", forKey: "scenePreviousUIState")

        app.terminate()
        super.tearDown()
    }

    private var skipPlatform: Bool {
        guard let platform = specificForPlatform else { return false }
        return UIDevice.current.userInterfaceIdiom != platform
    }

    func skipIfNeeded() throws {
        try XCTSkipIf(skipPlatform, "Not on \(specificForPlatform!)")
    }

    func restart(_ app: XCUIApplication, args: [String] = []) {
        XCUIDevice.shared.press(.home)
        var launchArguments = [LaunchArguments.Test]
        args.forEach { arg in
            launchArguments.append(arg)
        }
        app.launchArguments = launchArguments
        app.activate()
    }

    func waitForExistence(
        _ element: XCUIElement, timeout: TimeInterval = 5.0, file: String = #file,
        line: UInt = #line
    ) {
        waitFor(element, with: "exists == true", timeout: timeout, file: file, line: line)
    }

    func waitForNoExistence(
        _ element: XCUIElement, timeoutValue: TimeInterval = 5.0, file: String = #file,
        line: UInt = #line
    ) {
        waitFor(element, with: "exists != true", timeout: timeoutValue, file: file, line: line)
    }

    func waitForHittable(
        _ element: XCUIElement, timeout: TimeInterval = 5.0, file: String = #file,
        line: UInt = #line
    ) {
        waitFor(element, with: "isHittable == true", timeout: timeout, file: file, line: line)
    }

    func waitForValueContains(
        _ element: XCUIElement, value: String, timeout: TimeInterval = 5.0, file: String = #file,
        line: UInt = #line
    ) {
        waitFor(
            element, with: "value CONTAINS '\(value)'", timeout: timeout, file: file, line: line)
    }

    func waitFor(
        _ element: NSObject, with predicateString: String, description: String? = nil,
        timeout: TimeInterval = 5.0, file: String = #file, line: UInt = #line
    ) {
        let predicate = NSPredicate(format: predicateString)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        if result != .completed {
            let message =
                description ?? "Expect predicate \(predicateString) for \(element.description)"
            self.record(XCTIssue(type: .assertionFailure, compactDescription: message))
        }
    }

    func iPad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }

    func waitUntilPageLoad() {
        let app = XCUIApplication()
        let progressIndicator = app.progressIndicators.element(boundBy: 0)

        waitForNoExistence(progressIndicator, timeoutValue: 20.0)
    }

    public func enterSearchText(
        _ text: String, fromTabTray: Bool = false, waitForPageLoad: Bool = true
    ) {
        // exploiting the openURL func because it just copies and pastes
        openURL(text, fromTabTray: fromTabTray, waitForPageLoad: waitForPageLoad)
    }

    public func openURL(
        _ url: String = "example.com", fromTabTray: Bool = false, waitForPageLoad: Bool = true
    ) {
        // If the tab tray is visible, then start a new tab.
        if app.buttons["Add Tab"].exists || fromTabTray {
            app.buttons["Add Tab"].tap()
            waitForExistence(app.buttons["Cancel"])
        }

        if !app.buttons["Cancel"].exists && !fromTabTray {
            goToAddressBar()
        }

        app.textFields["address"].typeText(url + " \n")

        if waitForPageLoad {
            waitUntilPageLoad()
            waitForExistence(app.buttons["Show Tabs"], timeout: 15)
        }
    }

    public func openURLInNewTab(_ url: String = "example.com") {
        newTab()
        openURL(url)
    }

    public func newTab() {
        if app.buttons["Add Tab"].exists {
            app.buttons["Add Tab"].tap()
        } else {
            waitForExistence(app.buttons["Show Tabs"], timeout: 30)
            app.buttons["Show Tabs"].press(forDuration: 1)

            if app.buttons["New Incognito Tab"].exists {
                app.buttons["New Incognito Tab"].tap()
            } else {
                waitForExistence(app.buttons["New Tab"], timeout: 30)
                app.buttons["New Tab"].tap()
            }

        }

        waitForExistence(app.buttons["Cancel"])
    }

    public func closeAllTabs(fromTabSwitcher: Bool = false, createNewTab: Bool = true) {
        if !fromTabSwitcher {
            waitForExistence(app.buttons["Show Tabs"], timeout: 3)
            app.buttons["Show Tabs"].tap()
        }

        waitForExistence(app.buttons["Done"], timeout: 3)
        app.buttons["Done"].press(forDuration: 1)

        let closeAllTabButton = app.buttons["Close All Tabs"]
        if closeAllTabButton.exists {
            closeAllTabButton.tap()
            waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
            app.buttons["Confirm Close All Tabs"].tap()
        } else {
            app.buttons["Close Tab"].tap()
        }

        if createNewTab {
            waitForExistence(app.buttons["Add Tab"])
            openURLInNewTab()
        }
    }

    /// Returns the number of open tabs
    public func getNumberOfTabs(openTabTray: Bool = true) -> Int {
        if openTabTray {
            goToTabTray()
        }

        func valueAsInt(_ name: String) -> Int {
            guard let numTabsString = app.otherElements[name].value as? String,
                let numTabs = Int(
                    numTabsString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .joined())
            else { return 0 }
            return numTabs
        }

        let numTabs: Int
        if app.buttons["Normal Tabs"].isSelected {
            numTabs = valueAsInt("Tabs")
        } else if app.buttons["Incognito Tabs"].isSelected {
            numTabs = valueAsInt("Incognito Tabs")
        } else {
            numTabs = 0
        }

        return numTabs
    }

    func tapCoordinate(at xCoordinate: Double, and yCoordinate: Double) {
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinate = normalized.withOffset(CGVector(dx: xCoordinate, dy: yCoordinate))
        coordinate.tap()
    }
}

class IpadOnlyTestCase: BaseTestCase {
    override func setUp() {
        specificForPlatform = .pad
        if iPad() {
            super.setUp()
        }
    }
}

class IphoneOnlyTestCase: BaseTestCase {
    override func setUp() {
        specificForPlatform = .phone
        if !iPad() {
            super.setUp()
        }
    }
}

extension BaseTestCase {
    func tabTrayButton(forApp app: XCUIApplication) -> XCUIElement {
        return app.buttons["Show Tabs"]
    }
}

extension BaseTestCase {
    // Copy url from the browser
    func copyUrl() {
        app.buttons["Address Bar"].tap()

        waitForExistence(app.buttons["Edit current address"])
        app.buttons["Edit current address"].press(forDuration: 1)

        waitForExistence(app.buttons["Copy Address"])
        app.buttons["Copy Address"].tap()
    }

    // Workaround for `copyUrl` and reading pasteboard on IOS 16
    // UIPasteboard prompt cannot be programmatically dismissed
    @available(iOS 16.0, *)
    func getTabURL() -> URL? {
        app.buttons["Address Bar"].tap()

        waitForExistence(app.buttons["Edit current address"])
        app.buttons["Edit current address"].tap()

        waitForExistence(app.textFields["address"])
        let urlField = app.textFields["address"]

        guard let urlString = urlField.value as? String else {
            return nil
        }

        return URL(string: urlString)
    }
}

extension XCUIElement {
    /*
     * Tap the element, regardless of whether it is "hittable" or not.
     * We deliberately avoid checking `isHittable`, which is sometimes problematic.
     * See this SO comment and related discussion:
     *
     * "In this case, checking self.isHittable as suggested was causing an infinite loop.
     * Skipping that if clause and directly calling coordinate.tap() fixed the issue."
     * https://stackoverflow.com/a/33534187
     */
    func tap(force: Bool = true) {
        if force {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        } else {
            tap()
        }
    }
}
