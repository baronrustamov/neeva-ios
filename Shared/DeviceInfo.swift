/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

open class DeviceInfo {
    public static var specificModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""

        // Parses the string for the model name via NSUTF8StringEncoding, refer to
        // http://stackoverflow.com/questions/26028918/ios-how-to-determine-iphone-model-in-swift
        for child in mirror.children.enumerated() {
            if let value = child.1.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        return identifier
    }

    open class var isSimulator: Bool {
        ProcessInfo.processInfo.environment["SIMULATOR_ROOT"] != nil
    }
}
