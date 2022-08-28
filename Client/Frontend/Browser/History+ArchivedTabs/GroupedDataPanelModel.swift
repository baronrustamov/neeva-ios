// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

protocol GroupedDataPanelModel {
    associatedtype T: Equatable

    var tabManager: TabManager { get }
    var groupedData: DateGroupedTableData<T> { get set }
    var filteredGroupedData: DateGroupedTableData<T> { get set }

    func loadData()
    func loadData(filter query: String)
}
