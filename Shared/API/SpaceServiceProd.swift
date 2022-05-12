// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

public class SpaceServiceProd: SpaceService {
    public func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String? = nil, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable? {
        return AddToSpaceMutation(
            input: AddSpaceResultByURLInput(
                spaceId: spaceId,
                url: url,
                title: title,
                thumbnail: thumbnail,
                data: data,
                mediaType: mediaType,
                isBase64: isBase64
            )
        ).perform(resultHandler: completion)
    }

    public func getSpacesData(
        spaceIds: [String],
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable? {
        return SpacesDataQueryController.getSpacesData(spaceIds: spaceIds, completion: completion)
    }

    public func getSpaces(
        completion: @escaping (Result<[SpaceListController.Space], Error>) -> Void
    ) -> Cancellable? {
        return SpaceListController.getSpaces(completion: completion)
    }

    public func getRelatedSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable? {
        return RelatedSpacesQueryController.getSpacesData(spaceID: spaceID, completion: completion)
    }

    public func getRelatedSpacesCountData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable? {
        return RelatedSpacesCountQueryController.getSpacesData(
            spaceID: spaceID, completion: completion)
    }
}
