// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

extension UIApplication {
    // For more info: https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func openSettings(triggerFrom: OpenDefaultBrowserOnboardingTrigger) {
        ClientLogger.shared.logCounter(
            .GoToSysAppSettings,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.UIInteractionAttribute.openSysSettingTriggerFrom,
                    value: triggerFrom.rawValue
                )
            ]
        )
        if triggerFrom.defaultBrowserIntent {
            ConversionLogger.log(event: .visitedDefaultBrowserSettings)
        }
        self.open(
            URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
}
