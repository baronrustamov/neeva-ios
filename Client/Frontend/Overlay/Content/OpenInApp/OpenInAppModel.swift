// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation

extension Defaults.Keys {
    fileprivate static let openInAppPreferences = Defaults.Key<[String: Bool]>(
        "profile_prefkey_openInApp_prefs", default: [:])
}

class OpenInAppModel {
    static let shared = OpenInAppModel()

    // MARK: - Open in App
    func openInApp(url: URL, toastViewManager: ToastViewManager) {
        UIApplication.shared.open(url, options: [:]) { opened in
            if !opened {
                ToastDefaults().showToast(
                    with:
                        "Unable to open link in external app. Check if the app is installed on this device.",
                    toastViewManager: toastViewManager)
            }
        }
    }

    // MARK: - Preferences
    func savePreferences(for domain: String, shouldOpenInApp: Bool) {
        Defaults[.openInAppPreferences][domain] = shouldOpenInApp
    }

    func shouldOpenInApp(for domain: String) -> Bool? {
        return Defaults[.openInAppPreferences][domain]
    }

    func resetPreferences() {
        Defaults[.openInAppPreferences] = [:]
    }
}
