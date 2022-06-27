// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

class SpaceCardsViewModel: ObservableObject {
    @Published var dataSource: [SpaceCardDetails] = []
    private var subscriber: AnyCancellable?

    init(spacesModel: SpaceCardModel) {
        subscriber = spacesModel.$allDetails
            .combineLatest(spacesModel.$filterState, spacesModel.$sortType)
            .sink { (arr, filter, sort) in
                self.dataSource =
                    arr.filter {
                        NeevaFeatureFlags[.enableSpaceDigestCard]
                            || $0.id != SpaceStore.dailyDigestID
                    }
                    .filterSpaces(by: filter)
                    .sortSpaces(by: sort)
            }
    }

}

struct SpaceCardsView: View {
    @ObservedObject var viewModel: SpaceCardsViewModel

    init(spacesModel: SpaceCardModel) {
        self.viewModel = SpaceCardsViewModel(spacesModel: spacesModel)
    }

    var body: some View {
        ForEach(viewModel.dataSource, id: \.id) { details in
            FittedCard(details: details)
                .id(details.id)
        }
    }
}

extension MutableCollection where Self == [SpaceCardDetails] {
    // TODO: (Burak) Rewrite with sort feature
    fileprivate func sortSpaces(by sortType: SpaceSortState) -> Self {
        let dateFormatter = ISO8601DateFormatter()
        var temp = self
        return temp.sorted(
            by: {
                guard let firstItem = $0.item, let secondItem = $1.item else { return true }
                return firstItem.isPinned && !secondItem.isPinned
            },
            {
                guard let firstItem = $0.item, let secondItem = $1.item else { return true }
                if let date1 = dateFormatter.date(from: firstItem[keyPath: sortType.keyPath]),
                    let date2 = dateFormatter.date(from: secondItem[keyPath: sortType.keyPath])
                {
                    return date1 > date2
                } else {
                    return firstItem[keyPath: sortType.keyPath]
                        < secondItem[keyPath: sortType.keyPath]
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
