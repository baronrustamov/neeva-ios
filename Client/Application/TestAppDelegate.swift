/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import SDWebImage
import Shared
import WebKit
import XCGLogger

private let log = Logger.browser

private func testURLString(for resource: String) -> String {
    "http://localhost:\(AppInfo.webserverPort)/test-fixture/\(resource)"
}

class MockUserInfoProvider: UserInfoProvider {
    override init() {
        super.init()
    }

    override func fetch(completion: @escaping (UserInfoResult) -> Void) {
        DispatchQueue.main.async {
            if !NeevaUserInfo.shared.hasLoginCookie() {
                completion(.failureAuthenticationError)
            } else {
                let userInfo = UserInfo(
                    id: "123456",
                    name: "Bob",
                    email: "bob@example.com",
                    pictureUrl: testURLString(for: ""),
                    authProvider: SSOProvider.okta.rawValue,
                    featureFlags: [],
                    userFlags: [],
                    subscriptionType: nil,
                    isVerified: true
                )
                completion(.success(userInfo))
            }
        }
    }
}

class TestAppDelegate: AppDelegate {
    lazy var dirForTestProfile = { "\(appRootDir())/profile.testProfile" }()

    override func createProfile() -> Profile {
        var profile: BrowserProfile
        let launchArguments = ProcessInfo.processInfo.arguments
        var loginCookie: String?
        var enableFeatureFlags: [FeatureFlag]?

        launchArguments.forEach { arg in
            if arg.starts(with: LaunchArguments.ServerPort) {
                let portString = arg.replacingOccurrences(of: LaunchArguments.ServerPort, with: "")
                if let port = Int(portString) {
                    AppInfo.webserverPort = port
                } else {
                    fatalError("Failed to set web server port override.")
                }
            }

            if arg.starts(with: LaunchArguments.LoadDatabasePrefix) {
                if launchArguments.contains(LaunchArguments.ClearProfile) {
                    fatalError(
                        "Clearing profile and loading a test database is not a supported combination."
                    )
                }

                // Grab the name of file in the bundle's test-fixtures dir, and copy it to the runtime app dir.
                let filename = arg.replacingOccurrences(
                    of: LaunchArguments.LoadDatabasePrefix, with: "")
                let input = URL(
                    fileURLWithPath: Bundle(for: TestAppDelegate.self).path(
                        forResource: filename, ofType: nil, inDirectory: "test-fixtures")!)
                try? FileManager.default.createDirectory(
                    atPath: dirForTestProfile, withIntermediateDirectories: false, attributes: nil)
                let output = URL(fileURLWithPath: "\(dirForTestProfile)/browser.db")
                let enumerator = FileManager.default.enumerator(atPath: dirForTestProfile)
                let filePaths = enumerator?.allObjects as! [String]
                filePaths.filter { $0.contains(".db") }.forEach { item in
                    try! FileManager.default.removeItem(
                        at: URL(fileURLWithPath: "\(dirForTestProfile)/\(item)"))
                }

                try! FileManager.default.copyItem(at: input, to: output)
            }

            if arg.starts(with: LaunchArguments.LoadTabsStateArchive) {
                if launchArguments.contains(LaunchArguments.ClearProfile) {
                    fatalError(
                        "Clearing profile and loading a TabsState.Archive is not a supported combination."
                    )
                }

                // Grab the name of file in the bundle's test-fixtures dir, and copy it to the runtime app dir.
                let filenameArchive = arg.replacingOccurrences(
                    of: LaunchArguments.LoadTabsStateArchive, with: "")
                let input = URL(
                    fileURLWithPath: Bundle(for: TestAppDelegate.self).path(
                        forResource: filenameArchive, ofType: nil, inDirectory: "test-fixtures")!)

                try? FileManager.default.createDirectory(
                    atPath: dirForTestProfile, withIntermediateDirectories: false, attributes: nil)
                let output = URL(fileURLWithPath: "\(dirForTestProfile)/tabsState.archive")
                let enumerator = FileManager.default.enumerator(atPath: dirForTestProfile)
                let filePaths = enumerator?.allObjects as! [String]
                filePaths.filter { $0.contains(".archive") }.forEach { item in
                    try! FileManager.default.removeItem(
                        at: URL(fileURLWithPath: "\(dirForTestProfile)/\(item)"))
                }

                try! FileManager.default.copyItem(at: input, to: output)
            }

            if arg.starts(with: LaunchArguments.SetLoginCookie) {
                loginCookie = arg.replacingOccurrences(of: LaunchArguments.SetLoginCookie, with: "")
            }

            if arg.starts(with: LaunchArguments.EnableFeatureFlags) {
                let flags = arg.replacingOccurrences(
                    of: LaunchArguments.EnableFeatureFlags, with: "")
                enableFeatureFlags = flags.components(separatedBy: ",").compactMap {
                    FeatureFlag(caseName: $0)
                }
            }
        }

        if launchArguments.contains(LaunchArguments.EnableMockAppHost) {
            NeevaConstants.appHost = "localhost"
            NeevaConstants.buildAppURL = { path in
                let page: String
                switch path {
                case "signin":
                    page = "mock-neeva-signin.html"
                case "":
                    page = "mock-neeva-home.html"
                default:
                    page = "mock-neeva-home.html?path=\(path)"
                }
                return URL(string: testURLString(for: page))!
            }
        }

        if launchArguments.contains(LaunchArguments.EnableMockUserInfo) {
            UserInfoProvider.shared = MockUserInfoProvider()
        }

        if launchArguments.contains(LaunchArguments.ClearProfile) {
            // Use a clean profile for each test session.
            log.debug("Deleting all files in 'Documents' directory to clear the profile")
            profile = BrowserProfile(localName: "testProfile", clear: true)
        } else {
            profile = BrowserProfile(localName: "testProfile")
        }

        // Don't show the What's New page.
        if launchArguments.contains(LaunchArguments.SkipWhatsNew) {
            Defaults[.lastVersionNumber] = "1"
        }

        // Skip the intro when requested by for example tests or automation
        if launchArguments.contains(LaunchArguments.SkipIntro) {
            Defaults[.introSeen] = true
        }

        if launchArguments.contains(LaunchArguments.ReactivateIntro) {
            Defaults[.introSeen] = false
        }

        if launchArguments.contains(LaunchArguments.ForceExperimentControlArm) {
            NeevaExperiment.forceExperimentArm(
                experiment: .defaultBrowserRemindMeLater,
                experimentArm: NeevaExperiment.DefaultBrowserRemindMeLater.control.rawValue)
        }

        // Set signInOnce
        if launchArguments.contains(LaunchArguments.SetSignInOnce) {
            Defaults[.signedInOnce] = true
        }

        // Set didFirstNavigation
        if launchArguments.contains(LaunchArguments.SetDidFirstNavigation) {
            Defaults[.didFirstNavigation] = true
        }

        if !launchArguments.contains(LaunchArguments.DontAddTabOnLaunch) {
            BrowserViewController.createNewTabOnStartForTesting = true
        }

        // Deferred to here in case the ClearProfile argument was set.
        if let loginCookie = loginCookie {
            NeevaUserInfo.shared.setLoginCookie(loginCookie)
        }

        if let enableFeatureFlags = enableFeatureFlags {
            FeatureFlag.enabledFlags = Set(enableFeatureFlags)
        }

        return profile
    }

    override func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // If the app is running from a XCUITest reset all settings in the app
        if ProcessInfo.processInfo.arguments.contains(LaunchArguments.ClearProfile) {
            resetApplication()
        }

        Tab.ChangeUserAgent.clear()

        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }

    /// Use this to reset the application between tests.
    func resetApplication() {
        log.debug("Wiping everything for a clean start.")

        // Clear login state
        NeevaUserInfo.shared.deleteLoginCookie()
        NeevaUserInfo.shared.clearCache()

        // Clear WebKit's storage (grumble, why no `All` option?)
        let webkitDataTypes = Set([
            WKWebsiteDataTypeFetchCache,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeWebSQLDatabases,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeServiceWorkerRegistrations,
        ])
        WKWebsiteDataStore.default().removeData(
            ofTypes: webkitDataTypes, modifiedSince: .distantPast, completionHandler: {})

        // Clear image cache
        SDImageCache.shared.clearDisk()
        SDImageCache.shared.clearMemory()

        // Clear the cookie/url cache
        URLCache.shared.removeAllCachedResponses()
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }

        // Clear the documents directory
        let rootPath = appRootDir()
        let manager = FileManager.default
        let documents = URL(fileURLWithPath: rootPath)
        let docContents = try! manager.contentsOfDirectory(atPath: rootPath)
        for content in docContents {
            do {
                try manager.removeItem(at: documents.appendingPathComponent(content))
            } catch {
                log.debug("Couldn't delete some document contents.")
            }
        }
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Speed up the animations to 100 times as fast.
        defer { application.keyWindow?.layer.speed = 100.0 }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func appRootDir() -> String {
        var rootPath = ""
        let sharedContainerIdentifier = AppInfo.sharedContainerIdentifier
        if let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: sharedContainerIdentifier)
        {
            rootPath = url.path
        } else {
            rootPath =
                (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        }
        return rootPath
    }
}
