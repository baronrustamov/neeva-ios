// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

class PinToTopSitesActivity: UIActivity {
    private let isPinned: Bool
    fileprivate let callback: () -> Void

    init(isPinned: Bool, callback: @escaping () -> Void) {
        self.isPinned = isPinned
        self.callback = callback
    }

    override var activityTitle: String? {
        return isPinned == false
            ? Strings.PinToTopSitesTitleActivity : Strings.UnpinFromTopSitesTitleActivity
    }

    override var activityImage: UIImage? {
        return isPinned == false ? UIImage(systemName: "pin") : UIImage(systemName: "pin.slash")
    }

    override func perform() {
        callback()
        activityDidFinish(true)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
}
