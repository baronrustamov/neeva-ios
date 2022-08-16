// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public class CardDropDelegate: DropDelegate {
    // MARK: - Properties
    private let tabManager: TabManager
    static var draggingDetail: TabCardDetails?

    // MARK: - Drag Methods
    /// Called when the user drops the item.
    public func performDrop(info: DropInfo) -> Bool {
        Self.draggingDetail = nil
        return true
    }

    /// Called right when an item is dragged onto another item.
    /// Should be implemented by the conforming class.
    public func dropEntered(info: DropInfo) {
        tabManager.updateAllTabDataAndSendNotifications(notify: true)
        tabManager.storeChanges()
    }

    /// Called when the dragging state of an item has changed, including
    /// the location that it is getting dragged.
    public func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
