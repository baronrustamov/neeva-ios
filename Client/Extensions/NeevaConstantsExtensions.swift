// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

extension NeevaConstants {
    public static var appHomeURL: URL { appURL }

    public static func isNeevaHome(url: URL?) -> Bool {
        return url?.scheme == NeevaConstants.appHomeURL.scheme
            && url?.host == NeevaConstants.appHomeURL.host
            && url?.path == NeevaConstants.appHomeURL.path
    }
}
