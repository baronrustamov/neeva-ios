/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import MobileCoreServices
import Shared
import UIKit

extension UIPasteboard {
    func addImageWithData(_ data: Data, forURL url: URL) {
        let isGIF = data.isGIF

        // Setting pasteboard.items allows us to set multiple representations for the same item.
        items = [
            [
                kUTTypeURL as String: url,
                imageTypeKey(isGIF): data,
            ]
        ]
    }

    fileprivate func imageTypeKey(_ isGIF: Bool) -> String {
        return (isGIF ? kUTTypeGIF : kUTTypePNG) as String
    }

    /// Preferred method to get strings out of the clipboard.
    /// When iCloud pasteboards are enabled, the usually fast, synchronous calls
    /// become slow and synchronous causing very slow start up times.
    func asyncString() -> Deferred<Maybe<String?>> {
        return fetchAsync {
            return UIPasteboard.general.string
        }
    }

    // Converts the potentially long running synchronous operation into an asynchronous one.
    private func fetchAsync<T>(getter: @escaping () -> T) -> Deferred<Maybe<T>> {
        let deferred = Deferred<Maybe<T>>()
        DispatchQueue.global().async {
            let value = getter()
            deferred.fill(Maybe(success: value))
        }
        return deferred
    }
}
