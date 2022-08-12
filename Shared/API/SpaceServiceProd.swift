// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

public class SpaceServiceProd: SpaceService {
    public func addPublicACL(spaceID: String) -> AddPublicACLRequest? {
        return AddPublicACLRequest(spaceID: spaceID)
    }

    public func addSoloACLs(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String)
        -> AddSoloACLsRequest?
    {
        return AddSoloACLsRequest(spaceID: spaceID, emails: emails, acl: acl, note: note)
    }

    public func addSpaceComment(spaceID: String, comment: String) -> AddSpaceCommentRequest? {
        return AddSpaceCommentRequest(spaceID: spaceID, comment: comment)
    }

    public func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String? = nil, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable? {
        let mutation = AddToSpaceMutation(
            input: AddSpaceResultByURLInput(
                spaceId: spaceId,
                url: url,
                title: title,
                thumbnail: thumbnail,
                data: data,
                mediaType: mediaType,
                isBase64: isBase64
            )
        )
        return GraphQLAPI.shared.perform(mutation: mutation, resultHandler: completion)
    }

    public func addToSpaceWithURL(spaceID: String, url: String, title: String, description: String?)
        -> AddToSpaceWithURLRequest?
    {
        return AddToSpaceWithURLRequest(
            spaceID: spaceID, url: url, title: title, description: description)
    }

    public func claimGeneratedItem(spaceID: String, entityID: String) -> ClaimGeneratedItem? {
        return ClaimGeneratedItem(spaceID: spaceID, entityID: entityID)
    }

    public func createSpace(name: String) -> CreateSpaceRequest? {
        return CreateSpaceRequest(name: name)
    }

    public func deleteGenerator(spaceID: String, generatorID: String) -> DeleteGeneratorRequest? {
        return DeleteGeneratorRequest(spaceID: spaceID, generatorID: generatorID)
    }

    public func deletePublicACL(spaceID: String) -> DeletePublicACLRequest? {
        return DeletePublicACLRequest(spaceID: spaceID)
    }

    public func deleteSpace(spaceID: String) -> DeleteSpaceRequest? {
        return DeleteSpaceRequest(spaceID: spaceID)
    }

    public func deleteSpaceItems(spaceID: String, ids: [String]) -> DeleteSpaceItemsRequest? {
        return DeleteSpaceItemsRequest(spaceID: spaceID, ids: ids)
    }

    public func deleteSpaceResultByUrlMutation(
        spaceId: String, url: String,
        completion: @escaping (Result<DeleteSpaceResultByUrlMutation.Data, Error>) -> Void
    ) -> Cancellable? {
        let mutation = DeleteSpaceResultByUrlMutation(
            input: DeleteSpaceResultByURLInput(
                spaceId: spaceId,
                url: url
            )
        )
        return GraphQLAPI.shared.perform(mutation: mutation, resultHandler: completion)
    }

    public func getRelatedSpacesCountData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable? {
        return RelatedSpacesCountQueryController.getSpacesData(
            spaceID: spaceID, completion: completion)
    }

    public func getRelatedSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable? {
        return RelatedSpacesQueryController.getSpacesData(spaceID: spaceID, completion: completion)
    }

    public func getSpaces(
        completion: @escaping (Result<[SpaceListController.Space], Error>) -> Void
    ) -> Cancellable? {
        return SpaceListController.getSpaces(completion: completion)
    }

    public func getSpacesData(
        anonymous: Bool,
        spaceIds: [String],
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable? {
        let api: GraphQLAPI = anonymous ? .anonymous : .shared
        return SpacesDataQueryController.getSpacesData(
            spaceIds: spaceIds,
            using: api,
            completion: completion
        )
    }

    public func reorderSpace(spaceID: String, ids: [String]) -> ReorderSpaceRequest? {
        return ReorderSpaceRequest(spaceID: spaceID, ids: ids)
    }

    public func pinSpace(spaceId: String, isPinned: Bool) -> PinSpaceRequest? {
        return PinSpaceRequest(spaceId: spaceId, isPinned: isPinned)
    }

    public func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) -> UpdateSpaceEntityRequest? {
        return UpdateSpaceEntityRequest(
            spaceID: spaceID, entityID: entityID, title: title, snippet: snippet,
            thumbnail: thumbnail)
    }

    public func unfollowSpace(spaceID: String) -> UnfollowSpaceRequest? {
        return UnfollowSpaceRequest(spaceID: spaceID)
    }

    public func updateProfile(firstName: String, lastName: String) -> UpdateProfileRequest? {
        return UpdateProfileRequest(firstName: firstName, lastName: lastName)
    }

    public func updateSpace(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) -> UpdateSpaceRequest? {
        return UpdateSpaceRequest(
            spaceID: spaceID, title: title, description: description, thumbnail: thumbnail)
    }
}
