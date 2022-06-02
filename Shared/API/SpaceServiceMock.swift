// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import Foundation

// TODO(jon): Implement this class once SpaceService is sandwiched
// between Apollo and higher layers
public class SpaceServiceMock: SpaceService {
    private var spaces: [String: SpaceListController.Space] = [
        "wqQAiI6dmZItMkri9FRIxj26vjdeKJ8SvQWH93gh": SpaceListController.Space(unsafeResultMap: [
            "__typename": "Space",
            "pageMetadata": [
                "__typename": "PageMetadata",
                "pageID": "wqQAiI6dmZItMkri9FRIxj26vjdeKJ8SvQWH93gh",
            ],
            "space": [
                "isDefaultSpace": false,
                "notifications": nil,
                "__typename": "SpaceData",
                "resultCount": 1,
                "userACL": [
                    "acl": SpaceACLLevel.owner
                ],
                "name": "My Space",
                "lastModifiedTs": "2022-05-13T16:17:26Z",
            ],
        ])
    ]
    private var spacesData: [String: SpacesDataQueryController.Space] = [
        "wqQAiI6dmZItMkri9FRIxj26vjdeKJ8SvQWH93gh": SpacesDataQueryController.Space(
            id: "wqQAiI6dmZItMkri9FRIxj26vjdeKJ8SvQWH93gh",
            name: "My Space",
            entities: [
                SpaceEntityData(
                    id: "0x457d7904325b224d",
                    url: URL(stringLiteral: "http://myspace.com"),
                    title: "MySpace in My Space",
                    snippet: "", thumbnail: "",
                    previewEntity: .webPage)
            ], comments: [], generators: [])
    ]

    public init() {}

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
        // The choice of this value has no significance. We just need something unique
        let entityId = "\(Date.timeIntervalSinceReferenceDate)"

        spacesData[spaceId]?.entities.append(
            SpaceEntityData(
                id: entityId,
                url: URL(string: url),
                title: title,
                snippet: nil,
                thumbnail: nil,
                previewEntity: .webPage
            )
        )

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
        return nil
    }

    public func deleteGenerator(spaceID: String, generatorID: String) -> DeleteGeneratorRequest? {
        return nil
    }

    public func deletePublicACL(spaceID: String) -> DeletePublicACLRequest? {
        return nil
    }

    public func deleteSpace(spaceID: String) -> DeleteSpaceRequest? {
        return nil
    }

    public func deleteSpaceItems(spaceID: String, ids: [String]) -> DeleteSpaceItemsRequest? {
        return nil
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
        completion: @escaping (Result<[SpaceListController.Space], Error>) -> Void
    ) -> Combine.Cancellable? {
        return AnyCancellable({ [self] in
            completion(
                Result<[SpaceListController.Space], Error>(catching: {
                    return spaces.map { $0.value }
                }))
        })
    }

    public func getSpacesData(
        spaceIds: [String],
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Combine.Cancellable? {
        return AnyCancellable({ [self] in
            completion(
                Result<[SpacesDataQueryController.Space], Error>(catching: {
                    var arr: [SpacesDataQueryController.Space] = []
                    spaceIds.forEach { id in
                        if spacesData[id] != nil {
                            arr.append(spacesData[id]!)
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

    public func unfollowSpace(spaceID: String) -> UnfollowSpaceRequest? {
        return nil
    }

    public func updateProfile(firstName: String, lastName: String) -> UpdateProfileRequest? {
        return nil
    }

    public func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) -> UpdateSpaceEntityRequest? {
        return nil
    }
}
