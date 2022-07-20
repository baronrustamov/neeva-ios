// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SpaceDetailList: View {
    @Default(.showDescriptions) var showDescriptions
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    @Environment(\.shareURL) var shareURL
    @ObservedObject var primitive: SpaceCardDetails
    @Binding var headerVisible: Bool
    @Binding var isVerifiedProfile: Bool
    var onShowProfileUI: () -> Void
    let onShowAnotherSpace: (String) -> Void
    let addToAnotherSpace: (URL, String?, String?, String?) -> Void
    @State var addingComment = false
    @StateObject var spaceCommentsModel = SpaceCommentsModel()

    var canEdit: Bool {
        primitive.ACL >= .edit && !(primitive.item?.isDigest ?? false)
    }

    func descriptionForNote(_ details: SpaceEntityThumbnail) -> String? {
        if let snippet = details.data.snippet, snippet.contains("](@") {
            let index = snippet.firstIndex(of: "@")
            var substring = snippet.suffix(from: index!)
            if let endIndex = substring.firstIndex(of: ")") {
                substring = substring[..<endIndex]
                return snippet.replacingOccurrences(
                    of: substring,
                    with: SearchEngine.current.searchURLForQuery(String(substring))!.absoluteString)
            }
        }
        return details.data.snippet
    }

    var body: some View {
        VStack(spacing: 0) {
            if primitive.refreshSpaceSubscription != nil {
                progressView
            }

            ScrollViewReader { scrollReader in
                List {
                    if let space = primitive.item {
                        SpaceHeaderView(
                            space: space,
                            isVerifiedProfile: $isVerifiedProfile,
                            onShowProfileUI: onShowProfileUI
                        )
                        .modifier(ListSeparatorModifier())
                        .onAppear {
                            headerVisible = UIDevice.current.userInterfaceIdiom != .pad
                        }
                        .onDisappear {
                            headerVisible = false
                        }
                    }

                    if spacesModel.detailedSpace != nil && primitive.allDetails.isEmpty
                        && !(primitive.item?.isDigest ?? false) && primitive.isFollowing
                    {
                        EmptySpaceView()
                    }

                    ForEach(primitive.allDetails, id: \.id) { details in
                        let editSpaceItem = {
                            guard let space = primitive.item else {
                                return
                            }

                            SceneDelegate.getBVC(with: tabModel.manager.scene)
                                .showModal(
                                    style: .withTitle,
                                    toPosition: .top
                                ) {
                                    AddOrUpdateSpaceContent(
                                        space: space,
                                        config: .updateSpaceItem(details.id)
                                    ) { helpURL in
                                        SceneDelegate.getBVC(with: tabModel.manager.scene)
                                            .openURLInNewTab(helpURL)
                                    }
                                    .environmentObject(spacesModel)
                                }
                        }

                        SpaceEntityDetailView(
                            details: details,
                            onSelected: {
                                guard let url = details.data.url else { return }

                                if url.absoluteString.hasPrefix(
                                    NeevaConstants.appSpacesURL.absoluteString)
                                {
                                    let id = String(
                                        url.absoluteString.dropFirst(
                                            NeevaConstants.appSpacesURL.absoluteString.count + 1))
                                    onShowAnotherSpace(id)
                                    return
                                }

                                gridModel.closeDetailView()
                                browserModel.hideGridWithNoAnimation()
                                let bvc = SceneDelegate.getBVC(with: tabModel.manager.scene)
                                if let navPath = NavigationPath.navigationPath(
                                    from: url, with: bvc)
                                {
                                    NavigationPath.handle(nav: navPath, with: bvc)
                                    return
                                }

                                onOpenURLForSpace(url, primitive.id)
                            },
                            onDelete: { index in
                                onDelete(offsets: IndexSet([index]))
                            },
                            onPinToggle: { id, isPinned in
                                onPinToggle(spaceItemId: id, isPinned: isPinned)
                            },
                            addToAnotherSpace: addToAnotherSpace,
                            editSpaceItem: editSpaceItem,
                            index: primitive.allDetails.firstIndex { $0.id == details.id }
                                ?? 0,
                            canEdit: canEdit
                        )
                        .modifier(ListSeparatorModifier())
                        .listRowBackground(Color.DefaultBackground)
                        .onDrag {
                            NSItemProvider(id: details.id)
                        }
                    }
                    .onDelete(perform: canEdit ? onDelete : nil)
                    .onMove(perform: canEdit ? onMove : nil)

                    if let generators = primitive.item?.generators, !generators.isEmpty {
                        SpaceGeneratorHeader(generators: generators)
                            .modifier(ListSeparatorModifier())
                        ForEach(generators, id: \.id) { generator in
                            SpaceGeneratorView(generator: generator)
                                .modifier(ListSeparatorModifier())
                        }
                    }
                    if let space = primitive.item, !space.isDigest {
                        SpaceCommentsView(space: space, model: spaceCommentsModel)
                            .modifier(ListSeparatorModifier())
                            .id("CommentSection")
                    }
                }
                .modifier(ListStyleModifier(isDigest: primitive.item?.isDigest ?? false))
                .edgesIgnoringSafeArea([.top, .bottom])
                .keyboardListener { height in
                    guard height > 0 && addingComment else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            scrollReader.scrollTo("CommentSection", anchor: .bottom)
                        }
                    }
                }
                .useEffect(deps: spaceCommentsModel.addingComment) { addingComment in
                    self.addingComment = addingComment
                }
            }
            .ignoresSafeArea(.container)
        }
    }

    private var progressView: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(12)
            Spacer()
        }.background(Color.secondaryBackground)
    }

    private func onDelete(offsets: IndexSet) {
        let entitiesToBeDeleted = offsets.map { index in
            primitive.allDetails[index]
        }

        primitive.allDetails.remove(atOffsets: offsets)
        spacesModel.delete(
            space: primitive.id, entities: entitiesToBeDeleted, from: tabModel.manager.scene
        ) {
            for index in 0..<entitiesToBeDeleted.count {
                primitive.allDetails.insert(entitiesToBeDeleted[index], at: 0)
            }
        }
    }
    
    private func onPinToggle(spaceItemId: String, isPinned: Bool) {
        guard let index = primitive.item?.contentData?.firstIndex(where: { $0.id == spaceItemId }) else {
            return
        }
        primitive.item?.contentData?[index].isPinned = isPinned
        
        spacesModel.pinSpaceItem(spaceId: primitive.id, spaceItemId: spaceItemId, isPinned: isPinned)
    }

    private func onMove(source: IndexSet, destination: Int) {
        primitive.allDetails.move(fromOffsets: source, toOffset: destination)
        spacesModel.reorder(space: primitive.id, entities: primitive.allDetails.map { $0.id })
    }
}

struct CompactSpaceDetailList: View {
    let primitive: SpaceCardDetails
    let state: TriState
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace

    private var dataSource: [SpaceEntityThumbnail] {
        if state == .compact {
            return Array(primitive.allDetailsWithExclusionList.prefix(5))
        }
        return primitive.allDetailsWithExclusionList
    }

    var body: some View {
        VStack {

            ForEach(dataSource, id: \.id) { details in
                if let url = details.data.url {
                    Button(
                        action: {
                            onOpenURLForSpace(url, primitive.id)
                        },
                        label: {
                            HStack(alignment: .center, spacing: 12) {
                                details.thumbnail.frame(width: 36, height: 36).cornerRadius(8)
                                Text(details.title).withFont(.labelMedium).foregroundColor(.label)
                                    .lineLimit(1)
                                Spacer()
                            }.padding(.horizontal, 16)
                        })
                }
            }
        }
    }
}

struct ListSeparatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
                .listSectionSeparator(Visibility.hidden)
                .listRowSeparator(Visibility.hidden)
                .listSectionSeparatorTint(Color.secondaryBackground)
        } else {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
        }
    }
}

struct CompactSeparatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listSectionSeparator(Visibility.hidden)
                .listRowSeparator(Visibility.hidden)
        } else {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
                .padding(.horizontal, 16)
        }
    }
}

struct ListStyleModifier: ViewModifier {
    @Environment(\.onOpenURLForSpace) var openURLForSpace
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var spaceModel: SpaceCardModel

    var isDigest: Bool = false

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.plain)
                .background(Color.secondaryBackground)
                .environment(
                    \.openURL,
                    OpenURLAction(handler: {
                        openURLForSpace($0, spaceModel.detailedSpace!.id)
                        browserModel.hideGridWithNoAnimation()

                        return .handled
                    })
                )
                .if(!isDigest) {
                    $0.refreshable {
                        if let detailedSpace = self.spaceModel.detailedSpace {
                            detailedSpace.refresh()
                        }
                    }
                }
        } else {
            content
        }
    }
}
