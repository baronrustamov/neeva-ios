// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum SpaceViewUX {
    static let Padding: CGFloat = 4
    static let ThumbnailCornerRadius: CGFloat = 6
    static let ThumbnailSize: CGFloat = 54
    static let DetailThumbnailSize: CGFloat = 72
    static let ItemPadding: CGFloat = 14
    static let EditingRowInset: CGFloat = 8
}

struct SpaceContainerView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @State private var headerVisible = true
    @ObservedObject var primitive: SpaceCardDetails
    @State private var isVerifiedProfile = false
    @State private var showingProfileUI = false
    @State private var showingAnotherSpace = false
    @State private var selectedSpaceId: String?
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    @Environment(\.shareURL) var shareURL

    var space: Space? {
        primitive.item
    }

    var body: some View {
        VStack(spacing: 0) {

            SpaceTopView(
                primitive: primitive,
                headerVisible: $headerVisible,
                addToAnotherSpace: addToAnotherSpace
            )

            profileUINavigationLink
            anotherSpaceNavigationLink

            if !(space?.isDigest ?? false) && primitive.allDetails.isEmpty && primitive.isFollowing
            {
                EmptySpaceView()
            } else {
                SpaceDetailList(
                    primitive: primitive,
                    headerVisible: $headerVisible,
                    isVerifiedProfile: $isVerifiedProfile,
                    onShowProfileUI: {
                        if isVerifiedProfile {
                            self.showingProfileUI = true
                        }
                    },
                    onShowAnotherSpace: { id in
                        selectedSpaceId = id
                        self.showingAnotherSpace = true
                    },
                    addToAnotherSpace: addToAnotherSpace)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: {
            getSpacesCount()
        })
    }

    private func getSpacesCount() {
        guard let id = space?.id.id else { return }
        SpaceStore.shared.getRelatedSpacesCount(with: id) { result in
            switch result {
            case .success(let count):
                self.isVerifiedProfile = count > 0
            case .failure:
                return
            }
        }
    }

    private func addToAnotherSpace(url: URL, title: String?, description: String?) {
        spacesModel.detailedSpace = nil
        SceneDelegate.getBVC(with: tabModel.manager.scene)
            .showAddToSpacesSheet(
                url: url, title: title, description: description)
    }

    private var profileUINavigationLink: some View {
        NavigationLink(isActive: $showingProfileUI) {
            if let space = space {
                SpacesProfileView(
                    spaceId: space.id.id,
                    onBackTap: {
                        self.showingProfileUI = false
                    },
                    owner: space.owner
                )
            }
        } label: {
            EmptyView()
        }
    }

    @ViewBuilder
    private var anotherSpaceNavigationLink: some View {
        NavigationLink(isActive: $showingAnotherSpace) {
            if let selectedId = selectedSpaceId {
                let primitive = SpaceCardDetails(id: selectedId, manager: SpaceStore.shared)
                SpaceContainerView(primitive: primitive)
                    .environment(\.onOpenURLForSpace, onOpenURLForSpace)
                    .environment(\.shareURL, shareURL)
            }
        } label: {
            EmptyView()
        }
    }

}

// Allows the NavigationView to keep the swipe back interaction,
// while also hiding the navigation bar.

//To-Do: Figurate a better way to do
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
