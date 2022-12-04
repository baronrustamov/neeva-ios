// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Defaults
import Shared

enum PerformanceLoggerAttribute: String {
    case crashed
    case pageLoaded
}

class PerformanceLogger {

    static let shared = PerformanceLogger()

    // increment user default page load if scheme is http or https
    func incrementPageLoad(url: URL) {
        if url.scheme == "http" || url.scheme == "https" {
            let currentCount = Defaults[.pageLoadedCounter]
            Defaults[.pageLoadedCounter] = currentCount + 1
        }
    }

    // reset user default page load to 0
    private func reset() {
        Defaults[.pageLoadedCounter] = 0
    }

    // sent last crash status with page load number
    func logPageLoadWithCrashedStatus(crashed: Bool) {
        let pageLoadedCount = Defaults[.pageLoadedCounter]

        let attributes: [ClientLogCounterAttribute] = [
            ClientLogCounterAttribute(
                key: PerformanceLoggerAttribute.crashed.rawValue,
                value: String(crashed)
            ),
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.DeviceName, value: NeevaConstants.deviceNameValue
            ),
            ClientLogCounterAttribute(
                key: PerformanceLoggerAttribute.pageLoaded.rawValue,
                value: String(pageLoadedCount)
            ),
        ]
        ClientLogger.shared.logCounter(
            .AppCrashWithCrashReporter,
            attributes: attributes
        )

        reset()
    }
}
