// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation

extension Defaults.Keys {
    static let scenePreviousUIState = Defaults.Key<String>("scenePreviousUIState", default: "tab")
}

enum SceneUIState {
    case cardGrid(SwitcherView)
    case spaceDetailView(String)
    case tab

    var rawValue: String {
        switch self {
        case .cardGrid(let switcherView):
            return "cardGrid-\(switcherView.rawValue)"
        case .spaceDetailView(let id):
            return "spaceDetailView-\(id)"
        case .tab:
            return "tab"
        }
    }

    // MARK: - init
    init(rawValue: String) {
        switch rawValue {
        case rawValue where rawValue.contains("cardGrid"):
            let value = rawValue.split(separator: "-")[1]
            let switcherView = SwitcherView(rawValue: String(value))!
            self = .cardGrid(switcherView)
        case rawValue where rawValue.contains("spaceDetailView"):
            let id = rawValue.split(separator: "-")[1]
            self = .spaceDetailView(String(id))
        default:
            self = .tab
        }
    }
}
