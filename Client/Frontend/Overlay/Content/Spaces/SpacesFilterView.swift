// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SpaceFilterState: String, CaseIterable, Identifiable {
    case allSpaces = "All Spaces"
    case ownedByMe = "Owned by me"

    var id: RawValue { rawValue }

    var localizedString: LocalizedStringKey {
        switch self {
        case .allSpaces:
            return "All Spaces"
        case .ownedByMe:
            return "Can edit"
        }
    }
}

public enum SpaceSortType: String, CaseIterable, Identifiable {
    case updatedDate = "Last Updated"
    case name = "Name"

    public var id: RawValue { rawValue }

    public var keyPath: KeyPath<Space, AnyComparable> {
        switch self {
        case .updatedDate: return \Space.timestamp.anyComparable
        case .name: return \Space.name.anyComparable
        }
    }

    var localizedString: LocalizedStringKey {
        switch self {
        case .updatedDate:
            return "Last Updated"
        case .name:
            return "Name"
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
                ForEach(SpaceFilterState.allCases) {
                    data in
                    GroupedRowButtonView(
                        label: data.localizedString,
                        symbol: spaceCardModel.viewModel.filterState == data
                            ? .checkmark : nil
                    ) {
                        spaceCardModel.viewModel.filterState = data
                        spaceCardModel.objectWillChange.send()
                    }.onTapGesture {
                        logFilterTapped()
                    }

                    if data.id != SpaceFilterState.allCases.last?.id {
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
                ForEach(SpaceSortType.allCases) { data in
                    GroupedRowButtonView(
                        label: data.localizedString,
                        nicon: spaceCardModel.viewModel.sortType == data
                            ? spaceCardModel.viewModel.sortOrder.symbol : nil
                    ) {
                        if spaceCardModel.viewModel.sortType == data {
                            spaceCardModel.viewModel.sortOrder.toggle()
                        } else {
                            spaceCardModel.viewModel.sortType = data
                            spaceCardModel.viewModel.sortOrder = .ascending
                        }
                        spaceCardModel.objectWillChange.send()
                    }

                    if data.id != SpaceSortType.allCases.last?.id {
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

public struct AnyComparable: Equatable, Comparable {
    private let lessThan: (Any) -> Bool
    private let value: Any
    private let equals: (Any) -> Bool

    public static func == (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        lhs.equals(rhs.value) || rhs.equals(lhs.value)
    }

    public init<C: Comparable>(_ value: C) {
        self.value = value
        self.equals = { $0 as? C == value }
        self.lessThan = { ($0 as? C).map { value < $0 } ?? false }
    }

    public static func < (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        lhs.lessThan(rhs.value) || (rhs != lhs && !rhs.lessThan(lhs.value))
    }
}

extension Comparable {
    var anyComparable: AnyComparable {
        .init(self)
    }
}
