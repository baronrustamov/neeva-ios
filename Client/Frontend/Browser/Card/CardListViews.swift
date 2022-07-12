// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

class SpaceCardsViewModel: ObservableObject {
    @Published var dataSource: [SpaceCardDetails] = []
    // Because allDetails is an an array of ref types
    // updating properties in each detail will not trigger an update
    // we need an alternative way to signal an update
    private var refreshSignal = CurrentValueSubject<Void, Never>(Void())
    private var subscriber: AnyCancellable?

    init(spacesModel: SpaceCardModel) {
        subscriber = Publishers.CombineLatest4(
            spacesModel.$allDetails,
            spacesModel.$filterState,
            spacesModel.$sortType,
            spacesModel.$sortOrder
        )
        .combineLatest(refreshSignal)
        .sink { [weak self] in
            let (arr, filter, sort, order) = $0.0
            self?.dataSource =
                arr.filter {
                    NeevaFeatureFlags[.enableSpaceDigestCard]
                        || $0.id != SpaceStore.dailyDigestID
                }
                .filterSpaces(by: filter)
                .sortSpaces(by: sort, order: order)
        }
    }

    func refresh() {
        refreshSignal.send()
    }
}

struct SpaceCardsView: View {
    @ObservedObject var viewModel: SpaceCardsViewModel

    init(spacesModel: SpaceCardModel) {
        self.viewModel = spacesModel.cardsViewModel
    }

    var body: some View {
        ForEach(viewModel.dataSource, id: \.id) { details in
            FittedCard(details: details)
                .id(details.id)
        }
    }
}

extension MutableCollection where Self == [SpaceCardDetails] {
    fileprivate func sortSpaces(
        by sortType: SpaceSortState,
        order: SpaceSortOrder
    ) -> Self {
        let dateFormatter = ISO8601DateFormatter()
        var temp = self
        return temp.sorted(
            by: {
                guard let firstItem = $0.item, let secondItem = $1.item else { return true }
                return firstItem.isPinned && !secondItem.isPinned
            },
            {
                guard let firstItem = $0.item?[keyPath: sortType.keyPath],
                    let secondItem = $1.item?[keyPath: sortType.keyPath]
                else {
                    return true
                }
                if let date1 = dateFormatter.date(from: firstItem),
                    let date2 = dateFormatter.date(from: secondItem)
                {
                    return order.makeComparator()(date1, date2)
                } else {
                    return order.makeComparator()(firstItem, secondItem)
                }
            })
    }

    fileprivate func filterSpaces(by filterType: SpaceFilterState) -> Self {
        switch filterType {
        case .allSpaces:
            return self
        case .ownedByMe:
            return self.filter { $0.item?.userACL == .owner }
        }
    }
}

extension MutableCollection where Self: RandomAccessCollection {
    mutating func sorted(
        by firstPredicate: (Element, Element) -> Bool,
        _ secondPredicate: (Element, Element) -> Bool
    ) -> [Self.Element] {
        sorted(by:) { lhs, rhs in
            if firstPredicate(lhs, rhs) { return true }
            if firstPredicate(rhs, lhs) { return false }
            if secondPredicate(lhs, rhs) { return true }
            if secondPredicate(rhs, lhs) { return false }
            return false
        }
    }
}
