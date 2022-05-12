// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

// TODO(jon): Implement this class once SpaceService is sandwiched
// between Apollo and higher layers
public class SpaceServiceMock: SpaceService {
    public func createSpace(name: String) -> CreateSpaceRequest? {
        return nil
    }

    public func deleteSpace(spaceID: String) -> DeleteSpaceRequest? {
        return nil
    }

    public func deleteGenerator(spaceID: String, generatorID: String) -> DeleteGeneratorRequest? {
        return nil
    }

    public func unfollowSpace(spaceID: String) -> UnfollowSpaceRequest? {
        return nil
    }

    public func claimGeneratedItem(spaceID: String, entityID: String) -> ClaimGeneratedItem? {
        return nil
    }

    public func addSpaceComment(spaceID: String, comment: String) -> AddSpaceCommentRequest? {
        return nil
    }

    public func addPublicACL(spaceID: String) -> AddPublicACLRequest? {
        return nil
    }

    public func deletePublicACL(spaceID: String) -> DeletePublicACLRequest? {
        return nil
    }

    public func addSoloACLs(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String)
        -> AddSoloACLsRequest?
    {
        return nil
    }

    public func deleteSpaceItems(spaceID: String, ids: [String]) -> DeleteSpaceItemsRequest? {
        return nil
    }

    public func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) -> UpdateSpaceEntityRequest? {
        return nil
    }

    public func reorderSpace(spaceID: String, ids: [String]) -> ReorderSpaceRequest? {
        return nil
    }

    public func addToSpaceWithURL(spaceID: String, url: String, title: String, description: String?)
        -> AddToSpaceWithURLRequest?
    {
        return nil
    }

    public func updateProfile(firstName: String, lastName: String) -> UpdateProfileRequest? {
        return nil
    }

    public init() {}

    public func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String?, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable? {
        return nil
    }

    public func getSpacesData(
        spaceIds: [String],
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable? {
        return nil
    }

    public func getSpaces(
        completion: @escaping (Result<[SpaceListController.Space], Error>) -> Void
    ) -> Cancellable? {
        return nil
    }

    public func getRelatedSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable? {
        return nil
    }

    public func getRelatedSpacesCountData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable? {
        return nil
    }
}
