// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

struct OverlayStyle {
    let showTitle: Bool
    let backgroundColor: UIColor
    /// Disables dismissing the modal by clicking outside the view.
    let nonDismissible: Bool
    let embedScrollView: Bool
    /// If true, will fill the entire width of the screen with the popover.
    let expandPopoverWidth: Bool
    /// If true, expands the view to fill the height of the popover.
    let expandPopoverHeight: Bool

    init(
        showTitle: Bool,
        backgroundColor: UIColor = .DefaultBackground,
        nonDismissible: Bool = false,
        embedScrollView: Bool = true,
        expandPopoverWidth: Bool = true,
        expandPopoverHeight: Bool = true
    ) {
        self.showTitle = showTitle
        self.backgroundColor = backgroundColor
        self.nonDismissible = nonDismissible
        self.embedScrollView = embedScrollView
        self.expandPopoverWidth = expandPopoverWidth
        self.expandPopoverHeight = expandPopoverHeight
    }

    /// Use for sheets containing grouped sets of controls (e.g., like the Overflow menu).
    static let grouped = OverlayStyle(
        showTitle: false,
        backgroundColor: .systemGroupedBackground.elevated,
        expandPopoverWidth: false,
        expandPopoverHeight: false
    )

    static let spaces = OverlayStyle(
        showTitle: true,
        backgroundColor: .DefaultBackground
    )

    static let cheatsheet = OverlayStyle(
        showTitle: false,
        backgroundColor: .DefaultBackground,
        expandPopoverWidth: false,
        expandPopoverHeight: false
    )

    static let nonScrollableMenu = OverlayStyle(
        showTitle: false,
        backgroundColor: .systemGroupedBackground.elevated,
        embedScrollView: false
    )

    static let withTitle = OverlayStyle(showTitle: true)
}
