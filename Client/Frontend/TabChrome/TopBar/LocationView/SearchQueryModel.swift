// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

/// One per window scene. Contains the text of the location view. When `TabChromeModel/isEditingLocation`
/// is false, `SearchQueryModel/value` is not used by anything.
class SearchQueryModel: ObservableObject {
    @Published var value: String = ""

    // Contains the parameters that are preseved while editing a search query
    var components: URLComponents?

    init() {}
    init(previewValue: String) {
        self.value = previewValue
    }
}
