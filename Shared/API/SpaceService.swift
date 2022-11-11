// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

public protocol SpaceService {
    @discardableResult
    func addPublicACL(spaceID: String) -> AddPublicACLRequest?

    @discardableResult
    func addSoloACLs(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String)
        -> AddSoloACLsRequest?

    @discardableResult
    func addSpaceComment(spaceID: String, comment: String) -> AddSpaceCommentRequest?

    @discardableResult
    func addSpaceResultsByUrlMutation(
        input: AddSpaceResultsByURLInput,
        completion: @escaping (Result<AddSpaceResultsByUrlMutation.Data, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String?, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func addToSpaceWithURL(spaceID: String, url: String, title: String, description: String?)
        -> AddToSpaceWithURLRequest?

    @discardableResult
    func claimGeneratedItem(spaceID: String, entityID: String) -> ClaimGeneratedItem?

    @discardableResult
    func createSpace(name: String) -> CreateSpaceRequest?

    @discardableResult
    func createSpaceWithURLs(
        name: String, urls: [SpaceURLInput],
        completion: @escaping (Result<CreateSpaceWithUrLsMutation.Data, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func deleteGenerator(spaceID: String, generatorID: String) -> DeleteGeneratorRequest?

    @discardableResult
    func deletePublicACL(spaceID: String) -> DeletePublicACLRequest?

    @discardableResult
    func deleteSpace(spaceID: String) -> DeleteSpaceRequest?

    @discardableResult
    func deleteSpaceItems(spaceID: String, ids: [String]) -> DeleteSpaceItemsRequest?

    @discardableResult
    func deleteSpaceResultByUrlMutation(
        spaceId: String, url: String,
        completion: @escaping (Result<DeleteSpaceResultByUrlMutation.Data, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getRelatedSpacesCountData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getRelatedSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getSpaces(
        completion: @escaping (Result<[SpaceListController.Space], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getSpacesData(
        anonymous: Bool,
        spaceIds: [String],
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func reorderSpace(spaceID: String, ids: [String]) -> ReorderSpaceRequest?

    @discardableResult
    func pinSpace(spaceId: String, isPinned: Bool) -> PinSpaceRequest?

    @discardableResult
    func unfollowSpace(spaceID: String) -> UnfollowSpaceRequest?

    @discardableResult
    func updateProfile(firstName: String, lastName: String) -> UpdateProfileRequest?

    @discardableResult
    func updateSpace(
        spaceID: String, title: String,
        description: String?, thumbnail: String?
    ) -> UpdateSpaceRequest?

    @discardableResult
    func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) -> UpdateSpaceEntityRequest?
}

// !! WARNING !!
// Be very careful with extension hacks that allow default parameters in a protocol.
// The compiler does not enforce SpaceService implementers to implement these functions.
// That means at runtime, this could lead to an infinite loop.
extension SpaceService {
    func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String? = nil, data: String? = nil, mediaType: String?, isBase64: Bool? = nil,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable? {
        return addToSpaceMutation(
            spaceId: spaceId, url: url, title: title, thumbnail: thumbnail, data: data,
            mediaType: mediaType, isBase64: isBase64, completion: completion)
    }

    public func updateSpace(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) -> UpdateSpaceRequest? {
        return updateSpace(
            spaceID: spaceID, title: title, description: description, thumbnail: thumbnail)
    }
}
