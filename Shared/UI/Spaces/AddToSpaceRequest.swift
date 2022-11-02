// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SwiftUI

/// - TODO: (Jon) Sometimes we create this object and don't care about its state. So, for performance reasons, we should
/// figure out a way to create an `AddToSpaceRequest` object in a more memory-conserving manner.
public class AddToSpaceRequest: ObservableObject {
    var subscription: Cancellable?

    public let input: [AddToSpaceInput]
    public let updater: SocialInfoUpdater?

    /// Beware: This computed property will act funny when `input.count == 0`. Make sure that doesn't happen!
    public var isForOneTab: Bool {
        input.count == 1
    }

    public var singleTabData: AddToSpaceInput? {
        isForOneTab ? input.first : nil
    }

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

    public init?(input: [AddToSpaceInput], updater: SocialInfoUpdater? = nil) {
        guard !input.isEmpty else { return nil }

        self.input = input
        self.updater = updater

        // Do we need this?
        SpaceStore.shared.refresh()
    }

    func addToNewSpace(spaceName: String) {
        guard spaceName.count > 0 else { return }

        self.targetSpaceName = spaceName

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.subscription = GraphQLAPI.shared.perform(
            mutation: CreateSpaceMutation(name: spaceName)
        ) { [self] result in
            self.subscription = nil
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

    func addGroupToNewSpace(spaceName: String) {
        guard !spaceName.isEmptyOrWhitespace() else { return }

        self.targetSpaceName = spaceName

        subscription = SpaceStore.shared.addGroupToNewSpace(
            name: spaceName,
            group: input
        ) { [self] result in
            subscription?.cancel()
            switch result {
            case .success(let data):
                targetSpaceID = data.createSpaceWithUrLs?.spaceId
                SpaceStore.shared.refresh()
                state = .savedToSpace
            case .failure(let error):
                self.error = error
                state = .failed
            }
        }

        withAnimation {
            self.state = .creatingSpace
        }
    }

    public func addToExistingSpace(id: String, name: String) {
        guard input.count == 1, let first = input.first else { return }

        self.targetSpaceName = name

        let url = first.url
        let title = first.title
        let thumbnail = first.thumbnail
        let description = first.description

        self.subscription = SpaceServiceProvider.shared.addToSpaceMutation(
            spaceId: id,
            url: url.absoluteString,
            title: title,
            thumbnail: thumbnail,
            data: description,
            mediaType: "text/plain",
            isBase64: false
        ) { result in
            self.subscription = nil
            switch result {
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
                break
            case .success:
                self.targetSpaceID = id
                withAnimation {
                    self.state = .savedToSpace
                }
            }
        }

        withAnimation {
            self.state = .savingToSpace
        }
    }

    public func addGroupToExistingSpace(id: String, name: String) {
        self.targetSpaceName = name

        self.subscription = SpaceStore.shared.addGroupToExistingSpace(
            spaceID: id,
            group: input
        ) {
            [self] result in
            subscription?.cancel()
            switch result {
            case .success(_):
                targetSpaceID = id
                withAnimation {
                    self.state = .savedToSpace
                }
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
            }
        }

        withAnimation {
            self.state = .savingToSpace
        }
    }

    public func deleteFromExistingSpace(id: String, name: String) {
        guard input.count == 1, let first = input.first else { return }

        self.targetSpaceName = name

        let url = first.url

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.subscription = SpaceStore.shared.sendRemoveItemFromSpaceRequest(
            spaceId: id, url: url.absoluteString
        ) { result in
            self.subscription = nil
            switch result {
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
                break
            case .success:
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
