// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import Storage
import SwiftUI

/// This file contains models and views for the iPad card strip, which is not enabled by default.

private struct CardStrip<Model: CardModel>: View {
    @ObservedObject var model: Model
    let gridModel: GridModel
    let isTop = FeatureFlag[.topCardStrip]

    var pinnedDetails: [TabCardDetails] {
        let tabCardDetails = model.allDetails.compactMap { $0 as? TabCardDetails }
        return tabCardDetails.filter { $0.isPinned }
    }

    var unpinnedDetails: [TabCardDetails] {
        let tabCardDetails = model.allDetails.compactMap { $0 as? TabCardDetails }
        return tabCardDetails.filter { !$0.isPinned }
    }

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: isTop ? 0 : 8) {
                ForEach(pinnedDetails.indices, id: \.self) { index in
                    let details = pinnedDetails[index]
                    CompactCard(details: details)
                        .environment(\.selectionCompletion) {}
                        .environment(\.cardSize, CardUX.DefaultCardSize)
                        .environmentObject(gridModel)
                        .padding(.trailing, (pinnedDetails.count - 1 == index && isTop) ? -16 : 0)
                }
            }

            HStack(spacing: isTop ? 0 : 8) {
                ForEach(unpinnedDetails.indices, id: \.self) { index in
                    let details = unpinnedDetails[index]
                    CompactCard(details: details)
                        .environment(\.selectionCompletion) {}
                        .environment(\.cardSize, CardUX.DefaultCardSize)
                        .environmentObject(gridModel)
                }
            }

            Spacer()
        }.padding()
    }
}

private struct CardStripButtonSpec: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(width: CardUX.DefaultCardSize / 2, height: 124)
            .background(Color.DefaultBackground)
            .clipShape(Capsule())
            .shadow(radius: CardUX.ShadowRadius).padding(.leading, 20)
    }
}

class CardStripModel: ObservableObject {
    @Published private(set) var isVisible: Bool = false

    func toggleVisible() {
        withAnimation {
            isVisible.toggle()
        }
    }
}

struct CardStripView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var sitesModel: SiteCardModel
    @EnvironmentObject var cardStripModel: CardStripModel
    @EnvironmentObject var gridModel: GridModel

    let isTop = FeatureFlag[.topCardStrip]

    var cardStrip: some View {
        CardStrip(
            model: tabModel, gridModel: gridModel
        ).fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        VStack {
            if !isTop {
                Spacer()
            }

            if isTop {
                cardStrip.background(Color.white)
            } else {
                if #available(iOS 15.0, *) {
                    cardStrip.background(.regularMaterial)
                } else {
                    cardStrip.background(Color.groupedBackground)
                }
            }

            if isTop {
                Spacer()
            }
        }.onAppear {
            tabModel.onDataUpdated()
        }.frame(maxWidth: .infinity)
    }
}

private struct ToggleSpacesButton: View {
    @EnvironmentObject var spaceModel: SpaceCardModel
    @Binding var showingSpaces: Bool

    var body: some View {
        Button {
            spaceModel.onDataUpdated()
            withAnimation {
                showingSpaces.toggle()
            }
        } label: {
            Symbol(.bookmark, size: 18, weight: .semibold, label: "Show Spaces")
                .foregroundColor(
                    Color(showingSpaces ? UIColor.DefaultBackground : UIColor.label)
                )
                .aspectRatio(contentMode: .fit)
                .tapTargetFrame()
                .background(Color(showingSpaces ? UIColor.label : UIColor.DefaultBackground))
                .clipShape(Circle()).animation(.spring())
        }
    }
}

private struct DismissButton: View {
    var onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            Symbol(.xmark, size: 18, weight: .semibold, label: "Dismiss View")
                .foregroundColor(
                    Color(UIColor.label)
                )
                .aspectRatio(contentMode: .fit)
                .tapTargetFrame()
                .animation(.spring())
        }
    }
}
