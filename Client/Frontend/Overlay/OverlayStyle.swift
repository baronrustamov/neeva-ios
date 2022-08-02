// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

public struct OverlayStyle {
    let showTitle: Bool
    let backgroundColor: UIColor
    let nonDismissible: Bool  // disable dismiss modal by clicking the gray black
    let embedScrollView: Bool
    // TODO: this should be removed in the next version to support portrait popover
    let isAdBlockerPromo: Bool
    /// If true, will fill the entire width of the screen with the popover
    let expandPopoverWidth: Bool

    init(
        showTitle: Bool, backgroundColor: UIColor = .DefaultBackground,
        nonDismissible: Bool = false,
        embedScrollView: Bool = true, expandPopoverWidth: Bool = false,
        isAdBlockerPromo: Bool = false
    ) {
        self.showTitle = showTitle
        self.backgroundColor = backgroundColor
        self.nonDismissible = nonDismissible
        self.embedScrollView = embedScrollView
        self.expandPopoverWidth = expandPopoverWidth
        self.isAdBlockerPromo = isAdBlockerPromo
    }

    /// Use for sheets containing grouped sets of controls (e.g., like the Overflow menu).
    static let grouped = OverlayStyle(
        showTitle: false,
        backgroundColor: .systemGroupedBackground.elevated)

    static let spaces = OverlayStyle(
        showTitle: true,
        backgroundColor: .DefaultBackground,
        expandPopoverWidth: true
    )

    static let cheatsheet = OverlayStyle(
        showTitle: false,
        backgroundColor: .DefaultBackground
    )

    static let nonScrollableMenu = OverlayStyle(
        showTitle: false,
        backgroundColor: .systemGroupedBackground.elevated,
        embedScrollView: false
    )

    static let adBlockerPromo = OverlayStyle(
        showTitle: false,
        backgroundColor: .DefaultBackground,
        isAdBlockerPromo: true
    )

    static let withTitle = OverlayStyle(showTitle: true)
}
