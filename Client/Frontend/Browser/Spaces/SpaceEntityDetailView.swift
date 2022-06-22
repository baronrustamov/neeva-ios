// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

struct SpaceEntityDetailView: View {
    @Default(.showDescriptions) var showDescriptions
    @EnvironmentObject var spaceCardModel: SpaceCardModel
    let details: SpaceEntityThumbnail
    let onSelected: () -> Void
    let onDelete: (Int) -> Void
    let addToAnotherSpace: (URL, String?, String?) -> Void
    let editSpaceItem: () -> Void
    let index: Int
    var canEdit: Bool

    @State private var isPressed: Bool = false
    @State private var isPreviewActive: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if index > 0 {
                Color.secondaryBackground.frame(height: 2).edgesIgnoringSafeArea(.top)
                Spacer(minLength: 0)
            }

            let spaceLink: SpaceID? = {
                if case .spaceLink(let id) = details.data.previewEntity {
                    return id
                }
                return nil
            }()

            if spaceLink == nil, details.data.url != nil {
                SpaceListContentView(
                    details: details,
                    editSpaceItem: editSpaceItem,
                    onSelected: onSelected
                )
            } else if let spaceLink = spaceLink,
                let destinationDetails = spaceCardModel.allDetails.first(where: {
                    $0.id == spaceLink.id
                })
            {
                let isDigestSeeMore = details.id == .init(SpaceStore.dailyDigestSeeMoreID)

                NavigationLink(
                    destination: SpaceContainerView(primitive: destinationDetails)
                ) {
                    SpaceNoteEntityView(
                        details: details, showDescriptions: showDescriptions,
                        isDigestSeeMore: isDigestSeeMore)
                }
            } else {
                // notes and section title
                SpaceNoteEntityView(
                    details: details, showDescriptions: showDescriptions
                )
            }

        }
        .if(canEdit) {
            $0.modifier(
                SpaceActionsModifier(
                    details: details,
                    keepNewsItem: {
                        details.data.generatorID = nil
                        spaceCardModel.claimGeneratedItem(
                            spaceID: details.spaceID, entityID: details.id)
                    },
                    onDelete: {
                        onDelete(index)
                    }, addToAnotherSpace: addToAnotherSpace, editSpaceItem: editSpaceItem)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1)
        .accessibilityLabel(details.title)
        .accessibilityHint("Space Item")
    }

}

struct DescriptionTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color.secondaryLabel)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpaceActionsModifier: ViewModifier {
    let details: SpaceEntityThumbnail
    let keepNewsItem: () -> Void
    let onDelete: () -> Void
    let addToAnotherSpace: (URL, String?, String?) -> Void
    let editSpaceItem: () -> Void

    var isNewsItem: Bool {
        switch details.data.previewEntity {
        case .newsItem(_):
            return true
        default:
            return false
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "")
                    }

                    if details.data.generatorID != nil && isNewsItem {
                        Button {
                            keepNewsItem()
                        } label: {
                            Label("Keep", systemImage: "")
                        }.tint(.blue)
                    } else {
                        Button {
                            addToAnotherSpace(
                                (details.data.url)!,
                                details.title, details.description)
                        } label: {
                            Label("Add To", systemImage: "")
                        }.tint(.gray)

                        Button {
                            editSpaceItem()
                        } label: {
                            Label("Edit", systemImage: "")
                        }.tint(.blue)
                    }
                }
        } else {
            content
                .contextMenu(
                    ContextMenu(menuItems: {
                        if details.ACL >= .edit {
                            Button(
                                action: {
                                    editSpaceItem()
                                },
                                label: {
                                    Label("Edit item", systemSymbol: .squareAndPencil)
                                })
                        }
                        Button(
                            action: {
                                addToAnotherSpace(
                                    (details.data.url)!,
                                    details.title, details.description)
                            },
                            label: {
                                Label("Add to another Space", systemSymbol: .docOnDoc)
                            })
                    })
                )
        }
    }
}

struct EditSpaceActionModifier: ViewModifier {
    let details: SpaceEntityThumbnail
    let onDelete: (Int) -> Void
    let editSpaceItem: () -> Void
    let index: Int

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDelete(index)
                    } label: {
                        Label("Delete", systemImage: "")
                    }

                    Button {
                        editSpaceItem()
                    } label: {
                        Label("Edit", systemImage: "")
                    }.tint(.blue)
                }
        } else {
            content
                .contextMenu(
                    ContextMenu(menuItems: {
                        if details.ACL >= .edit {
                            Button(
                                action: {
                                    editSpaceItem()
                                },
                                label: {
                                    Label("Edit item", systemSymbol: .squareAndPencil)
                                })
                        }
                    })
                )
        }
    }
}
