// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

/// An action that’s able to be represented both as a button/menu item
/// and an accessibility action for VoiceOver users.
struct Action: Identifiable {
    /// The display name of the string
    let name: String
    /// The SF Symbol name of the icon displayed next to the name
    let icon: SFSymbol
    /// A function that performs the action
    let handler: () -> Void

    var id: String { name }

    init(_ name: String, icon: SFSymbol, handler: @escaping () -> Void) {
        self.name = name
        self.icon = icon
        self.handler = handler
    }
}
