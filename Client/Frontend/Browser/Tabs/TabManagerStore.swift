/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import XCGLogger

private let log = Logger.storage

class TabManagerStore {
    static let shared = TabManagerStore(
        imageStore: DiskImageStore(
            files: getAppDelegate().profile.files, namespace: "TabManagerScreenshots",
            quality: UIConstants.ScreenshotQuality))

    let imageStore: DiskImageStore?
    fileprivate var fileManager = FileManager.default
    private var backgroundFileWriters: [String: BackgroundFileWriter] = [:]

    init(imageStore: DiskImageStore?, _ fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        self.imageStore = imageStore
    }

    fileprivate func getBasePath() -> String? {
        if AppConstants.IsRunningTest || AppConstants.IsRunningPerfTest {
            return (UIApplication.shared.delegate as? TestAppDelegate)?.dirForTestProfile
        } else {
            return (UIApplication.shared.delegate as? AppDelegate)?.profile.files.rootPath
        }
    }

    fileprivate func fallbackTabsPath() -> String? {
        guard let path = getBasePath() else { return nil }
        return URL(fileURLWithPath: path).appendingPathComponent("tabsState.archive").path
    }

    fileprivate func tabSavePath(withId sceneId: String) -> String? {
        guard let path = getBasePath() else { return nil }
        let url = URL(fileURLWithPath: path).appendingPathComponent("tabsState.archive-\(sceneId)")
        return url.path
    }

    /// - Parameters:
    ///  - update existingSavedTabs: A collection of SavedTab objects whose screenshot images need to be updated in image store. These tabs are not included in the return value.
    fileprivate func prepareSavedTabs(
        fromTabs tabs: [Tab],
        fromArchivedTabs archivedTabs: [ArchivedTab],
        update existingSavedTabs: [SavedTab],
        selectedTab: Tab?
    ) -> [SavedTab]? {
        var savedTabs = [SavedTab]()
        var screenshots: [DiskImageStore.Entry] = []

        for tab in archivedTabs {
            savedTabs.append(tab.savedTab)
        }

        for tab in tabs {
            tab.tabUUID = tab.tabUUID.isEmpty ? UUID().uuidString : tab.tabUUID
            let savedTab = tab.saveSessionDataAndCreateSavedTab(
                isSelected: tab == selectedTab, tabIndex: nil)
            savedTabs.append(savedTab)

            if let image = tab.screenshot, let uuid = tab.screenshotUUID {
                screenshots.append(.init(key: uuid.uuidString, image: image))
            }
        }

        imageStore?.updateAll(
            screenshots,
            extraKeysToKeep: Set(existingSavedTabs.compactMap { $0.screenshotUUID?.uuidString })
        )

        return savedTabs.isEmpty ? nil : savedTabs
    }

    private func backgroundFileWriter(for path: String) -> BackgroundFileWriter {
        if let backgroundFileWriter = backgroundFileWriters[path] {
            return backgroundFileWriter
        }
        let writer = BackgroundFileWriter(label: "tabs", path: path)
        backgroundFileWriters[path] = writer
        return writer
    }

    // Async write of the tab state. In most cases, code doesn't care about performing an operation
    // after this completes. Deferred completion is called always, regardless of Data.write return value.
    // Write failures (i.e. due to read locks) are considered inconsequential, as preserveTabs will be called frequently.
    func preserveTabs(
        _ tabs: [Tab], archivedTabs: [ArchivedTab], existingSavedTabs: [SavedTab],
        selectedTab: Tab?, for scene: UIScene
    ) {
        log.info("Preserve tabs for scene: \(scene.session.persistentIdentifier)")

        assert(Thread.isMainThread)

        guard
            let savedTabs = prepareSavedTabs(
                fromTabs: tabs,
                fromArchivedTabs: archivedTabs,
                update: existingSavedTabs,
                selectedTab: selectedTab
            ),
            let path = tabSavePath(withId: scene.session.persistentIdentifier)
        else {
            clearArchive(for: scene)
            return
        }

        // Save a fallback copy in case the scene persistanceID changes
        // Prevents the loss of user's tabs
        if let fallbackTabsPath = fallbackTabsPath() {
            saveTabsToPath(path: fallbackTabsPath, savedTabs: savedTabs)
        }

        saveTabsToPath(path: path, savedTabs: savedTabs)
    }

    func saveTabsToPath(path: String, savedTabs: [SavedTab]) {
        log.info("Saving to \(path), number of tabs: \(savedTabs.count)")

        // Generate archive off the main thread since it can be a bit expensive if the
        // user has a lot of tabs. Possible given that `SavedTab` is safe to read from
        // a background thread.
        backgroundFileWriter(for: path).writeData(from: {
            do {
                return try NSKeyedArchiver.archivedData(
                    withRootObject: savedTabs, requiringSecureCoding: false)
            } catch {
                log.error("Failed to create data archive for tabs: \(error.localizedDescription)")
                return nil
            }
        })
    }

    func restoreStartupTabs(for scene: UIScene, clearIncognitoTabs: Bool, tabManager: TabManager)
        -> Tab?
    {
        let selectedTab = restoreTabs(
            savedTabs: getStartupTabs(for: scene),
            clearIncognitoTabs: clearIncognitoTabs,
            tabManager: tabManager
        )
        return selectedTab
    }

    private func restoreTabs(
        savedTabs: [SavedTab], clearIncognitoTabs: Bool, tabManager: TabManager
    )
        -> Tab?
    {
        assertIsMainThread("Restoration is a main-only operation")

        var savedTabs = savedTabs

        // Make sure to wipe the private tabs if the user has the pref turned on
        if clearIncognitoTabs {
            savedTabs = savedTabs.filter { !$0.isIncognito }
        }

        var tabToSelect: Tab?
        var restoredTabs = [Tab]()
        restoredTabs.reserveCapacity(savedTabs.count)  // Overestimating

        for savedTab in savedTabs {
            if savedTab.shouldBeArchived {
                tabManager.add(archivedTab: ArchivedTab(savedTab: savedTab))
            } else {
                let tab = tabManager.restore(savedTab: savedTab, resolveParentRef: false)

                restoredTabs.append(tab)

                if savedTab.isSelected, tab.isIncluded(in: [.pinned, .today]) {
                    tabToSelect = tab
                }
            }
        }

        tabManager.resolveParentRef(for: restoredTabs)

        if tabToSelect == nil {
            if !tabManager.activeTabs.isEmpty {
                tabToSelect = tabManager.activeTabs.first(where: {
                    $0.isIncognito == false && $0.isIncluded(in: .today)
                })
            } else {
                SceneDelegate.getBVC(with: tabManager.scene).showTabTray()
            }
        }

        return tabToSelect
    }

    func clearArchive(for scene: UIScene) {
        var path: String?

        log.info("Clearing archive for scene: \(scene.session.persistentIdentifier)")
        path = tabSavePath(withId: scene.session.persistentIdentifier)

        if let path = path {
            log.info("Removing \(path)")
            try? FileManager.default.removeItem(atPath: path)
        }

        if let fallbackTabsPath = fallbackTabsPath() {
            log.info("Removing \(fallbackTabsPath)")
            try? FileManager.default.removeItem(atPath: fallbackTabsPath)
        }
    }

    func getStartupTabs(for scene: UIScene) -> [SavedTab] {
        log.info("Getting startup tabs for scene: \(scene.session.persistentIdentifier)")

        let path = tabSavePath(withId: scene.session.persistentIdentifier)
        log.info("Restoring tabs from \(path ?? "")")

        let savedTabsWithNewPath = retrieveSavedTabs(fromArchivePath: path)
        let fallbackTabs = retrieveSavedTabs(fromArchivePath: fallbackTabsPath())

        if let savedTabsWithNewPath = savedTabsWithNewPath {
            return savedTabsWithNewPath
        } else if let fallbackTabs = fallbackTabs {
            return fallbackTabs
        } else {
            return [SavedTab]()
        }
    }

    fileprivate func retrieveSavedTabs(fromArchivePath archivePath: String?) -> [SavedTab]? {
        guard let archivePath = archivePath,
            FileManager.default.fileExists(atPath: archivePath),
            let tabData = try? Data(contentsOf: URL(fileURLWithPath: archivePath))
        else {
            return nil
        }

        do {
            if let savedTabs = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(tabData)
                as? [SavedTab], savedTabs.count > 0
            {
                return savedTabs
            }
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }
}

// Functions for testing
extension TabManagerStore {
    func countTabsOnDiskForTesting(sceneId: String) -> Int {
        assert(AppConstants.IsRunningTest)
        return retrieveSavedTabs(fromArchivePath: tabSavePath(withId: sceneId))?.count ?? 0
    }
}
