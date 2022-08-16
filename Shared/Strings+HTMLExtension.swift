// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import HTMLEntities

extension String {
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var removingHTMLencoding: String? {
        try? self.htmlUnescape(strict: true)
    }

    public func tryRemovingHTMLencoding(strict: Bool) -> String {
        do {
            return try self.htmlUnescape(strict: strict)
        } catch {
            return self
        }
    }
}
