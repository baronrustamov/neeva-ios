// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import Defaults
import Shared
import Storage
import UIKit

struct SuggestionPositionInfo {
    let positionIndex: Int

    func loggingAttributes() -> [ClientLogCounterAttribute] {
        var clientLogAttributes = [ClientLogCounterAttribute]()

        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.suggestionPosition, value: String(positionIndex))
        )

        let bvc = SceneDelegate.getBVC(for: nil)
        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.urlBarNumOfCharsTyped,
                value: String(bvc.searchQueryModel.value.count)))
        return clientLogAttributes
    }
}
