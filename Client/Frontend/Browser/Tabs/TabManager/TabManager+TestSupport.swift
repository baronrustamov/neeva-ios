// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage

// Helper functions for test cases
extension TabManager {
    convenience init(
        profile: Profile, imageStore: DiskImageStore?
    ) {
        assert(Thread.isMainThread)

        let scene = SceneDelegate.getCurrentScene(for: nil)
        let incognitoModel = IncognitoModel(isIncognito: false)
        self.init(profile: profile, scene: scene, incognitoModel: incognitoModel)
    }

    func testTabCountOnDisk() -> Int {
        assert(AppConstants.IsRunningTest)
        return store.testTabCountOnDisk(sceneId: SceneDelegate.getCurrentSceneId(for: nil))
    }

    func testCountRestoredTabs() -> Int {
        assert(AppConstants.IsRunningTest)
        return store.getStartupTabs(for: SceneDelegate.getCurrentScene(for: nil)).count
    }

    func testRestoreTabs() {
        assert(AppConstants.IsRunningTest)
        let _ = store.restoreStartupTabs(
            for: SceneDelegate.getCurrentScene(for: nil),
            clearIncognitoTabs: false,
            tabManager: self
        )
    }

    func testClearArchive() {
        assert(AppConstants.IsRunningTest)
        store.clearArchive(for: SceneDelegate.getCurrentScene(for: nil))
    }
}
