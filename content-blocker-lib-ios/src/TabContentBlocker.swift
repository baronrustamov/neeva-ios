/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

extension Notification.Name {
    public static let didChangeContentBlocking = Notification.Name("didChangeContentBlocking")
    public static let contentBlockerTabSetupRequired = Notification.Name(
        "contentBlockerTabSetupRequired")
}

protocol ContentBlockerTab: AnyObject {
    func currentURL() -> URL?
    func currentWebView() -> WKWebView?
}

class TabContentBlocker: ObservableObject {
    @Published var stats: TPPageStats = TPPageStats()
    private(set) weak var tab: ContentBlockerTab?

    var isEnabled: Bool {
        return false
    }

    @objc func notifiedTabSetupRequired() {}

    func notifyContentBlockingChanged() {}

    func scriptMessageHandlerName() -> String? {
        return "trackingProtectionStats"
    }

    class func prefsChanged() {
        // This class func needs to notify all the active instances of ContentBlocker to update.
        NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
    }

    func updateTab(_ tab: Tab) {
        self.tab = tab
    }

    init(tab: ContentBlockerTab) {
        self.tab = tab
        NotificationCenter.default.addObserver(
            self, selector: #selector(notifiedTabSetupRequired),
            name: .contentBlockerTabSetupRequired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
