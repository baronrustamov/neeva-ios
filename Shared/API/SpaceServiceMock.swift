// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

// TODO(jon): Implement this class once SpaceService is sandwiched
// between Apollo and higher layers
public class SpaceServiceMock: SpaceService {
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
