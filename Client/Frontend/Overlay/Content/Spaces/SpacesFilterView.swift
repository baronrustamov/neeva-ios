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

struct SpacesFilterView: View {
    @EnvironmentObject var spaceCardModel: SpaceCardModel
    @ObservedObject var spaceStore: SpaceStore = SpaceStore.shared

    var body: some View {
        GroupedStack {
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
        .overlayIsFixedHeight(isFixedHeight: true)
    }

    func logFilterTapped() {
        ClientLogger.shared.logCounter(LogConfig.Interaction.SpaceFilterClicked)
    }
}
