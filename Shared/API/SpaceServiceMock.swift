// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import Foundation

public class SpaceServiceMock: SpaceService {
    public typealias SpaceApollo = SpaceListController.Space
    public typealias SpaceDataApollo = SpacesDataQueryController.Space

    class SpaceMock {
        // SpaceApollo properties
        var id: String = UUID().uuidString
        var name: String
        var lastModifiedTs: Date = Date()
        var isOwner: Bool
        var resultCount: Int = 0

        // SpaceDataApollo properties
        var entities: [SpaceEntityData] = []

        var spaceApollo: SpaceApollo {
            SpaceApollo(
                pageMetadata: SpaceApollo.PageMetadatum(pageId: id),
                space: SpaceApollo.Space(
                    name: name,
                    lastModifiedTs: ISO8601DateFormatter().string(from: lastModifiedTs),
                    userAcl: SpaceApollo.Space.UserAcl(
                        acl: (isOwner ? SpaceACLLevel.owner : SpaceACLLevel.publicView)
                    ),
                    // Assume that "my" Spaces are private, and all others are public
                    hasPublicAcl: !isOwner,
                    resultCount: resultCount,
                    isDefaultSpace: false
                )
            )
        }

        var spaceDataApollo: SpaceDataApollo {
            SpaceDataApollo(id: id, name: name, entities: entities, comments: [], generators: [])
        }

        init(name: String, isOwner: Bool = true) {
            self.name = name
            self.isOwner = isOwner
        }

        @discardableResult
        func addSpaceEntity(title: String = "", description: String = "", url: String = "")
            -> String
        {
            let id = UUID().uuidString
            resultCount += 1
            entities.append(
                SpaceEntityData(
                    id: id,
                    url: URL(string: url),
                    title: title,
                    snippet: description,
                    thumbnail: "",
                    previewEntity: .webPage
                )
            )
            return id
        }

        @discardableResult
        func removeSpaceEntity(url: String) -> Bool {
            resultCount -= 1
            entities = entities.filter {
                $0.url?.absoluteString != url
            }
            // This operation is always successful.
            return true
        }
    }

    public static let mySpaceTitle = "My Space"
    public static let spaceNotOwnedByMeTitle = "Space not owned by me"

    var spaces: [String: SpaceMock] = [:]

    public init() {
        let mySpace = SpaceMock(name: SpaceServiceMock.mySpaceTitle)
        let spaceNotOwnedByMe = SpaceMock(
            name: SpaceServiceMock.spaceNotOwnedByMeTitle, isOwner: false)

        spaces[mySpace.id] = mySpace
        spaces[spaceNotOwnedByMe.id] = spaceNotOwnedByMe

        // Populate the Spaces
        spaces[spaceNotOwnedByMe.id]?.addSpaceEntity(
            title: "MySpace",
            description:
                "This is a Space entity description that is very long and needs to be expanded in order to see the whole thing",
            url: "https://myspace.com")
    }

    public func addPublicACL(spaceID: String) -> AddPublicACLRequest? {
        return nil
    }

    public func addSoloACLs(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String)
        -> AddSoloACLsRequest?
    {
        return nil
    }

    public func addSpaceComment(spaceID: String, comment: String) -> AddSpaceCommentRequest? {
        return nil
    }

    public func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String?, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Combine.Cancellable? {
        let entityId = (spaces[spaceId]?.addSpaceEntity(title: title, url: url))!

        // Simulate a network request
        DispatchQueue.main.async {
            completion(
                Result<AddToSpaceMutation.Data, Error>(catching: {
                    return AddToSpaceMutation.Data(entityId: entityId)
                })
            )
        }

        return AnyCancellable {
            // do nothing
        }
    }

    public func addToSpaceWithURL(spaceID: String, url: String, title: String, description: String?)
        -> AddToSpaceWithURLRequest?
    {
        return nil
    }

    public func claimGeneratedItem(spaceID: String, entityID: String) -> ClaimGeneratedItem? {
        return nil
    }

    public func createSpace(name: String) -> CreateSpaceRequest? {
        let space = SpaceMock(name: name)
        spaces[space.id] = space

        let request = CreateSpaceRequest()

        // Simulate a network request
        DispatchQueue.main.async {
            request.state = .success
        }

        return request
    }

    public func deleteGenerator(spaceID: String, generatorID: String) -> DeleteGeneratorRequest? {
        return nil
    }

    public func deletePublicACL(spaceID: String) -> DeletePublicACLRequest? {
        return nil
    }

    public func deleteSpace(spaceID: String) -> DeleteSpaceRequest? {
        spaces[spaceID] = nil
        return DeleteSpaceRequest()
    }

    public func deleteSpaceItems(spaceID: String, ids: [String]) -> DeleteSpaceItemsRequest? {
        return nil
    }

    public func deleteSpaceResultByUrlMutation(
        spaceId: String, url: String,
        completion: @escaping (Result<DeleteSpaceResultByUrlMutation.Data, Error>) -> Void
    ) -> Combine.Cancellable? {
        let success = (spaces[spaceId]?.removeSpaceEntity(url: url))!

        // Simulate a network request
        DispatchQueue.main.async {
            completion(
                Result<DeleteSpaceResultByUrlMutation.Data, Error>(catching: {
                    return DeleteSpaceResultByUrlMutation.Data(deleteSpaceResultByUrl: success)
                })
            )
        }

        return AnyCancellable {
            // do nothing
        }
    }

    public func getRelatedSpacesCountData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Combine.Cancellable? {
        return nil
    }

    public func getRelatedSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Combine.Cancellable? {
        return nil
    }

    public func getSpaces(
        completion: @escaping (Result<[SpaceApollo], Error>) -> Void
    ) -> Combine.Cancellable? {
        return AnyCancellable({ [self] in
            completion(
                Result<[SpaceApollo], Error>(catching: {
                    return spaces.map { $0.value.spaceApollo }
                }))
        })
    }

    public func getSpacesData(
        spaceIds: [String],
        completion: @escaping (Result<[SpaceDataApollo], Error>) -> Void
    ) -> Combine.Cancellable? {
        return AnyCancellable({ [self] in
            completion(
                Result<[SpaceDataApollo], Error>(catching: {
                    var arr: [SpaceDataApollo] = []
                    spaceIds.forEach { id in
                        // ignore suggested space
                        guard id != "RMB2VXVA5vvSSw1tvVG2ShtnkRZE2CqJmzlgqzYb" else { return }
                        if let match = spaces[id] {
                            arr.append(match.spaceDataApollo)
                        }
                    }
                    return arr
                })
            )
        })
    }

    public func reorderSpace(spaceID: String, ids: [String]) -> ReorderSpaceRequest? {
        return nil
    }

    public func pinSpace(spaceId: String, isPinned: Bool) -> PinSpaceRequest? {
        return nil
    }

    public func unfollowSpace(spaceID: String) -> UnfollowSpaceRequest? {
        spaces[spaceID] = nil
        return UnfollowSpaceRequest()
    }

    public func updateProfile(firstName: String, lastName: String) -> UpdateProfileRequest? {
        return nil
    }

    // TODO(jon): update description and thumbnail
    public func updateSpace(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) -> UpdateSpaceRequest? {
        spaces[spaceID]?.name = title
        return UpdateSpaceRequest()
    }

    public func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) -> UpdateSpaceEntityRequest? {
        return nil
    }
}
