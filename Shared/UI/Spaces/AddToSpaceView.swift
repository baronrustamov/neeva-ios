// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SwiftUI

public class AddToSpaceRequest: ObservableObject {
    var cancellable: Cancellable? = nil

    public let title: String
    public let description: String?  // meta description
    public let url: URL
    public let thumbnail: UIImage?
    public let updater: SocialInfoUpdater?

    public enum Mode {
        case saveToExistingSpace
        case saveToNewSpace

        public var title: LocalizedStringKey {
            switch self {
            case .saveToNewSpace:
                return "Create Space"
            case .saveToExistingSpace:
                return "Save to Spaces"
            }
        }
    }
    @Published public var mode: Mode = .saveToExistingSpace

    public enum State {
        case initial
        case creatingSpace
        case savingToSpace
        case savedToSpace
        case deletingFromSpace
        case deletedFromSpace
        case failed
    }
    @Published public var state: State = .initial

    // The results from a request. |targetSpaceName| is set on both
    // success and failure. |targetSpaceID| is only set on success.
    @Published public var targetSpaceName: String?
    @Published public var targetSpaceID: String?
    @Published public var error: Error?

    public var textInfo: (LocalizedStringKey, LocalizedStringKey, Bool) {
        switch self.state {
        case .initial:
            fatalError()
        case .creatingSpace, .savingToSpace:
            return ("Saving...", "Saved to \"\(self.targetSpaceName!)\"", false)
        case .savedToSpace:
            return (
                "Saved to \"\(self.targetSpaceName!)\"", "Saved to \"\(self.targetSpaceName!)\"",
                false
            )
        case .deletingFromSpace:
            return ("Deleting...", "Deleted from \"\(self.targetSpaceName!)\"", true)
        case .deletedFromSpace:
            return (
                "Deleted from \"\(self.targetSpaceName!)\"",
                "Deleted from \"\(self.targetSpaceName!)\"", true
            )
        default:
            return ("An error occured", "An error occured", false)
        }
    }

    /// - Parameters:
    ///   - title: The title of the newly created entity
    ///   - description: The description/snippet of the newly created entity
    ///   - url: The URL of the newly created entity
    public init(
        title: String, description: String?, url: URL,
        thumbnail: UIImage? = nil, updater: SocialInfoUpdater? = nil
    ) {
        self.title = title
        self.description = description
        self.url = url
        self.thumbnail = thumbnail
        self.updater = updater

        SpaceStore.shared.refresh()
    }

    func addToNewSpace(spaceName: String) {
        guard spaceName.count > 0 else { return }

        self.targetSpaceName = spaceName

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.cancellable = CreateSpaceMutation(
            name: spaceName
        ).perform { result in
            self.cancellable = nil
            switch result {
            case .success(let data):
                self.addToExistingSpace(id: data.createSpace, name: spaceName)
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
            }
        }
        withAnimation {
            self.state = .creatingSpace
        }
    }

    private func getThumbnailString(completion: @escaping (String?) -> Void) {
        guard let thumbnail = thumbnail else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard
                let data = thumbnail.jpegData(
                    compressionQuality: 0.7
                        - min(
                            0.4,
                            0.2 * floor(thumbnail.size.width / 1000)))
            else {
                completion(nil)
                return
            }

            completion(data.base64EncodedString())
        }
    }

    public func addToExistingSpace(id: String, name: String) {
        self.targetSpaceName = name

        getThumbnailString { thumbnailString in
            // Note: This creates a reference cycle between self and the mutation.
            // This means even if all other references are dropped to self, then
            // the mutation will attempt to run to completion.
            self.cancellable = SpaceServiceProvider.shared.addToSpaceMutation(
                spaceId: id, url: self.url.absoluteString, title: self.title,
                thumbnail: thumbnailString, data: self.description, mediaType: "text/plain",
                isBase64: false
            ) { result in
                self.cancellable = nil
                switch result {
                case .failure(let error):
                    self.error = error
                    withAnimation {
                        self.state = .failed
                    }
                    break
                case .success(_):
                    self.targetSpaceID = id
                    withAnimation {
                        self.state = .savedToSpace
                    }
                }
            }
        }

        withAnimation {
            self.state = .savingToSpace
        }
    }

    public func deleteFromExistingSpace(id: String, name: String) {
        self.targetSpaceName = name

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.cancellable = DeleteSpaceResultByUrlMutation(
            input: DeleteSpaceResultByURLInput(spaceId: id, url: self.url.absoluteString)
        ).perform { result in
            self.cancellable = nil
            switch result {
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
                break
            case .success(_):
                self.targetSpaceID = id
                withAnimation {
                    self.state = .deletedFromSpace
                }
                break
            }
        }
        withAnimation {
            self.state = .deletingFromSpace
        }
    }
}

public struct AddToSpaceView: View {
    @ObservedObject var request: AddToSpaceRequest
    @ObservedObject var spaceStore = SpaceStore.shared

    @State private var searchTerm = ""
    @State private var backgroundColor: Color? = nil
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
        if !searchTerm.isEmpty {
            return spaces.filter {
                $0.name.localizedCaseInsensitiveContains(searchTerm)
            }
        }
        return spaces
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
                ForEach(filteredSpaces, id: \.self) { space in
                    SpaceListItem(space, currentURL: request.url)
                        .onTapGesture {
                            if SpaceStore.shared.urlInSpace(request.url, spaceId: space.id) {
                                request.deleteFromExistingSpace(
                                    id: space.id.value, name: space.name)
                                onDismiss()
                            } else {
                                request.addToExistingSpace(id: space.id.value, name: space.name)
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
                    request.addToNewSpace(spaceName: $0)
                }
            } else {
                let spaceList = VStack {
                    if case .failed(_) = spaceStore.state {
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
            request: AddToSpaceRequest(
                title: "Hello, world!", description: "<h1>Testing!</h1>", url: "https://google.com"),
            onDismiss: { print("Done") })
    }
}
