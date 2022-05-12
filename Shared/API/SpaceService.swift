// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

public protocol SpaceService {
    func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String?, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getSpacesData(
        spaceIds: [String],
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getSpaces(
        completion: @escaping (Result<[SpaceListController.Space], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getRelatedSpacesData(
        spaceID: String,
        completion: @escaping (Result<[SpacesDataQueryController.Space], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func getRelatedSpacesCountData(
        spaceID: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable?
}

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
}
