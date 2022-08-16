// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Intents

class IntentHelper {
    /// Suggest a Shortcut with SearchNeevaIntent and query string
    ///
    /// returns `true` if success
    @discardableResult
    class func suggestSearchIntent(with query: String? = nil) -> Bool {
        let intent = SearchNeevaIntent()
        intent.text = query
        if let shortcut = INShortcut(intent: SearchNeevaIntent()) {
            INVoiceShortcutCenter.shared.setShortcutSuggestions([shortcut])
            return true
        }
        return false
    }

    /// Donate an Interaction with SearchNeevaIntent and query string
    class func donateSearchIntent(
        with query: String? = nil,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        let intent = SearchNeevaIntent()
        intent.text = query
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate(completion: completionHandler)
    }
}
