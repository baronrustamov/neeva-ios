// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SpaceFilterState: String, CaseIterable, Identifiable {
    case allSpaces = "All Spaces"
    case ownedByMe = "Owned by me"

    var id: RawValue { rawValue }
}

public enum SpaceSortState: String, CaseIterable, Identifiable {
    case updatedDate = "Last Updated"
    case name = "Name"

    public var id: RawValue { rawValue }

    public var keyPath: KeyPath<Space, String> {
        switch self {
        case .updatedDate: return \Space.lastModifiedTs
        case .name: return \Space.name
        }
    }
}

enum SpaceSortOrder {
    case ascending
    case descending

    var symbol: Nicon {
        switch self {
        case .ascending:
            return .arrowDown
        case .descending:
            return .arrowUp
        }
    }

    mutating func toggle() {
        self = self == .descending ? .ascending : .descending
    }
}

extension SpaceSortOrder {
    func makeComparator<T: Comparable>() -> (T, T) -> Bool {
        switch self {
        case .ascending:
            return (<)
        case .descending:
            return (>)
        }
    }
}

struct SpacesFilterView: View {
    @EnvironmentObject var spaceCardModel: SpaceCardModel
    @ObservedObject var spaceStore: SpaceStore = SpaceStore.shared

    var body: some View {
        GroupedStack {
            filterSection
            sortSection
        }
        .overlayIsFixedHeight(isFixedHeight: true)
    }

    @ViewBuilder
    private var filterSection: some View {
        Text("Filter")
            .modifier(SpaceFilterSectionTitle())

        GroupedCell.Decoration {
            VStack(spacing: 0) {
                ForEach(Array(SpaceFilterState.allCases.enumerated()), id: \.element.id) {
                    data in
                    GroupedRowButtonView(
                        label: LocalizedStringKey(data.element.rawValue),
                        symbol: spaceCardModel.filterState == data.element ? .checkmark : nil
                    ) {
                        spaceCardModel.objectWillChange.send()
                        spaceCardModel.filterState = data.element
                    }.onTapGesture {
                        logFilterTapped()
                    }
                    if data.offset < SpaceFilterState.allCases.count - 1 {
                        Color.secondaryBackground.frame(height: 1)
                    }

                }.accentColor(.label)
            }
        }
    }

    @ViewBuilder
    private var sortSection: some View {
        Text("Sort")
            .modifier(SpaceFilterSectionTitle())

        GroupedCell.Decoration {
            VStack(spacing: 0) {
                ForEach(Array(SpaceSortState.allCases.enumerated()), id: \.element.id) { data in
                    GroupedRowButtonView(
                        label: LocalizedStringKey(data.element.rawValue),
                        nicon: spaceCardModel.sortType == data.element
                            ? spaceCardModel.sortOrder.symbol : nil
                    ) {
                        spaceCardModel.objectWillChange.send()
                        if spaceCardModel.sortType == data.element {
                            spaceCardModel.sortOrder.toggle()
                        } else {
                            spaceCardModel.sortType = data.element
                            spaceCardModel.sortOrder = .ascending
                        }
                    }

                    if data.offset < SpaceFilterState.allCases.count - 1 {
                        Color.secondaryBackground.frame(height: 1)
                    }

                }.accentColor(.label)
            }
        }
    }

    func logFilterTapped() {
        ClientLogger.shared.logCounter(LogConfig.Interaction.SpaceFilterClicked)
    }
}

private struct SpaceFilterSectionTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.label)
            .withFont(unkerned: .headingSmall)
            .padding(.horizontal, 8)
    }

}
