// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

class SpacesProfileViewModel: ObservableObject {

    @Published var spaceCards: [SpaceCardDetails] = []
    @Published var owner: Space.Owner?
    @Published var isLoading: Bool = false

    func getSpaces(with id: String) {
        isLoading = true
        SpaceStore.shared.getRelatedSpaces(with: id) { result in
            switch result {
            case .success(let arr):
                self.spaceCards = arr.map({
                    let spaceCardDetails = SpaceCardDetails(
                        id: $0.id.id, manager: SpaceStore.shared)
                    spaceCardDetails.setSpace($0)
                    return spaceCardDetails
                })
                self.owner = arr.first?.owner
            case .failure(let error):
                print(error)
            }
            self.isLoading = false
        }
    }
}

struct SpacesProfileView: View {
    let spaceId: String
    var onBackTap: () -> Void
    var owner: Space.Owner?
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel
    @ObservedObject var viewModel = SpacesProfileViewModel()
    @State var headerVisible = true
    @State private var cardSize: CGFloat = CardUX.DefaultCardSize
    @State private var columnCount: Int = 2
    @State private var selectedSpace: String?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(spaceId: String, onBackTap: @escaping () -> Void, owner: Space.Owner?) {
        self.spaceId = spaceId
        self.onBackTap = onBackTap
        self.owner = owner
        viewModel.getSpaces(with: spaceId)

    }

    var isLandscape: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    private var columns: [GridItem] {
        return Array(
            repeating:
                GridItem(
                    .fixed(cardSize),
                    spacing: CardGridUX.GridSpacing,
                    alignment: .leading),
            count: columnCount)
    }

    var body: some View {
        VStack {
            topView
            GeometryReader { geom in
                if viewModel.isLoading {
                    loadingView
                }
                VStack(alignment: .leading) {
                    cardScrollView(with: geom)
                }
            }
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func cardScrollView(with geom: GeometryProxy) -> some View {
        CardScrollContainer(columns: columns) { scrollProxy in
            VStack(alignment: .leading) {
                LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                    ForEach(viewModel.spaceCards, id: \.id) { spaceCard in
                        thumbnail(spaceCard, geom: geom)
                    }
                }.animation(nil)
            }
            .padding(.vertical, CardGridUX.GridSpacing)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spaces")
    }

    @ViewBuilder
    private func thumbnail(_ spaceCard: SpaceCardDetails, geom: GeometryProxy) -> some View {
        ZStack {
            NavigationLink(
                tag: spaceCard.id,
                selection: $selectedSpace,
                destination: {
                    SpaceContainerView(
                        primitive: spaceCard,
                        onProfileUIDismissed: {
                            self.selectedSpace = nil
                        },
                        isShowingProfileUI: true)
                },
                label: {}
            )
            FittedCard(details: spaceCard)
                .environment(\.cardSize, cardSize)
                .environment(\.selectionCompletion) {
                    self.selectedSpace = spaceCard.id
                }
                .useEffect(
                    deps: geom.size.width, isLandscape, perform: updateCardSize
                ).useEffect(deps: gridModel.canResizeGrid) { _ in
                    updateCardSize(width: geom.size.width, topToolbar: isLandscape)
                }.ignoresSafeArea(.keyboard)
        }

    }

    private var ownerView: some View {
        SpaceACLView(isPublic: true, acls: [], owner: viewModel.owner ?? owner)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var topView: some View {
        HStack {
            Button(
                action: {
                    self.onBackTap()
                },
                label: {
                    Symbol(.arrowBackward, label: "Return to Space")
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                })
            ownerView
        }.frame(
            height: UIConstants
                .TopToolbarHeightWithToolbarButtonsShowing
        )
        .frame(maxWidth: .infinity)
        .background(Color.clear.ignoresSafeArea())
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // ToDo: Remove this duplication
    func updateCardSize(width: CGFloat, topToolbar: Bool) {
        guard gridModel.canResizeGrid else {
            return
        }

        if width > 1000 {
            self.columnCount = 4
        } else {
            columnCount = topToolbar ? 3 : 2
        }
        self.cardSize =
            (width - (columnCount + 1) * CardGridUX.GridSpacing)
            / columnCount
    }
}
