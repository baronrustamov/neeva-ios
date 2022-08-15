// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import UIKit

struct DownloadMenuView: View {
    let fileName: String
    let fileURL: String
    let fileSize: String?

    let onDownload: () -> Void
    let onCancel: () -> Void

    var body: some View {
        GroupedStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .withFont(.bodyLarge)
                    .truncationMode(.middle)
                    .foregroundColor(.label)

                Text(fileURL)
                    .withFont(.labelMedium)
                    .truncationMode(.head)
                    .foregroundColor(.secondaryLabel)
            }.padding(.bottom, 14)

            GroupedCellButton(
                fileSize != nil ? "Download (\(fileSize!))" : "Download", action: onDownload)
            GroupedCellButton("Cancel", style: .labelLarge, action: onCancel)
        }
    }
}

struct DownloadMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadMenuView(
            fileName: "markus-spiske-jsqrSfrtjB80-unsplash.jpg", fileURL: "www.unsplash.com",
            fileSize: "2.2 MB", onDownload: {}, onCancel: {})
    }
}
