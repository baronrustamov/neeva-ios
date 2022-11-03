/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Foundation
import Shared

class DynamicFontHelper: NSObject {
    private var cancellable: AnyCancellable?

    static var defaultHelper: DynamicFontHelper {
        struct Singleton {
            static let instance = DynamicFontHelper()
        }
        return Singleton.instance
    }

    override init() {
        // 11pt -> 12pt -> 17pt
        defaultSmallFontSize =
            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1).pointSize

        super.init()
    }

    /// Starts monitoring the `ContentSizeCategory` changes
    func startObserving() {
        cancellable = NotificationCenter.default
            .publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink(receiveValue: contentSizeCategoryDidChange(_:))
    }

    /// Small
    fileprivate var defaultSmallFontSize: CGFloat
    var DefaultSmallFont: UIFont {
        return UIFont.systemFont(ofSize: defaultSmallFontSize, weight: UIFont.Weight.regular)
    }

    func refreshFonts() {
        defaultSmallFontSize =
            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption2).pointSize
    }

    private func contentSizeCategoryDidChange(_ notification: Notification) {
        refreshFonts()
        let notification = Notification(name: .DynamicFontChanged, object: nil)
        NotificationCenter.default.post(notification)
    }
}
