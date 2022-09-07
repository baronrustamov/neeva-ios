// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage
import SwiftUI

protocol GroupedDataPanelModel: ObservableObject {
    associatedtype T: Equatable
    associatedtype Rows

    var tabManager: TabManager { get }
    var groupedData: DateGroupedTableData<T> { get set }
    var filteredGroupedData: DateGroupedTableData<T> { get set }

    // Return a Deferred object because history loads data async.
    // Might set up something for ArchivedTabs in the
    // future, simpler to have one return type for now.
    @discardableResult func loadData() -> Deferred<Maybe<Cursor<T?>>>
    @discardableResult func loadData(filter query: String) -> Deferred<Maybe<Cursor<T?>>>
    func buildRows(with data: [T], for section: DateGroupedTableDataSection) -> Rows
}
