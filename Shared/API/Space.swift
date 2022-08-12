// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

/// Retrieves all spaces the user can view.
public class SpaceListController: QueryController<ListSpacesQuery, [SpaceListController.Space]> {
    public typealias Space = ListSpacesQuery.Data.ListSpace.Space

    public override func reload() {
        self.perform(query: ListSpacesQuery(kind: .all))
    }

    public override class func processData(_ data: ListSpacesQuery.Data) -> [Space] {
        data.listSpaces?.space ?? []
    }

    @discardableResult static func getSpaces(
        completion: @escaping (Result<[Space], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: ListSpacesQuery(kind: .all), completion: completion)
    }
}

extension SpaceListController.Space: Identifiable {
    public var id: String {
        pageMetadata!.pageId!
    }
}

/// Retrieves all URLs for a space
public class SpacesDataQueryController: QueryController<
    GetSpacesDataQuery, [SpacesDataQueryController.Space]
>
{
    public struct Space {
        var id: String
        var name: String
        var description: String?
        var followers: Int?
        var views: Int?
        var owner: SpacesMetadata.Owner?
        var lastModifiedTs: String?
        var entities: [SpaceEntityData]
        var comments: [SpaceCommentData]
        var generators: [SpaceGeneratorData]
    }

    private var spaceIds: [String]

    public init(spaceIds: [String]) {
        self.spaceIds = spaceIds
        super.init()
    }

    public override func reload() {
        self.perform(query: GetSpacesDataQuery(ids: spaceIds))
    }

    public override class func processData(_ data: GetSpacesDataQuery.Data)
        -> [SpacesDataQueryController
        .Space]
    {
        var result: [Space] = []
        if let spaces = data.getSpace?.space {
            for space in spaces {

                if let id = space.pageMetadata?.pageId, let name = space.space?.name {
                    var spaceEntities: [SpaceEntityData] = []
                    if let entities = space.space?.fragments.spacesMetadata.entities {
                        for entity in entities {
                            guard let spaceEntity = entity.spaceEntity else {
                                continue
                            }
                            spaceEntities.append(
                                SpaceEntityData(
                                    id: entity.metadata?.docId ?? "unknown-id",
                                    url: URL(string: spaceEntity.url ?? ""),
                                    title: spaceEntity.title,
                                    snippet: spaceEntity.snippet,
                                    thumbnail: spaceEntity.thumbnail,
                                    previewEntity: SpaceEntityData.previewEntity(from: spaceEntity),
                                    generatorID: spaceEntity.generator?.id)
                            )
                        }
                    }
                    var spaceGenerators: [SpaceGeneratorData] = []
                    if let generators = space.space?.generators {
                        for generator in generators {
                            if let params = SpaceGeneratorData.params(from: generator.params ?? "")
                            {
                                spaceGenerators.append(
                                    SpaceGeneratorData(
                                        id: generator.id,
                                        params: params
                                    )
                                )
                            }
                        }
                    }
                    var spaceComments: [SpaceCommentData] = []
                    if let comments = space.space?.fragments.spacesMetadata.comments {
                        for comment in comments {
                            if let id = comment.id, let profile = comment.profile,
                                let createdTs = comment.createdTs, let comment = comment.comment
                            {
                                spaceComments.append(
                                    SpaceCommentData(
                                        id: id,
                                        profile: profile,
                                        createdTs: createdTs,
                                        comment: comment
                                    )
                                )
                            }
                        }
                    }
                    result.append(
                        Space(
                            id: id, name: name, description: space.space?.description,
                            followers: space.stats?.followers, views: space.stats?.views,
                            owner: space.space?.fragments.spacesMetadata.owner,
                            lastModifiedTs: space.space?.fragments.spacesMetadata.lastModifiedTs,
                            entities: spaceEntities, comments: spaceComments,
                            generators: spaceGenerators))
                }
            }
        }
        return result
    }

    @discardableResult static func getSpacesData(
        spaceIds: [String],
        using api: GraphQLAPI,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: GetSpacesDataQuery(ids: spaceIds), using: api, completion: completion)
    }
}

class RelatedSpacesQueryController: QueryController<
    GetRelatedSpacesQuery, [SpacesDataQueryController.Space]
>
{

    private var spaceID: String

    public init(spaceID: String) {
        self.spaceID = spaceID
        super.init()
    }

    override func reload() {
        self.perform(query: GetRelatedSpacesQuery(spaceID: spaceID))
    }

    override class func processData(_ data: GetRelatedSpacesQuery.Data)
        -> [SpacesDataQueryController.Space]
    {
        var result: [SpacesDataQueryController.Space] = []
        if let spaces = data.getRelatedSpaces?.sharedAuthor?.space {
            for space in spaces {

                if let id = space.pageMetadata?.pageId, let name = space.space?.name {
                    var spaceEntities: [SpaceEntityData] = []
                    if let entities = space.space?.fragments.spacesMetadata.entities {
                        for entity in entities {
                            guard let spaceEntity = entity.spaceEntity else {
                                continue
                            }
                            spaceEntities.append(
                                SpaceEntityData(
                                    id: entity.metadata?.docId ?? "unknown-id",
                                    url: URL(string: spaceEntity.url ?? ""),
                                    title: spaceEntity.title,
                                    snippet: spaceEntity.snippet,
                                    thumbnail: spaceEntity.thumbnail,
                                    previewEntity: SpaceEntityData.previewEntity(from: spaceEntity),
                                    generatorID: spaceEntity.generator?.id)
                            )
                        }
                    }
                    var spaceGenerators: [SpaceGeneratorData] = []
                    if let generators = space.space?.generators {
                        for generator in generators {
                            if let params = SpaceGeneratorData.params(from: generator.params ?? "")
                            {
                                spaceGenerators.append(
                                    SpaceGeneratorData(
                                        id: generator.id,
                                        params: params
                                    )
                                )
                            }
                        }
                    }
                    var spaceComments: [SpaceCommentData] = []
                    if let comments = space.space?.fragments.spacesMetadata.comments {
                        for comment in comments {
                            if let id = comment.id, let profile = comment.profile,
                                let createdTs = comment.createdTs, let comment = comment.comment
                            {
                                spaceComments.append(
                                    SpaceCommentData(
                                        id: id,
                                        profile: profile,
                                        createdTs: createdTs,
                                        comment: comment
                                    )
                                )
                            }
                        }
                    }
                    result.append(
                        SpacesDataQueryController.Space(
                            id: id, name: name, description: space.space?.description,
                            followers: space.stats?.followers, views: space.stats?.views,
                            owner: space.space?.fragments.spacesMetadata.owner,
                            entities: spaceEntities, comments: spaceComments,
                            generators: spaceGenerators))
                }
            }
        }
        return result
    }

    @discardableResult static func getSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: GetRelatedSpacesQuery(spaceID: spaceID), completion: completion)
    }
}

class RelatedSpacesCountQueryController: QueryController<
    GetRelatedSpacesCountQuery, Int
>
{

    private var spaceID: String

    public init(spaceID: String) {
        self.spaceID = spaceID
        super.init()
    }

    override func reload() {
        self.perform(query: GetRelatedSpacesCountQuery(spaceID: spaceID))
    }

    override class func processData(_ data: GetRelatedSpacesCountQuery.Data)
        -> Int
    {
        return data.getRelatedSpaces?.sharedAuthor?.space.count ?? 0

    }

    @discardableResult static func getSpacesData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Combine.Cancellable {
        self.perform(query: GetRelatedSpacesCountQuery(spaceID: spaceID), completion: completion)
    }
}

/// Retrieves all space title information for the given spaces
class SuggestedSpacesQueryController: QueryController<
    GetSpacesTitleInfoQuery, [SuggestedSpacesQueryController.SpaceTitleInfo]
>
{
    struct SpaceTitleInfo {
        var id: String
        var name: String
        var thumbnail: String?
    }

    private var spaceIds: [String]

    public init(spaceIds: [String]) {
        self.spaceIds = spaceIds
        super.init()
    }

    override func reload() {
        self.perform(query: GetSpacesTitleInfoQuery(ids: spaceIds))
    }

    override class func processData(_ data: GetSpacesTitleInfoQuery.Data) -> [SpaceTitleInfo] {
        var result: [SpaceTitleInfo] = []
        if let spaces = data.getSpace?.space {
            for space in spaces {
                if let id = space.pageMetadata?.pageId, let name = space.space?.name {
                    result.append(
                        SpaceTitleInfo(id: id, name: name, thumbnail: space.space?.thumbnail)
                    )
                }
            }
        }
        return result
    }

    @discardableResult static func getSpacesTitleInfo(
        spaceIds: [String],
        completion: @escaping (Result<[SpaceTitleInfo], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: GetSpacesTitleInfoQuery(ids: spaceIds), completion: completion)
    }
}

extension SpaceACLLevel: Comparable {
    public static func < (_ lhs: SpaceACLLevel, _ rhs: SpaceACLLevel) -> Bool {
        switch lhs {
        case .owner:
            return false
        case .edit:
            return rhs == .owner
        case .comment:
            return rhs == .owner || rhs == .edit
        case .view, .publicView, .publicIndexed:
            return rhs == .owner || rhs == .edit || rhs == .comment
        case .__unknown(let rawValue):
            fatalError("Cannot compare unknown ACL level \(rawValue)")
        }
    }
}

// convenience functions that assume `nil` == “no access”
public func >= (_ lhs: SpaceACLLevel?, _ rhs: SpaceACLLevel) -> Bool {
    if let lhs = lhs {
        return lhs >= rhs
    } else {
        return false
    }
}
public func < (_ lhs: SpaceACLLevel?, _ rhs: SpaceACLLevel) -> Bool {
    !(lhs >= rhs)
}
