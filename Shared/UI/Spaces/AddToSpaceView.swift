// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SwiftUI

public struct AddToSpaceView: View {
    @ObservedObject var request: AddToSpaceRequest
    @ObservedObject var spaceStore = SpaceStore.shared

    @State private var searchTerm = ""
    @State private var backgroundColor: Color?
    @State private var height: CGFloat = 0

    let onDismiss: () -> Void
    let importData: SpaceImportHandler?

    public init(
        request: AddToSpaceRequest,
        onDismiss: @escaping () -> Void = {},
        importData: SpaceImportHandler? = nil
    ) {
        self.request = request
        self.onDismiss = onDismiss
        self.importData = importData
    }

    func filter(_ spaces: [Space]) -> [Space] {
        // Put the pinned Spaces first
        let sortedSpaces = spaces.sorted {
            return $0.isPinned && !$1.isPinned
        }

        if !searchTerm.isEmpty {
            return sortedSpaces.filter {
                $0.name.localizedCaseInsensitiveContains(searchTerm)
            }
        }
        return sortedSpaces
    }

    var searchHeader: some View {
        SpacesSearchHeaderView(
            searchText: $searchTerm,
            createAction: {
                withAnimation {
                    request.mode = .saveToNewSpace
                }
            },
            onDismiss: onDismiss,
            importData: importData
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    var filteredListView: some View {
        let filteredSpaces = filter(spaceStore.editableSpaces)
        if !searchTerm.isEmpty && filteredSpaces.isEmpty {
            Text("No Results Found")
                .font(.title)
                .foregroundColor(.secondaryLabel)
                .padding(.top, 16)
        } else {
            LazyVStack(spacing: 14) {
                if request.isForOneTab, let url = request.singleTabData?.url {
                    ForEach(filteredSpaces, id: \.self) { space in
                        AddToSpaceListItem(space, currentURL: url)
                            .onTapGesture {
                                if SpaceStore.shared.urlInSpace(url, spaceId: space.id) {
                                    request.deleteFromExistingSpace(
                                        id: space.id.value, name: space.name)
                                    onDismiss()
                                } else {
                                    request.addToExistingSpace(id: space.id.value, name: space.name)
                                }
                            }
                    }
                } else {
                    // Tab Group
                    ForEach(filteredSpaces, id: \.self) { space in
                        AddToSpaceListItem(space)
                            .onTapGesture {
                                request.addGroupToExistingSpace(
                                    id: space.id.value, name: space.name)
                            }
                    }
                }
            }
            .padding(.bottom, 16)
        }
    }

    public var body: some View {
        Group {
            if request.mode == .saveToNewSpace {
                CreateSpaceView {
                    request.isForOneTab
                        ? request.addToNewSpace(spaceName: $0)
                        : request.addGroupToNewSpace(spaceName: $0)
                }
            } else {
                let spaceList = VStack {
                    if case .failed = spaceStore.state {
                    } else {
                        searchHeader
                    }

                    switch spaceStore.state {
                    case .refreshing:
                        VStack(spacing: 14) {
                            ForEach(0..<20) { _ in
                                LoadingSpaceListItem()
                                    .padding(.vertical, 10)
                                    .padding(.leading, 16)
                            }
                        }
                    case .mutatingLocally:
                        EmptyView()
                    case .failed(let error):
                        ErrorView(error, in: self, tryAgain: { spaceStore.refresh() })
                            .frame(maxHeight: .infinity)
                    case .ready:
                        filteredListView
                    }
                }

                if let bg = backgroundColor {
                    spaceList.background(bg.ignoresSafeArea())
                } else {
                    spaceList
                }
            }
        }.onPreferenceChange(ErrorViewBackgroundPreferenceKey.self) {
            self.backgroundColor = $0
        }
    }
}

struct AddToSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddToSpaceView(
            request: AddToSpaceRequest(input: [
                AddToSpaceInput(
                    url: "https://google.com", title: "Hello, world!",
                    description: "<h1>Testing!</h1>"
                )
            ])!,
            onDismiss: { print("Done") })
    }
}
