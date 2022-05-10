// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

public class SpaceServiceMock: SpaceService {
    public init() {}

    // TODO(jon): Implement this! :-)
    public func addToSpaceMutation(
        spaceId: String, url: String, title: String,
        thumbnail: String?, data: String?, mediaType: String?, isBase64: Bool?,
        completion: @escaping (Result<AddToSpaceMutation.Data, Error>) -> Void
    ) -> Cancellable? {
        return nil
    }

}
