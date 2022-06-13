// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SpaceTopView: View {
    @Default(.showDescriptions) var showDescriptions
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURL) var onOpenURL
    @Environment(\.shareURL) var shareURL
    @State private var shareTargetView: UIView? = nil
    @State private var showConfirmDeleteAlert = false
    @ObservedObject var primitive: SpaceCardDetails
    @Binding var headerVisible: Bool
    let addToAnotherSpace: (URL, String?, String?) -> Void
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var space: Space?

    var canEdit: Bool {
        primitive.ACL >= .edit
    }

    var ownerName: String? {
        space?.acls.first(where: { $0.acl == .owner })?.profile.displayName
    }

    var body: some View {
        HStack {
            Button(
                action: {
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    Symbol(.arrowBackward, label: "Return to all Spaces view")
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                })
            titleView
                .opacity(headerVisible ? 0 : 1)
                .animation(.easeInOut, value: headerVisible)
            Spacer()
            if headerVisible {
                if canEdit {
                    addButton
                    editButton
                }
                layoutButton
            }
            shareButton

            if let space = space,
                !space.isDigest
            {
                menuButton
            }
        }.frame(height: gridModel.pickerHeight)
            .frame(maxWidth: .infinity)
            .background(Color.DefaultBackground.ignoresSafeArea())
    }

    @ViewBuilder var titleView: some View {
        if let ownerName = ownerName {
            VStack(alignment: .leading, spacing: 0) {
                Text(primitive.title)
                    .withFont(.headingSmall)
                    .foregroundColor(Color.label)
                Text(ownerName)
                    .withFont(.bodyXSmall)
                    .foregroundColor(Color.secondaryLabel)
            }
        } else {
            Text(primitive.title)
                .withFont(.headingMedium)
                .foregroundColor(Color.label)
        }
    }

    @ViewBuilder var addButton: some View {
        if let space = space {
            Button(
                action: {
                    DispatchQueue.main.async {
                        SceneDelegate.getBVC(with: tabModel.manager.scene).showModal(
                            style: .spaces,
                            toPosition: .top
                        ) {
                            AddOrUpdateSpaceContent(space: space, config: .addSpaceItem) {
                                helpURL in
                                SceneDelegate.getBVC(with: tabModel.manager.scene).openURLInNewTab(
                                    helpURL)
                            }.environmentObject(spacesModel)
                        }
                    }
                },
                label: {
                    if !headerVisible {
                        Label(
                            title: {
                                Text("Add Item")
                                    .withFont(.labelMedium)
                                    .foregroundColor(Color.label)
                            },
                            icon: { Image(systemName: "plus.square") }
                        )
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(.label)
                            .tapTargetFrame()
                    }
                }
            )
        }
    }

    @ViewBuilder var shareButton: some View {
        if let space = space,
            !space.isDefaultSpace && !space.isDigest
        {
            Button(
                action: {
                    if case .owner = space.userACL {
                        SceneDelegate.getBVC(with: tabModel.manager.scene)
                            .showModal(style: .spaces) {
                                ShareSpaceContent(
                                    space: space,
                                    shareTargetView: shareTargetView ?? UIView(),
                                    fromAddToSpace: false,
                                    noteText: "Check out my Neeva Space!"
                                )
                                .environmentObject(spacesModel)
                                .environmentObject(tabModel)
                                .environment(\.onOpenURL) { url in
                                    browserModel.hideGridWithNoAnimation()
                                    spacesModel.detailedSpace = nil
                                    onOpenURL(url)
                                }
                                .environment(\.shareURL, shareURL)
                            }
                    } else {
                        shareURL(space.url, shareTargetView ?? UIView())
                        ClientLogger.shared.logCounter(
                            .FollowerSharedSpace,
                            attributes: getLogCounterAttributesForSpaces(
                                details: primitive))
                    }
                    ClientLogger.shared.logCounter(
                        .SpacesDetailShareButtonClicked,
                        attributes: EnvironmentHelper.shared.getAttributes())
                },
                label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                }
            ).uiViewRef($shareTargetView)
        }
    }

    @ViewBuilder var editButton: some View {
        if let space = space {
            Button(
                action: {
                    SceneDelegate.getBVC(with: tabModel.manager.scene)
                        .showModal(
                            style: .spaces,
                            toPosition: .top
                        ) {
                            AddOrUpdateSpaceContent(space: space, config: .updateSpace)
                                .environmentObject(spacesModel)
                        }
                    ClientLogger.shared.logCounter(
                        .SpacesDetailEditButtonClicked,
                        attributes: EnvironmentHelper.shared.getAttributes())
                },
                label: {
                    if !headerVisible {
                        Label(
                            title: {
                                Text("Edit Space")
                                    .withFont(.labelMedium)
                                    .foregroundColor(Color.label)
                            },
                            icon: { Image(systemName: "square.and.pencil") }
                        )
                    } else {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.label)
                            .tapTargetFrame()
                    }
                })
        }
    }

    @ViewBuilder var openAllURLsButton: some View {
        if let space = space, let urls = space.contentURLs {
            Button {
                self.tabModel.manager.addTabsForURLs(
                    Array(urls), shouldSelectTab: false, rootUUID: space.id.id)
                self.gridModel.closeDetailView(switchToTabs: true)
            } label: {
                Label("Open all Space links", systemSymbol: .arrowUpRight)
            }
        }
    }

    @ViewBuilder var followButton: some View {
        Button {
            if !primitive.isFollowing, let spaceId = space?.id.id {
                SpaceStore.followSpace(spaceId: spaceId) {
                    SpaceStore.shared.refresh()
                }
            } else {
                showConfirmDeleteAlert = true
            }
        } label: {
            Label(
                title: {
                    Text(primitive.isFollowing ? "Unfollow" : "Follow")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                },
                icon: { Image(systemName: primitive.isFollowing ? "trash" : "plus") }
            )
        }
    }

    @ViewBuilder var deleteButton: some View {
        Button {
            showConfirmDeleteAlert = true
        } label: {
            Label(
                title: {
                    Text("Delete Space")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                },
                icon: { Image(systemName: "trash") }
            )
        }
    }

    @ViewBuilder var addToAnotherSpaceButton: some View {
        if let space = space {
            Button {
                self.addToAnotherSpace(space.url, space.displayTitle, space.description)
            } label: {
                Label("Add to another Space", systemSymbol: .docOnDoc)
            }

        }
    }

    var descriptionToggle: some View {
        Toggle(isOn: $showDescriptions) {
            Text("Show Descriptions")
                .withFont(.labelMedium)
                .foregroundColor(.secondaryLabel)
        }
    }

    var layoutButton: some View {
        Button(
            action: { showDescriptions.toggle() },
            label: {
                (showDescriptions
                    ? Symbol(.arrowDownRightAndArrowUpLeft, label: "Collapse descriptions")
                    : Symbol(.arrowUpLeftAndArrowDownRight, label: "Expand descriptions"))
                    .foregroundColor(Color.label)
                    .tapTargetFrame()
            }
        )
    }

    @ViewBuilder var menuButton: some View {
        Menu(
            content: {
                if let space = space, !space.isDefaultSpace {
                    if space.ACL == .owner {
                        deleteButton
                    } else {
                        followButton
                    }
                    addToAnotherSpaceButton
                }

                openAllURLsButton

                if !headerVisible {
                    if canEdit {
                        addButton
                        editButton
                    }
                    descriptionToggle
                }
            },
            label: {
                Symbol(decorative: .ellipsis, style: .labelMedium)
                    .foregroundColor(Color.label)
                    .tapTargetFrame()
            }
        ).actionSheet(isPresented: $showConfirmDeleteAlert) {
            ActionSheet(
                title: Text(
                    "Are you sure you want to " + (space?.ACL == .owner ? "delete" : "unfollow")
                        + " this space?"),
                buttons: [
                    .destructive(
                        Text(space?.ACL == .owner ? "Delete Space" : "Unfollow Space"),
                        action: {
                            gridModel.closeDetailView()

                            guard
                                let index = spacesModel.allDetails.firstIndex(where: {
                                    primitive.id == $0.id
                                })
                            else {
                                return
                            }
                            spacesModel.allDetails.remove(at: index)
                            if let space = space {
                                spacesModel.removeSpace(
                                    spaceID: space.id.id, isOwner: space.ACL == .owner
                                )
                            }
                        }),
                    .cancel(),
                ])
        }
    }

}
