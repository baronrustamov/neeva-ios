// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct URLDisplayView: View {
    public init(url: URL) {
        self.url = url
    }

    public let url: URL

    @ViewBuilder public var body: some View {
        HStack(spacing: 0) {
            if let baseDomain = url.baseDomain {
                Text(baseDomain)
                    .withFont(.bodySmall)
                    .foregroundColor(.label)
                    .lineLimit(1)
                    .fixedSize()
            }
            if let pathDisplay = url.pathDisplay {
                Text(pathDisplay)
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
                    .lineLimit(1)
            }
        }
    }
}
