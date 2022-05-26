// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Storage
import SwiftUI

struct OpenInNeevaView: View {
    @Environment(\.openURL) var openURL

    let item: ShareItem
    let incognito: Bool

    var body: some View {
        Button(action: {
            item.url.addingPercentEncoding(
                withAllowedCharacters: NSCharacterSet.alphanumerics
            )
            .flatMap {
                URL(
                    string: "neeva://open-url?\(incognito ? "private=true&" : "")url=\($0)"
                )
            }
            .map { openURL($0) }
        }) {
            ShareToAction(
                name: incognito ? "Open in Neeva Incognito" : "Open in Neeva",
                icon: Image("open-in-neeva\(incognito ? "-incognito" : "")")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
            )
        }
    }
}
