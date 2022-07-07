// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation

extension Defaults.Keys {
    static let sceneLastOpenedTime = Defaults.Key<Date>("sceneLastOpenedTime", default: Date())
    static let scenePreviousUIState = Defaults.Key<String>("scenePreviousUIState", default: "tab")
}

enum SceneUIState {
    private static let seperator = "~~nui~~"

    // SwitcherView, isIncogntio
    case cardGrid(SwitcherView, Bool)
    case spaceDetailView(String)
    case tab

    var rawValue: String {
        switch self {
        case .cardGrid(let switcherView, let isIncognito):
            return
                "cardGrid\(Self.seperator)\(switcherView.rawValue)\(Self.seperator)\(isIncognito)"
        case .spaceDetailView(let id):
            return "spaceDetailView\(Self.seperator)\(id)"
        case .tab:
            return "tab"
        }
    }

    // MARK: - init
    init(rawValue: String) {
        switch rawValue {
        case rawValue where rawValue.contains("cardGrid"):
            let split = rawValue.components(separatedBy: Self.seperator)
            if let value = split[safeIndex: 1], let isIncognito = split[safeIndex: 2] {
                let switcherView = SwitcherView(rawValue: String(value))!
                self = .cardGrid(switcherView, isIncognito == "true")
            } else {
                self = .tab
            }
        case rawValue where rawValue.contains("spaceDetailView"):
            if let id = rawValue.components(separatedBy: Self.seperator)[safeIndex: 1] {
                self = .spaceDetailView(String(id))
            } else {
                self = .tab
            }
        default:
            self = .tab
        }
    }
}
