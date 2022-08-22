// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct DownloadOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let fileName: String
    let fileURL: String
    let fileSize: String?
    let onDownload: () -> Void

    var body: some View {
        DownloadMenuView(
            fileName: fileName, fileURL: fileURL, fileSize: fileSize,
            onDownload: {
                hideOverlay()
                onDownload()
            },
            onCancel: hideOverlay
        ).overlayIsFixedHeight(isFixedHeight: true)
    }
}
