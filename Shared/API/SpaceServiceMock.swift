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
        var isPublic: Bool
        var resultCount: Int = 0
        var isPinned: Bool = false

        // SpaceDataApollo properties
        var entities: [SpaceEntityData] = []

        var spaceApollo: SpaceApollo {
            SpaceApollo(
                pageMetadata: SpaceApollo.PageMetadatum(pageId: id),
                space: SpaceApollo.Space(
                    name: name,
                    lastModifiedTs: ISO8601DateFormatter().string(from: lastModifiedTs),
                    owner: SpaceApollo.Space.Owner(displayName: "Test User", pictureUrl: ""),
                    userAcl: SpaceApollo.Space.UserAcl(
                        acl: (isOwner ? SpaceACLLevel.owner : SpaceACLLevel.publicView)
                    ),
                    acl: [
                        SpaceApollo.Space.Acl(
                            userId: "0",
                            profile: SpaceApollo.Space.Acl.Profile(
                                displayName: "Test User", email: "testuser@example.com",
                                pictureUrl: ""
                            ),
                            acl: isOwner ? SpaceACLLevel.owner : SpaceACLLevel.publicView)
                    ],
                    hasPublicAcl: isPublic,
                    resultCount: resultCount,
                    isDefaultSpace: false,
                    isPinned: isPinned
                )
            )
        }

        var spaceDataApollo: SpaceDataApollo {
            SpaceDataApollo(
                id: id, name: name,
                owner: SpacesMetadata.Owner(
                    displayName: "Test User", pictureUrl: ""
                ),
                entities: entities,
                comments: [],
                generators: []
            )
        }

        init(name: String, isOwner: Bool = true, isPublic: Bool = false) {
            self.name = name
            self.isOwner = isOwner
            self.isPublic = isPublic
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

        static func handleMutationRequest<T: GraphQLMutation>(
            request: MutationRequest<T>, body: @escaping () -> Bool
        ) {
            // Using DispatchQueue.async simulates a network request, making the tests more realistic.
            DispatchQueue.main.async {
                if body() {
                    request.state = .success
                } else {
                    request.state = .failure
                }
            }
        }
    }

    public static let mySpaceTitle = "My Space"
    public static let spaceNotOwnedByMeTitle = "Space not owned by me"

    var spaces: [String: SpaceMock] = [:]

    public init() {
        let mySpace = SpaceMock(name: SpaceServiceMock.mySpaceTitle)
        let spaceNotOwnedByMe = SpaceMock(
            name: SpaceServiceMock.spaceNotOwnedByMeTitle, isOwner: false, isPublic: true)
        let spaceEntityTestsSpace = SpaceMock(name: "SpaceEntityTests Space")
        let spacePublicAclTestsSpace1 = SpaceMock(name: "SpacePublicAclTests Space1")
        let spacePublicAclTestsSpace2 = SpaceMock(
            name: "SpacePublicAclTests Space2", isPublic: true)

        spaces[mySpace.id] = mySpace
        spaces[spaceNotOwnedByMe.id] = spaceNotOwnedByMe
        spaces[spaceEntityTestsSpace.id] = spaceEntityTestsSpace
        spaces[spacePublicAclTestsSpace1.id] = spacePublicAclTestsSpace1
        spaces[spacePublicAclTestsSpace2.id] = spacePublicAclTestsSpace2

        // Populate the Spaces
        spaces[spaceNotOwnedByMe.id]?.addSpaceEntity(
            title: "MySpace",
            description:
                "This is a Space entity description that is very long and needs to be expanded in order to see the whole thing",
            url: "https://myspace.com")

        // For tests in SpaceEntityTests.swift
        spaces[spaceEntityTestsSpace.id]?.addSpaceEntity(
            title: "Example", url: "https://example.com")
        spaces[spaceEntityTestsSpace.id]?.addSpaceEntity(
            title: "Neeva", url: "https://neeva.com")
        spaces[spaceEntityTestsSpace.id]?.addSpaceEntity(
            title: "Yahoo", url: "https://yahoo.com")
        spaces[spaceEntityTestsSpace.id]?.addSpaceEntity(
            title: "Cnn", url: "https://cnn.com")

        // SpacePublicAclTests
        spaces[spacePublicAclTestsSpace1.id]?.addSpaceEntity(
            title: "Neeva", url: "https://neeva.com")
        spaces[spacePublicAclTestsSpace2.id]?.addSpaceEntity(
            title: "Neeva", url: "https://neeva.com")
    }

    public func addPublicACL(spaceID: String) -> AddPublicACLRequest? {
        let request = AddPublicACLRequest(spaceID: spaceID, testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            spaces[spaceID]?.isPublic = true
            return spaces[spaceID] != nil
        }

        return request
    }

    // TODO(jon): Waiting for solo ACL management to work better. See issue #3916
    public func addSoloACLs(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String)
        -> AddSoloACLsRequest?
    {
        return nil
    }

    // TODO(jon): Waiting for Space comment system to work better. See issue #3917
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

    // This can't really be tested because AddOrUpdateSpaceView already adds a new local entity.
    // However, this function is still implemented for completeness.
    public func addToSpaceWithURL(spaceID: String, url: String, title: String, description: String?)
        -> AddToSpaceWithURLRequest?
    {
        let request = AddToSpaceWithURLRequest(
            spaceID: spaceID, url: url, title: title, description: description, testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            if let space = spaces[spaceID] {
                space.addSpaceEntity(title: title, description: description ?? "", url: url)
            }
            return spaces[spaceID] != nil
        }

        return request
    }

    public func claimGeneratedItem(spaceID: String, entityID: String) -> ClaimGeneratedItem? {
        return nil
    }

    public func createSpace(name: String) -> CreateSpaceRequest? {
        let request = CreateSpaceRequest(name: name, testMode: true)

        // This operation is always successful
        SpaceMock.handleMutationRequest(request: request) { [self] in
            let space = SpaceMock(name: name)
            spaces[space.id] = space

            return true
        }

        return request
    }

    public func deleteGenerator(spaceID: String, generatorID: String) -> DeleteGeneratorRequest? {
        return nil
    }

    public func deletePublicACL(spaceID: String) -> DeletePublicACLRequest? {
        let request = DeletePublicACLRequest(spaceID: spaceID, testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            spaces[spaceID]?.isPublic = false
            return spaces[spaceID] != nil
        }

        return request
    }

    public func deleteSpace(spaceID: String) -> DeleteSpaceRequest? {
        let request = DeleteSpaceRequest(spaceID: spaceID, testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            spaces[spaceID] = nil
            return true
        }

        return request
    }

    public func deleteSpaceItems(spaceID: String, ids: [String]) -> DeleteSpaceItemsRequest? {
        let request = DeleteSpaceItemsRequest(spaceID: spaceID, ids: ids, testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            if let space = spaces[spaceID] {
                space.entities = space.entities.filter { !ids.contains($0.id) }
            }

            return spaces[spaceID] != nil
        }

        return request
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
                        guard id != SpaceConstants.suggestedSpaceId else { return }
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
        let request = PinSpaceRequest(spaceId: spaceId, isPinned: isPinned, testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            spaces[spaceId]?.isPinned = isPinned
            return spaces[spaceId] != nil
        }

        return request
    }

    public func unfollowSpace(spaceID: String) -> UnfollowSpaceRequest? {
        let request = UnfollowSpaceRequest(spaceID: spaceID, testMode: true)

        // This operation is always successful
        SpaceMock.handleMutationRequest(request: request) { [self] in
            spaces[spaceID] = nil
            return true
        }

        return request
    }

    public func updateProfile(firstName: String, lastName: String) -> UpdateProfileRequest? {
        return nil
    }

    // TODO(jon): update description and thumbnail
    public func updateSpace(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) -> UpdateSpaceRequest? {
        let request = UpdateSpaceRequest(
            spaceID: spaceID, title: title, description: description, thumbnail: thumbnail,
            testMode: true)

        SpaceMock.handleMutationRequest(request: request) { [self] in
            spaces[spaceID]?.name = title
            return spaces[spaceID] != nil
        }

        return request
    }

    public func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) -> UpdateSpaceEntityRequest? {
        return nil
    }
}
